type publicClient
type address = string
type abi = array<{
  "inputs": array<{
    "name": string,
    "type": string,
  }>,
  "name": string,
  "outputs": array<{
    "name": string,
    "type": string,
  }>,
  "stateMutability": string,
  "type": string,
}>

@module("viem") external createPublicClient: 'a => publicClient = "createPublicClient"
@module("viem") external http: string => 'transport = "http"
@module("viem") external koi: 'chain = "koi"

@unboxed type argType = String(string) | Int(int) | BigInt(bigint)
type readContractParams = {
  address: address,
  abi: abi,
  functionName: string,
  args: array<argType>,
}

@send external readContract: (publicClient, readContractParams) => promise<'result> = "readContract"

@module("viem/ens") external namehash: string => string = "namehash"

let registryContract = {
  "address": Constants.registryContractAddress,
  "abi": [
    {"type": "function","name": "recordExists","inputs": [{"name": "node", "type": "bytes32"}],"outputs": [{"name": "", "type": "bool"}],"stateMutability": "view",},
  ],
}

let controllerContract = {
  "address": Constants.controllerContractAddress,
  "abi": [
    {"type":"function","name":"available","inputs":[{"name":"name","type":"string"}],"outputs":[{"name":"","type":"bool"}],"stateMutability":"view"},
    {"type":"function","name":"registerPrice","inputs":[{"name":"name","type":"string"},{"name":"duration","type":"uint256"}],"outputs":[{"name":"","type":"uint256"}],"stateMutability":"view"},
    {"type":"function","name":"renew","inputs":[{"name":"name","type":"string"},{"name":"duration","type":"uint256"}],"outputs":[],"stateMutability":"payable"}
  ]
}

let client = createPublicClient({
  "chain": koi,
  "transport": http(Constants.rpcUrl),
})

let recordExists: string => promise<bool> = async name => {
  let node = namehash(`${name}.ringdao.eth`)
  Console.log(node)
  await readContract(
    client,
    {
      address: registryContract["address"],
      abi: registryContract["abi"],
      functionName: "recordExists",
      args: [String(node)],
    },
  )
}

let available: string => promise<bool> = async (name) => {
  await readContract(
    client,
    {
      address: controllerContract["address"],
      abi: controllerContract["abi"],
      functionName: "available",
      args: [String(name)],
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
      address: controllerContract["address"],
      abi: controllerContract["abi"],
      functionName: "registerPrice",
      args: args,
    },
  )
  BigInt.fromInt(result)
}
