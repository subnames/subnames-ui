type state = {
  name: string,
  panel: string,
  action: Types.action,
  result: option<Types.actionResult>,
  // Preserve InputPanel state
  inputPanelKey: string,
}

let initialState: state = {
  name: "",
  panel: "input",
  action: Types.Register,
  result: None,
  inputPanelKey: "initial",
}

@react.component
let make = (~isWalletConnected: bool) => {
  let {setForceRefresh} = React.useContext(NameContext.context)
  let (state, setState) = React.useState(_ => initialState)

  let onSuccess = (result: Types.actionResult) => {
    setState(prev => {
      ...prev,
      panel: "result",
      result: Some(result),
    })
    setForceRefresh(_ => true)
  }

  let onNext = (name: string, action: Types.action) => {
    setState(prev => {
      ...prev,
      name,
      panel: switch action {
      | Types.Register => "register"
      | Types.Transfer => "transfer"
      | Types.Extend => "extend"
      | _ => raise(Failure("Invalid action"))
      },
      action,
    })
  }

  <div className="w-full max-w-xl mx-auto">
    {switch state.panel {
    | "input" => <InputPanel key={state.inputPanelKey} onNext={onNext} isWalletConnected initialValue={state.name} />
    | "register" | "extend" =>
      <RegisterExtendPanel
        name={state.name}
        isWalletConnected
        onBack={() => {
          setState(prev => {
            Console.log(prev);
            // Generate a new key to force the component to preserve its state
            let newKey = Date.now()->Float.toString
            {...prev, panel: "input", inputPanelKey: newKey}
          })
        }}
        onSuccess={onSuccess}
        action={state.action}
      />
    | "transfer" =>
      <TransferPanel
        name={state.name}
        receiver={None}
        onCancel={() => {
          setState(prev => {
            // Generate a new key to force the component to preserve its state
            let newKey = Date.now()->Float.toString
            {...prev, panel: "input", inputPanelKey: newKey}
          })
        }}
        onSuccess={onSuccess}
        buttonType=#close
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
