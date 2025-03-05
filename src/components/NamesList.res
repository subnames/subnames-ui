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

type owner = {id: string}
type subname = {
  label: string,
  name: string,
  expires: int,
  resolvedTo: owner,
  owner: owner,
  reverseResolvedFrom: option<owner>,

  underTransfer: bool, // true if resolvedTo.id is not current account
  receiver: option<string>,
}
type queryResponse = {subnames: array<subname>}

@react.component
let make = () => {
  let account = UseAccount.use()
  let {setForceRefresh, primaryName} = NameContext.use()
  let (names, setNames) = React.useState(() => [])
  let (loading, setLoading) = React.useState(() => true)
  let (isSynced, setIsSynced) = React.useState(() => true)
  let (activeDropdown, setActiveDropdown) = React.useState(() => None)
  let (settingPrimaryName, setSettingPrimaryName) = React.useState(() => false)
  let (showExtendPanel, setShowExtendPanel) = React.useState(() => None)
  let (showTransferPanel: option<(string, option<string>)>, setShowTransferPanel) = React.useState(() => None) // (name, receiver)
  let dropdownRef = React.useRef(Nullable.null)
  // let (currentAddress, setCurrentAddress) = React.useState(() => None)

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
      let label = getStringExn(obj, "label")
      let name = getStringExn(obj, "name")
      let expires = getStringExn(obj, "expires")->Int.fromString->Option.getExn
      let resolvedTo: owner = getObjectExn(obj, "resolvedTo", o => {id: getStringExn(o, "id")})
      let owner: owner = getObjectExn(obj, "owner", o => {id: getStringExn(o, "id")})
      let reverseResolvedFrom: option<owner> = getObject(obj, "reverseResolvedFrom", o => {
        id: getStringExn(o, "id"),
      })

      let currentAddressLowercase = account.address->Option.map(String.toLowerCase)->Option.getExn
      {
        label,
        name,
        expires,
        owner,
        resolvedTo,
        reverseResolvedFrom,
        underTransfer: resolvedTo.id !== currentAddressLowercase,
        receiver: resolvedTo.id !== currentAddressLowercase ? Some(resolvedTo.id) : None,
      }
    })
    ->Option.getExn
  }

  // Check indexer sync status
  let checkSyncStatus = async () => {
    try {
      let response = await Fetch.fetch(
        Constants.metricsUrl, {
          method: #GET
        }
      )

      let text = await response->Fetch.Response.text
      
      // Parse the metrics text to extract chain height and last block
      let lines = text->String.split("\n")
      let chainHeightLine = lines->Array.find(line => line->String.startsWith("sqd_processor_chain_height"))
      let lastBlockLine = lines->Array.find(line => line->String.startsWith("sqd_processor_last_block"))
      
      switch (chainHeightLine, lastBlockLine) {
      | (Some(chainHeightStr), Some(lastBlockStr)) => {
          // Extract the numbers from the lines
          let chainHeight = chainHeightStr
            ->String.split(" ")
            ->Array.get(1)
            ->Option.flatMap(str => str->Int.fromString)
            ->Option.getOr(0)
            
          let lastBlock = lastBlockStr
            ->String.split(" ")
            ->Array.get(1)
            ->Option.flatMap(str => str->Int.fromString)
            ->Option.getOr(0)

          Console.log(`Chain height: ${chainHeight->Int.toString}, Last block: ${lastBlock->Int.toString}`)
            
          // Check if the difference is more than 3 blocks
          let diff = chainHeight - lastBlock
          setIsSynced(_ => diff <= 3)
        }
      | _ => setIsSynced(_ => true) // Default to synced if can't parse
      }
    } catch {
    | _ => setIsSynced(_ => true) // Default to synced if fetch fails
    }
  }

  // Check sync status periodically
  React.useEffect0(() => {
    // Initial check
    checkSyncStatus()->ignore
    
    // Set up interval to check every 30 seconds
    let intervalId = Js.Global.setInterval(() => {
      checkSyncStatus()->ignore
    }, 30000)
    
    // Clean up interval on unmount
    Some(() => Js.Global.clearInterval(intervalId))
  })

  React.useEffect2(() => {
    if account.isConnected {
      let fetchNames = async () => {
        let address =
          account.address
          ->Option.map(String.toLowerCase)
          ->Option.getExn(~message="No address found")

        let query = `
          query {
            subnames(where: {
              owner: {id_eq: "${address}"}
            }) {
              label
              name
              expires
              owner {
                id
              }
              resolvedTo {
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
            let subnames: array<subname> = getArrayExn(data, "subnames", buildSubname)
            subnames->Array.sort((a, b) => float(a.expires - b.expires))
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
  }, (account, currentAddress))

  <>
    <div className="p-8">
      <div className="w-full max-w-xl mx-auto">
        <div className="bg-white rounded-custom shadow-lg">

          // Header
          <div className="p-8 py-6 border-b border-gray-200 relative">
            <h1 className="text-3xl font-bold text-gray-900"> {React.string("Your names")} </h1>
            <div className="text-sm text-gray-500">
              {React.string("It may take a while to sync your names. ")}
              {if !isSynced {
                <span className="text-amber-600 font-medium">
                  {React.string("Indexer is currently syncing...")}
                </span>
              } else {
                <span className="text-green-600 font-medium">
                  {React.string("Indexer is fully synced")}
                </span>
              }}
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
              {React.string("You don't have any names yet")}
            </div>
          } else {
            <div>
              <div className="py-1">
                {names
                ->Array.mapWithIndex((subname, index) => {
                  <div key={subname.name}>
                    <div className="px-8 py-6">
                      <div className="flex items-center justify-between">
                        <div>
                          <div className="flex items-center gap-2">
                            <p className="text-gray-800">
                              {if subname.underTransfer {
                                <span className="text-gray-400">
                                  <span className="font-bold"> {React.string(subname.name)} </span>
                                  {React.string(`.${Constants.sld}`)}
                                </span>
                              } else {
                                <>
                                  <span className="font-bold"> {React.string(subname.name)} </span>
                                  {React.string(`.${Constants.sld}`)}
                                </>
                              }}
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
                          {if subname.underTransfer {
                            <p className="text-xs text-gray-300 mt-1">
                              {React.string(
                                `Expires ${distanceToExpiry(timestampToDate(subname.expires))}`,
                              )}
                            </p>
                          } else {
                            <p className="text-xs text-gray-400 mt-1">
                              {React.string(
                                `Expires ${distanceToExpiry(timestampToDate(subname.expires))}`,
                              )}
                            </p>
                          }}
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
                                {if !subname.underTransfer {
                                  <>
                                    // Set primary
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
                                    // Extend
                                    <button
                                      type_="button"
                                      onClick={_ => {
                                        setShowExtendPanel(_ => Some(subname.name))
                                        setActiveDropdown(_ => None)
                                      }}
                                      className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left">
                                      {React.string("Extend")}
                                    </button>
                                  </>
                                } else {
                                  React.null
                                }}
                                // Transfer
                                {switch primaryName {
                                | Some({name}) if name == subname.name => React.null
                                | Some(_) | None =>
                                  <button
                                    type_="button"
                                    onClick={_ => {
                                      setShowTransferPanel(_ => Some(subname.name, subname.receiver))
                                      setActiveDropdown(_ => None)
                                    }}
                                    className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left">
                                    {React.string("Transfer")}
                                  </button>
                                }}
                              </div>
                            </div>
                          } else {
                            React.null
                          }}
                        </div>
                      </div>
                    </div>
                    {if index < names->Array.length - 1 {
                      <div className="border-b border-gray-100 mx-6" />
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
      </div>
    </div>
    {if settingPrimaryName || Option.isSome(showTransferPanel) || Option.isSome(showExtendPanel) {
      <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
        <div className="bg-white rounded-2xl shadow-xl">
          {if settingPrimaryName {
            <div className="flex items-center gap-3 py-4 px-6 bg-gray-100 rounded-2xl shadow-sm">
              <Icons.Spinner className="h-6 w-6 text-gray-900" />
              <p className="text-gray-900 text-lg font-medium">
                {React.string("Setting primary name...")}
              </p>
            </div>
          } else if Option.isSome(showTransferPanel) {
            let (name, receiver) = showTransferPanel->Option.getExn
            <TransferPanel
              name
              receiver
              onCancel={() => setShowTransferPanel(_ => None)}
              onSuccess=handleTransferSuccess
              buttonType=#close
            />
          } else if Option.isSome(showExtendPanel) {
            let name = showExtendPanel->Option.getExn
            <RegisterExtendPanel
              name
              isWalletConnected=account.isConnected
              onBack={() => setShowExtendPanel(_ => None)}
              onSuccess=handleExtendSuccess
              action={Types.Extend}
              buttonType=#close
            />
          } else {
            React.null
          }}
        </div>
      </div>
    } else {
      React.null
    }}
  </>
}
