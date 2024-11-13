module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

@react.component
let make = () => {
  let account = UseAccount.use()
  let fn: unit => array<string> = () => []
  let (names, setNames) = React.useState(fn)
  let (loading, setLoading) = React.useState(() => true)

  React.useEffect1(() => {
    switch account.address {
    | Some(addr) => {
        setLoading(_ => true)
        let _ = OnChainOperations.getSubnames(addr)->Promise.then(subnames => {
          setNames(_ => subnames)
          setLoading(_ => false)
          Promise.resolve()
        })
      }
    | None => ()
    }
    None
  }, [account.address])

  <div className="p-8">
    <div className="w-full max-w-xl mx-auto">
      <div className="bg-white rounded-custom shadow-lg overflow-hidden">
        <div className="px-6 pt-4 pb-4 border-b border-gray-200">
          <h3 className="font-medium"> {React.string("Under Construction")} </h3>
        </div>

        {if loading {
          <div className="text-center py-4"> {React.string("Loading...")} </div>
        } else if names->Array.length == 0 {
          <div className="text-center py-4 text-gray-500">
            {React.string("You don't have any subnames yet")}
          </div>
        } else {
          <div className="py-1">
            {names
            ->Array.mapWithIndex((name, index) => {
              <div>
                <div className="px-6 py-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-gray-700"> {React.string(`${name}.${Constants.sld}`)} </p>
                      <p className="text-sm text-gray-500 mt-1">
                        {React.string(`Your name will expire in 10 days`)}
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
