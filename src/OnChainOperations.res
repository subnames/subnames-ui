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
      "inputs": [
        {"name": "id", "type": "uint256"},
        {"name": "owner", "type": "address"},
      ],
      "outputs": [],
      "stateMutability": "nonpayable",
    },
  ],
}

let resolverContract = {
  "address": Constants.resolverContractAddress,
  "abi": [
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "node",
          "type": "bytes32",
        },
      ],
      "name": "name",
      "outputs": [
        {
          "internalType": "string",
          "name": "",
          "type": "string",
        },
      ],
      "stateMutability": "view",
      "type": "function",
    },
  ],
}

let registryContract = {
  "address": Constants.registryContractAddress,
  "abi": [
    {
      "type": "function",
      "name": "recordExists",
      "inputs": [{"name": "node", "type": "bytes32"}],
      "outputs": [{"name": "", "type": "bool"}],
      "stateMutability": "view",
    },
    {
      "type": "function",
      "name": "owner",
      "inputs": [{"name": "node", "type": "bytes32"}],
      "outputs": [{"name": "", "type": "address"}],
      "stateMutability": "view",
    },
  ],
}

let controllerContract = {
  "address": Constants.controllerContractAddress,
  "abi": [
    {
      "type": "function",
      "name": "available",
      "inputs": [{"name": "name", "type": "string"}],
      "outputs": [{"name": "", "type": "bool"}],
      "stateMutability": "view",
    },
    {
      "type": "function",
      "name": "registerPrice",
      "inputs": [{"name": "name", "type": "string"}, {"name": "duration", "type": "uint256"}],
      "outputs": [{"name": "", "type": "uint256"}],
      "stateMutability": "view",
    },
    {
      "type": "function",
      "name": "rentPrice",
      "inputs": [{"name": "name", "type": "string"}, {"name": "duration", "type": "uint256"}],
      "outputs": [{"name": "", "type": "uint256"}],
      "stateMutability": "view",
    },
  ],
  "register": 
    {
      "inputs": [
        {
          "components": [
            {
              "internalType": "string",
              "name": "name",
              "type": "string",
            },
            {
              "internalType": "address",
              "name": "owner",
              "type": "address",
            },
            {
              "internalType": "uint256",
              "name": "duration",
              "type": "uint256",
            },
            {
              "internalType": "address",
              "name": "resolver",
              "type": "address",
            },
            {
              "internalType": "bytes[]",
              "name": "data",
              "type": "bytes[]",
            },
            {
              "internalType": "bool",
              "name": "reverseRecord",
              "type": "bool",
            },
          ],
          "internalType": "struct RegistrarController.RegisterRequest",
          "name": "request",
          "type": "tuple",
        },
      ],
      "name": "register",
      "outputs": Array.make(~length=0, ()),
      "stateMutability": "payable",
      "type": "function",
    },
    "renew": {
      "inputs": [
        {
          "internalType": "string",
          "name": "name",
          "type": "string",
        },
        {
          "internalType": "uint256",
          "name": "duration",
          "type": "uint256",
        },
      ],
      "name": "renew",
      "outputs": Array.make(~length=0, ()),
      "stateMutability": "payable",
      "type": "function",
    },
}

let recordExists: string => promise<bool> = async name => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  Console.log(`domain: "${domain}", node: "${node}"`)
  await readContract(
    publicClient,
    {
      "address": registryContract["address"],
      "abi": registryContract["abi"],
      "functionName": "recordExists",
      "args": [String(node)],
    },
  )
}

let available: string => promise<bool> = async name => {
  await readContract(
    publicClient,
    {
      "address": controllerContract["address"],
      "abi": controllerContract["abi"],
      "functionName": "available",
      "args": [String(name)],
    },
  )
}

// price is denominated in wei
// duration is in seconds
let registerPrice: (string, int) => promise<bigint> = async (name, duration) => {
  let args: array<argType> = [String(name), Int(duration)]
  let result = await readContract(
    publicClient,
    {
      "address": controllerContract["address"],
      "abi": controllerContract["abi"],
      "functionName": "registerPrice",
      "args": args,
    },
  )
  BigInt.fromInt(result)
}

let rentPrice: (string, int) => promise<bigint> = async (name, duration) => {
  let args: array<argType> = [String(name), Int(duration)]
  await readContract(
    publicClient,
    {
      "address": controllerContract["address"],
      "abi": controllerContract["abi"],
      "functionName": "rentPrice",
      "args": args,
    },
  )
}

