// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Fee from "../Fee.res.mjs";
import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Js_exn from "rescript/lib/es6/js_exn.js";
import * as Constants from "../Constants.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function RegisterExtendPanel(props) {
  var __buttonType = props.buttonType;
  var action = props.action;
  var onSuccess = props.onSuccess;
  var onBack = props.onBack;
  var name = props.name;
  var buttonType = __buttonType !== undefined ? __buttonType : "close";
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
          return Js_exn.raiseError("Unreachable");
      
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
        tmp = "Register";
        break;
    case "Extend" :
        tmp = "Extend";
        break;
    case "Transfer" :
    case "Reclaim" :
        tmp = Js_exn.raiseError("Unreachable");
        break;
    
  }
  var tmp$1;
  if (props.isWalletConnected) {
    var tmp$2;
    if (isWaitingForConfirmation) {
      var tmp$3;
      switch (action) {
        case "Register" :
            tmp$3 = "Registering...";
            break;
        case "Extend" :
            tmp$3 = "Extending...";
            break;
        case "Transfer" :
        case "Reclaim" :
            tmp$3 = Js_exn.raiseError("Unreachable");
            break;
        
      }
      tmp$2 = React.createElement(React.Fragment, {}, React.createElement(Icons.Spinner.make, {
                className: "w-5 h-5 text-white"
              }), React.createElement("span", undefined, tmp$3));
    } else if (isCalculatingFee) {
      tmp$2 = React.createElement(React.Fragment, {}, React.createElement(Icons.Spinner.make, {
                className: "w-5 h-5 text-white"
              }), React.createElement("span", undefined, "Calculating..."));
    } else {
      var tmp$4;
      switch (action) {
        case "Register" :
            tmp$4 = "Register Now";
            break;
        case "Extend" :
            tmp$4 = "Extend Now";
            break;
        case "Transfer" :
        case "Reclaim" :
            tmp$4 = Js_exn.raiseError("Unreachable");
            break;
        
      }
      tmp$2 = React.createElement("span", undefined, tmp$4);
    }
    tmp$1 = React.createElement("button", {
          className: "w-full py-4 px-6 " + (
            isCalculatingFee || isWaitingForConfirmation ? "bg-zinc-400 cursor-not-allowed dark:bg-[#ffffff0a]" : "bg-zinc-800 hover:bg-zinc-700 dark:bg-[#ffffff0a] dark:hover:bg-[#ffffff14] "
          ) + " text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2",
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
                    return Js_exn.raiseError("Unreachable");
                
              }
            })
        }, tmp$2);
  } else {
    tmp$1 = React.createElement("button", {
          className: "w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2 dark:bg-zinc-700 dark:hover:bg-zinc-600 dark:active:bg-zinc-800",
          onClick: (function (param) {
              handleConnectWallet();
            })
        }, React.createElement("span", undefined, "Connect Wallet"));
  }
  return React.createElement("div", {
              className: "fixed inset-0 flex items-center justify-center z-40"
            }, React.createElement("div", {
                  className: "fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm dark:bg-opacity-80"
                }), React.createElement("div", {
                  className: "bg-white rounded-custom shadow-2xl overflow-hidden relative z-50 max-w-md w-full mx-4 animate-fadeIn dark:bg-[#1b1b1b] dark:border dark:border-[rgba(255,255,255,0.08)]"
                }, React.createElement("div", {
                      className: "pt-6 pb-8 px-8"
                    }, React.createElement("div", {
                          className: "flex justify-between"
                        }, React.createElement("div", {
                              className: "flex gap-3"
                            }, buttonType === "close" ? null : React.createElement("button", {
                                    className: "p-1 hover:bg-gray-100 rounded-full transition-colors dark:hover:bg-gray-700",
                                    type: "button",
                                    onClick: (function (param) {
                                        onBack();
                                      })
                                  }, React.createElement(Icons.Back.make, {})), React.createElement("div", undefined, React.createElement("h1", {
                                      className: "text-xl font-semibold text-gray-900 truncate dark:text-white"
                                    }, tmp), React.createElement("div", {
                                      className: "mt-0"
                                    }, React.createElement("span", {
                                          className: "text-sm text-gray-500 dark:text-gray-400"
                                        }, name + "." + Constants.sld)))), buttonType === "close" ? React.createElement("div", {
                                className: "self-center"
                              }, React.createElement("button", {
                                    className: "rounded-full transition-colors hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300",
                                    type: "button",
                                    onClick: (function (param) {
                                        onBack();
                                      })
                                  }, React.createElement(Icons.Close.make, {}))) : null), React.createElement("div", {
                          className: "border-t border-gray-200 my-4 -mx-8 dark:border-[rgba(255,255,255,0.08)]"
                        }), React.createElement("div", {
                          className: "p-6 rounded-xl"
                        }, React.createElement("div", {
                              className: "flex flex-col items-center gap-6"
                            }, React.createElement("div", {
                                  className: "w-full"
                                }, React.createElement("div", {
                                      className: "flex items-center justify-between border-2 border-gray-600 rounded-full p-1 w-full max-w-md dark:border-gray-500"
                                    }, React.createElement("button", {
                                          className: "w-10 h-10 border-2 border-gray-300 rounded-full " + (
                                            isCalculatingFee || fee.years <= 1 ? "bg-gray-200 text-gray-400 cursor-not-allowed dark:bg-gray-700 dark:text-gray-500" : "bg-gray-200 text-gray-700 hover:bg-gray-100 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600"
                                          ) + " flex items-center justify-center transition-colors",
                                          disabled: isCalculatingFee || fee.years <= 1,
                                          onClick: (function (param) {
                                              decrementYears();
                                            })
                                        }, React.createElement("div", {
                                              className: "flex items-center justify-center w-5 h-5"
                                            }, React.createElement(Icons.Minus.make, {}))), React.createElement("div", {
                                          className: "text-2xl font-bold text-gray-900 text-center dark:text-white"
                                        }, fee.years.toString() + " year" + (
                                          fee.years > 1 ? "s" : ""
                                        )), React.createElement("button", {
                                          className: "w-10 h-10 border-2 border-gray-300 rounded-full " + (
                                            isCalculatingFee ? "bg-gray-200 text-gray-400 cursor-not-allowed dark:bg-gray-700 dark:text-gray-500" : "bg-gray-200 text-gray-700 hover:bg-gray-100 dark:bg-gray-700 dark:text-gray-200 dark:hover:bg-gray-600"
                                          ) + " flex items-center justify-center transition-colors",
                                          disabled: isCalculatingFee,
                                          onClick: (function (param) {
                                              incrementYears();
                                            })
                                        }, React.createElement("div", {
                                              className: "flex items-center justify-center w-5 h-5"
                                            }, React.createElement(Icons.Plus.make, {}))))), React.createElement("div", {
                                  className: "w-full flex flex-col items-center pt-2"
                                }, React.createElement("div", {
                                      className: "text-sm font-medium text-gray-600 text-center uppercase tracking-wider dark:text-gray-400"
                                    }, "Cost"), React.createElement("div", {
                                      className: "py-1 min-w-[180px] text-center"
                                    }, isCalculatingFee ? React.createElement("div", {
                                            className: "flex items-center justify-center gap-2 h-12"
                                          }, React.createElement(Icons.Spinner.make, {
                                                className: "w-6 h-6 text-gray-600 dark:text-gray-400"
                                              }), React.createElement("span", {
                                                className: "text-gray-500 font-medium dark:text-gray-400"
                                              }, "Calculating...")) : React.createElement("div", {
                                            className: "flex flex-col items-center"
                                          }, React.createElement("div", {
                                                className: "text-3xl font-bold text-gray-900 dark:text-white"
                                              }, fee.feeAmount.toFixed()), React.createElement("div", {
                                                className: "text-xs text-gray-500 mt-1 dark:text-gray-400"
                                              }, "Paid in RING tokens on Darwinia Network")))))), React.createElement("div", {
                          className: "mt-2"
                        }, tmp$1))));
}

var make = RegisterExtendPanel;

export {
  make ,
}
/* Fee Not a pure module */
