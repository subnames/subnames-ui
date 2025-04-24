open OnChainOperationsCommon
open Utils

type state = {
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: bool,
  owner: option<string>,
  expiryDate: option<Date.t>,
  isOwnedByUser: option<bool>,
  isFocused: bool
}

let initialState = {
  value: "",

  // validation
  isValid: false,
  errorMessage: None,

  // availability check
  isChecking: false,
  isAvailable: false,

  // ownership check if name is not available(registered)
  owner: None,
  expiryDate: None,
  isOwnedByUser: None,
  isFocused: false,
}

// Validation rules for ENS subnames
let isValidSubname = (name: string): (bool, option<string>) => {
  let length = String.length(name)

  if length == 0 {
    (false, None)
  } else if length < 3 {
    (false, Some("Name is too short"))
  } else if length > 32 {
    (false, Some("Name is too long"))
  } else {
    // Check if contains only allowed characters (letters, numbers, and hyphens)
    let validCharRegex = %re("/^[a-zA-Z0-9-]+$/")
    let isValidFormat = Js.Re.test_(validCharRegex, name)

    if !isValidFormat {
      (false, Some("Invalid characters"))
    } else if String.get(name, 0) == Some("-") || String.get(name, length - 1) == Some("-") {
      (false, Some("Cannot start or end with hyphen"))
    } else {
      (true, None)
    }
  }
}


let isOwnedByUser = async (owner: string) => {
  switch buildWalletClient() {
    | Some(walletClient) => {
      let user = await currentAddress(walletClient)
      user == owner
    }
    | None => 
      false
  }
}

