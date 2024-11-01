type account = {
  displayName: string,
  displayBalance: option<string>,
}
type chain = {
  name: string,
  iconUrl: option<string>,
  iconBackground: string,
  unsupported: bool,
}
type renderProps = {
  account: option<account>,
  chain: option<chain>,
  openAccountModal: unit => unit,
  openChainModal: unit => unit,
  openConnectModal: unit => unit,
  mounted: bool,
}
type children = renderProps => React.element

module ConnectButton = {
  module Custom = {
    @module("@rainbow-me/rainbowkit") @scope("ConnectButton") @react.component
    external make: (~children: children) => React.element = "Custom"
  }
}

@react.component
let make = () => {
  <ConnectButton.Custom>
    {props => {
      let {account, chain, openAccountModal, openChainModal, openConnectModal, mounted} = props
      let ready = mounted
      let connected = ready && Option.isSome(account) && Option.isSome(chain)
      let ariaHidden = connected ? false : true
      let style = connected ? ReactDOM.Style.make() : ReactDOM.Style.make(~opacity="0", ~pointerEvents="none", ~userSelect="none", ())
      <div ariaHidden style />
    }}
  </ConnectButton.Custom>
}
