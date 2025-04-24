@val @scope("window") external ethereum: option<Dom.window> = "ethereum"


type publicClient
type walletClient

@module("viem") external getAddress: string => string = "getAddress"
@module("viem") external createPublicClient: 'a => publicClient = "createPublicClient"
@module("viem") external createWalletClient: 'a => walletClient = "createWalletClient"
@module("viem") external http: string => 'transport = "http"
@module("viem") external keccak256: string => string = "keccak256"
@module("viem") external encodePacked: (array<string>, array<string>) => string = "encodePacked"
@module("viem") external custom: 'a => 'b = "custom"
@module("viem") external encodeFunctionData: 'a => string = "encodeFunctionData"
@module("viem/chains") external targetChain: 'chain = "darwinia"
@module("viem/ens") external namehash: string => string = "namehash"

@unboxed type argType = String(string) | Int(int) | BigInt(bigint) | Array(array<string>)

type request
type requestResult = {request: request}
type transaction = {
  blockNumber: bigint,
  status: string,
}
// type standaloneParams = {
//   account: string,
//   address: string,
//   abi: array<argType>,
//   functionName: string,
//   args: array<argType>
// }
@send external readContract: (publicClient, 'readContractParams) => promise<'result> = "readContract"
@send external simulateContract: (publicClient, 'simulateContractParams) => promise<requestResult> = "simulateContract"
@send external writeContract: (walletClient, request) => promise<'result> = "writeContract"
@send external writeContractStandalone: (walletClient, 'standaloneParams) => promise<'result> = "writeContract"
@send external requestAddresses: walletClient => promise<array<string>> = "requestAddresses"
@send external getAddresses: walletClient => promise<array<string>> = "getAddresses"
@send external waitForTransactionReceipt: (publicClient, 'a) => promise<transaction> = "waitForTransactionReceipt"

// Enhanced version with retry logic
let waitForTransactionReceiptWithRetry = async (publicClient, hash, ~maxRetries=10, ~delayMs=2000) => {
  let rec attempt = async (retryCount) => {
    try {
      Console.log(`Waiting for transaction receipt: ${hash}, attempt ${retryCount->Int.toString}/${maxRetries->Int.toString}`)
      let receipt = await waitForTransactionReceipt(publicClient, {"hash": hash})
      Console.log(`Transaction ${hash} confirmed in block ${BigInt.toString(receipt.blockNumber)}, status: ${receipt.status}`)
      receipt
    } catch {
    | _ => {
        if (retryCount < maxRetries) {
          Console.log(`Receipt not found yet, retrying in ${delayMs->Int.toString}ms...`)
          // Sleep for delayMs
          await Promise.make((resolve, _) => {
            let _ = setTimeout(() => resolve(. ()), delayMs)
          })
          await attempt(retryCount + 1)
        } else {
          Console.log(`Max retries reached for transaction ${hash}. The transaction may still succeed on-chain.`)
          // Return a "fake" receipt so the UI can continue
          // This is a workaround for transactions that succeed on-chain but we can't get the receipt
          {
            blockNumber: BigInt.fromInt(0),
            status: "success_assumed", // Special status to indicate we're assuming success
          }
        }
      }
    }
  }
  
  await attempt(1)
}

@module("../sha3.mjs") external sha3HexAddress: string => string = "default"

let publicClient = createPublicClient({
  "chain": targetChain,
  "transport": http(Constants.rpcUrl),
})

let buildWalletClient = () => {
  switch ethereum {
  | Some(ethereum) => Some(createWalletClient({"chain": targetChain, "transport": custom(ethereum)}))
  | None => None
  }
}

let currentAddress = async walletClient => {
  let result = await requestAddresses(walletClient)
  assert(result->Array.length >= 1)

  result->Array.get(0)->Option.getUnsafe
}

let getCurrentAddress = async () => {
  let walletClient = buildWalletClient()
  switch walletClient {
  | Some(client) => {
      Some(await currentAddress(client))
    }
  | None => None
  }
}
