type state = {
  value: string,
  isValid: bool,
  errorMessage: option<string>,
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
let make = (~onValidChange: (string, bool) => unit) => {
  let (state, setState) = React.useState(_ => {
    value: "",
    isValid: false,
    errorMessage: None,
  })

  let timeoutRef = React.useRef(None)

  let runValidation = value => {
    let (isValid, errorMessage) = isValidSubname(value)
    setState(prev => {...prev, isValid, errorMessage})
    onValidChange(value, isValid)
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
    setState(_ => {
      value: "",
      isValid: false,
      errorMessage: None,
    })
    onValidChange("", false)
  }

  <div className="w-full max-w-xl mx-auto">
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
              type_="button"
            >
              <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                <path 
                  d="M18 6L6 18M6 6L18 18" 
                  stroke="#999999" 
                  strokeWidth="2" 
                  strokeLinecap="round" 
                  strokeLinejoin="round"
                />
              </svg>
            </button>
          } else {
            React.null
          }}
          {if state.value == "" {
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path 
                d="M21 21L16.5 16.5M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z" 
                stroke="#999999" 
                strokeWidth="2" 
                strokeLinecap="round" 
                strokeLinejoin="round"
              />
            </svg>
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
                {React.string(state.value)}
              </p>
              <button
                type_="button"
                className="rounded-xl bg-blue-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-blue-500">
                {React.string("Register")}
              </button>
            </div>
          </div>
        } else {
          React.null
        }
      }}
    </div>
  </div>
}
