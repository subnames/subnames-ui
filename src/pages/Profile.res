module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

@react.component
let make = (~profileName=?) => {
  let {primaryName} = NameContext.use()
  let account = UseAccount.use()

  // Handle direct profile URL access
  switch profileName {
  | Some(name) => {
      // Public profile view - no wallet connection needed
      <ProfileView name />
    }
  | None => {
      // Personal profile view - requires wallet connection
      // Redirect to home if disconnected
      React.useEffect(() => {
        if !account.isConnected || primaryName->Option.isNone {
          RescriptReactRouter.push(Router.toUrl(Router.Home))
        }
        None
      }, (account.isConnected, primaryName))

      switch primaryName {
      | None => React.null
      | Some(name) => <ProfileView name={name.name}/>
      }
    }
  }
}

