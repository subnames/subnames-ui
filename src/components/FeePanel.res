type feeState = {
  years: int,
  feeAmount: string,
}

@react.component
let make = (
  ~name: string,
  ~isWalletConnected: bool,
  ~isRegistering: bool,
  ~onBack: unit => unit,
  ~onConnectWallet: unit => unit,
  ~onRegister: (~years: int) => unit,
) => {
  let (fee, setFee) = React.useState(_ => {
    years: 1,
    feeAmount: "0.1",
  })
  let (isCalculatingFee, setIsCalculatingFee) = React.useState(_ => false)

  let calculateFee = async years => {
    let priceInEth = await Fee.calculate(name, years)
    setFee(_ => {
      years: years,
      feeAmount: priceInEth,
    })
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

  <div className="p-4 sm:p-6 max-w-2xl mx-auto">
    <div className="flex justify-between items-center mb-8">
      <div className="flex items-center gap-3">
        <button
          onClick={_ => onBack()}
          className="p-2 hover:bg-gray-100 rounded-full transition-colors"
          type_="button">
          <div className="w-5 h-5 text-gray-600">
            <Icons.Back />
          </div>
        </button>
        <span className="text-lg sm:text-xl font-medium text-gray-700 truncate">
          {React.string(`${name}.${Constants.sld}`)}
        </span>
      </div>
    </div>

    <div className="flex flex-col sm:flex-row justify-between gap-6 mb-8">
      <div className="space-y-2">
        <div className="text-base sm:text-lg font-medium text-gray-600">
          {React.string("CLAIM FOR")}
        </div>
        <div className="flex items-center justify-center gap-4">
          <button
            onClick={_ => decrementYears()}
            disabled={isCalculatingFee}
            className={`w-12 h-12 rounded-full ${
              isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100 hover:bg-gray-200"
            } flex items-center justify-center transition-colors`}>
            <span className="text-xl font-medium text-gray-700">{React.string("-")}</span>
          </button>
          
          <div className="text-2xl sm:text-3xl font-bold text-gray-900 min-w-[120px] text-center">
            {React.string(`${fee.years->Int.toString} year${fee.years > 1 ? "s" : ""}`)}
          </div>
          
          <button
            onClick={_ => incrementYears()}
            disabled={isCalculatingFee}
            className={`w-12 h-12 rounded-full ${
              isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100 hover:bg-gray-200"
            } flex items-center justify-center transition-colors`}>
            <span className="text-xl font-medium text-gray-700">{React.string("+")}</span>
          </button>
        </div>
      </div>

      <div className="space-y-2">
        <div className="text-base sm:text-lg font-medium text-gray-600">
          {React.string("AMOUNT")}
        </div>
        <div className="text-2xl sm:text-3xl font-bold text-gray-900 h-12 flex items-center justify-center sm:justify-end">
          {if isCalculatingFee {
            <Icons.Spinner className="w-8 h-8 text-zinc-600" />
          } else {
            React.string(`${fee.feeAmount} RING`)
          }}
        </div>
      </div>
    </div>

    <div className="mt-8">
      {if !isWalletConnected {
        <button
          onClick={_ => onConnectWallet()}
          className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md">
          {React.string("Connect wallet")}
        </button>
      } else {
        <button
          onClick={_ => onRegister(~years=fee.years)}
          disabled={isCalculatingFee || isRegistering}
          className={`w-full py-4 px-6 ${
            isCalculatingFee || isRegistering 
              ? "bg-zinc-400 cursor-not-allowed" 
              : "bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900"
          } text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md`}>
          {if isRegistering {
            React.string("Registering...")
          } else if isCalculatingFee {
            React.string("Calculating...")
          } else {
            React.string("Register name")
          }}
        </button>
      }}
    </div>
  </div>
} 