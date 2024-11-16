open Utils

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
  let (names, setNames) = React.useState(() => [])
  let (loading, setLoading) = React.useState(() => true)

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

  <div className="p-8">
    <div className="w-full max-w-xl mx-auto">
      <div className="bg-white rounded-custom shadow-lg overflow-hidden">
        <div className="px-6 pt-4 pb-4 border-b border-gray-200 relative">
          <div className="text-lg"> {React.string("Your Subnames")} </div>
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
                      <p className="text-gray-800">
                        {React.string(`${subname.name}.${Constants.sld}`)}
                      </p>
                      <p className="text-xs text-gray-400 mt-1">
                        {React.string(`Expires ${distanceToExpiry(timestampStringToDate(subname.expires))}`)}
                      </p>
                    </div>
                    <div className="flex gap-2">
                      <button
                        type_="button"
                        className="rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50">
                        {React.string("Transfer")}
                      </button>
                      <button
                        type_="button"
                        className="rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50">
                        {React.string("Extend")}
                      </button>
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
}
