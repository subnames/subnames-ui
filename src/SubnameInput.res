type state = {
  name: string,
  panel: string,
  action: Types.action,
  result: option<Types.actionResult>,
}

let initialState: state = {
  name: "",
  panel: "input",
  action: Types.Register,
  result: None,
}

@react.component
let make = (~isWalletConnected: bool) => {
  let {updateName, setUpdateName} = NameContext.use()
  let (state, setState) = React.useState(_ => initialState)

  let onSuccess = (result: Types.actionResult) => {
    setState(prev => {
      ...prev,
      panel: "result",
      result: Some(result),
    })
    setUpdateName(_ => true)
  }

  let onNext = (name: string, action: Types.action) => {
    setState(prev => {
      ...prev,
      name,
      panel: switch action {
      | Types.Register => "register"
      | Types.Transfer => "transfer"
      | Types.Extend(_) => "extend"
      },
      action,
    })
  }

  <div className="w-full max-w-xl mx-auto">
    {switch state.panel {
    | "input" =>
      <InputPanel onNext={onNext} isWalletConnected />
    | "register" =>
      <RegisterExtendPanel
        name={state.name}
        isWalletConnected
        onBack={() => setState(prev => {...prev, panel: "input"})}
        onSuccess={onSuccess}
        action={state.action}
      />
    | "extend" =>
      <RegisterExtendPanel
        name={state.name}
        isWalletConnected
        onBack={() => setState(prev => {...prev, panel: "input"})}
        onSuccess={onSuccess}
        action={state.action}
      />
    | "transfer" =>
      <TransferPanel
        name={state.name}
        isWalletConnected
        onBack={() => setState(prev => {...prev, panel: "input"})}
        onSuccess={onSuccess} 
      />
    | "result" =>
      <ResultPanel
        name={state.name}
        actionResult={state.result->Option.getUnsafe}
        onRegisterAnother={() => setState(_ => initialState)}
      />
    | _ => <div />
    }}
  </div>
}
