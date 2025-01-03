open Utils
open ReverseRegistrar
open OnChainOperationsCommon

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

let getPrimaryName = async address => {
  await OnChainOperations.name(address)
}

@react.component
let make = () => {
  let account = UseAccount.use()
  let {_, setUpdateName} = NameContext.use()
  let (names, setNames) = React.useState(() => [])
  let (loading, setLoading) = React.useState(() => true)
  let (activeDropdown, setActiveDropdown) = React.useState(() => None)
  let (settingPrimaryName, setSettingPrimaryName) = React.useState(() => false)
  let (primaryName, setPrimaryName) = React.useState(() => None)
  let (refetchTrigger, setRefetchTrigger) = React.useState(() => 0)

  let updatePrimaryName = async name => {
    setSettingPrimaryName(_ => true)
    switch buildWalletClient() {
    | Some(walletClient) => {
        try {
          await setNameForAddr(walletClient, name)
          setUpdateName(_ => true)
          // Trigger effect re-run to fetch updated primary name
          setRefetchTrigger(prev => prev + 1)
        } catch {
        | Js.Exn.Error(err) => Console.error2("Error setting primary name:", err)
        | _ => Console.error("Unknown error setting primary name")
        }
        setSettingPrimaryName(_ => false)
      }
    | None => {
        Console.log("Wallet connection failed")
        setSettingPrimaryName(_ => false)
      }
    }
  }

  // Add effect to fetch primary name
  React.useEffect2(() => {
    if account.isConnected {
      let fetchPrimaryName = async () => {
        switch account.address {
        | Some(address) => {
            let primaryName = await getPrimaryName(address)
            Console.log("Primary name set to: ${primaryName}")
            setPrimaryName(_ => Some(primaryName))
          }
        | None => ()
        }
      }
      fetchPrimaryName()->ignore
    }
    None
  }, (account.isConnected, refetchTrigger))

  React.useEffect1(() => {
    if account.isConnected {
      let fetchNames = async () => {
        let query = `
          query {
            subnames(limit: 20, where: {owner: {id_eq: "${account.address->Option.getExn->String.toLowerCase}"}}) {
              label
              name
              expires
              owner {
                id
              }
            }
          }
        `

        let result = await GraphQLClient.makeRequest(
          ~endpoint=Constants.indexerUrl,
          ~query,
          (),
        )

        switch result {
        | {data: Some(data), errors: None} => {
            // Assuming data can be decoded to queryResponse type
            let subnames = data
              ->Dict.get("subnames")
              ->Option.getExn
              ->Js.Json.decodeArray
              ->Option.getExn
              ->Array.map(json => {
                let obj = json->Js.Json.decodeObject->Option.getExn
                {
                  label: obj->Dict.get("label")->Option.getExn->Js.Json.decodeString->Option.getExn,
                  name: obj->Dict.get("name")->Option.getExn->Js.Json.decodeString->Option.getExn,
                  expires: obj->Dict.get("expires")->Option.getExn->Js.Json.decodeString->Option.getExn,
                  owner: {
                    id: obj
                      ->Dict.get("owner")
                      ->Option.getExn
                      ->Js.Json.decodeObject
                      ->Option.getExn
                      ->Dict.get("id")
                      ->Option.getExn
                      ->Js.Json.decodeString
                      ->Option.getExn,
                  },
                }
              })
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
                            <>
                              <span className="font-bold"> {React.string(subname.name)} </span>
                              {React.string(`.${Constants.sld}`)}
                            </>
                          </p>
                          {switch primaryName {
                          | Some(name) if name == subname.name =>
                            <span
                              className="px-2 py-0.5 text-xs bg-blue-100 text-blue-800 rounded-full font-medium">
                              {React.string("Primary")}
                            </span>
                          | _ => React.null
                          }}
                        </div>
                        <p className="text-xs text-gray-400 mt-1">
                          {React.string(`Expires ${distanceToExpiry(timestampStringToDate(subname.expires))}`)}
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
                            className="absolute right-0 z-10 mt-2 w-40 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none">
                            <div className="py-1">
                              {switch primaryName {
                              | Some(name) if name == subname.name => React.null
                              | _ =>
                                <button
                                  type_="button"
                                  onClick={_ => {
                                    updatePrimaryName(subname.name)->ignore
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
                                onClick={_ => setActiveDropdown(_ => None)}
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
      </div>
    </div>
    {if settingPrimaryName {
      <div
        className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white p-6 rounded-lg shadow-xl">
          <div className="flex items-center gap-3">
            <div className="animate-spin rounded-full h-5 w-5 border-2 border-gray-900 border-t-transparent" />
            <p className="text-gray-900"> {React.string("Setting primary name...")} </p>
          </div>
        </div>
      </div>
    } else {
      React.null
    }}
  </>
}
