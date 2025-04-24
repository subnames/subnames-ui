open OnChainOperationsCommon

let baseRegistrarContract = {
  "address": Constants.baseRegistrarContractAddress,
  "abi": [
    {
      "type": "function",
      "name": "nameExpires",
      "inputs": [{"name": "id", "type": "uint256"}],
      "outputs": [{"name": "expiry", "type": "uint256"}],
      "stateMutability": "view",
    },
    {
      "type": "function",
      "name": "safeTransferFrom",
      "inputs": [
        {"name": "from", "type": "address"},
        {"name": "to", "type": "address"},
        {"name": "tokenId", "type": "uint256"},
      ],
      "outputs": [],
      "stateMutability": "nonpayable",
    },
    {
      "type": "function",
      "name": "reclaim",
      "inputs": [{"name": "id", "type": "uint256"}, {"name": "owner", "type": "address"}],
      "outputs": [],
      "stateMutability": "nonpayable",
    },
    {
      "type": "function",
      "name": "ownerOf",
      "inputs": [{"name": "id", "type": "uint256"}],
      "outputs": [{"name": "result", "type": "address"}],
      "stateMutability": "view",
    },
  ],
}

let nameExpires: string => promise<bigint> = async name => {
  let tokenId = BigInt.fromString(keccak256(name))
  let result = await readContract(
    publicClient,
    {
      "address": baseRegistrarContract["address"],
      "abi": baseRegistrarContract["abi"],
      "functionName": "nameExpires",
      "args": [BigInt(tokenId)],
    },
  )
  result
}

// Alias for nameExpires to be used in public profile view
let getNameExpiry = nameExpires

let getTokenOwner: string => promise<string> = async name => {
  let tokenId = BigInt.fromString(keccak256(name))
  await readContract(
    publicClient,
    {
      "address": baseRegistrarContract["address"],
      "abi": baseRegistrarContract["abi"],
      "functionName": "ownerOf",
      "args": [BigInt(tokenId)],
    },
  )
}

let reclaim = async (walletClient, tokenId, newOwner) => {
  let currentAddress = await currentAddress(walletClient)

  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": Constants.baseRegistrarContractAddress,
      "abi": [
        {
          "type": "function",
          "name": "reclaim",
          "inputs": [{"name": "id", "type": "uint256"}, {"name": "owner", "type": "address"}],
          "outputs": [],
          "stateMutability": "nonpayable",
        },
      ],
      "functionName": "reclaim",
      "args": [BigInt(tokenId), String(newOwner)],
    },
  )
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
  hash
}

let safeTransferFrom = async (walletClient, from, to, tokenId) => {
  let {request: transferRequest} = await simulateContract(
    publicClient,
    {
      "account": from,
      "address": Constants.baseRegistrarContractAddress,
      "abi": [
        {
          "type": "function",
          "name": "safeTransferFrom",
          "inputs": [
            {"name": "from", "type": "address"},
            {"name": "to", "type": "address"},
            {"name": "tokenId", "type": "uint256"},
          ],
          "outputs": [],
          "stateMutability": "payable",
        },
      ],
      "functionName": "safeTransferFrom",
      "args": [String(from), String(to), BigInt(tokenId)],
    },
  )
  let hash = await writeContract(walletClient, transferRequest)
  let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
  Console.log(`transfer confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
  hash
}