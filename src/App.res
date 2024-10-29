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
  external make: (~label: string, ~accountStatus: string) => React.element = "ConnectButton"
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

module Layout = {
  @react.component
  let make = (~children: React.element) => {
    <div className="min-h-screen bg-gray-50">
      <header>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex justify-between items-center h-16">
            <div className="flex-shrink-0">
              <h1 className="text-xl font-bold text-gray-900"> {"ringdao.eth"->React.string} </h1>
            </div>
            <div className="flex items-center">
              <ConnectButton label="Connect" accountStatus="address"/>
            </div>
          </div>
        </div>
      </header>
      <main>
        <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8"> {children} </div>
      </main>
    </div>
  }
}

module Subname = {
  @react.component
  let make = () => {
    let (validSubname, setValidSubname) = React.useState(_ => ("", false))
    let (isWalletConnected, setWalletConnected) = React.useState(() => false)

    let handleValidChange = (value, isValid) => {
      setValidSubname(_ => (value, isValid))
    }

    let handleConnectWallet = () => {
      setWalletConnected(_ => true)
    }

    <div className="p-8">
      <SubnameInput 
        onValidChange={handleValidChange}
        isWalletConnected
        onConnectWallet={handleConnectWallet}
      />
    </div>
  }
}

@react.component
let make = () => {
  <WagmiProvider config={config}>
    <QueryClientProvider client={queryClient}>
      <RainbowKitProvider>
        <Layout>
            <Subname />
        </Layout>
      </RainbowKitProvider>
    </QueryClientProvider>
  </WagmiProvider>
}
