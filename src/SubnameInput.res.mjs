// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as InputPanel from "./components/InputPanel.res.mjs";
import * as NameContext from "./NameContext.res.mjs";
import * as ResultPanel from "./components/ResultPanel.res.mjs";
import * as TransferPanel from "./components/TransferPanel.res.mjs";
import * as RegisterExtendPanel from "./components/RegisterExtendPanel.res.mjs";

var initialState = {
  name: "",
  panel: "input",
  action: "Register",
  result: undefined
};

function SubnameInput(props) {
  var isWalletConnected = props.isWalletConnected;
  var match = React.useContext(NameContext.context);
  var setForceRefresh = match.setForceRefresh;
  var match$1 = React.useState(function () {
        return initialState;
      });
  var setState = match$1[1];
  var state = match$1[0];
  var onSuccess = function (result) {
    setState(function (prev) {
          return {
                  name: prev.name,
                  panel: "result",
                  action: prev.action,
                  result: result
                };
        });
    setForceRefresh(function (param) {
          return true;
        });
  };
  var onNext = function (name, action) {
    setState(function (prev) {
          var tmp;
          switch (action) {
            case "Register" :
                tmp = "register";
                break;
            case "Extend" :
                tmp = "extend";
                break;
            case "Transfer" :
                tmp = "transfer";
                break;
            case "Reclaim" :
                throw {
                      RE_EXN_ID: "Match_failure",
                      _1: [
                        "SubnameInput.res",
                        33,
                        13
                      ],
                      Error: new Error()
                    };
            
          }
          return {
                  name: name,
                  panel: tmp,
                  action: action,
                  result: prev.result
                };
        });
  };
  var match$2 = state.panel;
  var tmp;
  switch (match$2) {
    case "extend" :
        tmp = React.createElement(RegisterExtendPanel.make, {
              name: state.name,
              isWalletConnected: isWalletConnected,
              onBack: (function () {
                  setState(function (prev) {
                        return {
                                name: prev.name,
                                panel: "input",
                                action: prev.action,
                                result: prev.result
                              };
                      });
                }),
              onSuccess: onSuccess,
              action: state.action
            });
        break;
    case "input" :
        tmp = React.createElement(InputPanel.make, {
              onNext: onNext,
              isWalletConnected: isWalletConnected
            });
        break;
    case "register" :
        tmp = React.createElement(RegisterExtendPanel.make, {
              name: state.name,
              isWalletConnected: isWalletConnected,
              onBack: (function () {
                  setState(function (prev) {
                        return {
                                name: prev.name,
                                panel: "input",
                                action: prev.action,
                                result: prev.result
                              };
                      });
                }),
              onSuccess: onSuccess,
              action: state.action
            });
        break;
    case "result" :
        tmp = React.createElement(ResultPanel.make, {
              name: state.name,
              onRegisterAnother: (function () {
                  setState(function (param) {
                        return initialState;
                      });
                }),
              actionResult: state.result
            });
        break;
    case "transfer" :
        tmp = React.createElement(TransferPanel.make, {
              name: state.name,
              isWalletConnected: isWalletConnected,
              onBack: (function () {
                  setState(function (prev) {
                        return {
                                name: prev.name,
                                panel: "input",
                                action: prev.action,
                                result: prev.result
                              };
                      });
                }),
              onSuccess: onSuccess
            });
        break;
    default:
      tmp = React.createElement("div", undefined);
  }
  return React.createElement("div", {
              className: "w-full max-w-xl mx-auto"
            }, tmp);
}

var make = SubnameInput;

export {
  make ,
}
/* react Not a pure module */
