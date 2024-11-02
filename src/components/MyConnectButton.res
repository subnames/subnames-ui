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
  <ConnectButton.Custom>
    {props => {
      let (name, setName) = React.useState(() => "Loading...")

      let {updateName, setUpdateName} = NameContext.use()
      let {account, chain, openAccountModal, openChainModal, openConnectModal, mounted} = props

      React.useEffect1(() => {
        switch account {
        | Some(acc) =>
          let _ = OnChainOperations.name(acc.address)->Promise.then(resolvedName => {
            if resolvedName == "" {
              setName(_ => acc.address)
            } else {
              setName(_ => resolvedName)
            }
            Promise.resolve()
          })
        | None => ()
        }
        None
      }, [account])
      React.useEffect1(() => {
        Console.log(`updateName: ${updateName ? "true" : "false"}`)
        if updateName {
          Console.log(`account: ${Option.isSome(account) ? Option.getUnsafe(account).address : "None"}`)
          switch account {
          | Some(acc) =>
            let _ = OnChainOperations.name(acc.address)->Promise.then(resolvedName => {
              if resolvedName == "" {
                setName(_ => acc.address)
              } else {
                setName(_ => resolvedName)
              }
              setUpdateName(_ => false)
              Promise.resolve()
            })
          | None => ()
          }
        }
        None
      }, [updateName])

      let ready = mounted
      let connected = ready && Option.isSome(account) && Option.isSome(chain)
      let ariaHidden = !ready ? true : false
      let style = !ready
        ? ReactDOM.Style.make(~opacity="0", ~pointerEvents="none", ~userSelect="none", ())
        : ReactDOM.Style.make()

      let buttonClasses = "bg-zinc-800 text-white px-4 py-2 rounded-xl border-none cursor-pointer text-sm font-medium transition-colors hover:bg-zinc-700"

      <div ariaHidden style>
        {(
          () => {
            if !connected {
              <button
                onClick={openConnectModal} className=buttonClasses dataTestId="rk-connect-button">
                {React.string("Connect Wallet")}
              </button>
            } else if Option.getUnsafe(chain).unsupported {
              <button onClick={openChainModal} className=buttonClasses>
                {React.string("Wrong network")}
              </button>
            } else {
              <div className="flex gap-3">
                <button onClick={openAccountModal} className=buttonClasses>
                  {React.string(name)}
                  {Option.isSome(Option.getUnsafe(account).displayBalance)
                    ? React.string(
                        ` (${Option.getUnsafe(Option.getUnsafe(account).displayBalance)})`,
                      )
                    : React.null}
                </button>
              </div>
            }
          }
        )()}
      </div>
    }}
  </ConnectButton.Custom>
}
