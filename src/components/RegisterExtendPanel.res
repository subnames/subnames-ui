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
  ~buttonType: [#back | #close]=#back,
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
    }
  }

  let handleConnectWallet = () => {
    let connectButton = document->querySelector("[data-testid='rk-connect-button']")
    connectButton->click
  }

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-4 sm:p-6 max-w-2xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center justify-center gap-3">
          {switch buttonType {
          | #back => 
            <button
              onClick={_ => onBack()}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors"
              type_="button">
              <div className="w-6 h-6 text-gray-600">
                <Icons.Back />
              </div>
            </button>
          | #close => React.null
          }}
          <span className="text-lg sm:text-xl font-medium text-gray-700 truncate">
            {React.string(`${name}.${Constants.sld}`)}
          </span>
        </div>
        {switch buttonType {
        | #close => 
          <button
            onClick={_ => onBack()}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            type_="button">
            <div className="w-6 h-6 text-gray-600">
              <Icons.Close />
            </div>
          </button>
        | #back => React.null
        }}
      </div>
      <div className="flex flex-col sm:flex-row justify-between gap-6 mb-8">
        <div className="space-y-2">
          <div className="text-base sm:text-lg font-medium text-gray-600 text-center sm:text-left">
            {switch action {
            | Types.Register => React.string("CLAIM FOR")
            | Types.Extend => React.string("EXTEND FOR")
            }}
          </div>
          <div className="flex items-center justify-center gap-4">
            <button
              onClick={_ => decrementYears()}
              disabled={isCalculatingFee}
              className={`w-12 h-12 rounded-full ${isCalculatingFee
                  ? "bg-gray-50 cursor-not-allowed"
                  : "bg-gray-100 hover:bg-gray-200"} flex items-center justify-center transition-colors`}>
              <span className="text-xl font-medium text-gray-700"> {React.string("-")} </span>
            </button>
            <div className="text-2xl sm:text-3xl font-bold text-gray-900 min-w-[120px] text-center">
              {React.string(`${fee.years->Int.toString} year${fee.years > 1 ? "s" : ""}`)}
            </div>
            <button
              onClick={_ => incrementYears()}
              disabled={isCalculatingFee}
              className={`w-12 h-12 rounded-full ${isCalculatingFee
                  ? "bg-gray-50 cursor-not-allowed"
                  : "bg-gray-100 hover:bg-gray-200"} flex items-center justify-center transition-colors`}>
              <span className="text-xl font-medium text-gray-700"> {React.string("+")} </span>
            </button>
          </div>
        </div>
        <div className="space-y-2">
          <div className="text-base sm:text-lg font-medium text-gray-600 text-center sm:text-right">
            {React.string("AMOUNT")}
          </div>
          <div
            className="text-2xl sm:text-3xl font-bold text-gray-900 h-12 flex items-center justify-center sm:justify-end">
            {if isCalculatingFee {
              <Icons.Spinner className="w-8 h-8 text-zinc-600" />
            } else {
              React.string(`${fee.feeAmount->Float.toExponential(~digits=2)} RING`)
            }}
          </div>
        </div>
      </div>
      <div className="mt-8">
        {if !isWalletConnected {
          <button
            onClick={_ => handleConnectWallet()}
            className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md">
            {React.string("Connect Wallet")}
          </button>
        } else {
          <button
            onClick={_ => handleClick(~years=fee.years)}
            disabled={isCalculatingFee || isWaitingForConfirmation}
            className={`w-full py-4 px-6 ${isCalculatingFee || isWaitingForConfirmation 
                ? "bg-zinc-400 cursor-not-allowed"
                : "bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900"} text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md`}>
            {if isWaitingForConfirmation {
              switch action {
              | Types.Register => React.string("Registering...")
              | Types.Extend => React.string("Extending...")
              }
            } else if isCalculatingFee {
              React.string("Calculating...")
            } else {
              switch action {
              | Types.Register => React.string("Register")
              | Types.Extend => React.string("Extend")
              }
            }}
          </button>
        }}
      </div>
    </div>
  </div>
}
