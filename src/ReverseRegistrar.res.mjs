// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Constants from "./Constants.res.mjs";
import * as OnChainOperationsCommon from "./contracts/OnChainOperationsCommon.res.mjs";

var reverseRegistrarContract = {
  address: Constants.reverseRegistrarContractAddress,
  abi: [{
      type: "function",
      name: "setNameForAddr",
      inputs: [
        {
          name: "addr",
          type: "address"
        },
        {
          name: "owner",
          type: "address"
        },
        {
          name: "resolver",
          type: "address"
        },
        {
          name: "name",
          type: "string"
        }
      ],
      outputs: [{
          name: "",
          type: "bytes32"
        }],
      stateMutability: "nonpayable"
    }]
};

async function setNameForAddr(walletClient, name) {
  var currentAddress = await OnChainOperationsCommon.currentAddress(walletClient);
  console.log("Setting reverse name for " + currentAddress + " to '" + name + "'");
  var match = await OnChainOperationsCommon.publicClient.simulateContract({
        account: currentAddress,
        address: reverseRegistrarContract.address,
        abi: reverseRegistrarContract.abi,
        functionName: "setNameForAddr",
        args: [
          currentAddress,
          currentAddress,
          Constants.resolverContractAddress,
          name
        ]
      });
  var hash = await walletClient.writeContract(match.request);
  var match$1 = await OnChainOperationsCommon.publicClient.waitForTransactionReceipt({
        hash: hash
      });
  console.log(hash + " confirmed in block " + match$1.blockNumber.toString() + ", status: " + match$1.status);
}

export {
  reverseRegistrarContract ,
  setNameForAddr ,
}
/* OnChainOperationsCommon Not a pure module */
