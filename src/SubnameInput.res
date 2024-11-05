open OnChainOperations

type state = {
  name: string,
  isRegistering: bool,
  onChainStatus: OnChainOperations.transactionStatus,
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: option<bool>,
  showFeeSelect: bool,
  showResultPanel: bool,
  registeredName: option<string>,
}

let initialState = {
  name: "",
  isRegistering: false,
  onChainStatus: Simulating,
  value: "",
  isValid: false,
  errorMessage: None,
  isChecking: false,
  isAvailable: None,
  showFeeSelect: false,
  showResultPanel: false,
  registeredName: None,
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
  let {updateName, setUpdateName} = NameContext.use()
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

  let handleOnChainStatusChange = (status: transactionStatus) => {
    setState(prev => {...prev, onChainStatus: status})
  }

  let handleRegister = (~years: int) => {
    setState(prev => {...prev, isRegistering: true})
    let walletClient = OnChainOperations.buildWalletClient()
    let _ = OnChainOperations.register(
      walletClient->Option.getUnsafe,
      state.value,
      years,
      None,
      handleOnChainStatusChange,
    )->Promise.then(_ => {
      setState(prev => {
        ...initialState,
        showResultPanel: true,
        registeredName: Some(state.value),
      })
      onValidChange("", false)
      setUpdateName(_ => true)
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
    {if state.showResultPanel {
      // Result panel
      <div className="bg-white rounded-custom shadow-lg overflow-hidden">
        <div className="p-6">
          <div className="flex flex-col items-center text-center">
            <div className="mb-4">
              <Icons.Success className="w-16 h-16 text-green-500" />
            </div>
            <h2 className="text-2xl font-bold mb-2">
              {React.string("Registration Successful!")}
            </h2>
            <p className="text-lg text-gray-700 mb-6">
              <Confetti recycle=false />
              {React.string(`${state.registeredName->Option.getOr("")}.${Constants.sld}`)}
            </p>
            <button
              onClick={_ => setState(_ => initialState)}
              className="py-3 px-6 bg-zinc-800 hover:bg-zinc-700 text-white rounded-2xl font-medium">
              {React.string("Register Another Name")}
            </button>
          </div>
        </div>
      </div>
    } else if !state.showFeeSelect {
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
                      onClick={_ => setState(prev => {...prev, showFeeSelect: true})}
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
      <div className={`bg-white rounded-custom shadow-lg overflow-hidden`}>
        <FeePanel
          name={state.value}
          onBack={() => setState(prev => {...prev, showFeeSelect: false})}
          isWalletConnected
          onConnectWallet
          onRegister={handleRegister}
          isRegistering={state.isRegistering}
        />
      </div>
    }}
  </div>
}
