// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function TransferPanel(props) {
  var onSuccess = props.onSuccess;
  var onBack = props.onBack;
  var isWalletConnected = props.isWalletConnected;
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
                  status: "NotStarted"
                },
                {
                  label: "Set Name",
                  status: "NotStarted"
                },
                {
                  label: "Reclaim Token",
                  status: "NotStarted"
                },
                {
                  label: "Transfer Token",
                  status: "NotStarted"
                }
              ];
      });
  var setStepStatuses = match$4[1];
  var updateStepStatus = function (index, status) {
    setStepStatuses(function (prev) {
          return Belt_Array.mapWithIndex(prev, (function (i, step) {
                        if (i === index) {
                          return {
                                  label: step.label,
                                  status: status
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
        updateStepStatus(0, "InProgress");
        await OnChainOperations.setAddr(walletClient, name, recipientAddress);
        updateStepStatus(0, "Completed");
        setCurrentStep(function (param) {
              return 1;
            });
        updateStepStatus(1, "InProgress");
        var primaryName$1 = await OnChainOperations.name(currentAddress);
        await OnChainOperations.setName(walletClient, primaryName$1);
        updateStepStatus(1, "Completed");
        setCurrentStep(function (param) {
              return 2;
            });
        updateStepStatus(2, "InProgress");
        await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress);
        updateStepStatus(2, "Completed");
        setCurrentStep(function (param) {
              return 3;
            });
        updateStepStatus(3, "InProgress");
        await OnChainOperations.safeTransferFrom(walletClient, currentAddress, Viem.getAddress(recipientAddress), tokenId);
        updateStepStatus(3, "Completed");
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
        updateStepStatus(currentStep, "Failed");
        console.error(error);
      }
    }
    return setIsWaitingForConfirmation(function (param) {
                return false;
              });
  };
  return React.createElement("div", {
              className: "bg-white rounded-custom shadow-lg overflow-hidden"
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
                            }, isReclaim ? "Reclaim Subname" : "Transfer Subname"))), isReclaim ? React.createElement("div", {
                        className: "mb-6 text-gray-700"
                      }, "Click Reclaim to sync the Registry ownership with your NFT ownership.") : React.createElement("div", {
                        className: "mb-6"
                      }, React.createElement("label", {
                            className: "block text-sm font-medium text-gray-700 mb-2"
                          }, "Recipient Address"), React.createElement("input", {
                            className: "w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500",
                            placeholder: "0x...",
                            type: "text",
                            value: recipientAddress,
                            onChange: (function (e) {
                                setRecipientAddress(e.target.value);
                              })
                          })), React.createElement("button", {
                      className: "w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400",
                      disabled: isWaitingForConfirmation || !isReclaim && recipientAddress === "",
                      onClick: (function (param) {
                          handleTransfer();
                        })
                    }, isWaitingForConfirmation ? "Processing..." : (
                        isReclaim ? "Reclaim" : "Transfer"
                      ))));
}

var make = TransferPanel;

export {
  make ,
}
/* viem Not a pure module */
