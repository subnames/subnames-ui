open OnChainOperations
open Utils

type state = {
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: option<bool>,
  isOwnedByUser: option<bool>,
  expiryDate: option<Date.t>,
}

let initialState = {
  value: "",
  isValid: false,
  errorMessage: None,
  isChecking: false,
  isAvailable: None,
  isOwnedByUser: None,
  expiryDate: None,
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

let isOwner: (string, bool) => promise<option<bool>> = async (name, isWalletConnected) => {
  switch isWalletConnected {
  | true =>
    switch buildWalletClient() {
    | Some(walletClient) =>
      let owner = await owner(name)
      let currentAccount = await currentAddress(walletClient)
      Some(owner == currentAccount)
    | None => None
    }
  | false => None
  }
}

@module("date-fns")
external addDays: (Date.t, int) => Date.t = "addDays"

@module("date-fns")
external formatDistanceToNow: (Date.t, {"addSuffix": bool}) => string = "formatDistanceToNow"

let distanceToExpiry: Date.t => string = date => {
  formatDistanceToNow(date, {"addSuffix": true})
}


@react.component
let make = (~onNext: (string, Types.action) => unit, ~isWalletConnected: bool) => {
  let (state, setState) = React.useState(_ => initialState)

  let checkNameAvailability = async value => {
    setState(prev => {...prev, isChecking: true, isAvailable: None, isOwnedByUser: None, expiryDate: None})
    try {
      let available = await OnChainOperations.available(value)
      if !available {
        // If name is not available, check ownership and expiry
        let isOwner = await isOwner(value, isWalletConnected)
        let expiryInt = await OnChainOperations.nameExpires(value)
        let expiry = Int.toFloat(expiryInt) *. 1000.0
        setState(prev => {
          ...prev,
          isChecking: false,
          isAvailable: Some(false),
          isOwnedByUser: isOwner,
          expiryDate: Some(Date.fromTime(expiry)),
        })
      } else {
        setState(prev => {
          ...prev,
          isChecking: false,
          isAvailable: Some(true),
          isOwnedByUser: None,
          expiryDate: None,
        })
      }
    } catch {
    | e =>
      Console.error(e)
      setState(prev => {
        ...prev,
        isChecking: false,
        errorMessage: Some("Failed to check availability"),
        isOwnedByUser: None,
        expiryDate: None,
      })
    }
  }

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

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div
      className={`relative ${state.errorMessage->Option.isSome ||
          (state.isValid && state.value != "")
          ? "divide-y-short"
          : ""}`}>
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
        <div className="text-gray-600 text-md"> {React.string(error)} </div>
      </div>
    | None =>
      if state.isValid && state.value != "" {
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-gray-700"> {React.string(`${state.value}.${Constants.sld}`)} </p>
              {switch (state.isOwnedByUser, state.expiryDate) {
              | (Some(true), Some(date)) =>
                <p className="text-sm text-gray-500 mt-1">
                  {React.string(`Your name will expire ${distanceToExpiry(date)}`)}
                </p>
              | _ => React.null
              }}
            </div>
            {if state.isChecking {
              <Icons.Spinner className="w-5 h-5 text-zinc-600" />
            } else {
              switch state.isAvailable {
              | Some(true) =>
                <button
                  onClick={_ => onNext(state.value, Types.Register)}
                  type_="button"
                  className="rounded-xl bg-zinc-800 px-3 py-1.5 text-sm font-medium text-white hover:bg-zinc-700">
                  {React.string("Register")}
                </button>
              | Some(false) =>
                switch state.isOwnedByUser {
                | Some(true) =>
                  <div className="flex gap-2">
                    <button
                      type_="button"
                      className="rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50">
                      {React.string("Transfer")}
                    </button>
                    <button
                      onClick={_ => onNext(state.value, Types.Extend(state.expiryDate->Option.getUnsafe))}
                      type_="button"
                      className="rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50">
                      {React.string("Extend")}
                    </button>
                  </div>
                | Some(false) | None =>
                  <span className="text-red-500 text-sm"> {React.string("Not available")} </span>
                }
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
