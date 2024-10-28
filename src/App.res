type chain = {
  id: int,
  name: string,
}
type transport
type params = {
  "appName": string,
  "projectId": string,
  "chains": array<chain>,
  "transports": Map.t<int, transport>,
  "ssr": bool,
}
@module("@rainbow-me/rainbowkit")
external getDefaultConfig: params => 'config = "getDefaultConfig"

module RainbowKitProvider = {
  @module("@rainbow-me/rainbowkit") @react.component
  external make: (~children: React.element) => React.element =
    "RainbowKitProvider"
}

module WagmiProvider = {
  @module("wagmi") @react.component
  external make: (~config: 'config, ~children: React.element) => React.element = "WagmiProvider"
}

@module("wagmi/chains")
external koi: chain = "koi"

module QueryClientProvider = {
  @module("@tanstack/react-query") @react.component
  external make: (~client: 'client, ~children: React.element) => React.element = "QueryClientProvider"
}

@new @module("@tanstack/react-query")
external makeQueryClient: unit => 'client = "QueryClient"

@module("wagmi")
external http: unit => transport = "http"

module ConnectButton = {
  @module("@rainbow-me/rainbowkit") @react.component
  external make: unit => React.element = "ConnectButton"
}

let queryClient = makeQueryClient()

let transports = Map.make()
transports->Map.set(koi.id, http())
let config = getDefaultConfig({
  "appName": "Subnames App",
  "projectId": "873f70fa626990b1ee3c14d55130a573",
  "chains": [koi],
  "transports": transports,
  "ssr": false,
})

@react.component
let make = () => {
  // let (validSubname, setValidSubname) = React.useState(_ => ("", false))

  // let handleValidChange = (value, isValid) => {
  //   setValidSubname(_ => (value, isValid))
  // }

  <WagmiProvider config={config}>
    <QueryClientProvider client={queryClient}>
      <RainbowKitProvider>
        <ConnectButton />
      </RainbowKitProvider>
    </QueryClientProvider>
  </WagmiProvider>
}
