type feeState = {
  years: int,
  feeAmount: string,
}

@react.component
let make = (
  ~name: string,
  ~onBack: unit => unit,
  ~isWalletConnected: bool,
  ~onConnectWallet: unit => unit,
  ~onRegister: (~years: int) => unit,
  ~isRegistering: bool,
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

  <div className="p-6">
    <div className="flex justify-between items-center mb-6">
      <div className="flex items-center gap-2">
        <button
          onClick={_ => onBack()}
          className="p-1 hover:bg-gray-100 rounded-full transition-colors"
          type_="button">
          <Icons.Back />
        </button>
        <span className="text-lg font-medium text-gray-700">
          {React.string(`${name}.${Constants.sld}`)}
        </span>
      </div>
    </div>

    <div className="flex justify-between items-center mb-4">
      <div className="text-lg font-medium">{React.string("CLAIM FOR")}</div>
      <div className="text-lg font-medium">{React.string("AMOUNT")}</div>
    </div>
    
    <div className="flex justify-between items-center">
      <div className="flex items-center gap-4">
        <button
          onClick={_ => decrementYears()}
          disabled={isCalculatingFee}
          className={`w-10 h-10 rounded-full ${isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"} flex items-center justify-center`}>
          {React.string("-")}
        </button>
        
        <div className="text-3xl font-bold">
          {React.string(`${fee.years->Int.toString} year${fee.years > 1 ? "s" : ""}`)}
        </div>
        
        <button
          onClick={_ => incrementYears()}
          disabled={isCalculatingFee}
          className={`w-10 h-10 rounded-full ${isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"} flex items-center justify-center`}>
          {React.string("+")}
        </button>
      </div>

      <div className="text-3xl font-bold">
        {if isCalculatingFee {
          <Icons.Spinner className="w-8 h-8 text-zinc-600" />
        } else {
          React.string(`${fee.feeAmount} RING`)
        }}
      </div>
    </div>

    <div className="mt-6">
      {if !isWalletConnected {
        <button
          onClick={_ => onConnectWallet()}
          className="w-full py-3 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-2xl font-medium">
          {React.string("Connect wallet")}
        </button>
      } else {
        <button
          onClick={_ => onRegister(~years=fee.years)}
          disabled={isCalculatingFee || isRegistering}
          className={`w-full py-3 px-4 ${
            isCalculatingFee || isRegistering 
              ? "bg-zinc-400" 
              : "bg-zinc-800 hover:bg-zinc-700"
          } text-white rounded-2xl font-medium`}>
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