import * as admin from "firebase-admin";
import * as Functions from "firebase-functions";
import {CLOUD_REGION} from "./constants";
import {IapRepository, IAPSource} from "./iap.repository";
import {PurchaseHandler} from "./purchase-handler";
import {GooglePlayPurchaseHandler} from "./google-play.purchase-handler";
import {AppStorePurchaseHandler} from "./app-store.purchase-handler";
import {HttpsError} from "firebase-functions/lib/providers/https";
import {productDataMap} from "./products";

// The Cloud Functions for Firebase SDK to create Cloud Functions
// and setup triggers.
// const functions = require("firebase-functions");

// The Firebase Admin SDK to access Cloud Firestore.
// const admin = require("firebase-admin");
admin.initializeApp({projectId: "army-leaders-book"});
const functions = Functions.region(CLOUD_REGION);
// Initialize the IAP repository that the purchase handlers depend on
const iapRepository = new IapRepository(admin.firestore());
// Initialize an instance of each purchase handler,
// and store them in a map for easy access.
const purchaseHandlers: { [source in IAPSource]: PurchaseHandler } = {
  "google_play": new GooglePlayPurchaseHandler(iapRepository),
  "app_store": new AppStorePurchaseHandler(iapRepository),
};
// Verify Purchase Function
interface VerifyPurchaseParams {
    source: IAPSource;
    verificationData: string;
    productId: string;
}

// Handling of purchase verifications
export const verifyPurchase = functions.https.onCall(
    async (
        data: VerifyPurchaseParams,
        context,
    ): Promise<boolean> => {
      const premiumIds = [
        "N5EIa03V7rSma0LDlko6YzGXuXF3", // bhultuist84
        "WtI8grypTbTd0657WmEjgtGophO2", // armynoncomtools
        "i0dn21YEgsfaoQyegu4Aa4AnQn82", // CW2 Lents
        "nqjvb229UIe8JobyXd8Cmddq93t1", // SPC Browne
        "N4qAFiFApucAkM9ouvXjGmgjJoG3", // Andrew Beals
        "8p1IsNvzBfd8SaEnoDSMV6IzRKj2", // 1SG Hardel
        "0v4SkNMrtpPrs25hEtMU6uwwYUK2", // Vic Harper
        "ozdVTlpNrraI16I76XjIWePZnX32", // Lascelles May
        "l8PsXklsIXbrFLqNDcqmp26BWi22", // test
        "dZnvpPh22EYNgIgCkhzZiVV2VPc2", // Tyler Siegfried
      ];
      // Check authentication
      if (!context.auth) {
        console.warn("verifyPurchase called when not authenticated");
        throw new HttpsError(
            "unauthenticated",
            "Request was not authenticated.",
        );
      }
      // Premium IDs
      if (premiumIds.includes(context.auth.uid)) {
        console.warn(`Premium ID: ${context.auth.uid}`);
        return true;
      }
      // App Check
      // if (context.app == undefined) {
      //   console.warn("verifyPurchase called when failed app check");
      //   throw new HttpsError(
      //       "failed-precondition",
      //       "The function must be called from an App Check verified app.",
      //   );
      // }
      // Get the product data from the map
      const productData = productDataMap[data.productId];
      // If it was for an unknown product, do not process it.
      if (!productData) {
        console.warn(`verifyPurchase called for an unknown product 
          ("${data.productId}")`);
        return false;
      }
      // If it was for an unknown source, do not process it.
      if (!purchaseHandlers[data.source]) {
        console.warn(`verifyPurchase called for an unknown source 
          ("${data.source}")`);
        return false;
      }
      // Process the purchase for the product
      return purchaseHandlers[data.source].verifyPurchase(
          context.auth.uid,
          productData,
          data.verificationData,
      );
    });

// Handling of AppStore server-to-server events
export const handleAppStoreServerEvent =
      (purchaseHandlers.app_store as AppStorePurchaseHandler)
          .handleServerEvent;

// Handling of PlayStore server-to-server events
export const handlePlayStoreServerEvent =
      (purchaseHandlers.google_play as GooglePlayPurchaseHandler)
          .handleServerEvent;

// Scheduled job for expiring subscriptions in the case of
// missing store events
export const expireSubscriptions = functions.pubsub.schedule("5 11 * * *")
    .onRun(() => iapRepository.expireSubscriptions());

