type context = {
  updateName: bool,
  setUpdateName: (bool => bool) => unit,
}

let context = React.createContext({
  updateName: true, 
  setUpdateName: _ => (),
})

module Provider = {
  let make = React.Context.provider(context)
}

let use = () => React.useContext(context) 