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
  expires: string,
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

  let buildSubname = subnameObj => {
    subnameObj
    ->JSON.Decode.object
    ->Option.map(obj => {
      let label = getString(obj, "label")
      let name = getString(obj, "name")
      let expires = getString(obj, "expires")
      let owner: owner = getObject(obj, "owner", ownerObj => {id: getString(ownerObj, "id")})

      {label, name, expires, owner}
    })
    ->Option.getExn
  }

  let buildSubnames = subnameObjs => {
    let current = primaryName->Option.getExn
    let currentSubname = {
      label: current.name,
      name: currentPrimaryName,
      expires: "",
      owner: {id: account.address},
    }
    subnameObjs->Array.map(buildSubname)
  }

  React.useEffect2(() => {
    if account.isConnected {
      let fetchNames = async () => {
        let address =
          account.address
          ->Option.map(String.toLowerCase)
          ->Option.getExn(~message="No address found")

        let query = `
          query {
            subnames(limit: 20, where: {owner: {id_eq: "${address}"}}) {
              label
              name
              expires
              owner {
                id
              }
            }
          }
        `

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
  }, (account.isConnected, primaryName))

  <>
    <div className="p-8">
      <div className="w-full max-w-xl mx-auto">
        {switch showExtendPanel {
        | Some(name) =>
          <RegisterExtendPanel
            name
            isWalletConnected=account.isConnected
            onBack={() => setShowExtendPanel(_ => None)}
            onSuccess=handleExtendSuccess
            action={Types.Extend}
          />
        | None =>
          <div className="bg-white rounded-custom shadow-lg overflow-hidden">
            <div className="px-6 pt-4 pb-4 border-b border-gray-200 relative">
              <div className="text-lg"> {React.string("Your Subnames")} </div>
              <div className="text-sm text-gray-500">
                {React.string("New name may take a while to appear")}
              </div>
              <button
                onClick={_ => RescriptReactRouter.push("/")}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors absolute right-4 top-1/2 -translate-y-1/2">
                <Icons.Close />
              </button>
            </div>
            {if !account.isConnected {
              <div className="text-center py-4 text-gray-500">
                {React.string("Please connect your wallet to see your names")}
              </div>
            } else if loading {
              <div className="text-center py-4"> {React.string("Loading...")} </div>
            } else if names->Array.length == 0 {
              <div className="text-center py-4 text-gray-500">
                {React.string("You don't have any subnames yet")}
              </div>
            } else {
              <div className="py-1">
                {names
                ->Array.mapWithIndex((subname, index) => {
                  <div key={subname.name}>
                    <div className="px-6 py-4">
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
                              `Expires ${distanceToExpiry(timestampStringToDate(subname.expires))}`,
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
                            className="rounded-lg bg-white border border-zinc-200 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50">
                            {React.string("...")}
                          </button>
                          {if activeDropdown == Some(subname.name) {
                            <div
                              ref={ReactDOM.Ref.domRef(dropdownRef)}
                              className="absolute right-0 z-10 mt-2 w-40 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
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
                                    className="block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100">
                                    {React.string("Set primary")}
                                  </button>
                                }}
                                <button
                                  type_="button"
                                  onClick={_ => setActiveDropdown(_ => None)}
                                  className="block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100">
                                  {React.string("Transfer")}
                                </button>
                                <button
                                  type_="button"
                                  onClick={_ => {
                                    setShowExtendPanel(_ => Some(subname.name))
                                    setActiveDropdown(_ => None)
                                  }}
                                  className="block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100">
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
