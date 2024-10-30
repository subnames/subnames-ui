// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "./components/Icons.res.mjs";
import * as React from "react";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as ReadContract from "./ReadContract.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";

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

function SubnameInput(props) {
  var onConnectWallet = props.onConnectWallet;
  var onValidChange = props.onValidChange;
  var match = React.useState(function () {
        return {
                value: "",
                isValid: false,
                errorMessage: undefined,
                isChecking: false,
                isAvailable: undefined,
                showFeeSelect: false,
                fee: {
                  years: 1,
                  feeAmount: "0.1"
                },
                isCalculatingFee: false
              };
      });
  var setState = match[1];
  var state = match[0];
  var timeoutRef = React.useRef(undefined);
  var checkNameAvailability = async function (value) {
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: true,
                  isAvailable: undefined,
                  showFeeSelect: prev.showFeeSelect,
                  fee: prev.fee,
                  isCalculatingFee: prev.isCalculatingFee
                };
        });
    try {
      var available = await ReadContract.available(value);
      console.log(available);
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: prev.errorMessage,
                          isChecking: false,
                          isAvailable: available,
                          showFeeSelect: prev.showFeeSelect,
                          fee: prev.fee,
                          isCalculatingFee: prev.isCalculatingFee
                        };
                });
    }
    catch (exn){
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: "Failed to check availability",
                          isChecking: false,
                          isAvailable: prev.isAvailable,
                          showFeeSelect: prev.showFeeSelect,
                          fee: prev.fee,
                          isCalculatingFee: prev.isCalculatingFee
                        };
                });
    }
  };
  var handleChange = function ($$event) {
    var newValue = $$event.target.value;
    setState(function (prev) {
          return {
                  value: newValue,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  showFeeSelect: prev.showFeeSelect,
                  fee: prev.fee,
                  isCalculatingFee: prev.isCalculatingFee
                };
        });
    var timeout = timeoutRef.current;
    if (timeout !== undefined) {
      clearTimeout(Caml_option.valFromOption(timeout));
    }
    var timeout$1 = setTimeout((function () {
            var match = isValidSubname(newValue);
            var errorMessage = match[1];
            var isValid = match[0];
            setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: isValid,
                          errorMessage: errorMessage,
                          isChecking: prev.isChecking,
                          isAvailable: prev.isAvailable,
                          showFeeSelect: prev.showFeeSelect,
                          fee: prev.fee,
                          isCalculatingFee: prev.isCalculatingFee
                        };
                });
            onValidChange(newValue, isValid);
            if (isValid && newValue !== "") {
              checkNameAvailability(newValue);
            }
            
          }), 500);
    timeoutRef.current = Caml_option.some(timeout$1);
  };
  var handleClear = function (param) {
    setState(function (param) {
          return {
                  value: "",
                  isValid: false,
                  errorMessage: undefined,
                  isChecking: false,
                  isAvailable: undefined,
                  showFeeSelect: false,
                  fee: {
                    years: 1,
                    feeAmount: "0.1"
                  },
                  isCalculatingFee: false
                };
        });
    onValidChange("", false);
  };
  var calculateFee = async function (years) {
    try {
      console.log("years: " + years.toString());
      console.log("state.value: " + state.value);
      var duration = Math.imul(years, ReadContract.secondsPerYear);
      console.log("duration: " + duration.toString());
      var priceInWei = await ReadContract.registerPrice(state.value, duration);
      console.log("price: " + priceInWei.toString());
      var priceInEth = (Number(priceInWei) / 10e18).toFixed(8);
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: prev.errorMessage,
                          isChecking: prev.isChecking,
                          isAvailable: prev.isAvailable,
                          showFeeSelect: prev.showFeeSelect,
                          fee: {
                            years: years,
                            feeAmount: priceInEth
                          },
                          isCalculatingFee: prev.isCalculatingFee
                        };
                });
    }
    catch (raw_err){
      var err = Caml_js_exceptions.internalToOCamlException(raw_err);
      console.error(err);
      return ;
    }
  };
  var incrementYears = function () {
    if (state.isCalculatingFee) {
      return ;
    }
    var newYears = state.fee.years + 1 | 0;
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  showFeeSelect: prev.showFeeSelect,
                  fee: prev.fee,
                  isCalculatingFee: true
                };
        });
    calculateFee(newYears).then(function () {
          setState(function (prev) {
                return {
                        value: prev.value,
                        isValid: prev.isValid,
                        errorMessage: prev.errorMessage,
                        isChecking: prev.isChecking,
                        isAvailable: prev.isAvailable,
                        showFeeSelect: prev.showFeeSelect,
                        fee: prev.fee,
                        isCalculatingFee: false
                      };
              });
          return Promise.resolve();
        });
  };
  var decrementYears = function () {
    if (!(!state.isCalculatingFee && state.fee.years > 1)) {
      return ;
    }
    var newYears = state.fee.years - 1 | 0;
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  showFeeSelect: prev.showFeeSelect,
                  fee: prev.fee,
                  isCalculatingFee: true
                };
        });
    calculateFee(newYears).then(function () {
          setState(function (prev) {
                return {
                        value: prev.value,
                        isValid: prev.isValid,
                        errorMessage: prev.errorMessage,
                        isChecking: prev.isChecking,
                        isAvailable: prev.isAvailable,
                        showFeeSelect: prev.showFeeSelect,
                        fee: prev.fee,
                        isCalculatingFee: false
                      };
              });
          return Promise.resolve();
        });
  };
  var handleRegisterClick = function () {
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  showFeeSelect: true,
                  fee: prev.fee,
                  isCalculatingFee: true
                };
        });
    calculateFee(1).then(function () {
          setState(function (prev) {
                return {
                        value: prev.value,
                        isValid: prev.isValid,
                        errorMessage: prev.errorMessage,
                        isChecking: prev.isChecking,
                        isAvailable: prev.isAvailable,
                        showFeeSelect: prev.showFeeSelect,
                        fee: prev.fee,
                        isCalculatingFee: false
                      };
              });
          return Promise.resolve();
        });
  };
  var tmp;
  if (state.showFeeSelect) {
    tmp = JsxRuntime.jsx("div", {
          children: JsxRuntime.jsxs("div", {
                children: [
                  JsxRuntime.jsx("div", {
                        children: JsxRuntime.jsxs("div", {
                              children: [
                                JsxRuntime.jsx("button", {
                                      children: JsxRuntime.jsx(Icons.Back.make, {}),
                                      className: "p-1 hover:bg-gray-100 rounded-full transition-colors",
                                      type: "button",
                                      onClick: (function (param) {
                                          setState(function (prev) {
                                                return {
                                                        value: prev.value,
                                                        isValid: prev.isValid,
                                                        errorMessage: prev.errorMessage,
                                                        isChecking: prev.isChecking,
                                                        isAvailable: prev.isAvailable,
                                                        showFeeSelect: false,
                                                        fee: prev.fee,
                                                        isCalculatingFee: prev.isCalculatingFee
                                                      };
                                              });
                                        })
                                    }),
                                JsxRuntime.jsx("span", {
                                      children: state.value + ".ringdao.eth",
                                      className: "text-lg font-medium text-gray-700"
                                    })
                              ],
                              className: "flex items-center gap-2"
                            }),
                        className: "flex justify-between items-center mb-6"
                      }),
                  JsxRuntime.jsxs("div", {
                        children: [
                          JsxRuntime.jsx("div", {
                                children: "CLAIM FOR",
                                className: "text-lg font-medium"
                              }),
                          JsxRuntime.jsx("div", {
                                children: "AMOUNT",
                                className: "text-lg font-medium"
                              })
                        ],
                        className: "flex justify-between items-center mb-4"
                      }),
                  JsxRuntime.jsxs("div", {
                        children: [
                          JsxRuntime.jsxs("div", {
                                children: [
                                  JsxRuntime.jsx("button", {
                                        children: "-",
                                        className: "w-10 h-10 rounded-full " + (
                                          state.isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"
                                        ) + " flex items-center justify-center",
                                        disabled: state.isCalculatingFee,
                                        onClick: (function (param) {
                                            decrementYears();
                                          })
                                      }),
                                  JsxRuntime.jsx("div", {
                                        children: state.fee.years.toString() + " year" + (
                                          state.fee.years > 1 ? "s" : ""
                                        ),
                                        className: "text-3xl font-bold"
                                      }),
                                  JsxRuntime.jsx("button", {
                                        children: "+",
                                        className: "w-10 h-10 rounded-full " + (
                                          state.isCalculatingFee ? "bg-gray-50 cursor-not-allowed" : "bg-gray-100"
                                        ) + " flex items-center justify-center",
                                        disabled: state.isCalculatingFee,
                                        onClick: (function (param) {
                                            incrementYears();
                                          })
                                      })
                                ],
                                className: "flex items-center gap-4"
                              }),
                          JsxRuntime.jsx("div", {
                                children: state.isCalculatingFee ? JsxRuntime.jsx(Icons.Spinner.make, {
                                        className: "w-8 h-8 text-zinc-600"
                                      }) : state.fee.feeAmount + " RING",
                                className: "text-3xl font-bold"
                              })
                        ],
                        className: "flex justify-between items-center"
                      }),
                  JsxRuntime.jsx("div", {
                        children: props.isWalletConnected ? JsxRuntime.jsx("button", {
                                children: "Register name",
                                className: "w-full py-3 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-full font-medium",
                                onClick: (function (param) {
                                    
                                  })
                              }) : JsxRuntime.jsx("button", {
                                children: "Connect wallet",
                                className: "w-full py-3 px-4 bg-zinc-800 hover:bg-zinc-700 text-white rounded-full font-medium",
                                onClick: (function (param) {
                                    onConnectWallet();
                                  })
                              }),
                        className: "mt-6"
                      })
                ],
                className: "p-6"
              }),
          className: "bg-white rounded-custom shadow-lg overflow-hidden"
        });
  } else {
    var error = state.errorMessage;
    var tmp$1;
    if (error !== undefined) {
      tmp$1 = JsxRuntime.jsx("div", {
            children: JsxRuntime.jsx("div", {
                  children: error,
                  className: "text-gray-600 text-md"
                }),
            className: "px-6 py-4"
          });
    } else if (state.isValid && state.value !== "") {
      var tmp$2;
      if (state.isChecking) {
        tmp$2 = JsxRuntime.jsx(Icons.Spinner.make, {
              className: "w-5 h-5 text-zinc-600"
            });
      } else {
        var match$1 = state.isAvailable;
        tmp$2 = match$1 !== undefined ? (
            match$1 ? JsxRuntime.jsx("button", {
                    children: "Next",
                    className: "rounded-full bg-zinc-800 px-3 py-1.5 text-sm font-medium text-white hover:bg-zinc-700",
                    type: "button",
                    onClick: (function (param) {
                        handleRegisterClick();
                      })
                  }) : JsxRuntime.jsx("span", {
                    children: "Not available",
                    className: "text-red-500 text-sm"
                  })
          ) : null;
      }
      tmp$1 = JsxRuntime.jsx("div", {
            children: JsxRuntime.jsxs("div", {
                  children: [
                    JsxRuntime.jsx("p", {
                          children: state.value + ".ringdao.eth",
                          className: "text-gray-700"
                        }),
                    tmp$2
                  ],
                  className: "flex items-center justify-between"
                }),
            className: "px-6 py-4"
          });
    } else {
      tmp$1 = null;
    }
    tmp = JsxRuntime.jsxs("div", {
          children: [
            JsxRuntime.jsxs("div", {
                  children: [
                    JsxRuntime.jsx("input", {
                          className: "w-full px-6 py-4 text-lg focus:outline-none",
                          placeholder: "SEARCH FOR A NAME",
                          type: "text",
                          value: state.value,
                          onChange: handleChange
                        }),
                    JsxRuntime.jsxs("div", {
                          children: [
                            state.value !== "" ? JsxRuntime.jsx("button", {
                                    children: JsxRuntime.jsx(Icons.Close.make, {}),
                                    className: "p-1 hover:bg-gray-100 rounded-full transition-colors",
                                    type: "button",
                                    onClick: handleClear
                                  }) : null,
                            state.value === "" ? JsxRuntime.jsx(Icons.Search.make, {}) : null
                          ],
                          className: "absolute right-4 top-1/2 -translate-y-1/2 flex items-center gap-2"
                        })
                  ],
                  className: "relative " + (
                    Core__Option.isSome(state.errorMessage) || state.isValid && state.value !== "" ? "divide-y-short" : ""
                  )
                }),
            tmp$1
          ],
          className: "bg-white rounded-custom shadow-lg overflow-hidden"
        });
  }
  return JsxRuntime.jsx("div", {
              children: tmp,
              className: "w-full max-w-xl mx-auto"
            });
}

var make = SubnameInput;

export {
  make ,
}
/* Icons Not a pure module */
