// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Constants from "../Constants.res.mjs";
import * as NameContext from "../NameContext.res.mjs";
import * as Core__Option from "@rescript/core/src/Core__Option.res.mjs";
import * as Caml_js_exceptions from "rescript/lib/es6/caml_js_exceptions.js";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function Profile$ProfileForm(props) {
  var onCancel = props.onCancel;
  var onSubmit = props.onSubmit;
  var match = React.useState(function () {
        return "";
      });
  var setDescription = match[1];
  var description = match[0];
  var match$1 = React.useState(function () {
        return "";
      });
  var setLocation = match$1[1];
  var $$location = match$1[0];
  var match$2 = React.useState(function () {
        return "";
      });
  var setTwitter = match$2[1];
  var twitter = match$2[0];
  var match$3 = React.useState(function () {
        return "";
      });
  var setTelegram = match$3[1];
  var telegram = match$3[0];
  var match$4 = React.useState(function () {
        return "";
      });
  var setGithub = match$4[1];
  var github = match$4[0];
  var match$5 = React.useState(function () {
        return "";
      });
  var setWebsite = match$5[1];
  var website = match$5[0];
  var match$6 = React.useState(function () {
        return "";
      });
  var setEmail = match$6[1];
  var email = match$6[0];
  var match$7 = React.useState(function () {
        return "";
      });
  var setAvatar = match$7[1];
  var avatar = match$7[0];
  var match$8 = React.useState(function () {
        return false;
      });
  var loading = match$8[0];
  var match$9 = React.useState(function () {
        
      });
  var setError = match$9[1];
  var error = match$9[0];
  var validateEmail = function (email) {
    var emailRegex = new RegExp("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$");
    return emailRegex.test(email);
  };
  var validateWebsite = function (website) {
    var urlRegex = new RegExp("^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$");
    if (website === "") {
      return true;
    } else {
      return urlRegex.test(website);
    }
  };
  var handleSubmit = function ($$event) {
    $$event.preventDefault();
    var match = validateEmail(email);
    var match$1 = validateWebsite(website);
    if (match) {
      if (match$1) {
        setError(function (param) {
              
            });
        return onSubmit(description, $$location, twitter, telegram, github, website, email, avatar);
      } else {
        return setError(function (param) {
                    return "Please enter a valid website URL";
                  });
      }
    } else {
      return setError(function (param) {
                  return "Please enter a valid email address";
                });
    }
  };
  return React.createElement("div", {
              className: "w-full max-w-xl mx-auto bg-white rounded-custom shadow-lg p-8"
            }, React.createElement("h1", {
                  className: "text-3xl font-bold mb-8 text-gray-900"
                }, "Edit Profile"), React.createElement("form", {
                  onSubmit: handleSubmit
                }, React.createElement("div", {
                      className: "space-y-6"
                    }, React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Description"), React.createElement("textarea", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "About yourself...",
                              rows: 4,
                              value: description,
                              onChange: (function ($$event) {
                                  setDescription(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Avatar"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "Avatar URL",
                              type: "text",
                              value: $$location,
                              onChange: (function ($$event) {
                                  setAvatar(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Location"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "City, Country",
                              type: "text",
                              value: $$location,
                              onChange: (function ($$event) {
                                  setLocation(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "X (Twitter)"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "@username",
                              type: "text",
                              value: twitter,
                              onChange: (function ($$event) {
                                  setTwitter(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Telegram"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "@username",
                              type: "text",
                              value: telegram,
                              onChange: (function ($$event) {
                                  setTelegram(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "GitHub"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "username",
                              type: "text",
                              value: github,
                              onChange: (function ($$event) {
                                  setGithub(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Website"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "https://",
                              type: "url",
                              value: website,
                              onChange: (function ($$event) {
                                  setWebsite(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), React.createElement("div", undefined, React.createElement("label", {
                              className: "block text-sm font-medium mb-2 text-gray-700"
                            }, "Email"), React.createElement("input", {
                              className: "w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors",
                              placeholder: "your@email.com",
                              type: "email",
                              value: email,
                              onChange: (function ($$event) {
                                  setEmail(function (param) {
                                        return $$event.target.value;
                                      });
                                })
                            })), error !== undefined ? React.createElement("div", {
                            className: "p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm"
                          }, error) : null, React.createElement("div", {
                          className: "flex gap-4"
                        }, React.createElement("button", {
                              className: "flex-1 bg-gray-100 text-gray-700 p-3 rounded-xl font-medium hover:bg-gray-200 transition-colors",
                              type: "button",
                              onClick: (function (param) {
                                  onCancel();
                                })
                            }, "Cancel"), React.createElement("button", {
                              className: "flex-1 bg-blue-600 text-white p-3 rounded-xl font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors",
                              disabled: loading,
                              type: "submit"
                            }, loading ? "Saving..." : "Save Profile")))));
}

var ProfileForm = {
  make: Profile$ProfileForm
};

function Profile$ProfileField(props) {
  var value = props.value;
  return React.createElement("div", {
              className: "flex items-center space-x-3 rounded-lg p-3 bg-gradient-to-r to-white from-slate-100 "
            }, React.createElement("div", {
                  className: "flex items-center justify-center w-10 h-10 rounded-lg"
                }, React.cloneElement(props.icon, {
                      className: "w-5 h-5 text-gray-600"
                    })), React.createElement("div", {
                  className: "flex-1"
                }, React.createElement("div", {
                      className: "text-sm font-medium text-gray-500 mb-1"
                    }, props.label), React.createElement("div", {
                      className: "text-gray-800"
                    }, value === "" ? React.createElement("span", {
                            className: "text-gray-400 italic"
                          }, "Not provided") : value)));
}

var ProfileField = {
  make: Profile$ProfileField
};

function Profile$ViewProfile(props) {
  var setIsEditing = props.setIsEditing;
  var profile = props.profile;
  var match = React.useState(function () {
        return false;
      });
  var description = profile[0];
  var setShowDropdown = match[1];
  var match$1 = NameContext.use();
  var primaryName = match$1.primaryName;
  var match$2 = primaryName !== undefined ? primaryName : ({
        name: "",
        expires: 0
      });
  var name = match$2.name;
  return React.createElement("div", {
              className: "w-full max-w-xl mx-auto relative"
            }, React.createElement("div", {
                  className: "absolute -top-20 left-1/2 transform -translate-x-1/2"
                }, React.createElement("img", {
                      className: "w-32 h-32 rounded-full border-4 border-white",
                      alt: "Profile Avatar",
                      src: "https://ui-avatars.com/api/?uppercase=false&name=" + name
                    })), React.createElement("div", {
                  className: "bg-white rounded-custom shadow-lg p-8 py-6 mt-16"
                }, React.createElement("div", {
                      className: "flex flex-col mb-4"
                    }, React.createElement("div", {
                          className: "flex items-center justify-between w-full"
                        }, React.createElement("div", {
                              className: "flex  w-full justify-between items-end"
                            }, React.createElement("div", undefined, React.createElement("div", {
                                      className: "text-sm text-gray-400 mt-1"
                                    }, "Expiry: ", Utils.timestampToDate(match$2.expires).toLocaleDateString()), React.createElement("h1", {
                                      className: "text-3xl font-bold text-gray-900"
                                    }, name + "." + Constants.sld)), React.createElement("div", {
                                  className: "relative flex-shrink-0"
                                }, React.createElement("button", {
                                      className: "p-2 rounded-lg hover:bg-gray-100 focus:outline-none",
                                      onClick: (function (param) {
                                          setShowDropdown(function (prev) {
                                                return !prev;
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
                                            }))), React.createElement("div", {
                                      className: "absolute right-0 mt-2 w-48 rounded-lg shadow-xl bg-white/95 backdrop-blur-sm border border-gray-100 " + (
                                        match[0] ? "" : "hidden"
                                      )
                                    }, React.createElement("div", {
                                          className: "py-1"
                                        }, React.createElement("button", {
                                              className: "block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left",
                                              onClick: (function (param) {
                                                  setShowDropdown(function (param) {
                                                        return false;
                                                      });
                                                  setIsEditing(function (param) {
                                                        return true;
                                                      });
                                                })
                                            }, "Edit Profile")))))), description !== undefined ? React.createElement("div", {
                            className: "text-gray-400 leading-relaxed  py-2"
                          }, description) : React.createElement("div", {
                            className: "text-gray-400 italic leading-relaxed py-2"
                          }, "No description")), React.createElement("div", {
                      className: "grid grid-cols-1 md:grid-cols-2 gap-4 pb-4"
                    }, React.createElement(Profile$ProfileField, {
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
                          value: profile[1]
                        }), React.createElement(Profile$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                                  })),
                          label: "X",
                          value: profile[2]
                        }), React.createElement(Profile$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.514.26l.204-2.98 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.87 4.326-2.962-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.535-.196 1.006.128.832.941z"
                                  })),
                          label: "Telegram",
                          value: profile[3]
                        }), React.createElement(Profile$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    clipRule: "evenodd",
                                    d: "M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z",
                                    fillRule: "evenodd"
                                  })),
                          label: "GitHub",
                          value: profile[4]
                        }), React.createElement(Profile$ProfileField, {
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
                          value: profile[5]
                        }), React.createElement(Profile$ProfileField, {
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
                          value: profile[6]
                        }))));
}

var ViewProfile = {
  make: Profile$ViewProfile
};

function Profile(props) {
  var match = React.useState(function () {
        
      });
  var setProfile = match[1];
  var match$1 = React.useState(function () {
        return false;
      });
  var setLoading = match$1[1];
  var match$2 = React.useState(function () {
        
      });
  var setError = match$2[1];
  var match$3 = React.useState(function () {
        return false;
      });
  var setIsEditing = match$3[1];
  var isEditing = match$3[0];
  var handleCancel = function () {
    setIsEditing(function (param) {
          return false;
        });
  };
  var handleSubmit = function (description, $$location, twitter, telegram, github, website, email, avatar) {
    setLoading(function (param) {
          return true;
        });
    setError(function (param) {
          
        });
    var updateProfile = async function () {
      try {
        var walletClient = Core__Option.getExn(OnChainOperationsCommon.buildWalletClient(), "Wallet connection failed");
        await OnChainOperationsCommon.currentAddress(walletClient);
        console.log("Profile updated successfully!");
        setProfile(function (param) {
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
            });
      }
      catch (raw_error){
        var error = Caml_js_exceptions.internalToOCamlException(raw_error);
        setError(function (param) {
              return "Failed to update profile";
            });
        console.log("Error updating profile:", error);
      }
      return setLoading(function (param) {
                  return false;
                });
    };
    updateProfile();
  };
  return React.createElement("div", {
              className: "p-8"
            }, isEditing ? React.createElement(Profile$ProfileForm, {
                    onSubmit: (function (description, $$location, twitter, telegram, github, website, email, avatar) {
                        handleSubmit(description, $$location, twitter, telegram, github, website, email, avatar);
                        setIsEditing(function (param) {
                              return false;
                            });
                      }),
                    onCancel: handleCancel
                  }) : React.createElement(Profile$ViewProfile, {
                    profile: [
                      undefined,
                      "",
                      "",
                      "",
                      "",
                      "",
                      "",
                      ""
                    ],
                    setProfile: (function (param) {
                        
                      }),
                    isEditing: isEditing,
                    setIsEditing: setIsEditing,
                    onCancel: handleCancel
                  }));
}

var make = Profile;

export {
  ProfileForm ,
  ProfileField ,
  ViewProfile ,
  make ,
}
/* Utils Not a pure module */
