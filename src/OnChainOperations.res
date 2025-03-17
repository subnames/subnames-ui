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
    {
      "inputs": [
        {
          "internalType": "bytes32",
          "name": "nodehash",
          "type": "bytes32",
        },
        {
          "internalType": "bytes[]",
          "name": "data",
          "type": "bytes[]",
        },
      ],
      "name": "multicallWithNodeCheck",
      "outputs": [
        {
          "internalType": "bytes[]",
          "name": "results",
          "type": "bytes[]",
        },
      ],
      "stateMutability": "nonpayable",
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

let multicallWithNodeCheck = async (walletClient, name, calls) => {
  let node = namehash(`${name}.${Constants.sld}`)
  let currentAddress = await currentAddress(walletClient)

  let {request} = await simulateContract(
    publicClient,
    {
      "account": currentAddress,
      "address": resolverContract["address"],
      "abi": resolverContract["abi"],
      "functionName": "multicallWithNodeCheck",
      "args": [String(node), Array(calls)],
    },
  )

  let hash = await writeContract(walletClient, request)
  let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
  Console.log(`${hash} confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
}

let encodeSetText = (name: string, key: string, value: string): string => {
  let node = namehash(`${name}.${Constants.sld}`)
  let abi = [
    {
      "type": "function",
      "name": "setText",
      "inputs": [
        {"name": "node", "type": "bytes32"},
        {"name": "key", "type": "string"},
        {"name": "value", "type": "string"},
      ],
      "outputs": [],
      "stateMutability": "view",
    },
  ]
  encodeFunctionData({
    "abi": abi,
    "functionName": "setText",
    "args": [String(node), String(key), String(value)],
  })
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

let encodeSetName: string => string = name => {
  let abi = [
    {
      "type": "function",
      "name": "setName",
      "inputs": [{"name": "name", "type": "string"}],
      "outputs": [],
      "stateMutability": "view",
    },
  ]
  encodeFunctionData({
    "abi": abi,
    "functionName": "setName",
    "args": [String(name)],
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
  try {
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
  } catch {
    | Exn.Error(e) => {
      Console.error("Error in register function")
      Console.error(e)
      onStatusChange(Failed("Transaction failed or was rejected"))
      Exn.raiseError("Transaction failed or was rejected") // Re-throw the exception to be caught by the caller
    }
  }
}

let renew: (walletClient, string, int) => promise<unit> = async (walletClient, name, years) => {
  try {
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
  } catch {
    | Exn.Error(e) => {
      switch Exn.message(e) {
      | Some(m) => {
        Console.error("Error in renew function! Message: " ++ m)
        Exn.raiseError(m)
      }
      | None => {
        Console.error("Error in renew function")
        Exn.raiseError("Transaction failed or was rejected")
      }
      }
    }
  }
}

let setAddr = async (walletClient, name, a) => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)

  let address = getAddress(a)

  let currentAddr = await currentAddress(walletClient)
  let {request: setAddrRequest} = await simulateContract(
    publicClient,
    {
      "account": currentAddr,
      "address": Constants.resolverContractAddress,
      "abi": [
        {
          "type": "function",
          "name": "setAddr",
          "inputs": [{"name": "node", "type": "bytes32"}, {"name": "a", "type": "address"}],
          "outputs": [],
          "stateMutability": "nonpayable",
        },
      ],
      "functionName": "setAddr",
      "args": [String(node), String(address)],
    },
  )
  let hash = await writeContract(walletClient, setAddrRequest)
  let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
  Console.log(`setAddr confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
  hash
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
  hash}

let setName = async (walletClient, name) => {
  let currentAddress = await currentAddress(walletClient)

  let hash = await writeContractStandalone(walletClient, {
    "address": Constants.reverseRegistrarContractAddress,
    "abi": [
      {
        "type": "function",
        "name": "setName",
        "inputs": [{"name": "name", "type": "string"}],
        "outputs": [],
        "stateMutability": "nonpayable",
      },
    ],
    "functionName": "setName",
    "account": currentAddress,
    "args": [String(name)],
  })

  let {blockNumber, status} = await waitForTransactionReceiptWithRetry(publicClient, hash)
  Console.log(`setName confirmed in block ${BigInt.toString(blockNumber)}, status: ${status}`)
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

let getText = async (name: string, key: string) => {
  let node = namehash(`${name}.${Constants.sld}`)
  let result = await readContract(
    publicClient,
    {
      "address": resolverContract["address"],
      "abi": [
        {
          "type": "function",
          "name": "text",
          "inputs": [{"name": "node", "type": "bytes32"}, {"name": "key", "type": "string"}],
          "outputs": [{"name": "", "type": "string"}],
          "stateMutability": "view",
        },
      ],
      "functionName": "text",
      "args": [String(node), String(key)],
    },
  )

  result == "" ? None : Some(result)
}

let getAddr = async (name: string) => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  
  try {
    let result = await readContract(
      publicClient,
      {
        "address": resolverContract["address"],
        "abi": [
          {
            "type": "function",
            "name": "addr",
            "inputs": [{"name": "node", "type": "bytes32"}],
            "outputs": [{"name": "", "type": "address"}],
            "stateMutability": "view",
          },
        ],
        "functionName": "addr",
        "args": [String(node)],
      },
    )
    
    Some(result)
  } catch {
  | _ => None
  }
}

let getOwner = async tokenId => {
  let label = `0x${tokenId->BigInt.toString(~radix=16)->String.padStart(64, "0")}`;

  // Compute the node for the subdomain
  let node = keccak256(
    encodePacked(
      ["bytes32", "bytes32"],
      [Constants.parentNode, label],
    ),
  )
  
  // Get the owner from the registry contract
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
