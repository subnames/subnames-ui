// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as React from "react";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Ens from "viem/ens";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as JsxRuntime from "react/jsx-runtime";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";

var contract = {
  address: "0xd3E89BB05F63337a450711156683d533db976C85",
  abi: [{
      inputs: [{
          name: "node",
          type: "bytes32"
        }],
      name: "recordExists",
      outputs: [{
          name: "",
          type: "bool"
        }],
      stateMutability: "view",
      type: "function"
    }]
};

var client = Viem.createPublicClient({
      chain: Viem.koi,
      transport: Viem.http("https://koi-rpc.darwinia.network")
    });

function recordExists(name) {
  try {
    var node = Ens.namehash(name + ".ringdao.eth");
    console.log(node);
    return client.readContract({
                address: contract.address,
                abi: contract.abi,
                functionName: "recordExists",
                args: [node]
              });
  }
  catch (raw_err){
    var err = Caml_js_exceptions.internalToOCamlException(raw_err);
    console.error("Error checking recordExists:", err);
    return Promise.reject(err);
  }
}

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
                  feeAmount: 0.1
                }
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
                  fee: prev.fee
                };
        });
    try {
      var available = !await recordExists(value);
      console.log(available);
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: prev.errorMessage,
                          isChecking: false,
                          isAvailable: available,
                          showFeeSelect: prev.showFeeSelect,
                          fee: prev.fee
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
                          fee: prev.fee
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
                  fee: prev.fee
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
                          fee: prev.fee
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
                    feeAmount: 0.1
                  }
                };
        });
    onValidChange("", false);
  };
  var incrementYears = function () {
    setState(function (prev) {
          return {
                  value: prev.value,
                  isValid: prev.isValid,
                  errorMessage: prev.errorMessage,
                  isChecking: prev.isChecking,
                  isAvailable: prev.isAvailable,
                  showFeeSelect: prev.showFeeSelect,
                  fee: {
                    years: prev.fee.years + 1 | 0,
                    feeAmount: 0.1 * (prev.fee.years + 1 | 0)
                  }
                };
        });
  };
  var decrementYears = function () {
    if (state.fee.years > 1) {
      return setState(function (prev) {
                  return {
                          value: prev.value,
                          isValid: prev.isValid,
                          errorMessage: prev.errorMessage,
                          isChecking: prev.isChecking,
                          isAvailable: prev.isAvailable,
                          showFeeSelect: prev.showFeeSelect,
                          fee: {
                            years: prev.fee.years - 1 | 0,
                            feeAmount: 0.1 * (prev.fee.years - 1 | 0)
                          }
                        };
                });
    }
    
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
                  fee: prev.fee
                };
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
                                      children: JsxRuntime.jsx("svg", {
                                            children: JsxRuntime.jsx("path", {
                                                  d: "M19 12H5M5 12L12 19M5 12L12 5",
                                                  stroke: "#999999",
                                                  strokeLinecap: "round",
                                                  strokeLinejoin: "round",
                                                  strokeWidth: "2"
                                                }),
                                            height: "24",
                                            width: "24",
                                            fill: "none",
                                            viewBox: "0 0 24 24",
                                            xmlns: "http://www.w3.org/2000/svg"
                                          }),
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
                                                        fee: prev.fee
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
                                        className: "w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center",
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
                                        className: "w-10 h-10 rounded-full bg-gray-100 flex items-center justify-center",
                                        onClick: (function (param) {
                                            incrementYears();
                                          })
                                      })
                                ],
                                className: "flex items-center gap-4"
                              }),
                          JsxRuntime.jsx("div", {
                                children: state.fee.feeAmount.toString() + " ETH",
                                className: "text-3xl font-bold"
                              })
                        ],
                        className: "flex justify-between items-center"
                      }),
                  JsxRuntime.jsx("div", {
                        children: props.isWalletConnected ? JsxRuntime.jsx("button", {
                                children: "Register name",
                                className: "w-full py-3 px-4 bg-black text-white rounded-full font-medium",
                                onClick: (function (param) {
                                    
                                  })
                              }) : JsxRuntime.jsx("button", {
                                children: "Connect wallet",
                                className: "w-full py-3 px-4 bg-black text-white rounded-full font-medium",
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
        tmp$2 = JsxRuntime.jsx("div", {
              children: JsxRuntime.jsxs("svg", {
                    children: [
                      JsxRuntime.jsx("circle", {
                            className: "opacity-25",
                            cx: "12",
                            cy: "12",
                            r: "10",
                            stroke: "currentColor",
                            strokeWidth: "4"
                          }),
                      JsxRuntime.jsx("path", {
                            className: "opacity-75",
                            d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z",
                            fill: "currentColor"
                          })
                    ],
                    className: "w-5 h-5 text-blue-600",
                    fill: "none",
                    viewBox: "0 0 24 24",
                    xmlns: "http://www.w3.org/2000/svg"
                  }),
              className: "animate-spin"
            });
      } else {
        var match$1 = state.isAvailable;
        tmp$2 = match$1 !== undefined ? (
            match$1 ? JsxRuntime.jsx("button", {
                    children: "Register",
                    className: "rounded-xl bg-blue-600 px-3 py-1.5 text-sm font-medium text-white hover:bg-blue-500",
                    type: "button",
                    onClick: (function (param) {
                        handleRegisterClick();
                      })
                  }) : JsxRuntime.jsx("span", {
                    children: "Already registered",
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
                                    children: JsxRuntime.jsx("svg", {
                                          children: JsxRuntime.jsx("path", {
                                                d: "M18 6L6 18M6 6L18 18",
                                                stroke: "#999999",
                                                strokeLinecap: "round",
                                                strokeLinejoin: "round",
                                                strokeWidth: "2"
                                              }),
                                          height: "24",
                                          width: "24",
                                          fill: "none",
                                          viewBox: "0 0 24 24",
                                          xmlns: "http://www.w3.org/2000/svg"
                                        }),
                                    className: "p-1 hover:bg-gray-100 rounded-full transition-colors",
                                    type: "button",
                                    onClick: handleClear
                                  }) : null,
                            state.value === "" ? JsxRuntime.jsx("svg", {
                                    children: JsxRuntime.jsx("path", {
                                          d: "M21 21L16.5 16.5M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z",
                                          stroke: "#999999",
                                          strokeLinecap: "round",
                                          strokeLinejoin: "round",
                                          strokeWidth: "2"
                                        }),
                                    height: "24",
                                    width: "24",
                                    fill: "none",
                                    viewBox: "0 0 24 24",
                                    xmlns: "http://www.w3.org/2000/svg"
                                  }) : null
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
/* client Not a pure module */
