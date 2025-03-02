// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Js_string from "rescript/lib/es6/js_string.js";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function shortenHash(hash) {
  var length = hash.length;
  if (length <= 10) {
    return hash;
  }
  var start = hash.slice(0, 6);
  var end = hash.slice(length - 4 | 0, length);
  return start + "..." + end;
}

function TransferPanel$StatusIcon$NotStarted(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "w-6 h-6";
  return React.createElement("svg", {
              className: className,
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("circle", {
                  cx: "12",
                  cy: "12",
                  r: "9",
                  stroke: "currentColor",
                  strokeWidth: "2"
                }));
}

var NotStarted = {
  make: TransferPanel$StatusIcon$NotStarted
};

function TransferPanel$StatusIcon$InProgress(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "w-6 h-6";
  return React.createElement("svg", {
              className: className + " animate-spin",
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("circle", {
                  className: "opacity-25",
                  cx: "12",
                  cy: "12",
                  r: "10",
                  stroke: "currentColor",
                  strokeWidth: "2"
                }), React.createElement("path", {
                  className: "opacity-75",
                  d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z",
                  fill: "currentColor"
                }));
}

var InProgress = {
  make: TransferPanel$StatusIcon$InProgress
};

function TransferPanel$StatusIcon$Completed(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "w-6 h-6";
  return React.createElement("svg", {
              className: className,
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("circle", {
                  cx: "12",
                  cy: "12",
                  fill: "currentColor",
                  fillOpacity: "0.2",
                  r: "9",
                  stroke: "currentColor",
                  strokeWidth: "2"
                }), React.createElement("path", {
                  d: "M8 12L11 15L16 9",
                  stroke: "currentColor",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  strokeWidth: "2"
                }));
}

var Completed = {
  make: TransferPanel$StatusIcon$Completed
};

function TransferPanel$StatusIcon$Failed(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "w-6 h-6";
  return React.createElement("svg", {
              className: className,
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("circle", {
                  cx: "12",
                  cy: "12",
                  fill: "currentColor",
                  fillOpacity: "0.2",
                  r: "9",
                  stroke: "currentColor",
                  strokeWidth: "2"
                }), React.createElement("path", {
                  d: "M15 9L9 15M9 9L15 15",
                  stroke: "currentColor",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  strokeWidth: "2"
                }));
}

var Failed = {
  make: TransferPanel$StatusIcon$Failed
};

var StatusIcon = {
  NotStarted: NotStarted,
  InProgress: InProgress,
  Completed: Completed,
  Failed: Failed
};

function TransferPanel$StepProgress(props) {
  var onClose = props.onClose;
  var allStepsCompleted = props.allStepsCompleted;
  var steps = props.steps;
  return React.createElement("div", {
              className: "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
            }, React.createElement("div", {
                  className: "bg-white px-8 py-6 rounded-custom shadow-lg w-full max-w-sm mx-4"
                }, React.createElement("div", {
                      className: "flex items-center justify-between mb-5"
                    }, React.createElement("h1", {
                          className: "text-lg font-semibold text-gray-900"
                        }, "Transfer Progress"), allStepsCompleted ? React.createElement("button", {
                            className: "p-1.5 hover:bg-gray-100 rounded-full transition-colors duration-150 focus:outline-none focus:ring-2 focus:ring-gray-200 flex items-center justify-center",
                            type: "button",
                            onClick: (function (param) {
                                onClose();
                              })
                          }, React.createElement("div", {
                                className: "w-4 h-4 text-gray-600 flex items-center justify-center"
                              }, React.createElement(Icons.Close.make, {}))) : React.createElement("div", {
                            className: "text-xs font-medium text-gray-500"
                          }, (props.currentStep + 1 | 0).toString() + "/" + steps.length.toString())), React.createElement("div", {
                      className: "border-b border-gray-200 mb-4 -mx-8"
                    }), React.createElement("div", {
                      className: "space-y-2"
                    }, Belt_Array.mapWithIndex(steps, (function (index, step) {
                            var match = step.status;
                            var statusColor = match === "Completed" ? "text-green-600" : (
                                match === "NotStarted" ? "text-gray-400" : (
                                    match === "Failed" ? "text-red-600" : "text-blue-600"
                                  )
                              );
                            var match$1 = step.status;
                            var borderColor = match$1 === "Completed" ? "border-green-200" : (
                                match$1 === "NotStarted" ? "border-gray-100" : (
                                    match$1 === "Failed" ? "border-red-200" : "border-blue-200"
                                  )
                              );
                            var match$2 = step.status;
                            var statusIcon = match$2 === "Completed" ? React.createElement(TransferPanel$StatusIcon$Completed, {
                                    className: "w-4 h-4"
                                  }) : (
                                match$2 === "NotStarted" ? React.createElement(TransferPanel$StatusIcon$NotStarted, {
                                        className: "w-4 h-4"
                                      }) : (
                                    match$2 === "Failed" ? React.createElement(TransferPanel$StatusIcon$Failed, {
                                            className: "w-4 h-4"
                                          }) : React.createElement(TransferPanel$StatusIcon$InProgress, {
                                            className: "w-4 h-4"
                                          })
                                  )
                              );
                            var match$3 = step.status;
                            if (match$3 === "InProgress") {
                              React.createElement("span", {
                                    className: "text-xs text-blue-600 ml-1"
                                  }, "Processing");
                            }
                            var match$4 = step.status;
                            var match$5 = step.txHash;
                            return React.createElement("div", {
                                        key: String(index),
                                        className: "py-2 px-2 rounded border-l-0 " + borderColor + " transition-all duration-200"
                                      }, React.createElement("div", {
                                            className: "flex items-center"
                                          }, React.createElement("div", {
                                                className: "flex-shrink-0 " + statusColor
                                              }, statusIcon), React.createElement("div", {
                                                className: "flex-1 ml-2"
                                              }, React.createElement("div", {
                                                    className: "flex items-center"
                                                  }, React.createElement("span", {
                                                        className: "text-sm " + statusColor
                                                      }, step.label))), match$4 === "Completed" && match$5 !== undefined ? React.createElement("a", {
                                                  className: "text-xs text-blue-600 hover:text-blue-800 ml-auto",
                                                  href: "https://sepolia.etherscan.io/tx/" + match$5,
                                                  target: "_blank"
                                                }, React.createElement("span", {
                                                      className: "underline"
                                                    }, shortenHash(match$5))) : null));
                          }))), React.createElement("div", {
                      className: "border-t border-gray-200 mt-4 -mx-8"
                    }), React.createElement("div", {
                      className: "mt-5 text-center text-sm text-gray-500"
                    }, allStepsCompleted ? "All steps completed successfully, you can close this window now." : "Don't close or refresh this window.")));
}

var StepProgress = {
  make: TransferPanel$StepProgress
};

function TransferPanel(props) {
  var __buttonType = props.buttonType;
  var onSuccess = props.onSuccess;
  var onCancel = props.onCancel;
  var receiver = props.receiver;
  var name = props.name;
  var buttonType = __buttonType !== undefined ? __buttonType : "back";
  var match = React.useState(function () {
        return Core__Option.getOr(receiver, "");
      });
  var setRecipientAddress = match[1];
  var recipientAddress = match[0];
  var match$1 = React.useState(function () {
        return false;
      });
  var setIsWaitingForConfirmation = match$1[1];
  var isWaitingForConfirmation = match$1[0];
  var match$2 = React.useState(function () {
        return false;
      });
  var setAllStepsCompleted = match$2[1];
  var match$3 = React.useState(function () {
        return 0;
      });
  var setCurrentStep = match$3[1];
  var match$4 = React.useState(function () {
        return [
                {
                  label: "Set Address",
                  status: "NotStarted",
                  txHash: undefined
                },
                {
                  label: "Clear Name",
                  status: "NotStarted",
                  txHash: undefined
                },
                {
                  label: "Reclaim Token",
                  status: "NotStarted",
                  txHash: undefined
                },
                {
                  label: "Transfer Token",
                  status: "NotStarted",
                  txHash: undefined
                }
              ];
      });
  var setStepStatuses = match$4[1];
  React.useEffect((function () {
          if (receiver !== undefined) {
            setRecipientAddress(function (param) {
                  return receiver;
                });
          }
          
        }), [receiver]);
  var updateStepStatus = function (index, status, txHashOpt) {
    var txHash = txHashOpt !== undefined ? Caml_option.valFromOption(txHashOpt) : undefined;
    setStepStatuses(function (prev) {
          return Belt_Array.mapWithIndex(prev, (function (i, step) {
                        if (i === index) {
                          return {
                                  label: step.label,
                                  status: status,
                                  txHash: txHash
                                };
                        } else {
                          return step;
                        }
                      }));
        });
  };
  var handleTransfer = async function () {
    setIsWaitingForConfirmation(function (param) {
          return true;
        });
    console.log("Transferring " + name + " to " + recipientAddress);
    var executeStep = async function (stepIndex, stepName, operation) {
      try {
        updateStepStatus(stepIndex, "InProgress", undefined);
        var result = await operation();
        updateStepStatus(stepIndex, "Completed", Caml_option.some(result.txHash));
        setCurrentStep(function (param) {
              return stepIndex + 1 | 0;
            });
        return result.value;
      }
      catch (raw_error){
        var error = Caml_js_exceptions.internalToOCamlException(raw_error);
        console.log("Error in step " + stepIndex.toString() + " (" + stepName + "): " + String(error));
        updateStepStatus(stepIndex, "Failed", undefined);
        if (Js_string.includes("TransactionReceiptNotFoundError", String(error))) {
          console.log("This is a transaction receipt error. The transaction might have actually succeeded on-chain.");
          console.log("You can safely try again or check the transaction status on the blockchain explorer.");
        }
        console.error(error);
        throw error;
      }
    };
    var walletClient = Core__Option.getExn(OnChainOperationsCommon.buildWalletClient(), "Wallet connection failed");
    var currentAddress = await OnChainOperationsCommon.currentAddress(walletClient);
    var tokenId = BigInt(Viem.keccak256(name));
    await executeStep(0, "Set Address", (async function () {
            var currentAddrOnChain = await OnChainOperations.getAddr(name);
            if (currentAddrOnChain !== undefined && Caml_option.valFromOption(currentAddrOnChain) === Viem.getAddress(recipientAddress)) {
              console.log("Address for " + name + " is already set to " + recipientAddress + ", skipping setAddr step");
              return {
                      value: undefined,
                      txHash: undefined
                    };
            }
            var hash = await OnChainOperations.setAddr(walletClient, name, recipientAddress);
            return {
                    value: undefined,
                    txHash: hash
                  };
          }));
    await executeStep(1, "Clear Name", (async function () {
            var hash = await OnChainOperations.setName(walletClient, "");
            return {
                    value: undefined,
                    txHash: hash
                  };
          }));
    await executeStep(2, "Reclaim Token", (async function () {
            var newOwner = await OnChainOperations.getOwner(tokenId);
            var normalizedNewOwner = Viem.getAddress(newOwner);
            var normalizedRecipient = Viem.getAddress(recipientAddress);
            if (normalizedNewOwner !== normalizedRecipient) {
              var hash = await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress);
              return {
                      value: undefined,
                      txHash: hash
                    };
            }
            console.log("Token for " + name + " is already owned by " + recipientAddress + ", skipping reclaim step");
            return {
                    value: undefined,
                    txHash: undefined
                  };
          }));
    await executeStep(3, "Transfer Token", (async function () {
            var currentTokenOwner = await OnChainOperations.getTokenOwner(name);
            var normalizedCurrentTokenOwner = Viem.getAddress(currentTokenOwner);
            var normalizedRecipient = Viem.getAddress(recipientAddress);
            console.log("Current token owner: " + normalizedCurrentTokenOwner);
            if (normalizedCurrentTokenOwner !== normalizedRecipient) {
              var hash = await OnChainOperations.safeTransferFrom(walletClient, currentAddress, normalizedRecipient, tokenId);
              return {
                      value: undefined,
                      txHash: hash
                    };
            }
            console.log("Token for " + name + " is already owned by " + recipientAddress + ", skipping transfer step");
            return {
                    value: undefined,
                    txHash: undefined
                  };
          }));
    return setAllStepsCompleted(function (param) {
                return true;
              });
  };
  return React.createElement(React.Fragment, {
              children: Caml_option.some(React.createElement("div", {
                        className: "fixed inset-0 flex items-center justify-center z-40"
                      }, React.createElement("div", {
                            className: "fixed inset-0 bg-black bg-opacity-50"
                          }), isWaitingForConfirmation ? React.createElement(TransferPanel$StepProgress, {
                              steps: match$4[0],
                              currentStep: match$3[0],
                              allStepsCompleted: match$2[0],
                              onClose: (function () {
                                  setIsWaitingForConfirmation(function (param) {
                                        return false;
                                      });
                                  onSuccess({
                                        action: "Transfer",
                                        newExpiryDate: undefined
                                      });
                                })
                            }) : React.createElement("div", {
                              className: "bg-white rounded-custom shadow-lg overflow-hidden relative z-50 max-w-2xl w-full mx-4"
                            }, React.createElement("div", {
                                  className: "pt-6 pb-8 px-8 max-w-2xl mx-auto"
                                }, React.createElement("div", {
                                      className: "flex justify-between items-center mb-6"
                                    }, React.createElement("div", {
                                          className: "flex items-center gap-3"
                                        }, buttonType === "close" ? null : React.createElement("button", {
                                                className: "p-2 hover:bg-gray-100 rounded-full transition-colors",
                                                type: "button",
                                                onClick: (function (param) {
                                                    onCancel();
                                                  })
                                              }, React.createElement("div", {
                                                    className: "w-6 h-6 text-gray-600"
                                                  }, React.createElement(Icons.Back.make, {}))), React.createElement("h2", {
                                              className: "text-xl font-semibold text-gray-900"
                                            }, "Transfer \`" + name + "\`")), buttonType === "close" ? React.createElement("button", {
                                            className: "p-2 hover:bg-gray-100 rounded-full transition-colors",
                                            type: "button",
                                            onClick: (function (param) {
                                                onCancel();
                                              })
                                          }, React.createElement("div", {
                                                className: "w-6 h-6 text-gray-600"
                                              }, React.createElement(Icons.Close.make, {}))) : null), React.createElement("div", {
                                      className: "mb-8 mx-[1px]"
                                    }, React.createElement("label", {
                                          className: "block text-gray-700 text-sm font-medium mb-2"
                                        }, "To:"), React.createElement("input", {
                                          className: "w-full px-3 py-2 rounded-md border border-gray-300 shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 font-medium text-lg",
                                          placeholder: "0x...",
                                          type: "text",
                                          value: recipientAddress,
                                          onChange: (function (e) {
                                              setRecipientAddress(e.target.value);
                                            })
                                        })), React.createElement("button", {
                                      className: "w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md",
                                      disabled: isWaitingForConfirmation || recipientAddress === "",
                                      onClick: (function (param) {
                                          handleTransfer();
                                        })
                                    }, isWaitingForConfirmation ? "Processing..." : "Transfer")))))
            });
}

var make = TransferPanel;

export {
  shortenHash ,
  StatusIcon ,
  StepProgress ,
  make ,
}
/* viem Not a pure module */
