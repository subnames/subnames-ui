// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as DateFns from "date-fns";
import * as Core__JSON from "@rescript/core/src/Core__JSON.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";

var UseAccount = {};

function useDebounce(callback, delay) {
  var timeoutRef = React.useRef(undefined);
  return function (value) {
    var timeout = timeoutRef.current;
    if (timeout !== undefined) {
      clearTimeout(Caml_option.valFromOption(timeout));
    }
    var timeout$1 = setTimeout((function () {
            callback(value);
          }), delay);
    timeoutRef.current = Caml_option.some(timeout$1);
  };
}

function distanceToExpiry(date) {
  return DateFns.formatDistanceToNow(date, {
              addSuffix: true
            });
}

function timestampToDate(timestamp) {
  return new Date(Number(timestamp * 1000n));
}

function timestampStringToDate(timestampStr) {
  return timestampToDate(BigInt(timestampStr));
}

function getString(jsonObj, fieldName) {
  return Core__Option.flatMap(jsonObj[fieldName], Core__JSON.Decode.string);
}

function getStringExn(jsonObj, fieldName) {
  return Core__Option.getExn(getString(jsonObj, fieldName), "Failed to get ${fieldName}");
}

function getObject(jsonObj, fieldName, f) {
  return Core__Option.map(Core__Option.flatMap(jsonObj[fieldName], Core__JSON.Decode.object), f);
}

function getObjectExn(jsonObj, fieldName, f) {
  return Core__Option.getExn(getObject(jsonObj, fieldName, f), "Failed to get ${fieldName}");
}

function getArray(jsonObj, fieldName, f) {
  return Core__Option.map(Core__Option.flatMap(jsonObj[fieldName], Core__JSON.Decode.array), (function (arr) {
                return arr.map(f);
              }));
}

function getArrayExn(jsonObj, fieldName, f) {
  return Core__Option.getExn(getArray(jsonObj, fieldName, f), "Failed to get ${fieldName}");
}

export {
  UseAccount ,
  useDebounce ,
  distanceToExpiry ,
  timestampToDate ,
  timestampStringToDate ,
  getString ,
  getStringExn ,
  getObject ,
  getObjectExn ,
  getArray ,
  getArrayExn ,
}
/* react Not a pure module */
