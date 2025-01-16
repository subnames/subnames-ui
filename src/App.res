open OnChainOperationsCommon
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
  external make: (~children: React.element, ~theme: 'theme) => React.element = "RainbowKitProvider"
}

module WagmiProvider = {
  @module("wagmi") @react.component
  external make: (~config: 'config, ~children: React.element) => React.element = "WagmiProvider"
}

@module("wagmi/chains")
external koi: chain = "koi"

module QueryClientProvider = {
  @module("@tanstack/react-query") @react.component
  external make: (~client: 'client, ~children: React.element) => React.element =
    "QueryClientProvider"
}

@new @module("@tanstack/react-query")
external makeQueryClient: unit => 'client = "QueryClient"

@module("wagmi")
external http: unit => transport = "http"

type themeParams = {
  accentColor: string,
  accentColorForeground: string,
  borderRadius: string,
}
@module("@rainbow-me/rainbowkit")
external lightTheme: themeParams => 'theme = "lightTheme"

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

module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

module Subname = {
  let walletClient = buildWalletClient()
  let hasWallet = switch walletClient {
  | Some(_) => true
  | None => false
  }

  @react.component
  let make = () => {
    let account = UseAccount.use()
    let (isWalletConnected, setWalletConnected) = React.useState(() => false)

    React.useEffect1(() => {
      if account.isConnected {
        setWalletConnected(_ => true)
      } else {
        setWalletConnected(_ => false)
      }
      None
    }, [account.isConnected])

    <div className="p-8">
      {if !hasWallet {
        <div className="text-center p-4 bg-yellow-100 rounded-2xl mb-4">
          <p className="text-yellow-800">
            {React.string("Please install a wallet extension like MetaMask to continue.")}
          </p>
          <a
            href="https://metamask.io/download/"
            target="_blank"
            rel="noopener noreferrer"
            className="text-blue-600 hover:text-blue-800 underline mt-2 inline-block">
            {React.string("Install MetaMask")}
          </a>
        </div>
      } else {
        <SubnameInput isWalletConnected />
      }}
    </div>
  }
}

module Layout = {
  @react.component
  let make = () => {
    let (forceRefresh, setForceRefresh) = React.useState(() => false)
    let (primaryName, setPrimaryName) = React.useState(() => None)
    let url = RescriptReactRouter.useUrl()
    let account = UseAccount.use()

    <NameContext.Provider value={forceRefresh, setForceRefresh, primaryName, setPrimaryName}>
      <div className="min-h-screen bg-gray-50">
        <header>
          <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div className="flex justify-between items-center h-16">
              <div className="flex-shrink-0">
                <button
                  onClick={_ => RescriptReactRouter.push("/")}
                  className="text-xl font-bold text-gray-900">
                  {React.string(Constants.sld)}
                </button>
              </div>
              <div className="flex items-center gap-4">
                {if account.isConnected {
                  <button
                    onClick={_ => RescriptReactRouter.push("/names")}
                    className="text-sm font-medium text-zinc-800 hover:text-zinc-600 transition-colors underline">
                    {React.string("Your Names")}
                  </button>
                } else {
                  React.null
                }}
                <MyConnectButton />
              </div>
            </div>
          </div>
        </header>
        <main>
          <div className="max-w-7xl mx-auto py-6 sm:px-6 lg:px-8">
            {
            switch url->Router.fromUrl {
            | Router.Home => <Subname />
            | Router.Names => <NamesList />
            | Router.Profile => <Profile />
            | _ => <div> {React.string("Page Not Found")} </div>
            }
            }
          </div>
        </main>
      </div>
    </NameContext.Provider>
  }
}

@react.component
let make = () => {
  <WagmiProvider config={config}>
    <QueryClientProvider client={queryClient}>
      <RainbowKitProvider
        theme={lightTheme({
          accentColor: "rgb(39, 39, 42)",
          accentColorForeground: "white",
          borderRadius: "large",
        })}>
        <Layout />
      </RainbowKitProvider>
    </QueryClientProvider>
  </WagmiProvider>
}
