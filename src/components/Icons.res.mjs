// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";

function Icons$Search(props) {
  return React.createElement("svg", {
              height: "24",
              width: "24",
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("path", {
                  d: "M21 21L16.5 16.5M19 11C19 15.4183 15.4183 19 11 19C6.58172 19 3 15.4183 3 11C3 6.58172 6.58172 3 11 3C15.4183 3 19 6.58172 19 11Z",
                  stroke: "#999999",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  strokeWidth: "2"
                }));
}

var Search = {
  make: Icons$Search
};

function Icons$Close(props) {
  return React.createElement("svg", {
              height: "24",
              width: "24",
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("path", {
                  d: "M18 6L6 18M6 6L18 18",
                  stroke: "#999999",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  strokeWidth: "2"
                }));
}

var Close = {
  make: Icons$Close
};

function Icons$Back(props) {
  return React.createElement("svg", {
              height: "24",
              width: "24",
              fill: "none",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("path", {
                  d: "M19 12H5M5 12L12 19M5 12L12 5",
                  stroke: "#999999",
                  strokeLinecap: "round",
                  strokeLinejoin: "round",
                  strokeWidth: "2"
                }));
}

var Back = {
  make: Icons$Back
};

function Icons$Spinner(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "w-5 h-5 text-blue-600";
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
                  strokeWidth: "4"
                }), React.createElement("path", {
                  className: "opacity-75",
                  d: "M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z",
                  fill: "currentColor"
                }));
}

var Spinner = {
  make: Icons$Spinner
};

function Icons$Success(props) {
  var __className = props.className;
  var className = __className !== undefined ? __className : "";
  return React.createElement("svg", {
              className: className,
              fill: "none",
              stroke: "currentColor",
              strokeWidth: "1.5",
              viewBox: "0 0 24 24",
              xmlns: "http://www.w3.org/2000/svg"
            }, React.createElement("path", {
                  d: "M9 12.75L11.25 15 15 9.75M21 12a9 9 0 11-18 0 9 9 0 0118 0z",
                  strokeLinecap: "round",
                  strokeLinejoin: "round"
                }));
}

var Success = {
  make: Icons$Success
};

export {
  Search ,
  Close ,
  Back ,
  Spinner ,
  Success ,
}
/* react Not a pure module */