exports.onUserDeleted = functions.auth.user().onDelete( async (user) => {
  const snapshot = await admin.firestore().doc(`users/${user.uid}`).get();
  if (snapshot.exists) {
    return snapshot.ref.delete();
  } else {
    console.log(`No profile for User:${user.uid}`);

    const notes = await admin.firestore().collection("notes")
        .where("owner", "==", user.uid).get();
    notes.docs.forEach((doc) => {
      try {
        doc.ref.delete();
      } catch (e) {
        console.log(`Notes delete failed: ${e}`);
      }
    });

    // Delete all phone numbers associated with User
    const phones = await admin.firestore().collection("phoneNumbers")
        .where("owner", "==", user.uid).get();
    phones.docs.forEach((doc) => {
      try {
        doc.ref.delete();
      } catch (e) {
        console.log(`Phones delete failed: ${e}`);
      }
    });

    // Delete alert Soldiers associated with User
    await admin.firestore().doc(`alertSoldiers/${user.uid}`).delete()
        .catch((e) => console.log(`Alert Soldier delete failed: ${e}`));

    // Delete perstat by names associated with User
    await admin.firestore().doc(`perstatByName/${user.uid}`).delete()
        .catch((e) => console.log(`Perstat By Name delete failed: ${e}`));

    // Delete all savedEvents associated with User
    const events = await admin.firestore().collection("savedEvents")
        .where("owner", "==", user.uid).get();
    events.docs.forEach((doc) => {
      try {
        doc.ref.delete();
      } catch (e) {
        console.log(`Saved Events delete failed: ${e}`);
      }
    });

    // Delete settings associated with User
    await admin.firestore().doc(`settings/${user.uid}`).delete();

    // Delete all Soldiers owned by User
    const snapshot = await admin.firestore().collection("soldiers")
        .where("owner", "==", user.uid).get();
    snapshot.docs.forEach((doc) => {
      let users = [""];
      try {
        users = doc.get("users");
      } catch (e) {
        console.log(`Users Field: ${e}`);
      }
      if (users.length <= 1) {
        doc.ref.delete();
      } else {
        const newUsers: Array<string> = [];
        users.forEach((userId) => {
          if (userId !== user.uid) {
            newUsers.push(userId);
          }
        });
        console.log(`New Users Length = ${newUsers.length}`);
        const owner: string = newUsers[0];
        console.log(`Owner = ${owner}`);
        doc.ref.update({"users": newUsers, "owner": owner});
      }
    });
    // Remove user from Soldiers where users contains user
    const soldiers = await admin.firestore().collection("soldiers")
        .where("users", "!=", null)
        .where("users", "array-contains", user.uid).get();
    return soldiers.docs.forEach((doc) => {
      doc.ref.update(
          {"users": admin.firestore.FieldValue.arrayRemove(user.uid)});
    });
  }
});

