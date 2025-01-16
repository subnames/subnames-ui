// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Utils from "../Utils.res.mjs";
import * as React from "react";
import * as Constants from "../Constants.res.mjs";
import * as NameContext from "../NameContext.res.mjs";
import * as OnChainOperationsCommon from "../OnChainOperationsCommon.res.mjs";

function Profile$ProfileForm(props) {
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
        return false;
      });
  var loading = match$7[0];
  var match$8 = React.useState(function () {
        
      });
  var error = match$8[0];
  var handleSubmit = function ($$event) {
    $$event.preventDefault();
    onSubmit(description, $$location, twitter, telegram, github, website, email);
  };
  return React.createElement("div", {
              className: "max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-sm"
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
                              placeholder: "Tell us about yourself...",
                              rows: 4,
                              value: description,
                              onChange: (function ($$event) {
                                  setDescription(function (param) {
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
                          }, error) : null, React.createElement("button", {
                          className: "w-full bg-blue-600 text-white p-3 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors",
                          disabled: loading,
                          type: "submit"
                        }, loading ? "Saving..." : "Save Profile"))));
}

var ProfileForm = {
  make: Profile$ProfileForm
};

function Profile$ProfileField(props) {
  var value = props.value;
  return React.createElement("div", {
              className: "flex items-center space-x-3 rounded-lg bg-slate-100 p-3"
            }, React.createElement("div", {
                  className: "flex items-center justify-center w-10 h-10 rounded-lg"
                }, React.cloneElement(props.icon, {
                      className: "w-5 h-5 text-gray-600"
                    })), React.createElement("div", {
                  className: "flex-1"
                }, React.createElement("div", {
                      className: "text-sm font-medium text-gray-500 mb-1"
                    }, props.label), React.createElement("div", {
                      className: "text-gray-800 font-medium"
                    }, value === "" ? React.createElement("span", {
                            className: "text-gray-400 italic"
                          }, "Not provided") : value)));
}

var ProfileField = {
  make: Profile$ProfileField
};

function Profile$ViewProfile(props) {
  var profile = props.profile;
  var description = profile[0];
  var match = NameContext.use();
  var primaryName = match.primaryName;
  var match$1 = primaryName !== undefined ? primaryName : ({
        name: "",
        expires: 0
      });
  return React.createElement("div", {
              className: "w-full max-w-xl mx-auto"
            }, React.createElement("div", {
                  className: "bg-white rounded-custom shadow-lg overflow-hidden p-8"
                }, React.createElement("div", {
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
                                    d: "M22.23 5.924c-.807.358-1.672.6-2.582.71a4.526 4.526 0 001.984-2.496 9.037 9.037 0 01-2.866 1.095 4.513 4.513 0 00-7.69 4.116 12.81 12.81 0 01-9.3-4.715 4.513 4.513 0 001.396 6.022 4.493 4.493 0 01-2.043-.564v.057a4.513 4.513 0 003.62 4.425 4.52 4.52 0 01-2.037.077 4.513 4.513 0 004.216 3.134 9.05 9.05 0 01-5.604 1.93c-.364 0-.724-.021-1.08-.063a12.773 12.773 0 006.92 2.029c8.3 0 12.84-6.876 12.84-12.84 0-.195-.004-.39-.013-.583a9.172 9.172 0 002.252-2.336z"
                                  })),
                          label: "X (Twitter)",
                          value: profile[2]
                        }), React.createElement(Profile$ProfileField, {
                          icon: React.createElement("svg", {
                                className: "w-5 h-5",
                                fill: "currentColor",
                                viewBox: "0 0 24 24"
                              }, React.createElement("path", {
                                    d: "M16 8.2A4.4 4.4 0 1111.6 12.6 4.4 4.4 0 0116 8.2zM2 2v20h20V2zm18 2.8a6.8 6.8 0 01-6.78 6.8A6.8 6.8 0 014 4.8V4h16z"
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
                        })), React.createElement("div", {
                      className: "flex flex-col "
                    }, description !== undefined ? React.createElement("div", {
                            className: "text-gray-600 leading-relaxed"
                          }, description) : null, React.createElement("div", {
                          className: "flex items-center justify-between"
                        }, React.createElement("div", undefined, React.createElement("div", {
                                  className: "text-sm text-gray-400 mt-1"
                                }, "Expiry: ", Utils.timestampToDate(match$1.expires).toLocaleDateString()), React.createElement("h1", {
                                  className: "text-3xl font-bold text-gray-900"
                                }, match$1.name + "." + Constants.sld))))));
}

var ViewProfile = {
  make: Profile$ViewProfile
};

function Profile(props) {
  React.useState(function () {
        
      });
  React.useState(function () {
        return false;
      });
  React.useState(function () {
        
      });
  return React.createElement("div", {
              className: "p-8"
            }, React.createElement(Profile$ViewProfile, {
                  profile: [
                    undefined,
                    "",
                    "",
                    "",
                    "",
                    "",
                    ""
                  ]
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
