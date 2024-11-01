type account = {
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
    {
      props => {
        let {account, chain, openAccountModal, openChainModal, openConnectModal, mounted} = props
        let ready = mounted
        let connected = ready && Option.isSome(account) && Option.isSome(chain)
        let ariaHidden = !ready ? true : false
        let style = !ready ? ReactDOM.Style.make(~opacity="0", ~pointerEvents="none", ~userSelect="none", ()) : ReactDOM.Style.make()
        <div ariaHidden style>
        {
          (() => {
            if (!connected) {
              <button onClick={openConnectModal}>
                {React.string("Connect Wallet")}
              </button>
            } else if (Option.getUnsafe(chain).unsupported) {
              <button onClick={openChainModal}>
                {React.string("Wrong network")}
              </button>
            } else {
              <div style={ReactDOM.Style.make(~display="flex", ~gap="12px", ())}>
                <button
                  onClick={openChainModal}
                  style={ReactDOM.Style.make(~display="flex", ~alignItems="center", ())}
                >
                  {
                    if (Option.getUnsafe(chain).hasIcon) {
                      <div
                        style={ReactDOM.Style.make(~background=Option.getUnsafe(chain).iconBackground, ~width="12px", ~height="12px", ~borderRadius="999px", ~overflow="hidden", ~marginRight="4px", ())}
                      >
                        {
                          if (Option.isSome(Option.getUnsafe(chain).iconUrl)) {
                            <img src=Option.getUnsafe(Option.getUnsafe(chain).iconUrl) alt="" style={ReactDOM.Style.make(~width="12px", ~height="12px", ())}/>
                          } else {
                            React.null
                          }
                        }
                      </div>
                    } else {
                      React.null
                    }
                  }
                  {React.string(Option.getUnsafe(chain).name)}
                </button>

                <button onClick={openAccountModal}>
                  {React.string(Option.getUnsafe(account).displayName)}
                  {Option.isSome(Option.getUnsafe(account).displayBalance)
                    ? React.string(` (${Option.getUnsafe(Option.getUnsafe(account).displayBalance))})`)
                    : React.null
                  }
                </button>
              </div>
            }
          })()
        }
        </div>
      }
    }
  </ConnectButton.Custom>
}
