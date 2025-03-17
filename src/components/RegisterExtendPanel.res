@val external document: Dom.document = "document"
@send external querySelector: (Dom.document, string) => Dom.element = "querySelector"
@send external click: Dom.element => unit = "click"

type feeState = {
  years: int,
  feeAmount: float,
}

@react.component
let make = (
  ~name: string,
  ~isWalletConnected: bool,
  ~onBack: unit => unit,
  ~onSuccess: Types.actionResult => unit,
  ~action: Types.action,
  ~buttonType: [#back | #close]=#close,
) => {
  let (fee, setFee) = React.useState(_ => {
    years: 1,
    feeAmount: 0.0,
  })
  let (isCalculatingFee, setIsCalculatingFee) = React.useState(_ => false)
  let (isWaitingForConfirmation, setIsWaitingForConfirmation) = React.useState(() => false)
  let (onChainStatus, setOnChainStatus) = React.useState(() => OnChainOperations.Simulating)

  let calculateFee = async years => {
    switch action {
    | Types.Register =>
      let priceInEth = await Fee.calculate(name, years)
      setFee(_ => {
        years,
        feeAmount: priceInEth,
      })
    | Types.Extend =>
      let priceInEth = await Fee.calculateRenew(name, years)
      setFee(_ => {
        years,
        feeAmount: priceInEth,
      })
    | _ => Exn.raiseError("Unreachable")
    }
  }

  let incrementYears = () => {
    if !isCalculatingFee {
      let newYears = fee.years + 1
      setIsCalculatingFee(_ => true)
      let _ = calculateFee(newYears)->Promise.then(_ => {
        setIsCalculatingFee(_ => false)
        Promise.resolve()
      })
    }
  }

  let decrementYears = () => {
    if !isCalculatingFee && fee.years > 1 {
      let newYears = fee.years - 1
      setIsCalculatingFee(_ => true)
      let _ = calculateFee(newYears)->Promise.then(_ => {
        setIsCalculatingFee(_ => false)
        Promise.resolve()
      })
    }
  }

  React.useEffect0(() => {
    setIsCalculatingFee(_ => true)
    let _ = calculateFee(1)->Promise.then(_ => {
      setIsCalculatingFee(_ => false)
      Promise.resolve()
    })
    None
  })

  let handleClick = (~years: int) => {
    setIsWaitingForConfirmation(_ => true)
    let walletClient = OnChainOperationsCommon.buildWalletClient()
    
    // Helper function to handle transaction errors and re-enable the button
    let handleTransactionError = exn => {
      setIsWaitingForConfirmation(_ => false)
      
      // Check if the error is related to insufficient funds
      let errorMessage = 
        try {
          // Convert exception to string by using JSON.stringify
          let exnStr = %raw(`JSON.stringify(exn)`)
          Console.error2("Transaction error:", exnStr)
          if String.includes(exnStr, "OutOfFund") {
            "Insufficient funds. Please make sure you have enough RING tokens to cover the transaction fee and the registration cost."
          } else {
            "Transaction rejected or failed"
          }
        } catch {
        | _ => "Transaction rejected or failed"
        }
      
      setOnChainStatus(_ => OnChainOperations.Failed(errorMessage))
      Promise.resolve()
    }
    
    switch action {
    | Types.Register =>
      let _ = OnChainOperations.register(walletClient->Option.getUnsafe, name, years, None, status => setOnChainStatus(_ => status))
        ->Promise.then(_ => {
          OnChainOperations.nameExpires(name)->Promise.then(expiry => {
            let expiryDate = expiry
            ->BigInt.mul(1000n)
            ->BigInt.toFloat
            ->Date.fromTime
            onSuccess({
              action,
              newExpiryDate: Some(expiryDate),
            })
            Promise.resolve()
          })
        })
        ->Promise.catch(exn => handleTransactionError(exn))
    | Types.Extend =>
      let _ = OnChainOperations.renew(walletClient->Option.getUnsafe, name, years)
        ->Promise.then(_ => {
          OnChainOperations.nameExpires(name)->Promise.then(expiry => {
            let expiryDate = expiry
            ->BigInt.mul(1000n)
            ->BigInt.toFloat
            ->Date.fromTime
            onSuccess({
              action,
              newExpiryDate: Some(expiryDate),
            })
            Promise.resolve()
          })
        })
        ->Promise.catch(exn => handleTransactionError(exn))
    | _ => Exn.raiseError("Unreachable")
    }
  }

  let handleConnectWallet = () => {
    let connectButton = document->querySelector("[data-testid='rk-connect-button']")
    connectButton->click
  }

<div className="fixed inset-0 flex items-center justify-center z-40">
  <div className="fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm dark:bg-opacity-80" />
  <div className="bg-white rounded-custom shadow-2xl overflow-hidden relative z-50 max-w-md w-full mx-4 animate-fadeIn dark:bg-[#1b1b1b] dark:border dark:border-[rgba(255,255,255,0.08)]">
    <div className="pt-6 pb-8 px-8">
      <div className="flex justify-between">
        <div className="flex gap-3">
          {switch buttonType {
          | #back => 
            <button
              onClick={_ => onBack()}
              className="p-1 hover:bg-gray-100 rounded-full transition-colors dark:hover:bg-gray-700"
              type_="button">
                <Icons.Back />
            </button>
          | #close => React.null
          }}
          <div>
            <h1 className="text-xl font-semibold text-gray-900 truncate dark:text-white">
              {React.string(`${switch action {
              | Types.Register => "Register"
              | Types.Extend => "Extend"
              | _ => Exn.raiseError("Unreachable")
              }}`)}
            </h1>
            <div className="mt-0">
              <span className="text-sm text-gray-500 dark:text-gray-400">{React.string(`${name}.${Constants.sld}`)}</span>
            </div>
          </div>
        </div>
        {switch buttonType {
        | #close => 
          <div className="self-center">
            <button
              onClick={_ => onBack()}
              className="rounded-full transition-colors hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300"
              type_="button">
              <Icons.Close/>
            </button>
          </div>
        | #back => React.null
        }}
      </div>

      <div className="border-t border-gray-200 my-4 -mx-8 dark:border-[rgba(255,255,255,0.08)]"></div>
      
      <div className="p-6 rounded-xl">
        <div className="flex flex-col items-center gap-6">
          <div className="w-full">
            <div className="flex items-center justify-between border-2 border-gray-600 rounded-full p-1 w-full max-w-md dark:border-gray-500">
              <button
                onClick={_ => decrementYears()}
                disabled={isCalculatingFee || fee.years <= 1}
                className={`w-10 h-10 border-2 border-gray-300 rounded-full ${isCalculatingFee || fee.years <= 1
                    ? "bg-gray-200 text-gray-400 cursor-not-allowed dark:bg-gray-700 dark:text-gray-500"
                    : "bg-gray-200 text-gray-700 hover:bg-gray-100 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600"} flex items-center justify-center transition-colors`}>
                <div className="flex items-center justify-center w-5 h-5">
                  <Icons.Minus />
                </div>
              </button>
              <div className="text-2xl font-bold text-gray-900 text-center dark:text-white">
                {React.string(`${fee.years->Int.toString} year${fee.years > 1 ? "s" : ""}`)}
              </div>
              <button
                onClick={_ => incrementYears()}
                disabled={isCalculatingFee}
                className={`w-10 h-10 border-2 border-gray-300 rounded-full ${isCalculatingFee
                    ? "bg-gray-200 text-gray-400 cursor-not-allowed dark:bg-gray-700 dark:text-gray-500"
                    : "bg-gray-200 text-gray-700 hover:bg-gray-100 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600"} flex items-center justify-center transition-colors`}>
                <div className="flex items-center justify-center w-5 h-5">
                  <Icons.Plus />
                </div>
              </button>
            </div>
          </div>

          <div className="w-full flex flex-col items-center pt-2">
            <div className="text-sm font-medium text-gray-600 text-center uppercase tracking-wider dark:text-gray-400">
              {React.string("Cost")}
            </div>
            <div className="py-1 min-w-[180px] text-center">
              {if isCalculatingFee {
                <div className="flex items-center justify-center gap-2 h-12">
                  <Icons.Spinner className="w-6 h-6 text-gray-600 dark:text-gray-400" />
                  <span className="text-gray-500 font-medium dark:text-gray-400"> {React.string("Calculating...")} </span>
                </div>
              } else {
                <div className="flex flex-col items-center">
                  <div className="text-3xl font-bold text-gray-900 dark:text-white">
                    {React.string(`${fee.feeAmount->Float.toFixed}`)}
                  </div>
                  <div className="text-xs text-gray-500 mt-1 dark:text-gray-400">
                    {React.string("Paid in RING tokens on Darwinia Network")}
                  </div>
                </div>
              }}
            </div>
          </div>
        </div>
      </div>

      {switch onChainStatus {
      | OnChainOperations.Failed(errorMessage) => 
          <div className="mb-4 mx-1 p-4 bg-red-50 border border-red-200 rounded-lg dark:bg-red-900/20 dark:border-red-800/30">
            <div className="flex items-start gap-3">
              <div className="text-red-500 dark:text-red-400 mt-0.5">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="w-5 h-5">
                  <path strokeLinecap="round" strokeLinejoin="round" d="M12 9v3.75m-9.303 3.376c-.866 1.5.217 3.374 1.948 3.374h14.71c1.73 0 2.813-1.874 1.948-3.374L13.949 3.378c-.866-1.5-3.032-1.5-3.898 0L2.697 16.126zM12 15.75h.007v.008H12v-.008z" />
                </svg>
              </div>
              <div>
                <h3 className="font-medium text-red-800 dark:text-red-300">{React.string("Transaction Failed")}</h3>
                <p className="mt-1 text-sm text-red-700 dark:text-red-400">{React.string(errorMessage)}</p>
                // {(if String.includes(errorMessage, "Insufficient") {
                //   <div className="mt-2 text-sm text-red-700 dark:text-red-400">
                //     <p className="font-medium">{React.string("Tips:")}</p>
                //     <ul className="list-disc pl-5 mt-1 space-y-1">
                //       <li>{React.string("Make sure you have enough RING tokens in your wallet")}</li>
                //       <li>{React.string("You need tokens for both gas fees and registration cost")}</li>
                //       <li>{React.string("Try registering for a shorter period to reduce cost")}</li>
                //     </ul>
                //   </div>
                // } else {
                //   React.null
                // })}
              </div>
            </div>
          </div>
      | _ => React.null
      }}

      <div className="mt-2">
        {if !isWalletConnected {
          <button
            onClick={_ => handleConnectWallet()}
            className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2 dark:bg-zinc-700 dark:hover:bg-zinc-600 dark:active:bg-zinc-800">
            <span>{React.string("Connect Wallet")}</span>
          </button>
        } else {
          <button
            onClick={_ => handleClick(~years=fee.years)}
            disabled={isCalculatingFee || isWaitingForConfirmation}
            className={`w-full py-4 px-6 ${isCalculatingFee || isWaitingForConfirmation
                ? "bg-zinc-400 cursor-not-allowed dark:border dark:active:bg-[#ffffff0a] dark:bg-[#ffffff0a] dark:hover:bg-[#ffffff14] "
                : "bg-zinc-800 hover:bg-zinc-700 dark:border dark:active:bg-[#ffffff0a] dark:bg-[#ffffff0a] dark:hover:bg-[#ffffff14] "} text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2`}>
            {if isWaitingForConfirmation {
              <>
                <Icons.Spinner className="w-5 h-5 text-white" />
                <span>
                  {switch action {
                  | Types.Register => React.string("Registering...")
                  | Types.Extend => React.string("Extending...")
                  | _ => Exn.raiseError("Unreachable")
                  }}
                </span>
              </>
            } else if isCalculatingFee {
              <>
                <Icons.Spinner className="w-5 h-5 text-white" />
                <span>{React.string("Calculating...")}</span>
              </>
            } else {
              <span>
                {switch action {
                | Types.Register => React.string("Register Now")
                | Types.Extend => React.string("Extend Now")
                | _ => Exn.raiseError("Unreachable")
                }}
              </span>
            }}
          </button>
        }}
      </div>
    </div>
  </div>
</div>
  }
