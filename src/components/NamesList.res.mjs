// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "./Icons.res.mjs";
import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Wagmi from "wagmi";
import * as Js_exn from "rescript/lib/es6/js_exn.js";
import * as Router from "../Router.res.mjs";
import * as Caml_obj from "rescript/lib/es6/caml_obj.js";
import * as Constants from "../Constants.res.mjs";
import * as Core__Int from "@rescript/core/src/Core__Int.res.mjs";
import * as Core__JSON from "@rescript/core/src/Core__JSON.res.mjs";
import * as Caml_option from "rescript/lib/es6/caml_option.js";
import * as NameContext from "../NameContext.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as GraphQLClient from "../GraphQLClient.res.mjs";
import * as TransferPanel from "./TransferPanel.res.mjs";
import * as ReverseRegistrar from "../ReverseRegistrar.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as RegisterExtendPanel from "./RegisterExtendPanel.res.mjs";
import * as RescriptReactRouter from "@rescript/react/src/RescriptReactRouter.res.mjs";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

var UseAccount = {};

function NamesList(props) {
  var account = Wagmi.useAccount();
  var match = NameContext.use();
  var primaryName = match.primaryName;
  var setForceRefresh = match.setForceRefresh;
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
  var setShowExtendPanel = match$5[1];
  var showExtendPanel = match$5[0];
  var match$6 = React.useState(function () {
        
      });
  var setShowTransferPanel = match$6[1];
  var showTransferPanel = match$6[0];
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
  React.useEffect((function () {
          if (!account.isConnected) {
            RescriptReactRouter.push(Router.toUrl("Home"));
          }
          
        }), [account.isConnected]);
  var setPrimary = async function (name) {
    setSettingPrimaryName(function (param) {
          return true;
        });
    try {
      var walletClient = Core__Option.getExn(OnChainOperationsCommon.buildWalletClient(), "Wallet connection failed");
      await ReverseRegistrar.setNameForAddr(walletClient, name);
      setForceRefresh(function (param) {
            return true;
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
    setForceRefresh(function (param) {
          return true;
        });
    setShowExtendPanel(function (param) {
          
        });
  };
  var handleTransferSuccess = function (param) {
    setForceRefresh(function (param) {
          return true;
        });
    setShowTransferPanel(function (param) {
          
        });
  };
  var buildSubname = function (subnameObj) {
    return Core__Option.getExn(Core__Option.map(Core__JSON.Decode.object(subnameObj), (function (obj) {
                      var label = Utils.getString(obj, "label");
                      var name = Utils.getString(obj, "name");
                      var expires = Core__Option.getExn(Core__Int.fromString(Utils.getString(obj, "expires"), undefined), undefined);
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
    var result = subnameObjs.map(buildSubname);
    Core__Option.map(Core__Option.map(primaryName, (function (c) {
                return {
                        label: c.name,
                        name: c.name,
                        expires: c.expires,
                        owner: {
                          id: Core__Option.getExn(account.address, undefined)
                        }
                      };
              })), (function (current) {
            if (result.findIndex(function (subname) {
                    return subname.name === current.name;
                  }) === -1) {
              result.push(current);
            }
            return result;
          }));
    result.sort(function (a, b) {
          return a.expires - b.expires | 0;
        });
    return result;
  };
  React.useEffect((function () {
          if (account.isConnected) {
            var fetchNames = async function () {
              var address = Core__Option.getExn(Core__Option.map(account.address, (function (prim) {
                          return prim.toLowerCase();
                        })), "No address found");
              var query = "\n          query {\n            subnames(limit: 20, where: {reverseResolvedFrom: {id_eq: \"" + address + "\"}}) {\n              label\n              name\n              expires\n              owner {\n                id\n              }\n            }\n          }\n        ";
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
                          }) : (
                        showTransferPanel !== undefined ? React.createElement(TransferPanel.make, {
                                name: showTransferPanel,
                                isWalletConnected: account.isConnected,
                                onBack: (function () {
                                    setShowTransferPanel(function (param) {
                                          
                                        });
                                  }),
                                onSuccess: handleTransferSuccess
                              }) : React.createElement("div", {
                                className: "bg-white rounded-custom shadow-lg"
                              }, React.createElement("div", {
                                    className: "p-8 py-6 border-b border-gray-200 relative"
                                  }, React.createElement("h1", {
                                        className: "text-3xl font-bold text-gray-900"
                                      }, "Your Subnames"), React.createElement("div", {
                                        className: "text-sm text-gray-500"
                                      }, "New name may take a while to appear"), React.createElement("button", {
                                        className: "p-1 hover:bg-gray-100 rounded-full transition-colors absolute right-8 top-1/2 -translate-y-1/2",
                                        onClick: (function (param) {
                                            RescriptReactRouter.push("/");
                                          })
                                      }, React.createElement(Icons.Close.make, {}))), account.isConnected ? (
                                  match$2[0] ? React.createElement("div", {
                                          className: "flex justify-center items-center py-4"
                                        }, React.createElement(Icons.Spinner.make, {
                                              className: "w-5 h-5 text-zinc-600"
                                            })) : (
                                      names.length === 0 ? React.createElement("div", {
                                              className: "text-center py-4 text-gray-500"
                                            }, "You don't have any subnames yet") : React.createElement("div", {
                                              className: "py-1"
                                            }, names.map(function (subname, index) {
                                                  var tmp;
                                                  if (Caml_obj.equal(activeDropdown, subname.name)) {
                                                    var tmp$1;
                                                    var exit = 0;
                                                    if (primaryName !== undefined && primaryName.name === subname.name) {
                                                      tmp$1 = null;
                                                    } else {
                                                      exit = 1;
                                                    }
                                                    if (exit === 1) {
                                                      tmp$1 = React.createElement("button", {
                                                            className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                                            type: "button",
                                                            onClick: (function (param) {
                                                                setPrimary(subname.name);
                                                                setActiveDropdown(function (param) {
                                                                      
                                                                    });
                                                              })
                                                          }, "Set primary");
                                                    }
                                                    var tmp$2;
                                                    var exit$1 = 0;
                                                    if (primaryName !== undefined && primaryName.name === subname.name) {
                                                      tmp$2 = null;
                                                    } else {
                                                      exit$1 = 1;
                                                    }
                                                    if (exit$1 === 1) {
                                                      tmp$2 = React.createElement("button", {
                                                            className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                                            type: "button",
                                                            onClick: (function (param) {
                                                                setShowTransferPanel(function (param) {
                                                                      return subname.name;
                                                                    });
                                                                setActiveDropdown(function (param) {
                                                                      
                                                                    });
                                                              })
                                                          }, "Transfer");
                                                    }
                                                    tmp = React.createElement("div", {
                                                          ref: Caml_option.some(dropdownRef),
                                                          className: "absolute right-0 mt-2 w-48 rounded-lg shadow-xl bg-white/95 backdrop-blur-sm border border-gray-100 z-50"
                                                        }, React.createElement("div", {
                                                              className: "py-1"
                                                            }, tmp$1, tmp$2, React.createElement("button", {
                                                                  className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
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
                                                                  className: "px-8 py-6"
                                                                }, React.createElement("div", {
                                                                      className: "flex items-center justify-between"
                                                                    }, React.createElement("div", undefined, React.createElement("div", {
                                                                              className: "flex items-center gap-2"
                                                                            }, React.createElement("p", {
                                                                                  className: "text-gray-800"
                                                                                }, React.createElement(React.Fragment, {}, React.createElement("span", {
                                                                                          className: "font-bold"
                                                                                        }, subname.name), "." + Constants.sld)), primaryName !== undefined && primaryName.name === subname.name ? React.createElement("span", {
                                                                                    className: "px-2 py-0.5 text-xs bg-blue-100 text-blue-800 rounded-full font-medium"
                                                                                  }, "Primary") : null), React.createElement("p", {
                                                                              className: "text-xs text-gray-400 mt-1"
                                                                            }, "Expires " + Utils.distanceToExpiry(Utils.timestampToDate(subname.expires)))), React.createElement("div", {
                                                                          className: "relative"
                                                                        }, React.createElement("button", {
                                                                              className: "p-2 rounded-lg hover:bg-gray-100 focus:outline-none",
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
                                                                            }, React.createElement("svg", {
                                                                                  className: "w-5 h-5",
                                                                                  fill: "none",
                                                                                  stroke: "currentColor",
                                                                                  viewBox: "0 0 24 24"
                                                                                }, React.createElement("path", {
                                                                                      d: "M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z",
                                                                                      strokeLinecap: "round",
                                                                                      strokeLinejoin: "round",
                                                                                      strokeWidth: "2"
                                                                                    }))), tmp))), index < (names.length - 1 | 0) ? React.createElement("div", {
                                                                    className: "border-b border-gray-200 mx-6"
                                                                  }) : null);
                                                }))
                                    )
                                ) : React.createElement("div", {
                                      className: "text-center py-4 text-gray-500"
                                    }, "Please connect your wallet to see your names"))
                      ))), match$4[0] ? React.createElement("div", {
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
  make ,
}
/* Icons Not a pure module */
