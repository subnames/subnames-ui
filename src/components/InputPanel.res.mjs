// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "./Icons.res.mjs";
import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Constants from "../Constants.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

var initialState = {
  value: "",
  isValid: false,
  errorMessage: undefined,
  isChecking: false,
  isAvailable: undefined,
  isOwnedByUser: undefined,
  expiryDate: undefined
};

function isValidSubname(name) {
  var length = name.length;
  if (length === 0) {
    return [
            false,
            undefined
          ];
  }
  if (length < 3) {
    return [
            false,
            "Name is too short"
          ];
  }
  if (length > 32) {
    return [
            false,
            "Name is too long"
          ];
  }
  var validCharRegex = /^[a-zA-Z0-9-]+$/;
  var isValidFormat = validCharRegex.test(name);
  if (isValidFormat) {
    if (Caml_obj.equal(name[0], "-") || Caml_obj.equal(name[length - 1 | 0], "-")) {
      return [
              false,
              "Cannot start or end with hyphen"
            ];
    } else {
      return [
              true,
              undefined
            ];
    }
  } else {
    return [
            false,
            "Invalid characters"
          ];
  }
}

async function isOwner(name, isWalletConnected) {
  if (!isWalletConnected) {
    return ;
  }
  var walletClient = OnChainOperationsCommon.buildWalletClient();
  if (walletClient === undefined) {
    return ;
  }
  var owner = await OnChainOperations.owner(name);
  var currentAccount = await OnChainOperationsCommon.currentAddress(Caml_option.valFromOption(walletClient));
  return owner === currentAccount;
}

