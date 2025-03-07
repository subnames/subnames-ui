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

let updatePrimaryName = (account, setPrimaryName) => {
  account->Option.map(async acc => {
    let resolvedName = await OnChainOperations.name(acc.address)

    if resolvedName == "" {
      setPrimaryName(_ => None)
    } else {
      let fixedName = if String.endsWith(resolvedName, Constants.sld) {
        String.split(resolvedName, ".")->Array.get(0)->Option.getExn
      } else {
        resolvedName
      }
      let expiresInt = await OnChainOperations.nameExpires(fixedName)
      let primaryName: NameContext.primaryName = {name: fixedName, expires: expiresInt}
      setPrimaryName(_ => Some(primaryName))
    }
  })
}

let displayName = (account, primaryName: option<NameContext.primaryName>) => {
  switch primaryName {
  | Some({name, _}) => name
  | None => Option.getExn(account).displayName
  }
}

@react.component
let make = () => {
  <ConnectButton.Custom >
    {props => {
      let {forceRefresh, setForceRefresh, primaryName, setPrimaryName} = NameContext.use()

      let {account, chain, openAccountModal, openChainModal, openConnectModal, mounted} = props

      // Get the account address for dependency
      let accountAddress = React.useMemo1(() => {
        account->Option.map(acc => acc.address)
      }, [account])

      // updatePrimaryName if account address changes
      React.useEffect1(() => {
        updatePrimaryName(account, setPrimaryName)->ignore
        None
      }, [accountAddress])

      // updatePrimaryName if forceRefresh
      React.useEffect1(() => {
        if forceRefresh {
          updatePrimaryName(account, setPrimaryName)->ignore
        }
        Some(() => setForceRefresh(_ => false))
      }, [forceRefresh])

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
                  {React.string(displayName(account, primaryName))}
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
