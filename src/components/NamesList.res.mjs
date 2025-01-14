// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "./Icons.res.mjs";
import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Wagmi from "wagmi";
import * as Js_exn from "rescript/lib/es6/js_exn.js";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Constants from "../Constants.res.mjs";
import * as Core__JSON from "@rescript/core/src/Core__JSON.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as NameContext from "../NameContext.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as GraphQLClient from "../GraphQLClient.res.mjs";
import * as ReverseRegistrar from "../ReverseRegistrar.res.mjs";
import * as OnChainOperations from "../OnChainOperations.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as RegisterExtendPanel from "./RegisterExtendPanel.res.mjs";
import * as RescriptReactRouter from "@rescript/react/src/RescriptReactRouter.res.mjs";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

var UseAccount = {};

async function getPrimaryName(address) {
  return await OnChainOperations.name(address);
}

function NamesList(props) {
  var account = Wagmi.useAccount();
  var match = NameContext.use();
  var setUpdateName = match.setUpdateName;
  var match$1 = React.useState(function () {
        return [];
      });
  var setNames = match$1[1];
  var names = match$1[0];
  var match$2 = React.useState(function () {
        return true;
      });
  var setLoading = match$2[1];
  var match$3 = React.useState(function () {
        
      });
  var setActiveDropdown = match$3[1];
  var activeDropdown = match$3[0];
  var match$4 = React.useState(function () {
        return false;
      });
  var setSettingPrimaryName = match$4[1];
  var match$5 = React.useState(function () {
        
      });
  var setPrimaryName = match$5[1];
  var primaryName = match$5[0];
  var match$6 = React.useState(function () {
        return 0;
      });
  var setRefetchTrigger = match$6[1];
  var match$7 = React.useState(function () {
        
      });
  var setShowExtendPanel = match$7[1];
  var showExtendPanel = match$7[0];
  var dropdownRef = React.useRef(null);
  React.useEffect((function () {
          var handleClickOutside = function ($$event) {
            Core__Option.map(Caml_option.nullable_to_opt(dropdownRef.current), (function (dropdownEl) {
                    var targetEl = $$event.target;
                    if (!dropdownEl.contains(targetEl)) {
                      return setActiveDropdown(function (param) {
                                  
                                });
                    }
                    
                  }));
          };
          document.addEventListener("mousedown", handleClickOutside);
          return (function () {
                    document.removeEventListener("mousedown", handleClickOutside);
                  });
        }), [activeDropdown]);
  var updatePrimaryName = async function (name) {
    setSettingPrimaryName(function (param) {
          return true;
        });
    try {
      var walletClient = Core__Option.getExn(OnChainOperationsCommon.buildWalletClient(), "Wallet connection failed");
      await ReverseRegistrar.setNameForAddr(walletClient, name);
      setUpdateName(function (param) {
            return true;
          });
      setRefetchTrigger(function (prev) {
            return prev + 1 | 0;
          });
    }
    catch (raw_obj){
      var obj = Caml_js_exceptions.internalToOCamlException(raw_obj);
      if (obj.RE_EXN_ID === Js_exn.$$Error) {
        var message = obj._1.message;
        if (message !== undefined) {
          if (message.includes("User rejected the request")) {
            console.log("User rejected the transaction");
          } else {
            console.log(message);
          }
        }
        
      } else {
        throw obj;
      }
    }
    return setSettingPrimaryName(function (param) {
                return false;
              });
  };
  var handleExtendSuccess = function (param) {
    setRefetchTrigger(function (prev) {
          return prev + 1 | 0;
        });
    setShowExtendPanel(function (param) {
          
        });
  };
  var buildSubname = function (subnameObj) {
    return Core__Option.getExn(Core__Option.map(Core__JSON.Decode.object(subnameObj), (function (obj) {
                      var label = Utils.getString(obj, "label");
                      var name = Utils.getString(obj, "name");
                      var expires = Utils.getString(obj, "expires");
                      var owner = Utils.getObject(obj, "owner", (function (ownerObj) {
                              return {
                                      id: Utils.getString(ownerObj, "id")
                                    };
                            }));
                      return {
                              label: label,
                              name: name,
                              expires: expires,
                              owner: owner
                            };
                    })), undefined);
  };
  var buildSubnames = function (subnameObjs) {
    return subnameObjs.map(buildSubname);
  };
  React.useEffect((function () {
          if (account.isConnected) {
            Core__Option.map(account.address, (async function (address) {
                    var primaryName = await getPrimaryName(address);
                    console.log("Primary name set to:", primaryName);
                    return setPrimaryName(function (param) {
                                return primaryName;
                              });
                  }));
          }
          
        }), [
        account.isConnected,
        match$6[0]
      ]);
  React.useEffect((function () {
          if (account.isConnected) {
            var fetchNames = async function () {
              var address = Core__Option.getExn(Core__Option.map(account.address, (function (prim) {
                          return prim.toLowerCase();
                        })), "No address found");
              var query = "\n          query {\n            subnames(limit: 20, where: {owner: {id_eq: \"" + address + "\"}}) {\n              label\n              name\n              expires\n              owner {\n                id\n              }\n            }\n          }\n        ";
              var result = await GraphQLClient.makeRequest(Constants.indexerUrl, query, undefined, undefined);
              var data = result.data;
              var exit = 0;
              if (data !== undefined && result.errors === undefined) {
                var subnames = Utils.getArray(data, "subnames", buildSubnames);
                setNames(function (param) {
                      return subnames;
                    });
              } else {
                exit = 1;
              }
              if (exit === 1) {
                var errors = result.errors;
                if (errors !== undefined) {
                  console.log("Errors:", errors);
                } else {
                  console.log("Unknown response");
                }
              }
              return setLoading(function (param) {
                          return false;
                        });
            };
            fetchNames();
          }
          
        }), [account.isConnected]);
  return React.createElement(React.Fragment, {}, React.createElement("div", {
                  className: "p-8"
                }, React.createElement("div", {
                      className: "w-full max-w-xl mx-auto"
                    }, showExtendPanel !== undefined ? React.createElement(RegisterExtendPanel.make, {
                            name: showExtendPanel,
                            isWalletConnected: account.isConnected,
                            onBack: (function () {
                                setShowExtendPanel(function (param) {
                                      
                                    });
                              }),
                            onSuccess: handleExtendSuccess,
                            action: "Extend"
                          }) : React.createElement("div", {
                            className: "bg-white rounded-custom shadow-lg overflow-hidden"
                          }, React.createElement("div", {
                                className: "px-6 pt-4 pb-4 border-b border-gray-200 relative"
                              }, React.createElement("div", {
                                    className: "text-lg"
                                  }, "Your Subnames"), React.createElement("div", {
                                    className: "text-sm text-gray-500"
                                  }, "New name may take a while to appear"), React.createElement("button", {
                                    className: "p-1 hover:bg-gray-100 rounded-full transition-colors absolute right-4 top-1/2 -translate-y-1/2",
                                    onClick: (function (param) {
                                        RescriptReactRouter.push("/");
                                      })
                                  }, React.createElement(Icons.Close.make, {}))), account.isConnected ? (
                              match$2[0] ? React.createElement("div", {
                                      className: "text-center py-4"
                                    }, "Loading...") : (
                                  names.length === 0 ? React.createElement("div", {
                                          className: "text-center py-4 text-gray-500"
                                        }, "You don't have any subnames yet") : React.createElement("div", {
                                          className: "py-1"
                                        }, names.map(function (subname, index) {
                                              var tmp;
                                              if (Caml_obj.equal(activeDropdown, subname.name)) {
                                                var tmp$1;
                                                var exit = 0;
                                                if (primaryName !== undefined && primaryName === subname.name) {
                                                  tmp$1 = null;
                                                } else {
                                                  exit = 1;
                                                }
                                                if (exit === 1) {
                                                  tmp$1 = React.createElement("button", {
                                                        className: "block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100",
                                                        type: "button",
                                                        onClick: (function (param) {
                                                            updatePrimaryName(subname.name);
                                                            setActiveDropdown(function (param) {
                                                                  
                                                                });
                                                          })
                                                      }, "Set primary");
                                                }
                                                tmp = React.createElement("div", {
                                                      ref: Caml_option.some(dropdownRef),
                                                      className: "absolute right-0 z-10 mt-2 w-40 origin-top-right rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none"
                                                    }, React.createElement("div", {
                                                          className: "py-1"
                                                        }, tmp$1, React.createElement("button", {
                                                              className: "block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100",
                                                              type: "button",
                                                              onClick: (function (param) {
                                                                  setActiveDropdown(function (param) {
                                                                        
                                                                      });
                                                                })
                                                            }, "Transfer"), React.createElement("button", {
                                                              className: "block w-full px-4 py-2 text-sm text-left text-gray-700 hover:bg-gray-100",
                                                              type: "button",
                                                              onClick: (function (param) {
                                                                  setShowExtendPanel(function (param) {
                                                                        return subname.name;
                                                                      });
                                                                  setActiveDropdown(function (param) {
                                                                        
                                                                      });
                                                                })
                                                            }, "Extend")));
                                              } else {
                                                tmp = null;
                                              }
                                              return React.createElement("div", {
                                                          key: subname.name
                                                        }, React.createElement("div", {
                                                              className: "px-6 py-4"
                                                            }, React.createElement("div", {
                                                                  className: "flex items-center justify-between"
                                                                }, React.createElement("div", undefined, React.createElement("div", {
                                                                          className: "flex items-center gap-2"
                                                                        }, React.createElement("p", {
                                                                              className: "text-gray-800"
                                                                            }, React.createElement(React.Fragment, {}, React.createElement("span", {
                                                                                      className: "font-bold"
                                                                                    }, subname.name), "." + Constants.sld)), primaryName !== undefined && primaryName === subname.name ? React.createElement("span", {
                                                                                className: "px-2 py-0.5 text-xs bg-blue-100 text-blue-800 rounded-full font-medium"
                                                                              }, "Primary") : null), React.createElement("p", {
                                                                          className: "text-xs text-gray-400 mt-1"
                                                                        }, "Expires " + Utils.distanceToExpiry(Utils.timestampStringToDate(subname.expires)))), React.createElement("div", {
                                                                      className: "relative"
                                                                    }, React.createElement("button", {
                                                                          className: "rounded-lg bg-white border border-zinc-200 px-3 py-1.5 text-sm font-medium text-zinc-800 hover:bg-zinc-50",
                                                                          type: "button",
                                                                          onClick: (function (param) {
                                                                              setActiveDropdown(function (current) {
                                                                                    if (Caml_obj.equal(current, subname.name)) {
                                                                                      return ;
                                                                                    } else {
                                                                                      return subname.name;
                                                                                    }
                                                                                  });
                                                                            })
                                                                        }, "..."), tmp))), index < (names.length - 1 | 0) ? React.createElement("div", {
                                                                className: "border-b border-gray-200 mx-6"
                                                              }) : null);
                                            }))
                                )
                            ) : React.createElement("div", {
                                  className: "text-center py-4 text-gray-500"
                                }, "Please connect your wallet to see your names")))), match$4[0] ? React.createElement("div", {
                    className: "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
                  }, React.createElement("div", {
                        className: "bg-white p-6 rounded-lg shadow-xl"
                      }, React.createElement("div", {
                            className: "flex items-center gap-3"
                          }, React.createElement("div", {
                                className: "animate-spin rounded-full h-5 w-5 border-2 border-gray-900 border-t-transparent"
                              }), React.createElement("p", {
                                className: "text-gray-900"
                              }, "Setting primary name...")))) : null);
}

var make = NamesList;

export {
  UseAccount ,
  getPrimaryName ,
  make ,
}
/* Icons Not a pure module */
