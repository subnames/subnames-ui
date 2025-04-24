open OnChainOperationsCommon

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