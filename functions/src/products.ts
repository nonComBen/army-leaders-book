export interface ProductData {
  productId: string;
  type: "SUBSCRIPTION" | "NON_SUBSCRIPTION";
}

export const productDataMap: { [productId: string]: ProductData } = {
  "ad_free_sub": {
    productId: "ad_free_sub",
    type: "SUBSCRIPTION",
  },
  "premium_sub": {
    productId: "premium_sub",
    type: "SUBSCRIPTION",
  },
  "ad_free_two": {
    productId: "ad_free_two",
    type: "SUBSCRIPTION",
  },
};
