// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Icons from "../components/Icons.res.mjs";
import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Wagmi from "wagmi";
import * as Js_exn from "rescript/lib/es6/js_exn.js";
import * as Constants from "../Constants.res.mjs";
import * as Jdenticon from "jdenticon";
import * as L2Resolver from "../contracts/L2Resolver.res.mjs";
import * as ProfileForm from "./ProfileForm.res.mjs";
import ColorMjs from "../color.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as BaseRegistrar from "../contracts/BaseRegistrar.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../contracts/OnChainOperationsCommon.res.mjs";

function stringToRgba(prim0, prim1) {
  return ColorMjs(prim0, prim1);
}

var UseAccount = {};

async function loadProfile(name) {
  var description = await L2Resolver.getText(name, "description");
  var $$location = await L2Resolver.getText(name, "location");
  var twitter = await L2Resolver.getText(name, "twitter");
  var telegram = await L2Resolver.getText(name, "telegram");
  var github = await L2Resolver.getText(name, "github");
  var website = await L2Resolver.getText(name, "website");
  var email = await L2Resolver.getText(name, "email");
  var avatar = await L2Resolver.getText(name, "avatar");
  return [
          description,
          $$location,
          twitter,
          telegram,
          github,
          website,
          email,
          avatar
        ];
}

async function getNameExpiry(name) {
  try {
    return await BaseRegistrar.nameExpires(name);
  }
  catch (raw_e){
    var e = Caml_js_exceptions.internalToOCamlException(raw_e);
    if (e.RE_EXN_ID === Js_exn.$$Error) {
      console.error("Failed to get name expiry: " + Core__Option.getOr(e._1.message, "Unknown error"));
      return 0n;
    }
    throw e;
  }
}

function ProfileView$ProfileField(props) {
  var value = props.value;
  var label = props.label;
  var tmp;
  var exit = 0;
  switch (label) {
    case "Email" :
        if (value !== undefined && value.indexOf("@") > 0) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: "mailto:" + value
              }, value);
        } else {
          exit = 1;
        }
        break;
    case "GitHub" :
        if (value !== undefined) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: "https://github.com/" + value,
                target: "_blank"
              }, value);
        } else {
          exit = 1;
        }
        break;
    case "Location" :
        if (value !== undefined) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: "https://maps.google.com/?q=" + value,
                target: "_blank"
              }, value);
        } else {
          exit = 1;
        }
        break;
    case "Telegram" :
        if (value !== undefined) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: "https://t.me/" + value.replace("@", ""),
                target: "_blank"
              }, value);
        } else {
          exit = 1;
        }
        break;
    case "Website" :
        if (value !== undefined && value.startsWith("http")) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: value,
                target: "_blank"
              }, value);
        } else {
          exit = 1;
        }
        break;
    case "X" :
        if (value !== undefined) {
          tmp = React.createElement("a", {
                className: "text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all",
                href: "https://x.com/" + value.replace("@", ""),
                target: "_blank"
              }, value);
        } else {
          exit = 1;
        }
        break;
    default:
      exit = 1;
  }
  if (exit === 1) {
    tmp = value !== undefined ? value : React.createElement("span", {
            className: "text-gray-400 italic"
          }, "Not provided");
  }
  return React.createElement("div", {
              className: "flex items-center space-x-3 rounded-lg p-5"
            }, React.createElement("div", {
                  className: "flex items-center justify-center w-10 h-10 rounded-lg"
                }, React.cloneElement(props.icon, {
                      className: "w-5 h-5 text-gray-600"
                    })), React.createElement("div", {
                  className: "flex-1"
                }, React.createElement("div", {
                      className: "text-sm font-medium text-gray-400 mb-1"
                    }, label), React.createElement("div", {
                      className: "text-gray-800 break-words mr-5"
                    }, tmp)));
}

var ProfileField = {
  make: ProfileView$ProfileField
};

