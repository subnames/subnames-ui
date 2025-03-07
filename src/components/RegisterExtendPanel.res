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
  let (_, setOnChainStatus) = React.useState(() => OnChainOperations.Simulating)

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
    switch action {
    | Types.Register =>
      let _ = OnChainOperations.register(walletClient->Option.getUnsafe, name, years, None, status => setOnChainStatus(_ => status))->Promise.then(_ => {
        OnChainOperations.nameExpires(name)->Promise.then(expiryInt => {
          let newExpiryDate = Date.fromTime(Int.toFloat(expiryInt) *. 1000.0)
          onSuccess({
            action,
            newExpiryDate: Some(newExpiryDate),
          })
          Promise.resolve()
        })
      })
    | Types.Extend =>
      let _ = OnChainOperations.renew(walletClient->Option.getUnsafe, name, years)->Promise.then(_ => {
        OnChainOperations.nameExpires(name)->Promise.then(expiryInt => {
          let newExpiryDate = Date.fromTime(Int.toFloat(expiryInt) *. 1000.0)
          onSuccess({
            action,
            newExpiryDate: Some(newExpiryDate),
          })
          Promise.resolve()
        })
      })
    | _ => Exn.raiseError("Unreachable")
    }
  }

  let handleConnectWallet = () => {
    let connectButton = document->querySelector("[data-testid='rk-connect-button']")
    connectButton->click
  }

  <div className="fixed inset-0 flex items-center justify-center z-40">
    <div className="fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm" />
    <div className="bg-white rounded-custom shadow-2xl overflow-hidden relative z-50 max-w-md w-full mx-4 animate-fadeIn">
      <div className="pt-6 pb-8 px-8">

        // header
        <div className="flex justify-between">
          <div className="flex gap-3">
            {switch buttonType {
            | #back => 
              <button
                onClick={_ => onBack()}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors"
                type_="button">
                  <Icons.Back />
              </button>
            | #close => React.null
            }}
            <div>
              <h1 className="text-xl font-semibold text-gray-900 truncate">
                {React.string(`${switch action {
                | Types.Register => "Register"
                | Types.Extend => "Extend"
                | _ => Exn.raiseError("Unreachable")
                }}`)}
              </h1>
              <div className="mt-0">
                <span className="text-sm text-gray-500">{React.string(`${name}.${Constants.sld}`)}</span>
              </div>
            </div>
          </div>
          {switch buttonType {
          | #close => 
            <div className="self-center">
              <button
                onClick={_ => onBack()}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors"
                type_="button">
                <Icons.Close />
              </button>
            </div>
          | #back => React.null
          }}
        </div>

        <div className="border-t border-gray-200 my-4 -mx-8"></div>
        
        // main content
        <div className="p-6 rounded-xl">
          <div className="flex flex-col items-center gap-6">

            // years selection
            <div className="w-full">
              
              <div className="flex items-center justify-between border-2 border-gray-600 rounded-full p-1 w-full max-w-md">
                <button
                  onClick={_ => decrementYears()}
                  disabled={isCalculatingFee || fee.years <= 1}
                  className={`w-10 h-10 border-2 border-gray-300 rounded-full ${isCalculatingFee || fee.years <= 1
                      ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                      : "bg-gray-200 text-gray-700 hover:bg-gray-100"} flex items-center justify-center transition-colors`}>
                  <div className="flex items-center justify-center w-5 h-5">
                    <Icons.Minus />
                  </div>
                </button>
                <div className="text-2xl font-bold text-gray-900 text-center">
                  {React.string(`${fee.years->Int.toString} year${fee.years > 1 ? "s" : ""}`)}
                </div>
                <button
                  onClick={_ => incrementYears()}
                  disabled={isCalculatingFee}
                  className={`w-10 h-10 border-2 border-gray-300 rounded-full ${isCalculatingFee
                      ? "bg-gray-200 text-gray-400 cursor-not-allowed"
                      : "bg-gray-200 text-gray-700 hover:bg-gray-100"} flex items-center justify-center transition-colors`}>
                  <div className="flex items-center justify-center w-5 h-5">
                    <Icons.Plus />
                  </div>
                </button>
              </div>
            </div>

            // fee amount
            <div className="w-full flex flex-col items-center pt-2">
              <div className="text-sm font-medium text-gray-600 text-center uppercase tracking-wider">
                {React.string("Cost")}
              </div>
              <div className="py-1 min-w-[180px] text-center">
                {if isCalculatingFee {
                  <div className="flex items-center justify-center gap-2 h-12">
                    <Icons.Spinner className="w-6 h-6 text-gray-600" />
                    <span className="text-gray-500 font-medium"> {React.string("Calculating...")} </span>
                  </div>
                } else {
                  <div className="flex flex-col items-center">
                    <div className="text-3xl font-bold text-gray-900">
                      {React.string(`${fee.feeAmount->Float.toFixed}`)}
                    </div>
                    <div className="text-xs text-gray-500 mt-1">
                      {React.string("Paid in RING tokens on Darwinia network")}
                    </div>
                  </div>
                }}
              </div>
            </div>
          </div>
        </div>

        <div className="mt-2">
          {if !isWalletConnected {
            <button
              onClick={_ => handleConnectWallet()}
              className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2">
              <span>{React.string("Connect Wallet")}</span>
            </button>
          } else {
            <button
              onClick={_ => handleClick(~years=fee.years)}
              disabled={isCalculatingFee || isWaitingForConfirmation}
              className={`w-full py-4 px-6 ${isCalculatingFee || isWaitingForConfirmation
                  ? "bg-zinc-400 cursor-not-allowed"
                  : "bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900"} text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2`}>
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

        // {if isWaitingForConfirmation {
        //   <div className="mt-4 p-4 bg-blue-50 rounded-lg border border-blue-100">
        //     <div className="flex items-start gap-3">
        //       <div className="text-blue-500 mt-0.5">
        //         <Icons.Spinner className="w-5 h-5" />
        //       </div>
        //       <div>
        //         <p className="text-sm text-blue-800 font-medium">
        //           {React.string("Transaction in progress")}
        //         </p>
        //         <p className="text-xs text-blue-600 mt-1">
        //           {React.string("Please wait while your transaction is being processed. This may take a moment.")}
        //         </p>
        //       </div>
        //     </div>
        //   </div>
        // } else {
        //   React.null
        // }}
      </div>
    </div>
  </div>
}
