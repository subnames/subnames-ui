type state = {
  name: string,
  panel: string,
  registeredName: option<string>,
}

let initialState = {
  name: "",
  panel: "input",
  registeredName: None,
}

@react.component
let make = (~isWalletConnected: bool) => {
  let {updateName, setUpdateName} = NameContext.use()
  let (state, setState) = React.useState(_ => initialState)

  let onRegisterSuccess = (name: string) => {
    setState(prev => {
      ...prev,
      panel: "result",
      registeredName: Some(name),
    })
    setUpdateName(_ => true)
  }

  <div className="w-full max-w-xl mx-auto">
    {switch state.panel {
    | "input" =>
      <InputPanel onNext={name => setState(prev => {...prev, panel: "register", name})} />
    | "register" =>
      <RegisterPanel
        name={state.name}
        isWalletConnected
        onBack={() => setState(prev => {...prev, panel: "input"})}
        onRegisterSuccess={onRegisterSuccess}
      />
    | "result" =>
      <ResultPanel
        registeredName={state.registeredName->Option.getOr("")}
        onRegisterAnother={() => setState(_ => initialState)}
      />
    | _ => <div />
    }}
  </div>
}