let name: string => promise<string> = async address => {
  let node = keccak256(
    encodePacked(
      ["bytes32", "bytes32"],
      [
        "0x32347c1de91cbc71535aee17456bbe8987cc116a2782950e2697c6fc411ba53f",
        sha3HexAddress(address),
      ],
    ),
  )
  await readContract(
    publicClient,
    {
      "address": resolverContract["address"],
      "abi": resolverContract["abi"],
      "functionName": "name",
      "args": [String(node)],
    },
  )
}

let nameExpires: string => promise<int> = async name => {
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
  BigInt.toInt(result)
}

let owner: string => promise<string> = async name => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  await readContract(
    publicClient,
    {
      "address": registryContract["address"],
      "abi": registryContract["abi"],
      "functionName": "owner",
      "args": [String(node)],
    },
  )
}

////////////////////////////////////////
// Wallet client
////////////////////////////////////////











// Console.log("ethereum")
// Console.log(ethereum)

// // let walletClient = createWalletClient({
// //   "chain": koi,
// //   "transport": custom(ethereum),
// // })



let encodeSetAddr: (string, string) => string = (name, owner) => {
  let node = namehash(`${name}.${Constants.sld}`)
  let abi = [
    {
      "type": "function",
      "name": "setAddr",
      "inputs": [{"name": "node", "type": "bytes32"}, {"name": "addr", "type": "address"}],
      "outputs": [],
      "stateMutability": "view",
    },
  ]
  encodeFunctionData({
    "abi": abi,
    "functionName": "setAddr",
    "args": [String(node), String(owner)],
  })
}

type transactionStatus =
  | Simulating
  | WaitingForSignature
  | Broadcasting
  | Confirmed
  | Failed(string)

let register: (
  walletClient,
  string,
  int,
  option<string>,
  transactionStatus => unit,
) => promise<unit> = async (walletClient, name, years, owner, onStatusChange) => {
  onStatusChange(Simulating)
  let duration = years * 31536000
  let currentAddress = await currentAddress(walletClient)
  let resolvedAddress = owner->Option.getOr(currentAddress)
  let setAddrData = encodeSetAddr(name, resolvedAddress)
  let priceInWei = await registerPrice(name, duration)
  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": controllerContract["address"],
      "abi": [controllerContract["register"]],
      "functionName": "register",
      "args": [
        {
          "name": name,
          "owner": resolvedAddress,
          "duration": duration,
          "resolver": Constants.resolverContractAddress,
          "data": [setAddrData],
          "reverseRecord": true,
        },
      ],
      "value": priceInWei,
    },
  )

  onStatusChange(WaitingForSignature)
  let hash = await writeContract(walletClient, request)

  onStatusChange(Broadcasting)
  // Wait for transaction confirmation
  let {blockNumber, status} = await waitForTransactionReceipt(publicClient, {"hash": hash})
  onStatusChange(Confirmed)
}

let renew: (walletClient, string, int) => promise<unit> = async (walletClient, name, years) => {
  let duration = years * 31536000
  let currentAddress = await currentAddress(walletClient)
  let priceInWei = await rentPrice(name, duration)
  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": controllerContract["address"],
      "abi": [controllerContract["renew"]],
      "functionName": "renew",
      "args": [String(name), Int(duration)],
      "value": priceInWei,
    },
  )
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceipt(publicClient, {"hash": hash})
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}

let transferSubname = async (walletClient, name, to) => {
  let tokenId = BigInt.fromString(keccak256(name))
  let currentAddress = await currentAddress(walletClient)

  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": baseRegistrarContract["address"],
      "abi": baseRegistrarContract["abi"],
      "functionName": "safeTransferFrom",
      "args": [String(currentAddress), String(to), BigInt(tokenId)],
    },
  )
  
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceipt(publicClient, {"hash": hash})
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}

let reclaimSubname = async (walletClient, name) => {
  let tokenId = BigInt.fromString(keccak256(name))
  let currentAddress = await currentAddress(walletClient)
  
  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": baseRegistrarContract["address"],
      "abi": baseRegistrarContract["abi"],
      "functionName": "reclaim",
      "args": [BigInt(tokenId), String(currentAddress)],
    }
  )
  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceipt(publicClient, {"hash": hash})
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}