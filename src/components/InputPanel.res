type state = {
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: option<bool>,
}

let initialState = {
  value: "",
  isValid: false,
  errorMessage: None,
  isChecking: false,
  isAvailable: None,
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
let make = (~onNext: string => unit) => {
  let (state, setState) = React.useState(_ => initialState)
  let timeoutRef = React.useRef(None)

  let checkNameAvailability = async value => {
    setState(prev => {...prev, isChecking: true, isAvailable: None})
    try {
      let available = await OnChainOperations.available(value)
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
  }

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
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
                  onClick={_ => onNext(state.value)}
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
}
