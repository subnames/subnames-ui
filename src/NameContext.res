type primaryName = {
  fullName: string,
  name: string,
  expires: int,
}

// Why here the set functions signature is (.. => ..) => unit?
// Because their values are from useState.
type context = {
  forceRefresh: bool,
  setForceRefresh: (bool => bool) => unit,
  primaryName: option<primaryName>,
  setPrimaryName: (option<primaryName> => option<primaryName>) => unit,
}

let context = React.createContext({
  forceRefresh: false,
  setForceRefresh: _ => (),
  primaryName: None,
  setPrimaryName: _ => (),
})

module Provider = {
  let make = React.Context.provider(context)
}

let use = () => React.useContext(context)
