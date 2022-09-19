import {ProductData} from "./products";
/**
   * It creates Puchase Handler class
   */
export abstract class PurchaseHandler {
  /**
   * It verifies purchase
   * @param {string} userId
   * @param {ProductData} productData
   * @param {string} token
   * @return {void}
   */
  async verifyPurchase(
      userId: string,
      productData: ProductData,
      token: string,
  ): Promise<boolean> {
    switch (productData.type) {
      case "SUBSCRIPTION":
        return this.handleSubscription(userId, productData, token);
      case "NON_SUBSCRIPTION":
        return this.handleNonSubscription(userId, productData, token);
      default:
        return false;
    }
  }

  abstract handleNonSubscription(
      userId: string,
      productData: ProductData,
      token: string,
  ): Promise<boolean>;

  abstract handleSubscription(
      userId: string,
      productData: ProductData,
      token: string,
  ): Promise<boolean>;
}
