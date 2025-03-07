// Generated by ReScript, PLEASE EDIT WITH CARE

import * as OnChainOperations from "./OnChainOperations.res.mjs";

async function calculate(name, years) {
  var duration = Math.imul(years, 31536000);
  var priceInWei = await OnChainOperations.registerPrice(name, duration);
  console.log("name: \"" + name + "\", duration: " + duration.toString() + ", price: " + priceInWei.toString());
  return Number(priceInWei) / 1e18;
}

async function calculateRenew(name, years) {
  var duration = Math.imul(years, 31536000);
  var priceInWei = await OnChainOperations.rentPrice(name, duration);
  return Number(priceInWei) / 1e18;
}

export {
  calculate ,
  calculateRenew ,
}
/* OnChainOperations Not a pure module */
