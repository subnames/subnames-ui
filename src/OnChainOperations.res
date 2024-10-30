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
      "outputs": (),
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

////////////////////////////////////////
// Wallet client
////////////////////////////////////////
type walletClient
@module("viem") external createWalletClient: 'a => walletClient = "createWalletClient"
@module("viem") external custom: 'a => 'b = "custom"
@val @scope("window") external ethereum: Dom.window = "ethereum"
@send external getAddresses: walletClient => promise<array<string>> = "getAddresses"

let publicClient = createPublicClient({
  "chain": koi,
  "transport": http(Constants.rpcUrl),
})

let walletClient = createWalletClient({
  "chain": koi,
  "transport": custom(ethereum),
})

let currentAddress = async () => {
  let result = await getAddresses(walletClient)
  if result->Array.length == 0 {
    None
  } else {
    Some(result->Array.get(0))
  }
}
