@react.component
let make: (
  ~onValidChange: (string, bool) => unit,
  ~isWalletConnected: bool,
  ~onConnectWallet: unit => unit,
) => React.element