function ProfileView(props) {
  var name = props.name;
  var account = Wagmi.useAccount();
  var match = React.useState(function () {
        return [
                undefined,
                undefined,
                undefined,
                undefined,
                undefined,
                undefined,
                undefined,
                undefined
              ];
      });
  var setProfile = match[1];
  var profile = match[0];
  var match$1 = React.useState(function () {
        return true;
      });
  var setLoading = match$1[1];
  var match$2 = React.useState(function () {
        return 0n;
      });
  var setExpires = match$2[1];
  var match$3 = React.useState(function () {
        return false;
      });
  var setIsOwner = match$3[1];
  var isOwner = match$3[0];
  var match$4 = React.useState(function () {
        return false;
      });
  var setIsEditing = match$4[1];
  React.useEffect((function () {
          var checkOwnership = async function () {
            if (!account.isConnected) {
              return setIsOwner(function (param) {
                          return false;
                        });
            }
            try {
              var owner = await BaseRegistrar.getTokenOwner(name);
              var currentAddress = await OnChainOperationsCommon.getCurrentAddress();
              if (currentAddress === undefined) {
                return setIsOwner(function (param) {
                            return false;
                          });
              }
              var isOwner = owner.toLowerCase() === currentAddress.toLowerCase();
              return setIsOwner(function (param) {
                          return isOwner;
                        });
            }
            catch (raw_e){
              var e = Caml_js_exceptions.internalToOCamlException(raw_e);
              if (e.RE_EXN_ID === Js_exn.$$Error) {
                console.error("Failed to check ownership: " + Core__Option.getOr(e._1.message, "Unknown error"));
                return setIsOwner(function (param) {
                            return false;
                          });
              }
              throw e;
            }
          };
          checkOwnership();
        }), [
        account.isConnected,
        name
      ]);
  React.useEffect((function () {
          var loadProfileData = async function () {
            try {
              var profileData = await loadProfile(name);
              setProfile(function (param) {
                    return profileData;
                  });
              var expiryBigInt = await getNameExpiry(name);
              setExpires(function (param) {
                    return expiryBigInt;
                  });
            }
            catch (raw_e){
              var e = Caml_js_exceptions.internalToOCamlException(raw_e);
              if (e.RE_EXN_ID === Js_exn.$$Error) {
                console.error("Failed to load profile: " + Core__Option.getOr(e._1.message, "Unknown error"));
              } else {
                throw e;
              }
            }
            return setLoading(function (param) {
                        return false;
                      });
          };
          loadProfileData();
        }), [name]);
  var onSave = function (profile) {
    setProfile(function (param) {
          return profile;
        });
    setIsEditing(function (param) {
          return false;
        });
  };
  if (match$1[0]) {
    return React.createElement("div", {
                className: "flex justify-center items-center h-64"
              }, React.createElement(Icons.Spinner.make, {
                    className: "w-8 h-8 text-zinc-600"
                  }));
  }
  if (match$4[0] && isOwner) {
    return React.createElement(ProfileForm.make, {
                onCancel: (function () {
                    setIsEditing(function (param) {
                          return false;
                        });
                  }),
                onSave: onSave,
                profile: profile
              });
  }
  var value = profile[7];
  var desc = profile[0];
  var loc = profile[1];
  var tw = profile[2];
  var tg = profile[3];
  var gh = profile[4];
  var ws = profile[5];
  var em = profile[6];
  return React.createElement("div", {
              className: "w-full max-w-xl mx-auto relative p-8"
            }, React.createElement("div", {
                  className: "bg-white rounded-custom shadow-lg mt-16 relative"
                }, React.createElement("div", {
                      className: "p-8 py-6 rounded-custom shadow-md",
                      style: {
                        backgroundColor: ColorMjs(name, 0.2)
                      }
                    }, isOwner ? React.createElement("div", {
                            className: "absolute top-4 right-4 z-10"
                          }, React.createElement("div", {
                                className: "relative flex-shrink-0"
                              }, React.createElement("button", {
                                    className: "p-2 rounded-lg hover:bg-gray-100 focus:outline-none",
                                    onClick: (function (param) {
                                        setIsEditing(function (param) {
                                              return true;
                                            });
                                      })
                                  }, React.createElement("svg", {
                                        className: "w-5 h-5",
                                        fill: "none",
                                        stroke: "currentColor",
                                        viewBox: "0 0 24 24"
                                      }, React.createElement("path", {
                                            d: "M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z",
                                            strokeLinecap: "round",
                                            strokeLinejoin: "round",
                                            strokeWidth: "2"
                                          }))))) : null, React.createElement("div", {
                          className: "flex flex-col mb-4 items-center"
                        }, React.createElement("div", {
                              className: "flex justify-center -mt-20 mb-3 relative"
                            }, React.createElement("div", {
                                  className: "w-32 h-32 rounded-full border-4 border-white overflow-hidden relative bg-gray-100 shadow"
                                }, React.createElement("div", {
                                      className: "flex justify-center items-center absolute inset-0"
                                    }, React.createElement(Icons.Spinner.make, {
                                          className: "w-5 h-5 text-zinc-600"
                                        })), value !== undefined ? React.createElement("img", {
                                        className: "w-full h-full object-cover absolute inset-0 opacity-0 transition-opacity duration-300 rounded-full",
                                        alt: "Profile Avatar",
                                        src: value,
                                        onLoad: (function (e) {
                                            var target = e.target;
                                            target.classList.remove("opacity-0");
                                          })
                                      }) : React.createElement("div", {
                                        className: "w-full h-full object-cover absolute inset-0 transition-opacity duration-300 rounded-full",
                                        dangerouslySetInnerHTML: {
                                          __html: Jdenticon.toSvg(name, 120, {
                                                backColor: "#ffffff",
                                                padding: 0.15
                                              })
                                        }
                                      }))), React.createElement("div", {
                              className: "flex justify-center items-center w-full relative"
                            }, React.createElement("h1", {
                                  className: "text-3xl font-bold text-gray-900 max-w-[90%] truncate text-center",
                                  title: name + "." + Constants.sld
                                }, name + "." + Constants.sld)), React.createElement("div", {
                              className: "text-xs text-gray-500 mt-1"
                            }, "Expiry: ", Utils.timestampToDate(match$2[0]).toLocaleDateString()), React.createElement("div", {
                              className: "text-center leading-relaxed py-2"
                            }, desc !== undefined ? desc : React.createElement("div", {
                                    className: "text-gray-400"
                                  }, "No description")))), React.createElement("div", {
                      className: "grid grid-cols-1 pb-4 pt-5"
                    }, React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "none",
                                stroke: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z",
                                    strokeLinecap: "round",
                                    strokeLinejoin: "round",
                                    strokeWidth: "2"
                                  }), React.createElement("path", {
                                    d: "M15 11a3 3 0 11-6 0 3 3 0 016 0z",
                                    strokeLinecap: "round",
                                    strokeLinejoin: "round",
                                    strokeWidth: "2"
                                  })),
                          label: "Location",
                          value: loc !== undefined ? loc : undefined
                        }), React.createElement("div", {
                          className: "border-t border-gray-100 my-3 mx-6"
                        }), React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                                  })),
                          label: "X",
                          value: tw !== undefined ? tw : undefined
                        }), React.createElement("div", {
                          className: "border-t border-gray-100 my-3 mx-6"
                        }), React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.514.26l.204-2.98 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.87 4.326-2.962-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.535-.196 1.006.128.832.941z"
                                  })),
                          label: "Telegram",
                          value: tg !== undefined ? tg : undefined
                        }), React.createElement("div", {
                          className: "border-t border-gray-100 my-3 mx-6"
                        }), React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "none",
                                stroke: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    clipRule: "evenodd",
                                    d: "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z",
                                    fillRule: "evenodd"
                                  })),
                          label: "GitHub",
                          value: gh !== undefined ? gh : undefined
                        }), React.createElement("div", {
                          className: "border-t border-gray-100 my-3 mx-6"
                        }), React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "none",
                                stroke: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1",
                                    strokeLinecap: "round",
                                    strokeLinejoin: "round",
                                    strokeWidth: "2"
                                  })),
                          label: "Website",
                          value: ws !== undefined ? ws : undefined
                        }), React.createElement("div", {
                          className: "border-t border-gray-100 my-3 mx-6"
                        }), React.createElement(ProfileView$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "none",
                                stroke: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z",
                                    strokeLinecap: "round",
                                    strokeLinejoin: "round",
                                    strokeWidth: "2"
                                  })),
                          label: "Email",
                          value: em !== undefined ? em : undefined
                        }))));
}

var make = ProfileView;

export {
  stringToRgba ,
  UseAccount ,
  loadProfile ,
  getNameExpiry ,
  ProfileField ,
  make ,
}
/* Icons Not a pure module */
