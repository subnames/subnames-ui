// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function TransferPanel$StepProgress(props) {
  return React.createElement("div", {
              className: "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
            }, React.createElement("div", {
                  className: "bg-white p-6 rounded-lg shadow-xl w-96"
                }, React.createElement("h3", {
                      className: "text-lg font-semibold mb-4"
                    }, "Transfer Progress"), React.createElement("div", {
                      className: "space-y-4"
                    }, Belt_Array.mapWithIndex(props.steps, (function (index, step) {
                            var match = step.status;
                            var statusColor = match === "Completed" ? "text-green-500" : (
                                match === "NotStarted" ? "text-gray-400" : (
                                    match === "Failed" ? "text-red-500" : "text-blue-500"
                                  )
                              );
                            var match$1 = step.status;
                            var statusIcon = match$1 === "Completed" ? "✅" : (
                                match$1 === "NotStarted" ? "⚪" : (
                                    match$1 === "Failed" ? "❌" : "🔄"
                                  )
                              );
                            var match$2 = step.status;
                            var match$3 = step.txHash;
                            return React.createElement("div", {
                                        key: String(index),
                                        className: "flex items-center gap-3"
                                      }, React.createElement("div", {
                                            className: statusColor
                                          }, statusIcon), React.createElement("div", {
                                            className: "flex-1 space-y-1"
                                          }, React.createElement("div", {
                                                className: "font-medium " + statusColor
                                              }, step.label), match$2 === "Completed" && match$3 !== undefined ? React.createElement("a", {
                                                  className: "text-xs text-blue-500 hover:text-blue-700 truncate block",
                                                  href: "https://sepolia.etherscan.io/tx/" + match$3,
                                                  target: "_blank"
                                                }, match$3) : null));
                          })))));
}

var StepProgress = {
  make: TransferPanel$StepProgress
};

function TransferPanel(props) {
  var onSuccess = props.onSuccess;
  var onBack = props.onBack;
  var isWalletConnected = props.isWalletConnected;
  var receiver = props.receiver;
  var name = props.name;
  var match = React.useState(function () {
        return "";
      });
  var setRecipientAddress = match[1];
  var recipientAddress = match[0];
  var match$1 = React.useState(function () {
        return false;
      });
  var setIsWaitingForConfirmation = match$1[1];
  var isWaitingForConfirmation = match$1[0];
  React.useState(function () {
        return "Simulating";
      });
  var match$2 = React.useState(function () {
        return false;
      });
  var isReclaim = match$2[0];
  var match$3 = React.useState(function () {
        return 0;
      });
  var setCurrentStep = match$3[1];
  var currentStep = match$3[0];
  var match$4 = React.useState(function () {
        return [
                {
                  label: "Set Address",
                  status: "NotStarted",
                  txHash: undefined
                },
                {
                  label: "Set Name",
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
    if (!isWalletConnected) {
      return ;
    }
    var walletClient = OnChainOperationsCommon.buildWalletClient();
    var currentAddr = await OnChainOperationsCommon.currentAddress(walletClient);
    var primaryName = await OnChainOperations.name(currentAddr);
    if (primaryName === "") {
      window.alert("You must set a primary subname before transferring.");
      return ;
    }
    setIsWaitingForConfirmation(function (param) {
          return true;
        });
    if (isReclaim) {
      console.log("Reclaiming " + name);
    } else {
      console.log("Transferring " + name + " to " + recipientAddress);
      try {
        var currentAddress = await OnChainOperationsCommon.currentAddress(walletClient);
        var tokenId = BigInt(Viem.keccak256(name));
        updateStepStatus(0, "InProgress", undefined);
        var hash = await OnChainOperations.setAddr(walletClient, name, recipientAddress);
        updateStepStatus(0, "Completed", Caml_option.some(hash));
        setCurrentStep(function (param) {
              return 1;
            });
        updateStepStatus(1, "InProgress", undefined);
        var hash2 = await OnChainOperations.setName(walletClient, "");
        updateStepStatus(1, "Completed", Caml_option.some(hash2));
        setCurrentStep(function (param) {
              return 2;
            });
        updateStepStatus(2, "InProgress", undefined);
        var hash3 = await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress);
        updateStepStatus(2, "Completed", Caml_option.some(hash3));
        setCurrentStep(function (param) {
              return 3;
            });
        updateStepStatus(3, "InProgress", undefined);
        var hash4 = await OnChainOperations.safeTransferFrom(walletClient, currentAddress, Viem.getAddress(recipientAddress), tokenId);
        updateStepStatus(3, "Completed", Caml_option.some(hash4));
        setCurrentStep(function (param) {
              return 4;
            });
        onSuccess({
              action: "Transfer",
              newExpiryDate: undefined
            });
      }
      catch (raw_error){
        var error = Caml_js_exceptions.internalToOCamlException(raw_error);
        updateStepStatus(currentStep, "Failed", undefined);
        console.error(error);
      }
    }
    return setIsWaitingForConfirmation(function (param) {
                return false;
              });
  };
  return React.createElement(React.Fragment, {
              children: Caml_option.some(React.createElement("div", {
                        className: "fixed inset-0 flex items-center justify-center z-40"
                      }, React.createElement("div", {
                            className: "fixed inset-0 bg-black bg-opacity-50"
                          }), isWaitingForConfirmation ? React.createElement(TransferPanel$StepProgress, {
                              steps: match$4[0],
                              currentStep: currentStep
                            }) : React.createElement("div", {
                              className: "bg-white rounded-custom shadow-lg overflow-hidden relative z-50 max-w-2xl w-full mx-4"
                            }, React.createElement("div", {
                                  className: "p-4 sm:p-6 max-w-2xl mx-auto"
                                }, React.createElement("div", {
                                      className: "flex justify-between items-center mb-8"
                                    }, React.createElement("div", {
                                          className: "flex items-center gap-3"
                                        }, React.createElement("button", {
                                              className: "p-2 hover:bg-gray-100 rounded-full transition-colors",
                                              type: "button",
                                              onClick: (function (param) {
                                                  onBack();
                                                })
                                            }, React.createElement("div", {
                                                  className: "w-6 h-6 text-gray-600"
                                                }, React.createElement(Icons.Back.make, {}))), React.createElement("h2", {
                                              className: "text-xl font-semibold text-gray-900"
                                            }, isReclaim ? "Reclaim Subname" : "Transfer \"" + name + "\" to"))), isReclaim ? React.createElement("div", {
                                        className: "mb-6 text-gray-700"
                                      }, "Click Reclaim to sync the Registry ownership with your NFT ownership.") : React.createElement("div", {
                                        className: "mb-6"
                                      }, React.createElement("input", {
                                            className: "w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500",
                                            placeholder: "0x...",
                                            type: "text",
                                            value: Core__Option.getOr(receiver, ""),
                                            onChange: (function (e) {
                                                setRecipientAddress(e.target.value);
                                              })
                                          })), React.createElement("button", {
                                      className: "w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400",
                                      disabled: isWaitingForConfirmation || !isReclaim && recipientAddress === "" && Core__Option.isNone(receiver),
                                      onClick: (function (param) {
                                          handleTransfer();
                                        })
                                    }, isWaitingForConfirmation ? "Processing..." : (
                                        isReclaim ? "Reclaim" : "Transfer"
                                      ))))))
            });
}

var make = TransferPanel;

export {
  StepProgress ,
  make ,
}
/* viem Not a pure module */
