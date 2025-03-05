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
        return true;
      });
  var setIsSynced = match$3[1];
  var isSynced = match$3[0];
  var match$4 = React.useState(function () {
        
      });
  var setActiveDropdown = match$4[1];
  var activeDropdown = match$4[0];
  var match$5 = React.useState(function () {
        return false;
      });
  var setSettingPrimaryName = match$5[1];
  var settingPrimaryName = match$5[0];
  var match$6 = React.useState(function () {
        
      });
  var setShowExtendPanel = match$6[1];
  var showExtendPanel = match$6[0];
  var match$7 = React.useState(function () {
        
      });
  var setShowTransferPanel = match$7[1];
  var showTransferPanel = match$7[0];
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
                      var label = Utils.getStringExn(obj, "label");
                      var name = Utils.getStringExn(obj, "name");
                      var expires = Core__Option.getExn(Core__Int.fromString(Utils.getStringExn(obj, "expires"), undefined), undefined);
                      var resolvedTo = Utils.getObjectExn(obj, "resolvedTo", (function (o) {
                              return {
                                      id: Utils.getStringExn(o, "id")
                                    };
                            }));
                      var owner = Utils.getObjectExn(obj, "owner", (function (o) {
                              return {
                                      id: Utils.getStringExn(o, "id")
                                    };
                            }));
                      var reverseResolvedFrom = Utils.getObject(obj, "reverseResolvedFrom", (function (o) {
                              return {
                                      id: Utils.getStringExn(o, "id")
                                    };
                            }));
                      var currentAddressLowercase = Core__Option.getExn(Core__Option.map(account.address, (function (prim) {
                                  return prim.toLowerCase();
                                })), undefined);
                      return {
                              label: label,
                              name: name,
                              expires: expires,
                              resolvedTo: resolvedTo,
                              owner: owner,
                              reverseResolvedFrom: reverseResolvedFrom,
                              underTransfer: resolvedTo.id !== currentAddressLowercase,
                              receiver: resolvedTo.id !== currentAddressLowercase ? resolvedTo.id : undefined
                            };
                    })), undefined);
  };
  var checkSyncStatus = async function () {
    try {
      var response = await fetch(Constants.metricsUrl, {
            method: "GET"
          });
      var text = await response.text();
      var lines = text.split("\n");
      var chainHeightLine = lines.find(function (line) {
            return line.startsWith("sqd_processor_chain_height");
          });
      var lastBlockLine = lines.find(function (line) {
            return line.startsWith("sqd_processor_last_block");
          });
      var exit = 0;
      if (chainHeightLine !== undefined) {
        if (lastBlockLine !== undefined) {
          var chainHeight = Core__Option.getOr(Core__Option.flatMap(chainHeightLine.split(" ")[1], (function (str) {
                      return Core__Int.fromString(str, undefined);
                    })), 0);
          var lastBlock = Core__Option.getOr(Core__Option.flatMap(lastBlockLine.split(" ")[1], (function (str) {
                      return Core__Int.fromString(str, undefined);
                    })), 0);
          console.log("Chain height: " + chainHeight.toString() + ", Last block: " + lastBlock.toString());
          var diff = chainHeight - lastBlock | 0;
          return setIsSynced(function (param) {
                      return diff <= 3;
                    });
        }
        exit = 1;
      } else {
        exit = 1;
      }
      if (exit === 1) {
        return setIsSynced(function (param) {
                    return true;
                  });
      }
      
    }
    catch (exn){
      return setIsSynced(function (param) {
                  return true;
                });
    }
  };
  React.useEffect((function () {
          checkSyncStatus();
          var intervalId = setInterval((function () {
                  checkSyncStatus();
                }), 30000);
          return (function () {
                    clearInterval(intervalId);
                  });
        }), []);
  React.useEffect((function () {
          if (account.isConnected) {
            var fetchNames = async function () {
              var address = Core__Option.getExn(Core__Option.map(account.address, (function (prim) {
                          return prim.toLowerCase();
                        })), "No address found");
              var query = "\n          query {\n            subnames(where: {\n              owner: {id_eq: \"" + address + "\"}\n            }) {\n              label\n              name\n              expires\n              owner {\n                id\n              }\n              resolvedTo {\n                id\n              }\n              reverseResolvedFrom {\n                id\n              }\n            }\n          }\n        ";
              console.log(query);
              var result = await GraphQLClient.makeRequest(Constants.indexerUrl, query, undefined, undefined);
              var data = result.data;
              var exit = 0;
              if (data !== undefined && result.errors === undefined) {
                var subnames = Utils.getArrayExn(data, "subnames", buildSubname);
                subnames.sort(function (a, b) {
                      return a.expires - b.expires | 0;
                    });
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
          
        }), [
        account,
        OnChainOperationsCommon.currentAddress
      ]);
  var tmp;
  if (settingPrimaryName || Core__Option.isSome(showTransferPanel) || Core__Option.isSome(showExtendPanel)) {
    var tmp$1;
    if (settingPrimaryName) {
      tmp$1 = React.createElement("div", {
            className: "flex items-center gap-3 py-4 px-6 bg-gray-100 rounded-2xl shadow-sm"
          }, React.createElement(Icons.Spinner.make, {
                className: "h-6 w-6 text-gray-900"
              }), React.createElement("p", {
                className: "text-gray-900 text-lg font-medium"
              }, "Setting primary name..."));
    } else if (Core__Option.isSome(showTransferPanel)) {
      var match$8 = Core__Option.getExn(showTransferPanel, undefined);
      tmp$1 = React.createElement(TransferPanel.make, {
            name: match$8[0],
            receiver: match$8[1],
            onCancel: (function () {
                setShowTransferPanel(function (param) {
                      
                    });
              }),
            onSuccess: handleTransferSuccess,
            buttonType: "close"
          });
    } else if (Core__Option.isSome(showExtendPanel)) {
      var name = Core__Option.getExn(showExtendPanel, undefined);
      tmp$1 = React.createElement(RegisterExtendPanel.make, {
            name: name,
            isWalletConnected: account.isConnected,
            onBack: (function () {
                setShowExtendPanel(function (param) {
                      
                    });
              }),
            onSuccess: handleExtendSuccess,
            action: "Extend",
            buttonType: "close"
          });
    } else {
      tmp$1 = null;
    }
    tmp = React.createElement("div", {
          className: "fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
        }, React.createElement("div", {
              className: "bg-white rounded-2xl shadow-xl"
            }, tmp$1));
  } else {
    tmp = null;
  }
  return React.createElement(React.Fragment, {}, React.createElement("div", {
                  className: "p-8"
                }, React.createElement("div", {
                      className: "w-full max-w-xl mx-auto"
                    }, React.createElement("div", {
                          className: "bg-white rounded-custom shadow-lg"
                        }, React.createElement("div", {
                              className: "p-8 py-6 border-b border-gray-200 relative"
                            }, React.createElement("h1", {
                                  className: "text-3xl font-bold text-gray-900"
                                }, "Your names"), React.createElement("div", {
                                  className: "text-sm text-gray-500"
                                }, "It may take a while to sync your names. ", isSynced ? React.createElement("span", {
                                        className: "text-green-600 font-medium"
                                      }, "Indexer is fully synced") : React.createElement("span", {
                                        className: "text-amber-600 font-medium"
                                      }, "Indexer is currently syncing... Operations are disabled.")), React.createElement("button", {
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
                                      }, "You don't have any names yet") : React.createElement("div", undefined, React.createElement("div", {
                                            className: "py-1"
                                          }, names.map(function (subname, index) {
                                                var tmp;
                                                if (Caml_obj.equal(activeDropdown, subname.name)) {
                                                  var tmp$1;
                                                  if (subname.underTransfer) {
                                                    tmp$1 = null;
                                                  } else {
                                                    var tmp$2;
                                                    var exit = 0;
                                                    if (primaryName !== undefined && primaryName.name === subname.name) {
                                                      tmp$2 = null;
                                                    } else {
                                                      exit = 1;
                                                    }
                                                    if (exit === 1) {
                                                      tmp$2 = React.createElement("button", {
                                                            className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                                            disabled: !isSynced,
                                                            type: "button",
                                                            onClick: (function (param) {
                                                                setPrimary(subname.name);
                                                                setActiveDropdown(function (param) {
                                                                      
                                                                    });
                                                              })
                                                          }, "Set primary");
                                                    }
                                                    tmp$1 = React.createElement(React.Fragment, {}, tmp$2, React.createElement("button", {
                                                              className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                                              disabled: !isSynced,
                                                              type: "button",
                                                              onClick: (function (param) {
                                                                  setShowExtendPanel(function (param) {
                                                                        return subname.name;
                                                                      });
                                                                  setActiveDropdown(function (param) {
                                                                        
                                                                      });
                                                                })
                                                            }, "Extend"));
                                                  }
                                                  var tmp$3;
                                                  var exit$1 = 0;
                                                  if (primaryName !== undefined && primaryName.name === subname.name) {
                                                    tmp$3 = null;
                                                  } else {
                                                    exit$1 = 1;
                                                  }
                                                  if (exit$1 === 1) {
                                                    tmp$3 = React.createElement("button", {
                                                          className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                                          disabled: !isSynced,
                                                          type: "button",
                                                          onClick: (function (param) {
                                                              setShowTransferPanel(function (param) {
                                                                    return [
                                                                            subname.name,
                                                                            subname.receiver
                                                                          ];
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
                                                          }, tmp$1, tmp$3));
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
                                                                              }, subname.underTransfer ? React.createElement("span", {
                                                                                      className: "text-gray-400"
                                                                                    }, React.createElement("span", {
                                                                                          className: "font-bold"
                                                                                        }, subname.name), "." + Constants.sld) : React.createElement(React.Fragment, {}, React.createElement("span", {
                                                                                          className: "font-bold"
                                                                                        }, subname.name), "." + Constants.sld)), primaryName !== undefined && primaryName.name === subname.name ? React.createElement("span", {
                                                                                  className: "px-2 py-0.5 text-xs bg-blue-100 text-blue-800 rounded-full font-medium"
                                                                                }, "Primary") : null), subname.underTransfer ? React.createElement("p", {
                                                                              className: "text-xs text-gray-300 mt-1"
                                                                            }, "Expires " + Utils.distanceToExpiry(Utils.timestampToDate(subname.expires))) : React.createElement("p", {
                                                                              className: "text-xs text-gray-400 mt-1"
                                                                            }, "Expires " + Utils.distanceToExpiry(Utils.timestampToDate(subname.expires)))), React.createElement("div", {
                                                                        className: "relative"
                                                                      }, React.createElement("button", {
                                                                            className: "p-2 rounded-lg focus:outline-none " + (
                                                                              isSynced ? "hover:bg-gray-100" : "opacity-50 cursor-not-allowed"
                                                                            ),
                                                                            disabled: !isSynced,
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
                                                                  className: "border-b border-gray-100 mx-6"
                                                                }) : null);
                                              })))
                              )
                          ) : React.createElement("div", {
                                className: "text-center py-4 text-gray-500"
                              }, "Please connect your wallet to see your names")))), tmp);
}

var make = NamesList;

export {
  make ,
}
/* Icons Not a pure module */
