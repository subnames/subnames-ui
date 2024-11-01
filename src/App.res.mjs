// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Wagmi from "wagmi";
import * as Constants from "./Constants.res.mjs";
import * as SubnameInput from "./SubnameInput.res.mjs";
import * as Chains from "wagmi/chains";
import * as MyConnectButton from "./components/MyConnectButton.res.mjs";
import * as ReactQuery from "@tanstack/react-query";
import * as Rainbowkit from "@rainbow-me/rainbowkit";

var queryClient = new ReactQuery.QueryClient();

var transports = new Map();

transports.set(Chains.koi.id, Wagmi.http());

var config = Rainbowkit.getDefaultConfig({
      appName: "Subnames App",
      projectId: "873f70fa626990b1ee3c14d55130a573",
      chains: [Chains.koi],
      transports: transports,
      ssr: false
    });

function App$Layout(props) {
  return React.createElement("div", {
              className: "min-h-screen bg-gray-50"
            }, React.createElement("header", undefined, React.createElement("div", {
                      className: "max-w-7xl mx-auto px-4 sm:px-6 lg:px-8"
                    }, React.createElement("div", {
                          className: "flex justify-between items-center h-16"
                        }, React.createElement("div", {
                              className: "flex-shrink-0"
                            }, React.createElement("h1", {
                                  className: "text-xl font-bold text-gray-900"
                                }, Constants.sld)), React.createElement("div", {
                              className: "flex items-center"
                            }, React.createElement(MyConnectButton.make, {}))))), React.createElement("main", undefined, React.createElement("div", {
                      className: "max-w-7xl mx-auto py-6 sm:px-6 lg:px-8"
                    }, props.children)));
}

function App$Subname(props) {
  var match = React.useState(function () {
        return [
                "",
                false
              ];
      });
  var setValidSubname = match[1];
  var account = Wagmi.useAccount();
  var match$1 = React.useState(function () {
        return false;
      });
  var setWalletConnected = match$1[1];
  React.useEffect((function () {
          setWalletConnected(function (param) {
                return account.isConnected;
              });
        }), [account.isConnected]);
  var handleValidChange = function (value, isValid) {
    setValidSubname(function (param) {
          return [
                  value,
                  isValid
                ];
        });
  };
  var handleConnectWallet = function () {
    var connectButton = document.querySelector("[data-testid='rk-connect-button']");
    connectButton.click();
  };
  return React.createElement("div", {
              className: "p-8"
            }, React.createElement(SubnameInput.make, {
                  onValidChange: handleValidChange,
                  isWalletConnected: match$1[0],
                  onConnectWallet: handleConnectWallet
                }));
}

function App(props) {
  return React.createElement(Wagmi.WagmiProvider, {
              config: config,
              children: React.createElement(ReactQuery.QueryClientProvider, {
                    client: queryClient,
                    children: React.createElement(Rainbowkit.RainbowKitProvider, {
                          children: React.createElement(App$Layout, {
                                children: React.createElement(App$Subname, {})
                              }),
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
