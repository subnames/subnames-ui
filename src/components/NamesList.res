open Utils
open ReverseRegistrar
open OnChainOperationsCommon

type document
type event = ReactEvent.Mouse.t
@val external doc: document = "document"
@send external getElementById: (document, string) => Dom.element = "getElementById"
@send external addEventListener: (document, string, event => unit) => unit = "addEventListener"
@send
external removeEventListener: (document, string, event => unit) => unit = "removeEventListener"

@get external target: ReactEvent.Mouse.t => Dom.element = "target"
@send external contains: (Dom.element, Dom.element) => bool = "contains"

module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

// Define the types for our GraphQL response
type owner = {id: string}
type subname = {
  label: string,
  name: string,
  expires: int,
  owner: owner,
}
type queryResponse = {subnames: array<subname>}

@react.component
let make = () => {
  let account = UseAccount.use()
  let {setForceRefresh, primaryName} = NameContext.use()
  let (names, setNames) = React.useState(() => [])
  let (loading, setLoading) = React.useState(() => true)
  let (activeDropdown, setActiveDropdown) = React.useState(() => None)
  let (settingPrimaryName, setSettingPrimaryName) = React.useState(() => false)
  let (showExtendPanel, setShowExtendPanel) = React.useState(() => None)
  let (showTransferPanel, setShowTransferPanel) = React.useState(() => None)
  let dropdownRef = React.useRef(Nullable.null)

  // Add effect for handling clicks outside dropdown
  React.useEffect1(() => {
    let handleClickOutside = event => {
      dropdownRef.current
      ->Nullable.toOption
      ->Option.map(dropdownEl => {
        let targetEl = event->target
        if !(dropdownEl->contains(targetEl)) {
          setActiveDropdown(_ => None)
        }
      })
      ->ignore
    }

    doc->addEventListener("mousedown", handleClickOutside)
    Some(() => doc->removeEventListener("mousedown", handleClickOutside))
  }, [activeDropdown])

  // Redirect to home if disconnected
  React.useEffect1(() => {
    if !account.isConnected {
      RescriptReactRouter.push(Router.toUrl(Router.Home))
    }
    None
  }, [account.isConnected])

  let setPrimary = async name => {
    setSettingPrimaryName(_ => true)

    try {
      let walletClient = buildWalletClient()->Option.getExn(~message="Wallet connection failed")

      await setNameForAddr(walletClient, name)
      setForceRefresh(_ => true)
    } catch {
    | Exn.Error(obj) =>
      switch Exn.message(obj) {
      | Some(message) if message->Js.String2.includes("User rejected the request") =>
        Console.log("User rejected the transaction")
      | Some(message) => Console.log(message)
      | None => ()
      }
    }

    setSettingPrimaryName(_ => false)
  }

  let handleExtendSuccess = (_: Types.actionResult) => {
    // Refresh the names list
    setForceRefresh(_ => true)
    setShowExtendPanel(_ => None)
  }

  let handleTransferSuccess = (_: Types.actionResult) => {
    // Refresh the names list
    setForceRefresh(_ => true)
    setShowTransferPanel(_ => None)
  }

  let buildSubname = subnameObj => {
    subnameObj
    ->JSON.Decode.object
    ->Option.map(obj => {
      let label = getString(obj, "label")
      let name = getString(obj, "name")
      let expires = getString(obj, "expires")->Int.fromString->Option.getExn
      let owner: owner = getObject(obj, "owner", ownerObj => {id: getString(ownerObj, "id")})

      {label, name, expires, owner}
    })
    ->Option.getExn
  }

  let buildSubnames = subnameObjs => {
    let result = subnameObjs->Array.map(buildSubname)

    primaryName
    ->Option.map(c => {
      {
        label: c.name,
        name: c.name,
        expires: c.expires,
        owner: {id: account.address->Option.getExn},
      }
    })
    ->Option.map(current => {
      if result->Array.findIndex(subname => subname.name == current.name) == -1 {
        result->Array.push(current)
      }
      result
    })
    ->ignore

    result->Array.sort((a, b) => float(a.expires - b.expires))

    result
  }

  React.useEffect1(() => {
    if account.isConnected {
      let fetchNames = async () => {
        let address =
          account.address
          ->Option.map(String.toLowerCase)
          ->Option.getExn(~message="No address found")

        let query = `
          query {
            subnames(limit: 20, where: {
              owner: {id_eq: "${address}"}
              resolvedTo: {id_eq: "${address}"}
            }) {
              label
              name
              expires
              owner {
                id
              }
              reverseResolvedFrom {
                id
              }
            }
          }
        `

        Console.log(query)
        let result = await GraphQLClient.makeRequest(~endpoint=Constants.indexerUrl, ~query, ())

        switch result {
        | {data: Some(data), errors: None} => {
            let subnames: array<subname> = getArray(data, "subnames", buildSubnames)
            setNames(_ => subnames)
          }
        | {errors: Some(errors)} => Console.log2("Errors:", errors)
        | _ => Console.log("Unknown response")
        }
        setLoading(_ => false)
      }
      fetchNames()->ignore
    }
    None
  }, [account.isConnected])

  <>
    <div className="p-8">
      <div className="w-full max-w-xl mx-auto">
        {switch (showExtendPanel, showTransferPanel) {
        | (Some(name), _) =>
          <RegisterExtendPanel
            name
            isWalletConnected=account.isConnected
            onBack={() => setShowExtendPanel(_ => None)}
            onSuccess=handleExtendSuccess
            action={Types.Extend}
          />
        | (_, Some(name)) =>
          <TransferPanel
            name
            isWalletConnected=account.isConnected
            onBack={() => setShowTransferPanel(_ => None)}
            onSuccess=handleTransferSuccess
          />
        | (None, None) =>
          <div className="bg-white rounded-custom shadow-lg">
            <div className="p-8 py-6 border-b border-gray-200 relative">
              <h1 className="text-3xl font-bold text-gray-900">
                {React.string("Your Subnames")}
              </h1>
              <div className="text-sm text-gray-500">
                {React.string("It may take a while to sync your subnames. ")}
              </div>
              <button
                onClick={_ => RescriptReactRouter.push("/")}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors absolute right-8 top-1/2 -translate-y-1/2">
                <Icons.Close />
              </button>
            </div>
            {if !account.isConnected {
              <div className="text-center py-4 text-gray-500">
                {React.string("Please connect your wallet to see your names")}
              </div>
            } else if loading {
              <div className="flex justify-center items-center py-4">
                <Icons.Spinner className="w-5 h-5 text-zinc-600" />
              </div>
            } else if names->Array.length == 0 {
              <div className="text-center py-4 text-gray-500">
                {React.string("You don't have any subnames yet")}
              </div>
            } else {
              <div>
                <div>
                  {switch primaryName {
                  | None =>
                    <div className="px-8 py-4 bg-yellow-50 border-b border-gray-200">
                      <div className="flex items-center gap-3">
                        <div className="text-yellow-700">
                          <svg
                            xmlns="http://www.w3.org/2000/svg"
                            viewBox="0 0 24 24"
                            fill="currentColor"
                            className="w-5 h-5">
                            <path
                              fillRule="evenodd"
                              d="M9.401 3.003c1.155-2 4.043-2 5.197 0l7.355 12.748c1.154 2-.29 4.5-2.599 4.5H4.645c-2.309 0-3.752-2.5-2.598-4.5L9.4 3.003zM12 8.25a.75.75 0 01.75.75v3.75a.75.75 0 01-1.5 0V9a.75.75 0 01.75-.75zm0 8.25a.75.75 0 100-1.5.75.75 0 000 1.5z"
                              clipRule="evenodd"
                            />
                          </svg>
                        </div>
                        <div className="text-sm text-yellow-700">
                          {React.string(
                            "You need to set a primary subname to enable transfers. Click 'Set primary' in the dropdown menu of any subname.",
                          )}
                        </div>
                      </div>
                    </div>
                  | Some(_) => React.null
                  }}
                </div>
                <div className="py-1">
                  {names
                  ->Array.mapWithIndex((subname, index) => {
                    <div key={subname.name}>
                      <div className="px-8 py-6">
                        <div className="flex items-center justify-between">
                          <div>
                            <div className="flex items-center gap-2">
                              <p className="text-gray-800">
                                {<>
                                  <span className="font-bold"> {React.string(subname.name)} </span>
                                  {React.string(`.${Constants.sld}`)}
                                </>}
                              </p>
                              {switch primaryName {
                              | Some({name}) if name == subname.name =>
                                <span
                                  className="px-2 py-0.5 text-xs bg-blue-100 text-blue-800 rounded-full font-medium">
                                  {React.string("Primary")}
                                </span>
                              | _ => React.null
                              }}
                            </div>
                            <p className="text-xs text-gray-400 mt-1">
                              {React.string(
                                `Expires ${distanceToExpiry(timestampToDate(subname.expires))}`,
                              )}
                            </p>
                          </div>
                          <div className="relative">
                            <button
                              type_="button"
                              onClick={_ => {
                                setActiveDropdown(current =>
                                  if current == Some(subname.name) {
                                    None
                                  } else {
                                    Some(subname.name)
                                  }
                                )
                              }}
                              className="p-2 rounded-lg hover:bg-gray-100 focus:outline-none">
                              <svg
                                className="w-5 h-5"
                                fill="none"
                                stroke="currentColor"
                                viewBox="0 0 24 24">
                                <path
                                  strokeLinecap="round"
                                  strokeLinejoin="round"
                                  strokeWidth="2"
                                  d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
                                />
                              </svg>
                            </button>
                            {if activeDropdown == Some(subname.name) {
                              <div
                                ref={ReactDOM.Ref.domRef(dropdownRef)}
                                className="absolute right-0 mt-2 w-48 rounded-lg shadow-xl bg-white/95 backdrop-blur-sm border border-gray-100 z-50">
                                <div className="py-1">
                                  {switch primaryName {
                                  | Some({name}) if name == subname.name => React.null
                                  | _ =>
                                    <button
                                      type_="button"
                                      onClick={_ => {
                                        setPrimary(subname.name)->ignore
                                        setActiveDropdown(_ => None)
                                      }}
                                      className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left">
                                      {React.string("Set primary")}
                                    </button>
                                  }}
                                  {switch primaryName {
                                  | Some({name}) if name == subname.name => React.null
                                  | None =>
                                    <button
                                      type_="button"
                                      disabled=true
                                      className="block w-full px-4 py-2.5 text-sm text-gray-400 cursor-not-allowed text-left"
                                      title="Set a primary subname first">
                                      {React.string("Transfer")}
                                    </button>
                                  | Some(_) =>
                                    <button
                                      type_="button"
                                      onClick={_ => {
                                        setShowTransferPanel(_ => Some(subname.name))
                                        setActiveDropdown(_ => None)
                                      }}
                                      className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left">
                                      {React.string("Transfer")}
                                    </button>
                                  }}
                                  <button
                                    type_="button"
                                    onClick={_ => {
                                      setShowExtendPanel(_ => Some(subname.name))
                                      setActiveDropdown(_ => None)
                                    }}
                                    className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left">
                                    {React.string("Extend")}
                                  </button>
                                </div>
                              </div>
                            } else {
                              React.null
                            }}
                          </div>
                        </div>
                      </div>
                      {if index < names->Array.length - 1 {
                        <div className="border-b border-gray-200 mx-6" />
                      } else {
                        React.null
                      }}
                    </div>
                  })
                  ->React.array}
                </div>
              </div>
            }}
          </div>
        }}
      </div>
    </div>
    {if settingPrimaryName {
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white p-6 rounded-lg shadow-xl">
          <div className="flex items-center gap-3">
            <div
              className="animate-spin rounded-full h-5 w-5 border-2 border-gray-900 border-t-transparent"
            />
            <p className="text-gray-900"> {React.string("Setting primary name...")} </p>
          </div>
        </div>
      </div>
    } else {
      React.null
    }}
  </>
}
