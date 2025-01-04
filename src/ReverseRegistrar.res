open OnChainOperationsCommon

let reverseRegistrarContract = {
  "address": Constants.reverseRegistrarContractAddress,
  "abi": [
    { // function setNameForAddr(address addr, address owner, address resolver, string memory name) external returns (bytes32);
      "type": "function",
      "name": "setNameForAddr",
      "inputs": [
        {"name": "addr", "type": "address"},
        {"name": "owner", "type": "address"},
        {"name": "resolver", "type": "address"},
        {"name": "name", "type": "string"}
      ],
      "outputs": [{"name": "", "type": "bytes32"}],
      "stateMutability": "nonpayable",
    },
  ],
}

let setNameForAddr = async (walletClient, name) => {
  let currentAddress = await currentAddress(walletClient)
  Console.log(`Setting reverse name for ${currentAddress} to '${name}'`)
  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": reverseRegistrarContract["address"],
      "abi": reverseRegistrarContract["abi"],
      "functionName": "setNameForAddr",
      "args": [
        String(currentAddress),
        String(currentAddress),
        String(Constants.resolverContractAddress),
        String(name)
      ],
    },
  )
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceipt(
    publicClient,
    {"hash": hash},
  )
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}