function InputPanel(props) {
  var isWalletConnected = props.isWalletConnected;
  var onNext = props.onNext;
  var match = React.useState(function () {
        return initialState;
      });
  var setState = match[1];
  var state = match[0];
  var checkNameAvailability = async function (value) {
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: true,
                  isAvailable: undefined,
                  isOwnedByUser: undefined,
                  expiryDate: undefined
                };
        });
    try {
      var available = await OnChainOperations.available(value);
      if (available) {
        return setState(function (prev) {
                    return {
                            value: prev.value,
                            isValid: prev.isValid,
                            errorMessage: prev.errorMessage,
                            isChecking: false,
                            isAvailable: true,
                            isOwnedByUser: undefined,
                            expiryDate: undefined
                          };
                  });
      }
      var isOwner$1 = await isOwner(value, isWalletConnected);
      var expiryInt = await OnChainOperations.nameExpires(value);
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: prev.errorMessage,
                          isChecking: false,
                          isAvailable: false,
                          isOwnedByUser: isOwner$1,
                          expiryDate: Caml_option.some(Utils.timestampToDate(expiryInt))
                        };
                });
    }
    catch (raw_e){
      var e = Caml_js_exceptions.internalToOCamlException(raw_e);
      console.error(e);
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: "Failed to check availability",
                          isChecking: false,
                          isAvailable: prev.isAvailable,
                          isOwnedByUser: undefined,
                          expiryDate: undefined
                        };
                });
    }
  };
  React.useEffect((function () {
          if (state.value !== "" && state.isValid) {
            checkNameAvailability(state.value);
          }
          
        }), [
        isWalletConnected,
        state.value
      ]);
  var runValidation = Utils.useDebounce((function (value) {
          var match = isValidSubname(value);
          var errorMessage = match[1];
          var isValid = match[0];
          setState(function (prev) {
                return {
                        value: prev.value,
                        isValid: isValid,
                        errorMessage: errorMessage,
                        isChecking: prev.isChecking,
                        isAvailable: prev.isAvailable,
                        isOwnedByUser: prev.isOwnedByUser,
                        expiryDate: prev.expiryDate
                      };
              });
          if (isValid && value !== "") {
            checkNameAvailability(value);
            return ;
          }
          
        }), 500);
  var handleChange = function ($$event) {
    var newValue = $$event.target.value;
    setState(function (prev) {
          return {
                  value: newValue,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  isOwnedByUser: prev.isOwnedByUser,
                  expiryDate: prev.expiryDate
                };
        });
    runValidation(newValue);
  };
  var handleClear = function (param) {
    setState(function (param) {
          return initialState;
        });
  };
  var error = state.errorMessage;
  var tmp;
  if (error !== undefined) {
    tmp = React.createElement("div", {
          className: "px-6 py-4"
        }, React.createElement("div", {
              className: "text-gray-600 text-md"
            }, error));
  } else if (state.isValid && state.value !== "") {
    var match$1 = state.isOwnedByUser;
    var match$2 = state.expiryDate;
    var tmp$1;
    if (state.isChecking) {
      tmp$1 = React.createElement(Icons.Spinner.make, {
            className: "w-5 h-5 text-zinc-600"
          });
    } else {
      var match$3 = state.isAvailable;
      if (match$3 !== undefined) {
        if (match$3) {
          tmp$1 = React.createElement("button", {
                className: "rounded-xl bg-zinc-800 px-3 py-1.5 text-sm font-medium text-white hover:bg-zinc-700",
                type: "button",
                onClick: (function (param) {
                    onNext(state.value, "Register");
                  })
              }, "Register");
        } else {
          var match$4 = state.isOwnedByUser;
          var exit = 0;
          if (match$4 !== undefined && match$4) {
            tmp$1 = React.createElement("div", {
                  className: "flex gap-2"
                }, React.createElement("button", {
                      className: "rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50",
                      type: "button",
                      onClick: (function (param) {
                          onNext(state.value, "Transfer");
                        })
                    }, "Transfer"), React.createElement("button", {
                      className: "rounded-xl bg-white border border-zinc-300 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50",
                      type: "button",
                      onClick: (function (param) {
                          onNext(state.value, {
                                TAG: "Extend",
                                _0: state.expiryDate
                              });
                        })
                    }, "Extend"));
          } else {
            exit = 1;
          }
          if (exit === 1) {
            tmp$1 = React.createElement("span", {
                  className: "text-red-500 text-sm"
                }, "Not available");
          }
          
        }
      } else {
        tmp$1 = null;
      }
    }
    tmp = React.createElement("div", {
          className: "px-6 py-4"
        }, React.createElement("div", {
              className: "flex items-center justify-between"
            }, React.createElement("div", undefined, React.createElement("p", {
                      className: "text-gray-800"
                    }, state.value + "." + Constants.sld), match$1 !== undefined && match$1 && match$2 !== undefined ? React.createElement("p", {
                        className: "text-xs text-gray-400 mt-1"
                      }, "Your name will expire " + Utils.distanceToExpiry(Caml_option.valFromOption(match$2))) : null), tmp$1));
  } else {
    tmp = null;
  }
  return React.createElement("div", {
              className: "bg-white rounded-custom shadow-lg overflow-hidden"
            }, React.createElement("div", {
                  className: "relative " + (
                    Core__Option.isSome(state.errorMessage) || state.isValid && state.value !== "" ? "divide-y-short" : ""
                  )
                }, React.createElement("input", {
                      className: "w-full px-6 py-4 text-lg focus:outline-none",
                      placeholder: "SEARCH FOR A NAME",
                      type: "text",
                      value: state.value,
                      onChange: handleChange
                    }), React.createElement("div", {
                      className: "absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2"
                    }, state.value !== "" ? React.createElement("button", {
                            className: "p-1 hover:bg-gray-100 rounded-full transition-colors",
                            type: "button",
                            onClick: handleClear
                          }, React.createElement(Icons.Close.make, {})) : null, state.value === "" ? React.createElement("div", {
                            className: "p-1 rounded-full transition-colors"
                          }, React.createElement(Icons.Search.make, {})) : null)), tmp);
}

var make = InputPanel;

export {
  initialState ,
  isValidSubname ,
  isOwner ,
  make ,
}
/* Icons Not a pure module */
