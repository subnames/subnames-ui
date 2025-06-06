// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Belt_Array from "rescript/lib/es6/belt_Array.js";
import * as Caml_int32 from "rescript/lib/es6/caml_int32.js";

function TransferProgress(props) {
  var steps = props.steps;
  var totalSteps = steps.length;
  var progress = Caml_int32.div(Math.imul(props.currentStep + 1 | 0, 100), totalSteps);
  return React.createElement("div", {
              className: "w-full"
            }, React.createElement("div", {
                  className: "mb-4"
                }, React.createElement("div", {
                      className: "h-2 w-full bg-gray-200 rounded-full"
                    }, React.createElement("div", {
                          className: "h-full bg-blue-600 rounded-full transition-all duration-500 ease-in-out",
                          style: {
                            width: String(progress) + "%"
                          }
                        }))), React.createElement("div", {
                  className: "flex justify-between"
                }, Belt_Array.mapWithIndex(steps, (function (index, step) {
                        var match = step.status;
                        var statusClass = match === "Completed" ? "text-green-600" : (
                            match === "NotStarted" ? "text-gray-500" : (
                                match === "Failed" ? "text-red-600" : "text-blue-600 font-medium animate-pulse"
                              )
                          );
                        var match$1 = step.status;
                        var icon = match$1 === "Completed" ? "●" : (
                            match$1 === "NotStarted" ? "○" : (
                                match$1 === "Failed" ? "×" : "◎"
                              )
                          );
                        return React.createElement("div", {
                                    key: String(index),
                                    className: "flex flex-col items-center"
                                  }, React.createElement("div", {
                                        className: "text-sm " + statusClass
                                      }, icon), React.createElement("div", {
                                        className: "text-xs mt-1 " + statusClass
                                      }, step.label));
                      }))));
}

var make = TransferProgress;

export {
  make ,
}
/* react Not a pure module */
