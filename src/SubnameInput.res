// Add these Viem bindings at the top of your file
type publicClient
type address = string
type abi
type hash

@module("viem") external createPublicClient: 'a => publicClient = "createPublicClient"
@module("viem") external http: string => 'transport = "http"
@module("viem") external koi: 'chain = "koi"

// Contract interaction bindings
type readContractParams = {
  address: address,
  abi: abi,
  functionName: string,
  args: array<string>,
}

@send external readContract: (publicClient, readContractParams) => promise<bool> = "readContract"

// Contract configuration
let contractConfig = {
  address: %raw(`process.env.VITE_REGISTRY_ADDR`),
  abi: [
    {
      "inputs": [{"name": "name", "type": "string"}],
      "name": "available",
      "outputs": [{"name": "", "type": "bool"}],
      "stateMutability": "view",
      "type": "function"
    }
  ]
}

// Initialize Viem client
let publicClient = createPublicClient({
  "chain": koi,
  "transport": http(%raw(`process.env.VITE_RPC_URL`))
})

// Update the checkAvailability function
let checkAvailability = (name: string): promise<bool> => {
  try {
    readContract(
      publicClient,
      {
        address: contractConfig.address,
        abi: contractConfig.abi,
        functionName: "available",
        args: [name],
      }
    )
  } catch {
  | err => {
      Js.Console.error2("Error checking availability:", err)
      Js.Promise.reject(err)
    }
  }
}

type state = {
  value: string,
  isValid: bool,
  errorMessage: option<string>,
  isChecking: bool,
  isAvailable: option<bool>,
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
    isChecking: false,
    isAvailable: None,
  })

  let timeoutRef = React.useRef(None)

  let checkNameAvailability = async value => {
    setState(prev => {...prev, isChecking: true, isAvailable: None})
    try {
      let available = await checkAvailability(value)
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
    setState(_ => {
      value: "",
      isValid: false,
      errorMessage: None,
      isChecking: false,
      isAvailable: None,
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
                {React.string(state.value ++ ".ringdao.eth")}
              </p>
              {if state.isChecking {
                <div className="animate-spin">
                  <svg
                    className="w-5 h-5 text-blue-600"
                    xmlns="http://www.w3.org/2000/svg"
                    fill="none"
                    viewBox="0 0 24 24">
                    <circle
                      className="opacity-25"
                      cx="12"
                      cy="12"
                      r="10"
                      stroke="currentColor"
                      strokeWidth="4"
                    />
                    <path
                      className="opacity-75"
                      fill="currentColor"
                      d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                    />
                  </svg>
                </div>
              } else {
                switch state.isAvailable {
                | Some(true) =>
                  <button
                    type_="button"
                    className="rounded-xl bg-blue-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-blue-500">
                    {React.string("Register")}
                  </button>
                | Some(false) =>
                  <span className="text-red-500 text-sm">
                    {React.string("Already registered")}
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
  </div>
}
