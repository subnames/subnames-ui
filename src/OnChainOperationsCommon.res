@val @scope("window") external ethereum: option<Dom.window> = "ethereum"


type publicClient
type walletClient

@module("viem") external createPublicClient: 'a => publicClient = "createPublicClient"
@module("viem") external createWalletClient: 'a => walletClient = "createWalletClient"
@module("viem") external http: string => 'transport = "http"
@module("viem") external keccak256: string => string = "keccak256"
@module("viem") external encodePacked: (array<string>, array<string>) => string = "encodePacked"
@module("viem") external custom: 'a => 'b = "custom"
@module("viem") external encodeFunctionData: 'a => string = "encodeFunctionData"
@module("viem/chains") external koi: 'chain = "koi"
@module("viem/ens") external namehash: string => string = "namehash"

@unboxed type argType = String(string) | Int(int) | BigInt(bigint)

type request
type requestResult = {request: request}
type transaction = {
  blockNumber: bigint,
  status: string,
}
@send external readContract: (publicClient, 'readContractParams) => promise<'result> = "readContract"
@send external simulateContract: (publicClient, 'simulateContractParams) => promise<requestResult> = "simulateContract"
@send external writeContract: (walletClient, request) => promise<'result> = "writeContract"
@send external requestAddresses: walletClient => promise<array<string>> = "requestAddresses"
@send external getAddresses: walletClient => promise<array<string>> = "getAddresses"
@send external waitForTransactionReceipt: (publicClient, 'a) => promise<transaction> = "waitForTransactionReceipt"

@module("./sha3.mjs") external sha3HexAddress: string => string = "default"

let publicClient = createPublicClient({
  "chain": koi,
  "transport": http(Constants.rpcUrl),
})

let buildWalletClient = () => {
  switch ethereum {
  | Some(ethereum) => Some(createWalletClient({"chain": koi, "transport": custom(ethereum)}))
  | None => None
  }
}

let currentAddress = async walletClient => {
  let result = await requestAddresses(walletClient)
  assert(result->Array.length >= 1)

  result->Array.get(0)->Option.getUnsafe
}