@react.component
let make = (~onNext: (string, Types.action) => unit, ~isWalletConnected: bool, ~initialValue: string="") => {
  // Initialize state with the provided initialValue if any
  let initialStateWithValue = initialValue != "" ? {
    ...initialState,
    value: initialValue,
    isValid: true, // We assume it's valid since it was previously validated
  } : initialState
  
  let (state, setState) = React.useState(_ => initialStateWithValue)

  let checkNameAvailability = async value => {
    setState(prev => {...prev, isChecking: true, isAvailable: false, owner: None, expiryDate: None})
    try {
      let available = await Controller.available(value)
      if available {
        setState(prev => {
          ...prev,
          isChecking: false,
          isAvailable: true
        })
      } else {
         // If name is not available, check ownership and expiry
        let owner = await Registry.owner(value)
        let expiryInt = await BaseRegistrar.nameExpires(value)
        let isOwnedByUser = isWalletConnected ? Some(await isOwnedByUser(owner)) : None
        setState(prev => {
          ...prev,
          isChecking: false,
          isAvailable: false,
          owner: Some(owner),
          expiryDate: Some(timestampToDate(expiryInt)),
          isOwnedByUser: isOwnedByUser
        })
      }
    } catch {
    | e =>
      Console.error(e)
      setState(prev => {
        ...prev,
        isChecking: false,
        errorMessage: Some("Failed to check availability")
      })
    }
  }


  // Check availability on initial render if we have an initialValue
  React.useEffect0(() => {
    if initialValue != "" {
      checkNameAvailability(initialValue)->Promise.done
    }
    None
  })

  // Check availability when value or wallet connection changes
  React.useEffect2(() => {
    if state.value != "" && state.isValid {
      checkNameAvailability(state.value)->Promise.done
    }
    None
  }, (isWalletConnected, state.value))

  let runValidation = useDebounce(value => {
    let (isValid, errorMessage) = isValidSubname(value)
    setState(prev => {...prev, isValid, errorMessage})
    if isValid && value != "" {
      let _ = checkNameAvailability(value)
    }
  }, 500)

  let handleChange = event => {
    let newValue = ReactEvent.Form.target(event)["value"]
    setState(prev => {
      ...prev,
      value: newValue,
    })

    runValidation(newValue)
  }

  let handleClear = _ => {
    setState(_ => initialState)
  }

  let handleFocus = _ => {
    setState(prev => {...prev, isFocused: true})
  }

  let handleBlur = _ => {
    setState(prev => {...prev, isFocused: false})
  }

  <div className={`bg-white dark:bg-[#36383ab3] dark:border-[#ffffff14] dark:border rounded-custom ${state.isFocused ? "shadow-xl" : "shadow-lg"} overflow-hidden transition-shadow duration-200`}>
    <div
      className={`relative ${state.errorMessage->Option.isSome ||
          (state.isValid && state.value != "")
          ? "border-b border-zinc-200 dark:border-zinc-700"
          : ""}`}>
      <input
        type_="text"
        value={state.value}
        onChange={handleChange}
        onFocus={handleFocus}
        onBlur={handleBlur}
        placeholder="SEARCH FOR A NAME"
className="w-full px-6 py-4 text-lg focus:outline-none dark:bg-[#36383ab3] dark:hover:bg-[#36383ae6] dark:text-white dark:placeholder-zinc-400"
      />
      <div className="absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2">
        {if state.value != "" {
          <button
            onClick={handleClear}
            className="p-1 hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300 rounded-full transition-colors"
            type_="button">
            <Icons.Close />
          </button>
        } else {
          React.null
        }}
        {if state.value == "" {
          <div className="p-1 rounded-full transition-colors dark:text-zinc-400">
            <Icons.Search />
          </div>
        } else {
          React.null
        }}
      </div>
    </div>
    {switch state.errorMessage {
    | Some(error) =>
      <div className="px-6 py-4">
        <div className="text-gray-600 dark:text-zinc-400 text-md"> {React.string(error)} </div>
      </div>
    | None =>
      if state.isValid && state.value != "" {
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-800 dark:text-white"> {React.string(`${state.value}.${Constants.sld}`)} </p>
              {switch (state.owner, state.expiryDate, state.isOwnedByUser) {
              | (Some(_owner), Some(date), Some(true)) =>
                <p className="text-xs text-gray-400 dark:text-zinc-500 mt-1">
                  {React.string(`Your name will expire ${distanceToExpiry(date)}`)}
                </p>
              | (Some(owner), Some(_date), None | Some(false)) => {
                <p className="text-xs text-gray-400 dark:text-zinc-500 mt-1">
                  {React.string(
                    String.concatMany(
                      String.slice(owner, ~start=0, ~end=6), 
                      ["..", String.sliceToEnd(owner, ~start=38)]
                    )
                  )
                  }
                </p>
                }
              | _ => React.null
              }}
            </div>
            {if state.isChecking {
              <Icons.Spinner className="w-5 h-5 text-zinc-600" />
            } else {
              switch state.isAvailable {
              | true =>
                <button
                  onClick={_ => onNext(state.value, Types.Register)}
                  type_="button"
                  className="rounded-xl bg-zinc-800 dark:bg-zinc-700 px-3 py-1.5 text-sm font-medium text-white hover:bg-zinc-700 dark:hover:bg-zinc-600">
                  {React.string("Register")}
                </button>
              | false =>
                switch state.isOwnedByUser {
                | Some(true) =>
                  <div className="flex gap-2">
                    <button
                      onClick={_ => onNext(state.value, Types.Transfer)}
                      type_="button"
                      className="rounded-xl bg-white dark:bg-zinc-700 border border-zinc-300 dark:border-zinc-600 px-3 py-1.5 text-sm font-medium text-zinc-800 dark:text-white hover:bg-zinc-50 dark:hover:bg-zinc-600">
                      {React.string("Transfer")}
                    </button>
                    <button
                      onClick={_ => onNext(state.value, Types.Extend)}
                      type_="button"
                      className="rounded-xl bg-white dark:bg-zinc-700 border border-zinc-300 dark:border-zinc-600 px-3 py-1.5 text-sm font-medium text-zinc-800 dark:text-white hover:bg-zinc-50 dark:hover:bg-zinc-600">
                      {React.string("Extend")}
                    </button>
                  </div>
                | Some(false) | None =>
                  <span className="text-red-500 dark:text-red-400 text-sm"> {React.string("Not available")} </span>
                }
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
