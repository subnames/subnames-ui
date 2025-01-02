open OnChainOperationsCommon

let reverseRegistrarContract = {
  "address": Constants.reverseRegistrarContractAddress,
  "abi": [
    {
      "type": "function",
      "name": "setName",
      "inputs": [{"name": "name", "type": "string"}],
      "outputs": [{"name": "", "type": "bytes32"}],
      "stateMutability": "nonpayable",
    },
  ],
}

let setName = async (walletClient, name) => {
  let currentAddress = await currentAddress(walletClient)
  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": reverseRegistrarContract["address"],
      "abi": reverseRegistrarContract["abi"],
      "functionName": "setName",
      "args": [String(name)],
    },
  )
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceipt(
    publicClient,
    {"hash": hash},
  )
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}