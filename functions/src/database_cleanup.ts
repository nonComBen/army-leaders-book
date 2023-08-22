import { Auth} from "firebase-admin/lib/auth/auth";
import { UserRecord } from "firebase-functions/v1/auth";

export class DatabaseCleanup {

    constructor(private auth: Auth) {}

    async deleteInactiveAccount(deletes: number, nextPageToken: string | undefined) {
        this.auth.listUsers(100, nextPageToken).then((result) => {
            result.users.forEach((user) => {
                if(this.isAnonymous(user) || this.isInactive(user, 365)) {
                    deletes++;
                    this.auth.deleteUser(user.uid)
                        .then(() => {
                            console.log(`Successfully deleted user ${user.uid}`);
                        })
                        .catch((error) => {
                            console.log(`Error deleting user ${user.uid}`, error);
                        });
                }
            });
            if(deletes < 100 && result.pageToken) {
                this.deleteInactiveAccount(deletes, result.pageToken);
            }
        })
        .catch((error) => {
            console.log("Error fetching users:", error);
        });
        
    }

    isAnonymous(user: UserRecord) {
        return user.providerData.length === 0 && this.isInactive(user, 2);
    }

    isInactive(user: UserRecord, days: number) {
        const lastLogin = new Date(user.metadata.lastSignInTime).getTime();
        const now = new Date().getTime();
        const difInMillis = now - lastLogin;
        const difInDays = difInMillis / (1000 * 60 * 60 * 24);
        return difInDays > days;
    }
}