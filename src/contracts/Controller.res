open OnChainOperationsCommon
open L2Resolver

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
  "register": {
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
    Console.log(`Registering ${name}`)
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
    let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
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
    let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
    Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}