// https://github.com/rainbow-me/rainbowkit/blob/main/packages/rainbowkit/src/components/ConnectButton/ConnectButtonRenderer.tsx
type account = {
  address: string,
  displayName: string,
  displayBalance: option<string>,
}
type chain = {
  name: string,
  iconUrl: option<string>,
  iconBackground: string,
  unsupported: bool,
  hasIcon: bool,
}
type renderProps = {
  account: option<account>,
  chain: option<chain>,
  openAccountModal: JsxEventU.Mouse.t => unit,
  openChainModal: JsxEventU.Mouse.t => unit,
  openConnectModal: JsxEventU.Mouse.t => unit,
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
  let (name, setName) = React.useState(() => "Loading...")

  <ConnectButton.Custom>
    {props => {
      let {account, chain, openAccountModal, openChainModal, openConnectModal, mounted} = props
      let ready = mounted
      let connected = ready && Option.isSome(account) && Option.isSome(chain)
      let ariaHidden = !ready ? true : false
      let style = !ready
        ? ReactDOM.Style.make(~opacity="0", ~pointerEvents="none", ~userSelect="none", ())
        : ReactDOM.Style.make()

      let buttonClasses = "bg-zinc-800 text-white px-4 py-2 rounded-xl border-none cursor-pointer text-sm font-medium transition-colors hover:bg-zinc-700"

      <div ariaHidden style>
        {(() => {
          if (!connected) {
            <button onClick={openConnectModal} className=buttonClasses dataTestId="rk-connect-button">
              {React.string("Connect Wallet")}
            </button>
          } else if (Option.getUnsafe(chain).unsupported) {
            <button onClick={openChainModal} className=buttonClasses>
              {React.string("Wrong network")}
            </button>
          } else {
            <div className="flex gap-3">
              <button onClick={openAccountModal} className=buttonClasses>
                {Option.getUnsafe(account).address
                ->OnChainOperations.name
                ->Promise.then(resolvedName => {
                  if (resolvedName == "") {
                    setName(_ => Option.getUnsafe(account).displayName)
                  } else {
                    setName(_ => resolvedName)
                  }
                  Promise.resolve()
                })
                ->ignore
                React.string(name)}
                {Option.isSome(Option.getUnsafe(account).displayBalance)
                  ? React.string(` (${Option.getUnsafe(Option.getUnsafe(account).displayBalance)})`)
                  : React.null}
              </button>
            </div>
          }
        })()}
      </div>
    }}
  </ConnectButton.Custom>
}
