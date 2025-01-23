// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as Constants from "./Constants.res.mjs";
import Sha3Mjs from "./sha3.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Chains from "viem/chains";

function sha3HexAddress(prim) {
  return Sha3Mjs(prim);
}

var publicClient = Viem.createPublicClient({
      chain: Chains.koi,
      transport: Viem.http(Constants.rpcUrl)
    });

function buildWalletClient() {
  var ethereum = window.ethereum;
  if (ethereum !== undefined) {
    return Caml_option.some(Viem.createWalletClient({
                    chain: Chains.koi,
                    transport: Viem.custom(Caml_option.valFromOption(ethereum))
                  }));
  }
  
}

async function currentAddress(walletClient) {
  var result = await walletClient.requestAddresses();
  if (result.length < 1) {
    throw {
          RE_EXN_ID: "Assert_failure",
          _1: [
            "OnChainOperationsCommon.res",
            57,
            2
          ],
          Error: new Error()
        };
  }
  return result[0];
}

export {
  sha3HexAddress ,
  publicClient ,
  buildWalletClient ,
  currentAddress ,
}
/* publicClient Not a pure module */