exports.onProfileDeleted = functions.firestore.document("users/{docId}")
    .onDelete( async (snap, context) => {
      const userId = context.params.docId;
      // Delete all notes associated with User
      const notes = await admin.firestore().collection("notes")
          .where("owner", "==", userId).get();
      notes.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Notes delete failed: ${e}`);
        }
      });

      // Delete all phone numbers associated with User
      const phones = await admin.firestore().collection("phoneNumbers")
          .where("owner", "==", userId).get();
      phones.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Phones delete failed: ${e}`);
        }
      });

      // Delete alert Soldiers associated with User
      await admin.firestore().doc(`alertSoldiers/${userId}`).delete()
          .catch((e) => console.log(`Alert Soldier delete failed: ${e}`));

      // Delete perstat by names associated with User
      await admin.firestore().doc(`perstatByName/${userId}`).delete()
          .catch((e) => console.log(`Perstat By Name delete failed: ${e}`));

      // Delete all savedEvents associated with User
      const events = await admin.firestore().collection("savedEvents")
          .where("owner", "==", userId).get();
      events.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Saved Events delete failed: ${e}`);
        }
      });

      // Delete settings associated with User
      await admin.firestore().doc(`settings/${userId}`).delete();

      // Delete all Soldiers owned by User
      const snapshot = await admin.firestore().collection("soldiers")
          .where("owner", "==", userId).get();
      snapshot.docs.forEach((doc) => {
        let users = [""];
        try {
          users = doc.get("users");
        } catch (e) {
          console.log(`Users Field: ${e}`);
        }
        if (users.length <= 1) {
          doc.ref.delete();
        } else {
          const newUsers: Array<string> = [];
          users.forEach((user) => {
            if (user !== userId) {
              newUsers.push(user);
            }
          });
          console.log(`New Users Length = ${newUsers.length}`);
          const owner = newUsers[0];
          console.log(`Owner = ${owner}`);
          doc.ref.update({"users": newUsers, "owner": owner});
        }
      });
      // Remove user from Soldiers where users contains user
      const soldiers = await admin.firestore().collection("soldiers")
          .where("users", "!=", null)
          .where("users", "array-contains", userId).get();
      return soldiers.docs.forEach((doc) => {
        doc.ref.update(
            {"users": admin.firestore.FieldValue.arrayRemove(userId)});
      });
    });

exports.onSoldierDeleted = functions.firestore.document("soldiers/{docId}")
    .onDelete( async (snap, context) => {
      const soldierId = context.params.docId;
      // delete ACFT Stats associated with Soldier that was deleted
      const acfts = await admin.firestore().collection("acftStats")
          .where("soldierId", "==", soldierId).get();
      acfts.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`ACFT Stats delete failed: ${e}`);
        }
      });

      // delete ACFT Stats associated with Soldier that was deleted
      const actions = await admin.firestore().collection("actions")
          .where("soldierId", "==", soldierId).get();
      actions.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Action delete failed: ${e}`);
        }
      });

      // delete APFT Stats associated with Soldier that was deleted
      const apfts = await admin.firestore().collection("apftStats")
          .where("soldierId", "==", soldierId).get();
      apfts.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`APFT Stats delete failed: ${e}`);
        }
      });

      // delete Appointments associated with Soldier that was deleted
      const apts = await admin.firestore().collection("appointments")
          .where("soldierId", "==", soldierId).get();
      apts.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Apts delete failed: ${e}`);
        }
      });

      // delete Awards associated with Soldier that was deleted
      const awards = await admin.firestore().collection("awards")
          .where("soldierId", "==", soldierId).get();
      awards.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Awards delete failed: ${e}`);
        }
      });

      // delete Body Fat Stats associated with Soldier that was deleted
      const bfs = await admin.firestore().collection("bodyfatStats")
          .where("soldierId", "==", soldierId).get();
      bfs.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`BF Stats delete failed: ${e}`);
        }
      });

      // delete Counselings associated with Soldier that was deleted
      const counselings = await admin.firestore().collection("counselings")
          .where("soldierId", "==", soldierId).get();
      counselings.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Counselings delete failed: ${e}`);
        }
      });

      // delete Duty Rosters associated with Soldier that was deleted
      const duties = await admin.firestore().collection("dutyRoster")
          .where("soldierId", "==", soldierId).get();
      duties.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Duty Roster delete failed: ${e}`);
        }
      });

      // delete Equipment associated with Soldier that was deleted
      const equipment = await admin.firestore().collection("equipment")
          .where("soldierId", "==", soldierId).get();
      equipment.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Equipment delete failed: ${e}`);
        }
      });

      // delete Flags associated with Soldier that was deleted
      const flags = await admin.firestore().collection("flags")
          .where("soldierId", "==", soldierId).get();
      flags.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Flags delete failed: ${e}`);
        }
      });

      // delete Flags associated with Soldier that was deleted
      const handReceipt = await admin.firestore().collection("handReceipt")
          .where("soldierId", "==", soldierId).get();
      handReceipt.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Hand Receipt delete failed: ${e}`);
        }
      });

      // delete HR Actions associated with Soldier that was deleted
      const hrActions = await admin.firestore().collection("hrActions")
          .where("soldierId", "==", soldierId).get();
      hrActions.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`HR Actions delete failed: ${e}`);
        }
      });

      // delete MedPros associated with Soldier that was deleted
      const medpros = await admin.firestore().collection("medpros")
          .where("soldierId", "==", soldierId).get();
      medpros.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`MedPros delete failed: ${e}`);
        }
      });

      // delete Military Licenses associated with Soldier that was deleted
      const milLics = await admin.firestore().collection("milLic")
          .where("soldierId", "==", soldierId).get();
      milLics.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Mil Lics delete failed: ${e}`);
        }
      });

      // delete Perstats associated with Soldier that was deleted
      const perstat = await admin.firestore().collection("perstat")
          .where("soldierId", "==", soldierId).get();
      perstat.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`PERSTAT delete failed: ${e}`);
        }
      });

      // delete POVs associated with Soldier that was deleted
      const povs = await admin.firestore().collection("povs")
          .where("soldierId", "==", soldierId).get();
      povs.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`POVs delete failed: ${e}`);
        }
      });

      // delete Profiles associated with Soldier that was deleted
      const profiles = await admin.firestore().collection("profiles")
          .where("soldierId", "==", soldierId).get();
      profiles.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Profiles delete failed: ${e}`);
        }
      });

      // delete Rating Schemes associated with Soldier that was deleted
      const ratings = await admin.firestore().collection("ratings")
          .where("soldierId", "==", soldierId).get();
      ratings.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Ratings delete failed: ${e}`);
        }
      });

      // delete Taskings associated with Soldier that was deleted
      const taskings = await admin.firestore().collection("taskings")
          .where("soldierId", "==", soldierId).get();
      taskings.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Taskings delete failed: ${e}`);
        }
      });

      // delete Training Records associated with Soldier that was deleted
      const trainings = await admin.firestore().collection("training")
          .where("soldierId", "==", soldierId).get();
      trainings.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Trainings delete failed: ${e}`);
        }
      });

      // delete Weapon Stats associated with Soldier that was deleted
      const weapons = await admin.firestore().collection("weaponStats")
          .where("soldierId", "==", soldierId).get();
      weapons.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Weapon Stats delete failed: ${e}`);
        }
      });

      // delete Working Awards associated with Soldier that was deleted
      const workingAwards = await admin.firestore().collection("workingAwards")
          .where("soldierId", "==", soldierId).get();
      workingAwards.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Working Awards delete failed: ${e}`);
        }
      });

      // delete Working Evals associated with Soldier that was deleted
      const workingEvals = await admin.firestore().collection("workingEvals")
          .where("soldierId", "==", soldierId).get();
      return workingEvals.docs.forEach((doc) => {
        try {
          doc.ref.delete();
        } catch (e) {
          console.log(`Working Evals delete failed: ${e}`);
        }
      });
    });

