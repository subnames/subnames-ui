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
  let fn: () => array<string> = () => []
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

  <div className="p-6">
    <h2 className="text-2xl font-bold mb-6"> {React.string("Your Subnames")} </h2>
    {if loading {
      <div className="text-center py-4"> {React.string("Loading...")} </div>
    } else if names->Array.length == 0 {
      <div className="text-center py-4 text-gray-500">
        {React.string("You don't have any subnames yet")}
      </div>
    } else {
      <div className="space-y-4">
        {React.string("Under Construction")}
      </div>
    }}
  </div>
} 