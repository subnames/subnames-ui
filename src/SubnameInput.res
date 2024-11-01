open OnChainOperations

type feeState = {
  years: int,
  feeAmount: string,
}

type state = {
  name: string,
  years: int,
  isRegistering: bool,
  onChainStatus: OnChainOperations.transactionStatus,
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: option<bool>,
  showFeeSelect: bool,
  fee: feeState,
  isCalculatingFee: bool,
}

let initialState = {
  name: "",
  years: 1,
  isRegistering: false,
  onChainStatus: Simulating,
  value: "",
  isValid: false,
  errorMessage: None,
  isChecking: false,
  isAvailable: None,
  showFeeSelect: false,
  fee: {
    years: 1,
    feeAmount: "0.1",
  },
  isCalculatingFee: false,
}

// Validation rules for ENS subnames
let isValidSubname = (name: string): (bool, option<string>) => {
  let length = String.length(name)
  
  if (length == 0) {
    (false, None)
  } else if (length < 3) {
    (false, Some("Name is too short"))
  } else if (length > 32) {
    (false, Some("Name is too long"))
  } else {
    // Check if contains only allowed characters (letters, numbers, and hyphens)
    let validCharRegex = %re("/^[a-zA-Z0-9-]+$/")
    let isValidFormat = Js.Re.test_(validCharRegex, name)
    
    if (!isValidFormat) {
      (false, Some("Invalid characters"))
    } else if (String.get(name, 0) == Some("-") || String.get(name, length - 1) == Some("-")) {
      (false, Some("Cannot start or end with hyphen"))
    } else {
      (true, None)
    }
  }
}