exports.onSoldierUpdated = functions.firestore.document("soldiers/{docId}")
    .onUpdate( async (change, context) => {
      // if the new doc doesn"t exist, return
      if (!change.after.exists) {
        return;
      }

      const newDoc = change.after.data();
      const oldDoc = change.before.data();

      let oldUsers = oldDoc.users;
      if (oldUsers === undefined || oldUsers === null) oldUsers = [];

      let newUsers = newDoc.users;
      if (newUsers === undefined || newUsers === null) {
        newUsers = [newDoc.owner];
      }

      const rankChanged = oldDoc.rank !== newDoc.rank;
      const lastNameChanged = oldDoc.lastName !== newDoc.lastName;
      const firstNameChanged = oldDoc.firstName !== newDoc.firstName;
      const sectionChanged = oldDoc.section !== newDoc.section;
      const ownerChanged = oldDoc.owner !== newDoc.owner;
      const usersChanged = oldUsers.length !== newUsers.length;

      // if none are changed, return
      if (rankChanged || lastNameChanged || firstNameChanged ||
        sectionChanged || ownerChanged || usersChanged) {
        // map of new data to update on all subrecords
        const newDataUsers = {
          "rank": newDoc.rank,
          "rankSort": newDoc.rankSort.toString(),
          "name": newDoc.lastName,
          "firstName": newDoc.firstName,
          "section": newDoc.section,
          "owner": newDoc.owner,
          "users": newUsers,
        };

        const newAwardData = {
          "owner": newDoc.owner,
          "users": newUsers,
        };

        const soldierId = context.params.docId;

        // update ACFT Stats associated with Soldier that was deleted
        const acfts = await admin.firestore().collection("acftStats")
            .where("soldierId", "==", soldierId).get();
        acfts.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`ACFT Stats update failed: ${e}`);
          }
        });

        // update Actions Stats associated with Soldier that was deleted
        const actions = await admin.firestore().collection("actions")
            .where("soldierId", "==", soldierId).get();
        actions.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Action update failed: ${e}`);
          }
        });

        // update APFT Stats associated with Soldier that was deleted
        const apfts = await admin.firestore().collection("apftStats")
            .where("soldierId", "==", soldierId).get();
        apfts.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`APFT Stats update failed: ${e}`);
          }
        });

        // update Appointments associated with Soldier that was deleted
        const apts = await admin.firestore().collection("appointments")
            .where("soldierId", "==", soldierId).get();
        apts.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Apts update failed: ${e}`);
          }
        });

        // update Awards associated with Soldier that was deleted
        const awards = await admin.firestore().collection("awards")
            .where("soldierId", "==", soldierId).get();
        awards.docs.forEach((doc) => {
          try {
            doc.ref.update(newAwardData);
          } catch (e) {
            console.log(`Awards update failed: ${e}`);
          }
        });

        // update Body Fat Stats associated with Soldier that was deleted
        const bfs = await admin.firestore().collection("bodyfatStats")
            .where("soldierId", "==", soldierId).get();
        bfs.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`BF Stats update failed: ${e}`);
          }
        });

        // update Duty Rosters associated with Soldier that was deleted
        const duties = await admin.firestore().collection("dutyRoster")
            .where("soldierId", "==", soldierId).get();
        duties.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Duty Roster update failed: ${e}`);
          }
        });

        // update Equipment associated with Soldier that was deleted
        const equip = await admin.firestore().collection("equipment")
            .where("soldierId", "==", soldierId).get();
        equip.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Equipment update failed: ${e}`);
          }
        });

        // update Flags associated with Soldier that was deleted
        const flags = await admin.firestore().collection("flags")
            .where("soldierId", "==", soldierId).get();
        flags.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Flags update failed: ${e}`);
          }
        });

        // update Hand Receipt associated with Soldier that was deleted
        const handReceipt = await admin.firestore().collection("handReceipt")
            .where("soldierId", "==", soldierId).get();
        handReceipt.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Hand Receipt update failed: ${e}`);
          }
        });

        // update HR Actions associated with Soldier that was deleted
        const hrActions = await admin.firestore().collection("hrActions")
            .where("soldierId", "==", soldierId).get();
        hrActions.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`HR Actions update failed: ${e}`);
          }
        });

        // update MedPros associated with Soldier that was deleted
        const medpros = await admin.firestore().collection("medpros")
            .where("soldierId", "==", soldierId).get();
        medpros.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`MedPros update failed: ${e}`);
          }
        });

        // update Military Licenses associated with Soldier that was deleted
        const milLics = await admin.firestore().collection("milLic")
            .where("soldierId", "==", soldierId).get();
        milLics.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Military Licenses update failed: ${e}`);
          }
        });

        // update Perstats associated with Soldier that was deleted
        const perstat = await admin.firestore().collection("perstat")
            .where("soldierId", "==", soldierId).get();
        perstat.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`PERSTAT update failed: ${e}`);
          }
        });

        // update POVs associated with Soldier that was deleted
        const povs = await admin.firestore().collection("povs")
            .where("soldierId", "==", soldierId).get();
        povs.docs.forEach((doc) => {
          try {
            doc.ref.update(newAwardData);
          } catch (e) {
            console.log(`POVs update failed: ${e}`);
          }
        });

        // update Profiles associated with Soldier that was deleted
        const profiles = await admin.firestore().collection("profiles")
            .where("soldierId", "==", soldierId).get();
        profiles.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Profiles update failed: ${e}`);
          }
        });

        // update Rating Schemes associated with Soldier that was deleted
        const ratings = await admin.firestore().collection("ratings")
            .where("soldierId", "==", soldierId).get();
        ratings.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Ratings update failed: ${e}`);
          }
        });

        // update Taskings associated with Soldier that was deleted
        const taskings = await admin.firestore().collection("taskings")
            .where("soldierId", "==", soldierId).get();
        taskings.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Taskings update failed: ${e}`);
          }
        });

        // update Training Records associated with Soldier that was deleted
        const training = await admin.firestore().collection("training")
            .where("soldierId", "==", soldierId).get();
        training.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`Training update failed: ${e}`);
          }
        });

        // update Weapon Stats associated with Soldier that was deleted
        const weapons = await admin.firestore().collection("weaponStats")
            .where("soldierId", "==", soldierId).get();
        weapons.docs.forEach((doc) => {
          try {
            doc.ref.update(newDataUsers);
          } catch (e) {
            console.log(`ACFT Stats update failed: ${e}`);
          }
        });

        if (rankChanged || lastNameChanged || firstNameChanged ||
        sectionChanged || ownerChanged) {
          const newData = {
            "rank": newDoc.rank,
            "rankSort": newDoc.rankSort.toString(),
            "name": newDoc.lastName,
            "firstName": newDoc.firstName,
            "section": newDoc.section,
            "owner": newDoc.owner,
          };

          // delete Counselings associated with Soldier that was deleted
          const counselings = await admin.firestore().collection("counselings")
              .where("soldierId", "==", soldierId).get();
          counselings.docs.forEach((doc) => {
            try {
              doc.ref.update(newData);
            } catch (e) {
              console.log(`Counselings update failed: ${e}`);
            }
          });

          // delete Working Awards associated with Soldier that was deleted
          const workingAwards = await admin.firestore()
              .collection("workingAwards")
              .where("soldierId", "==", soldierId).get();
          workingAwards.docs.forEach((doc) => {
            try {
              doc.ref.update(newData);
            } catch (e) {
              console.log(`Working Awards update failed: ${e}`);
            }
          });

          // delete Working Evals associated with Soldier that was deleted
          const workingEvals = await admin.firestore()
              .collection("workingEvals")
              .where("soldierId", "==", soldierId).get();
          return workingEvals.docs.forEach((doc) => {
            try {
              doc.ref.update(newData);
            } catch (e) {
              console.log(`Working Evals update failed: ${e}`);
            }
          });
        }
      }
    });
