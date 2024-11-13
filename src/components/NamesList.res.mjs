// Generated by ReScript, PLEASE EDIT WITH CARE

import * as React from "react";
import * as Wagmi from "wagmi";
import * as OnChainOperations from "../OnChainOperations.res.mjs";

var UseAccount = {};

function NamesList(props) {
  var account = Wagmi.useAccount();
  var fn = function () {
    return [];
  };
  var match = React.useState(fn);
  var setNames = match[1];
  var match$1 = React.useState(function () {
        return true;
      });
  var setLoading = match$1[1];
  React.useEffect((function () {
          var addr = account.address;
          if (addr !== undefined) {
            setLoading(function (param) {
                  return true;
                });
            OnChainOperations.getSubnames(addr).then(function (subnames) {
                  setNames(function (param) {
                        return subnames;
                      });
                  setLoading(function (param) {
                        return false;
                      });
                  return Promise.resolve();
                });
          }
          
        }), [account.address]);
  return React.createElement("div", {
              className: "p-6"
            }, React.createElement("h2", {
                  className: "text-2xl font-bold mb-6"
                }, "Your Subnames"), match$1[0] ? React.createElement("div", {
                    className: "text-center py-4"
                  }, "Loading...") : (
                match[0].length === 0 ? React.createElement("div", {
                        className: "text-center py-4 text-gray-500"
                      }, "You don't have any subnames yet") : React.createElement("div", {
                        className: "space-y-4"
                      }, "Under Construction")
              ));
}

var make = NamesList;

export {
  UseAccount ,
  make ,
}
/* react Not a pure module */