@react.component
let make = (~onValidChange: (string, bool) => unit, ~isWalletConnected: bool, ~onConnectWallet: unit => unit) => {
  let (state, setState) = React.useState(_ => initialState)

  let timeoutRef = React.useRef(None)

  let checkNameAvailability = async value => {
    setState(prev => {...prev, isChecking: true, isAvailable: None})
    try {
      let available = await available(value)
      Console.log(available)
      setState(prev => {...prev, isChecking: false, isAvailable: Some(available)})
    } catch {
    | _ =>
      setState(prev => {
        ...prev,
        isChecking: false,
        errorMessage: Some("Failed to check availability"),
      })
    }
  }

  let runValidation = value => {
    let (isValid, errorMessage) = isValidSubname(value)
    setState(prev => {...prev, isValid, errorMessage})
    onValidChange(value, isValid)
    if isValid && value != "" {
      let _ = checkNameAvailability(value)
    }
    ()
  }

  let handleChange = event => {
    let newValue = ReactEvent.Form.target(event)["value"]
    setState(prev => {...prev, value: newValue})

    switch timeoutRef.current {
    | Some(timeout) => Js.Global.clearTimeout(timeout)
    | None => ()
    }

    let timeout = Js.Global.setTimeout(() => {
      runValidation(newValue)
    }, 500)

    timeoutRef.current = Some(timeout)
  }

  let handleClear = _ => {
    setState(_ => initialState)
    onValidChange("", false)
  }

  let calculateFee = async years => {
    let priceInEth = await Fee.calculate(state.value, years)
    setState(prev => {
      ...prev,
      fee: {
        years: years,
        feeAmount: priceInEth,
      },
    })
  }

  let incrementYears = () => {
    if !state.isCalculatingFee {
      let newYears = state.fee.years + 1
      setState(prev => {...prev, isCalculatingFee: true})
      let _ = calculateFee(newYears)->Promise.then(_ => {
        setState(prev => {...prev, isCalculatingFee: false})
        Promise.resolve()
      })
    }
  }

  let decrementYears = () => {
    if !state.isCalculatingFee && state.fee.years > 1 {
      let newYears = state.fee.years - 1
      setState(prev => {...prev, isCalculatingFee: true})
      let _ = calculateFee(newYears)->Promise.then(_ => {
        setState(prev => {...prev, isCalculatingFee: false})
        Promise.resolve()
      })
    }
  }

  let handleNextClick = () => {
    setState(prev => {
      ...prev, 
      showFeeSelect: true,
      isCalculatingFee: true // Set to true immediately when opening the panel
    })
    // Calculate initial fee for 1 year
    let _ = calculateFee(1)->Promise.then(_ => {
      setState(prev => {...prev, isCalculatingFee: false})
      Promise.resolve()
    })
  }

  let handleOnChainStatusChange = (status: transactionStatus) => {
    setState(prev => {...prev, onChainStatus: status})
  }

  let handleRegister = () => {
    setState(prev => {...prev, isRegistering: true})
    let _ = OnChainOperations.register(
      state.value,
      state.fee.years,
      None,
      handleOnChainStatusChange,
    )->Promise.then(_ => {
      setState(_ => initialState)
      onValidChange("", false)
      Promise.resolve()
    })
  }

  let statusMessage = switch state.onChainStatus {
    | Simulating => "Preparing transaction..."
    | WaitingForSignature => "Please sign the transaction in your wallet"
    | Broadcasting => "Broadcasting transaction..."
    | Confirmed => "Registration successful!"
    | Failed(error) => `Registration failed: ${error}`
  }

  <div className="w-full max-w-xl mx-auto">
    {if !state.showFeeSelect {
      // Input panel
      <div className={`bg-white rounded-custom shadow-lg overflow-hidden`}>
        <div className={`relative ${state.errorMessage->Option.isSome || (state.isValid && state.value != "") ? "divide-y-short" : ""}`}>
          <input
            type_="text"
            value={state.value}
            onChange={handleChange}
            placeholder="SEARCH FOR A NAME"
            className="w-full px-6 py-4 text-lg focus:outline-none"
          />
          <div className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2">
            {if state.value != "" {
              <button
                onClick={handleClear}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors"
                type_="button">
                <Icons.Close />
              </button>
            } else {
              React.null
            }}
            {if state.value == "" {
              <Icons.Search />
            } else {
              React.null
            }}
          </div>
        </div>
        
        {switch state.errorMessage {
        | Some(error) =>
          <div className="px-6 py-4">
            <div className="text-gray-600 text-md">
              {React.string(error)}
            </div>
          </div>
        | None => 
          if state.isValid && state.value != "" {
            <div className="px-6 py-4">
              <div className="flex items-center justify-between">
                <p className="text-gray-700">
                  {React.string(`${state.value}.${Constants.sld}`)}
                </p>
                {if state.isChecking {
                  <Icons.Spinner className="w-5 h-5 text-zinc-600" />
                } else {
                  switch state.isAvailable {
                  | Some(true) =>
                    <button
                      onClick={_ => handleNextClick()}
                      type_="button"
                      className="rounded-xl bg-zinc-800 px-3 py-1.5 text-sm font-medium text-white hover:bg-zinc-700">
                      {React.string("Next")}
                    </button>
                  | Some(false) =>
                    <span className="text-red-500 text-sm">
                      {React.string("Not available")}
                    </span>
                  | None => React.null
                  }
                }}
              </div>
            </div>
          } else {
            React.null
          }
        }}
      </div>
    } else {
      // Fee panel
      <div className={`bg-white rounded-custom shadow-lg overflow-hidden`}>
        <div className="p-6">
          <div className="flex justify-between items-center mb-6">
            <div className="flex items-center gap-2">
              <button
                onClick={_ => setState(prev => {...prev, showFeeSelect: false})}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors"
                type_="button">
                <Icons.Back />
              </button>
              <span className="text-lg font-medium text-gray-700">
                {React.string(`${state.value}.${Constants.sld}`)}
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
                disabled={state.isCalculatingFee}
                className={`w-10 h-10 rounded-full ${state.isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"} flex items-center justify-center`}>
                {React.string("-")}
              </button>
              
              <div className="text-3xl font-bold">
                {React.string(`${state.fee.years->Int.toString} year${state.fee.years > 1 ? "s" : ""}`)}
              </div>
              
              <button
                onClick={_ => incrementYears()}
                disabled={state.isCalculatingFee}
                className={`w-10 h-10 rounded-full ${state.isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"} flex items-center justify-center`}>
                {React.string("+")}
              </button>
            </div>

            <div className="text-3xl font-bold">
              {if state.isCalculatingFee {
                <Icons.Spinner className="w-8 h-8 text-zinc-600" />
              } else {
                React.string(`${state.fee.feeAmount} RING`)
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
                onClick={_ => handleRegister()}
                disabled={state.isCalculatingFee || state.isRegistering}
                className={`w-full py-3 px-4 ${
                  state.isCalculatingFee || state.isRegistering 
                    ? "bg-zinc-400" 
                    : "bg-zinc-800 hover:bg-zinc-700"
                } text-white rounded-2xl font-medium`}>
                {if state.isRegistering {
                  React.string("Registering...")
                } else if state.isCalculatingFee {
                  React.string("Calculating...")
                } else {
                  React.string("Register name")
                }}
              </button>
            }}
          </div>
        </div>
      </div>
    }}
  </div>
}
