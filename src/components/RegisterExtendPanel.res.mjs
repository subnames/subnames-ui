// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Fee from "../Fee.res.mjs";
import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Constants from "../Constants.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function RegisterExtendPanel(props) {
  var action = props.action;
  var onSuccess = props.onSuccess;
  var onBack = props.onBack;
  var name = props.name;
  var match = React.useState(function () {
        return {
                years: 1,
                feeAmount: 0.0
              };
      });
  var setFee = match[1];
  var fee = match[0];
  var match$1 = React.useState(function () {
        return false;
      });
  var setIsCalculatingFee = match$1[1];
  var isCalculatingFee = match$1[0];
  var match$2 = React.useState(function () {
        return false;
      });
  var setIsWaitingForConfirmation = match$2[1];
  var isWaitingForConfirmation = match$2[0];
  var match$3 = React.useState(function () {
        return "Simulating";
      });
  var setOnChainStatus = match$3[1];
  var calculateFee = async function (years) {
    switch (action) {
      case "Register" :
          var priceInEth = await Fee.calculate(name, years);
          return setFee(function (param) {
                      return {
                              years: years,
                              feeAmount: priceInEth
                            };
                    });
      case "Extend" :
          var priceInEth$1 = await Fee.calculateRenew(name, years);
          return setFee(function (param) {
                      return {
                              years: years,
                              feeAmount: priceInEth$1
                            };
                    });
      case "Transfer" :
      case "Reclaim" :
          throw {
                RE_EXN_ID: "Match_failure",
                _1: [
                  "RegisterExtendPanel.res",
                  27,
                  4
                ],
                Error: new Error()
              };
      
    }
  };
  var incrementYears = function () {
    if (isCalculatingFee) {
      return ;
    }
    var newYears = fee.years + 1 | 0;
    setIsCalculatingFee(function (param) {
          return true;
        });
    calculateFee(newYears).then(function () {
          setIsCalculatingFee(function (param) {
                return false;
              });
          return Promise.resolve();
        });
  };
  var decrementYears = function () {
    if (!(!isCalculatingFee && fee.years > 1)) {
      return ;
    }
    var newYears = fee.years - 1 | 0;
    setIsCalculatingFee(function (param) {
          return true;
        });
    calculateFee(newYears).then(function () {
          setIsCalculatingFee(function (param) {
                return false;
              });
          return Promise.resolve();
        });
  };
  React.useEffect((function () {
          setIsCalculatingFee(function (param) {
                return true;
              });
          calculateFee(1).then(function () {
                setIsCalculatingFee(function (param) {
                      return false;
                    });
                return Promise.resolve();
              });
        }), []);
  var handleConnectWallet = function () {
    var connectButton = document.querySelector("[data-testid='rk-connect-button']");
    connectButton.click();
  };
  var tmp;
  switch (action) {
    case "Register" :
        tmp = "CLAIM FOR";
        break;
    case "Extend" :
        tmp = "EXTEND FOR";
        break;
    case "Transfer" :
    case "Reclaim" :
        throw {
              RE_EXN_ID: "Match_failure",
              _1: [
                "RegisterExtendPanel.res",
                128,
                13
              ],
              Error: new Error()
            };
    
  }
  var tmp$1;
  if (props.isWalletConnected) {
    var tmp$2;
    if (isWaitingForConfirmation) {
      switch (action) {
        case "Register" :
            tmp$2 = "Registering...";
            break;
        case "Extend" :
            tmp$2 = "Extending...";
            break;
        case "Transfer" :
        case "Reclaim" :
            throw {
                  RE_EXN_ID: "Match_failure",
                  _1: [
                    "RegisterExtendPanel.res",
                    184,
                    14
                  ],
                  Error: new Error()
                };
        
      }
    } else if (isCalculatingFee) {
      tmp$2 = "Calculating...";
    } else {
      switch (action) {
        case "Register" :
            tmp$2 = "Register";
            break;
        case "Extend" :
            tmp$2 = "Extend";
            break;
        case "Transfer" :
        case "Reclaim" :
            throw {
                  RE_EXN_ID: "Match_failure",
                  _1: [
                    "RegisterExtendPanel.res",
                    191,
                    14
                  ],
                  Error: new Error()
                };
        
      }
    }
    tmp$1 = React.createElement("button", {
          className: "w-full py-4 px-6 " + (
            isCalculatingFee || isWaitingForConfirmation ? "bg-zinc-400 cursor-not-allowed" : "bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900"
          ) + " text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md",
          disabled: isCalculatingFee || isWaitingForConfirmation,
          onClick: (function (param) {
              var years = fee.years;
              setIsWaitingForConfirmation(function (param) {
                    return true;
                  });
              var walletClient = OnChainOperationsCommon.buildWalletClient();
              switch (action) {
                case "Register" :
                    OnChainOperations.register(walletClient, name, years, undefined, (function (status) {
                              setOnChainStatus(function (param) {
                                    return status;
                                  });
                            })).then(function () {
                          return OnChainOperations.nameExpires(name).then(function (expiryInt) {
                                      var newExpiryDate = new Date(expiryInt * 1000.0);
                                      onSuccess({
                                            action: action,
                                            newExpiryDate: Caml_option.some(newExpiryDate)
                                          });
                                      return Promise.resolve();
                                    });
                        });
                    return ;
                case "Extend" :
                    OnChainOperations.renew(walletClient, name, years).then(function () {
                          return OnChainOperations.nameExpires(name).then(function (expiryInt) {
                                      var newExpiryDate = new Date(expiryInt * 1000.0);
                                      onSuccess({
                                            action: action,
                                            newExpiryDate: Caml_option.some(newExpiryDate)
                                          });
                                      return Promise.resolve();
                                    });
                        });
                    return ;
                case "Transfer" :
                case "Reclaim" :
                    throw {
                          RE_EXN_ID: "Match_failure",
                          _1: [
                            "RegisterExtendPanel.res",
                            77,
                            4
                          ],
                          Error: new Error()
                        };
                
              }
            })
        }, tmp$2);
  } else {
    tmp$1 = React.createElement("button", {
          className: "w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md",
          onClick: (function (param) {
              handleConnectWallet();
            })
        }, "Connect wallet");
  }
  return React.createElement("div", {
              className: "bg-white rounded-custom shadow-lg overflow-hidden"
            }, React.createElement("div", {
                  className: "p-4 sm:p-6 max-w-2xl mx-auto"
                }, React.createElement("div", {
                      className: "flex justify-between items-center mb-8"
                    }, React.createElement("div", {
                          className: "flex items-center justify-center gap-3"
                        }, React.createElement("button", {
                              className: "p-2 hover:bg-gray-100 rounded-full transition-colors",
                              type: "button",
                              onClick: (function (param) {
                                  onBack();
                                })
                            }, React.createElement("div", {
                                  className: "w-6 h-6 text-gray-600"
                                }, React.createElement(Icons.Back.make, {}))), React.createElement("span", {
                              className: "text-lg sm:text-xl font-medium text-gray-700 truncate"
                            }, name + "." + Constants.sld))), React.createElement("div", {
                      className: "flex flex-col sm:flex-row justify-between gap-6 mb-8"
                    }, React.createElement("div", {
                          className: "space-y-2"
                        }, React.createElement("div", {
                              className: "text-base sm:text-lg font-medium text-gray-600 text-center sm:text-left"
                            }, tmp), React.createElement("div", {
                              className: "flex items-center justify-center gap-4"
                            }, React.createElement("button", {
                                  className: "w-12 h-12 rounded-full " + (
                                    isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100 hover:bg-gray-200"
                                  ) + " flex items-center justify-center transition-colors",
                                  disabled: isCalculatingFee,
                                  onClick: (function (param) {
                                      decrementYears();
                                    })
                                }, React.createElement("span", {
                                      className: "text-xl font-medium text-gray-700"
                                    }, "-")), React.createElement("div", {
                                  className: "text-2xl sm:text-3xl font-bold text-gray-900 min-w-[120px] text-center"
                                }, fee.years.toString() + " year" + (
                                  fee.years > 1 ? "s" : ""
                                )), React.createElement("button", {
                                  className: "w-12 h-12 rounded-full " + (
                                    isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100 hover:bg-gray-200"
                                  ) + " flex items-center justify-center transition-colors",
                                  disabled: isCalculatingFee,
                                  onClick: (function (param) {
                                      incrementYears();
                                    })
                                }, React.createElement("span", {
                                      className: "text-xl font-medium text-gray-700"
                                    }, "+")))), React.createElement("div", {
                          className: "space-y-2"
                        }, React.createElement("div", {
                              className: "text-base sm:text-lg font-medium text-gray-600 text-center sm:text-right"
                            }, "AMOUNT"), React.createElement("div", {
                              className: "text-2xl sm:text-3xl font-bold text-gray-900 h-12 flex items-center justify-center sm:justify-end"
                            }, isCalculatingFee ? React.createElement(Icons.Spinner.make, {
                                    className: "w-8 h-8 text-zinc-600"
                                  }) : fee.feeAmount.toExponential(2) + " RING"))), React.createElement("div", {
                      className: "mt-8"
                    }, tmp$1)));
}

var make = RegisterExtendPanel;

export {
  make ,
}
/* Fee Not a pure module */
