// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Wagmi from "wagmi";
import * as Router from "./Router.res.mjs";
import * as Profile from "./pages/Profile.res.mjs";
import * as NamesList from "./components/NamesList.res.mjs";
import * as NameContext from "./NameContext.res.mjs";
import * as Chains from "viem/chains";
import * as SubnameInput from "./SubnameInput.res.mjs";
import * as MyConnectButton from "./components/MyConnectButton.res.mjs";
import * as RescriptReactRouter from "@rescript/react/src/RescriptReactRouter.res.mjs";
import * as ReactQuery from "@tanstack/react-query";
import * as Rainbowkit from "@rainbow-me/rainbowkit";
import * as OnChainOperationsCommon from "./OnChainOperationsCommon.res.mjs";

var queryClient = new ReactQuery.QueryClient();

var transports = new Map();

transports.set(Chains.crab.id, Wagmi.http());

var config = Rainbowkit.getDefaultConfig({
      appName: "Subnames App",
      projectId: "873f70fa626990b1ee3c14d55130a573",
      chains: [Chains.crab],
      transports: transports,
      ssr: false
    });

var walletClient = OnChainOperationsCommon.buildWalletClient();

var hasWallet = walletClient !== undefined;

function App$Subname(props) {
  var account = Wagmi.useAccount();
  var match = React.useState(function () {
        return false;
      });
  var setWalletConnected = match[1];
  React.useEffect((function () {
          if (account.isConnected) {
            setWalletConnected(function (param) {
                  return true;
                });
          } else {
            setWalletConnected(function (param) {
                  return false;
                });
          }
        }), [account.isConnected]);
  return React.createElement("div", {
              className: "p-8"
            }, hasWallet ? React.createElement(SubnameInput.make, {
                    isWalletConnected: match[0]
                  }) : React.createElement("div", {
                    className: "text-center p-4 bg-yellow-100 rounded-2xl mb-4"
                  }, React.createElement("p", {
                        className: "text-yellow-800"
                      }, "Please install a wallet extension like MetaMask to continue."), React.createElement("a", {
                        className: "text-blue-600 hover:text-blue-800 underline mt-2 inline-block",
                        href: "https://metamask.io/download/",
                        rel: "noopener noreferrer",
                        target: "_blank"
                      }, "Install MetaMask")));
}

function App$Layout(props) {
  var match = React.useState(function () {
        return false;
      });
  var match$1 = React.useState(function () {
        
      });
  var url = RescriptReactRouter.useUrl(undefined, undefined);
  var account = Wagmi.useAccount();
  var match$2 = Router.fromUrl(url);
  var tmp;
  switch (match$2) {
    case "Home" :
        tmp = React.createElement(App$Subname, {});
        break;
    case "Names" :
        tmp = React.createElement(NamesList.make, {});
        break;
    case "Profile" :
        tmp = React.createElement(Profile.make, {});
        break;
    case "NotFound" :
        tmp = React.createElement("div", undefined, "Page Not Found");
        break;
    
  }
  return React.createElement(NameContext.Provider.make, {
              value: {
                forceRefresh: match[0],
                setForceRefresh: match[1],
                primaryName: match$1[0],
                setPrimaryName: match$1[1]
              },
              children: React.createElement("div", {
                    className: "min-h-screen bg-gray-50"
                  }, React.createElement("header", undefined, React.createElement("div", {
                            className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
                          }, React.createElement("div", {
                                className: "flex justify-between items-center h-16"
                              }, React.createElement("div", {
                                    className: "flex-shrink-0"
                                  }, React.createElement("button", {
                                        className: "text-xl font-bold text-gray-900",
                                        onClick: (function (param) {
                                            RescriptReactRouter.push("/");
                                          })
                                      }, "Darwinia Names")), React.createElement("div", {
                                    className: "flex items-center gap-4"
                                  }, account.isConnected ? React.createElement(React.Fragment, {}, React.createElement("button", {
                                              className: "text-sm font-medium text-zinc-800 hover:text-zinc-600 transition-colors underline",
                                              onClick: (function (param) {
                                                  RescriptReactRouter.push("/profile");
                                                })
                                            }, "Profile"), React.createElement("button", {
                                              className: "text-sm font-medium text-zinc-800 hover:text-zinc-600 transition-colors underline",
                                              onClick: (function (param) {
                                                  RescriptReactRouter.push("/names");
                                                })
                                            }, "Your names")) : null, React.createElement(MyConnectButton.make, {}))))), React.createElement("main", undefined, React.createElement("div", {
                            className: "max-w-7xl mx-auto py-6 sm:px-6 lg:px-8"
                          }, tmp)))
            });
}

function App(props) {
  return React.createElement(Wagmi.WagmiProvider, {
              config: config,
              children: React.createElement(ReactQuery.QueryClientProvider, {
                    client: queryClient,
                    children: React.createElement(Rainbowkit.RainbowKitProvider, {
                          children: React.createElement(App$Layout, {}),
                          theme: Rainbowkit.lightTheme({
                                accentColor: "rgb(39, 39, 42)",
                                accentColorForeground: "white",
                                borderRadius: "large"
                              })
                        })
                  })
            });
}

var make = App;

export {
  make ,
}
/* queryClient Not a pure module */
