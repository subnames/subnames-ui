type publicClient
type address = string
type abi

@module("viem") external createPublicClient: 'a => publicClient = "createPublicClient"
@module("viem") external http: string => 'transport = "http"
@module("viem/chains") external koi: 'chain = "koi"

@unboxed type argType = String(string) | Int(int) | BigInt(bigint)
@send
external readContract: (publicClient, 'readContractParams) => promise<'result> = "readContract"

@module("viem/ens") external namehash: string => string = "namehash"

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
      "name": "renew",
      "inputs": [{"name": "name", "type": "string"}, {"name": "duration", "type": "uint256"}],
      "outputs": [],
      "stateMutability": "payable",
    },
  ],
  "abiForWrite": [
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
  ],
}

let client = createPublicClient({
  "chain": koi,
  "transport": http(Constants.rpcUrl),
})

let recordExists: string => promise<bool> = async name => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  Console.log(`domain: "${domain}", node: "${node}"`)
  await readContract(
    client,
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
    client,
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
    client,
    {
      "address": controllerContract["address"],
      "abi": controllerContract["abi"],
      "functionName": "registerPrice",
      "args": args,
    },
  )
  BigInt.fromInt(result)
}

@module("./sha3.mjs")
external sha3HexAddress: string => string = "default"
@module("viem") external keccak256: string => string = "keccak256"
@module("viem") external encodePacked: (array<string>, array<string>) => string = "encodePacked"

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
    client,
    {
      "address": resolverContract["address"],
      "abi": resolverContract["abi"],
      "functionName": "name",
      "args": [String(node)],
    },
  )
}

////////////////////////////////////////
// Wallet client
////////////////////////////////////////
type walletClient
@module("viem") external createWalletClient: 'a => walletClient = "createWalletClient"
@module("viem") external custom: 'a => 'b = "custom"
@val @scope("window") external ethereum: option<Dom.window> = "ethereum"
@send external requestAddresses: walletClient => promise<array<string>> = "requestAddresses"
@send external getAddresses: walletClient => promise<array<string>> = "getAddresses"
type request
type requestResult = {request: request}
@send
external simulateContract: (publicClient, 'simulateContractParams) => promise<requestResult> =
  "simulateContract"
@send external writeContract: (walletClient, request) => promise<'result> = "writeContract"
@module("viem") external encodeFunctionData: 'a => string = "encodeFunctionData"

let publicClient = createPublicClient({
  "chain": koi,
  "transport": http(Constants.rpcUrl),
})

type transaction = {
  blockNumber: bigint,
  status: string,
}
@send
external waitForTransactionReceipt: (publicClient, 'a) => promise<transaction> =
  "waitForTransactionReceipt"


// Console.log("ethereum")
// Console.log(ethereum)



// // let walletClient = createWalletClient({
// //   "chain": koi,
// //   "transport": custom(ethereum),
// // })

let buildWalletClient = () => {
  switch (ethereum) {
  | Some(ethereum) => Some(createWalletClient({"chain": koi, "transport": custom(ethereum)}))
  | None => None
  }
}

let currentAddress = async (walletClient) => {
  let result = await requestAddresses(walletClient)
  assert(result->Array.length >= 1)
  result->Array.get(0)->Option.getUnsafe
}

open Constants

let encodeSetAddr: (string, string) => string = (name, owner) => {
  let node = namehash(`${name}.${sld}`)
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

let register: (walletClient, string, int, option<string>, transactionStatus => unit) => promise<unit> = async (
  walletClient,
  name,
  years,
  owner,
  onStatusChange,
) => {
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
      "abi": controllerContract["abiForWrite"],
      "functionName": "register",
      "args": [
        {
          "name": name,
          "owner": resolvedAddress,
          "duration": duration,
          "resolver": resolverContractAddress,
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
