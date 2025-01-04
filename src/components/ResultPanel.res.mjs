// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "./Icons.res.mjs";
import * as React from "react";
import * as Constants from "../Constants.res.mjs";
import ConfettiReact from "confetti-react";

function ResultPanel(props) {
  var actionResult = props.actionResult;
  var onRegisterAnother = props.onRegisterAnother;
  var match = actionResult.action;
  var tmp;
  switch (match) {
    case "Register" :
        tmp = "Registration Successful!";
        break;
    case "Extend" :
        tmp = "Extension Successful!";
        break;
    case "Transfer" :
    case "Reclaim" :
        throw {
              RE_EXN_ID: "Match_failure",
              _1: [
                "ResultPanel.res",
                10,
                11
              ],
              Error: new Error()
            };
    
  }
  return React.createElement("div", {
              className: "bg-white rounded-custom shadow-lg overflow-hidden"
            }, React.createElement("div", {
                  className: "p-6"
                }, React.createElement("div", {
                      className: "flex flex-col items-center text-center"
                    }, React.createElement("div", {
                          className: "mb-4"
                        }, React.createElement(Icons.Success.make, {
                              className: "w-16 h-16 text-green-500"
                            })), React.createElement("h2", {
                          className: "text-2xl font-bold mb-2"
                        }, tmp), React.createElement("div", {
                          className: "text-lg text-gray-700 mb-6"
                        }, React.createElement(ConfettiReact, {
                              recycle: false
                            }), React.createElement("p", undefined, props.name + "." + Constants.sld), React.createElement("div", undefined, "until " + actionResult.newExpiryDate.toUTCString())), React.createElement("button", {
                          className: "py-3 px-6 bg-zinc-800 hover:bg-zinc-700 text-white rounded-2xl font-medium",
                          onClick: (function (param) {
                              onRegisterAnother();
                            })
                        }, "Go Home"))));
}

var make = ResultPanel;

export {
  make ,
}
/* Icons Not a pure module */
