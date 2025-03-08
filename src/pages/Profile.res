open OnChainOperationsCommon

@module("../assets/avatar.png") external avatarImage: string = "default"
@module("../color.mjs") external stringToRgba: (string, float) => string = "default"

type config = {
  backColor: string,
  padding: float
}
@module("jdenticon") external toSvg: (string, int, config) => string = "toSvg"

type p = {
  test: string => bool
}
@module("github-username-regex") external githubUsernameRegex: p = "default"

// Console.log(githubUsernameRegex.test("akiwu"))

module ProfileForm = {
  @react.component
  let make = (
    ~onCancel: unit => unit,
    ~onSave: ((option<string>, option<string>, option<string>, option<string>, option<string>, option<string>, option<string>, option<string>)) => unit,
    ~profile: (
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
  ),
  ) => {
      let (description, location, twitter, telegram, github, website, email, avatar) = profile
      let (description, setDescription) = React.useState(() => description)
      let (location, setLocation) = React.useState(() => location)
      let (twitter, setTwitter) = React.useState(() => twitter)
      let (telegram, setTelegram) = React.useState(() => telegram)
      let (github, setGithub) = React.useState(() => github)
      let (website, setWebsite) = React.useState(() => website)
      let (email, setEmail) = React.useState(() => email)
      let (avatar, setAvatar) = React.useState(() => avatar)
      let (loading, setLoading) = React.useState(() => false)
      let (error, setError) = React.useState(() => None)
      let (githubError, setGithubError) = React.useState(() => None)
      let (emailError, setEmailError) = React.useState(() => None)
      let (websiteError, setWebsiteError) = React.useState(() => None)
      let (avatarError, setAvatarError) = React.useState(() => None)
      let (twitterError, setTwitterError) = React.useState(() => None)
      let (telegramError, setTelegramError) = React.useState(() => None)

      let {primaryName} = NameContext.use()

      let validateEmail = email => {
        Console.log("Validating email: " ++ email->Option.getOr("None"))
        let result = switch email {
        | Some(addr) if addr !== "" =>
          let emailRegex = Js.Re.fromString("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
          let isValid = Js.Re.test_(emailRegex, addr)
          Console.log("Email regex test result: " ++ (isValid ? "true" : "false"))
          isValid
        | None => true
        | Some(_) => true
        }
        Console.log("Email validation result: " ++ (result ? "true" : "false"))
        result
      }

      let validateWebsite = website => {
        switch website {
        | Some(url) if url !== "" =>
          let urlRegex = Js.Re.fromString(
            "^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$",
          )
          Js.Re.test_(urlRegex, url)
        | None => true
        | Some(_) => true
        }
      }

      let validateGithub = github => {
        Console.log("Validating github: " ++ github->Option.getOr("None"))
        let result = switch github {
        | Some(name) if name !== "" => 
          let isValid = githubUsernameRegex.test(name)
          Console.log("Github regex test result: " ++ (isValid ? "true" : "false"))
          isValid
        | None => true
        | Some(_) => true
        }
        Console.log("Github validation result: " ++ (result ? "true" : "false"))
        result
      }

      let validateAvatar = avatar => {
        Console.log("Validating avatar: " ++ avatar->Option.getOr("None"))
        let result = switch avatar {
        | Some(url) if url !== "" => {
          // Simplified URL validation to avoid regex issues
          let isValid = try {
            // Check if it starts with http:// or https://
            let startsWithHttp = String.startsWith(url, "http://") || String.startsWith(url, "https://")
            // Check if it has at least one dot (for domain)
            let hasDot = String.indexOf(url, ".") > 0
            startsWithHttp && hasDot
          } catch {
          | _ => false
          }
          Console.log("Avatar URL validation result: " ++ (isValid ? "true" : "false"))
          isValid
        }
        | None => true
        | Some(_) => true
        }
        Console.log("Avatar validation result: " ++ (result ? "true" : "false"))
        result
      }

      let validateTwitter = twitter => {
        Console.log("Validating twitter: " ++ twitter->Option.getOr("None"))
        let result = switch twitter {
        | Some(username) if username !== "" => {
          // Ensure username starts with @
          let startsWithAt = String.startsWith(username, "@")
          if (!startsWithAt) {
            Console.log("Twitter username must start with @")
            false
          } else {
            // Remove @ for length check (should be 1-15 chars without @)
            let usernameWithoutAt = String.substringToEnd(username, ~start=1)
            let validLength = String.length(usernameWithoutAt) >= 1 && String.length(usernameWithoutAt) <= 15
            let validChars = Js.Re.test_(Js.Re.fromString("^[a-zA-Z0-9_]+$"), usernameWithoutAt)
            let isValid = validLength && validChars
            Console.log("Twitter validation details - starts with @: true, valid length: " ++ (validLength ? "true" : "false") ++ ", valid chars: " ++ (validChars ? "true" : "false"))
            isValid
          }
        }
        | None => true
        | Some(_) => true
        }
        Console.log("Twitter validation result: " ++ (result ? "true" : "false"))
        result
      }

      let validateTelegram = telegram => {
        Console.log("Validating telegram: " ++ telegram->Option.getOr("None"))
        let result = switch telegram {
        | Some(username) if username !== "" => {
          // Ensure username starts with @
          let startsWithAt = String.startsWith(username, "@")
          if (!startsWithAt) {
            Console.log("Telegram username must start with @")
            false
          } else {
            // Remove @ for length check (should be 5-32 chars without @)
            let usernameWithoutAt = String.substringToEnd(username, ~start=1)
            let validLength = String.length(usernameWithoutAt) >= 5 && String.length(usernameWithoutAt) <= 32
            let validChars = Js.Re.test_(Js.Re.fromString("^[a-zA-Z0-9_]+$"), usernameWithoutAt)
            let isValid = validLength && validChars
            Console.log("Telegram validation details - starts with @: true, valid length: " ++ (validLength ? "true" : "false") ++ ", valid chars: " ++ (validChars ? "true" : "false"))
            isValid
          }
        }
        | None => true
        | Some(_) => true
        }
        Console.log("Telegram validation result: " ++ (result ? "true" : "false"))
        result
      }

      let handleSubmit = async event => {
        ReactEvent.Form.preventDefault(event)
        Console.log("Starting form submission")
        
        try {
          // Reset all error states
          setGithubError(_ => None)
          setEmailError(_ => None)
          setWebsiteError(_ => None)
          setAvatarError(_ => None)
          setTwitterError(_ => None)
          setTelegramError(_ => None)
          setError(_ => None)

          // Check all validations
          Console.log("Checking validations")
          let isEmailValid = validateEmail(email)
          Console.log("Email valid: " ++ (isEmailValid ? "true" : "false"))
          let isWebsiteValid = validateWebsite(website)
          Console.log("Website valid: " ++ (isWebsiteValid ? "true" : "false"))
          let isGithubValid = validateGithub(github)
          Console.log("Github valid: " ++ (isGithubValid ? "true" : "false"))
          let isAvatarValid = validateAvatar(avatar)
          Console.log("Avatar valid: " ++ (isAvatarValid ? "true" : "false"))
          let isTwitterValid = validateTwitter(twitter)
          Console.log("Twitter valid: " ++ (isTwitterValid ? "true" : "false"))
          let isTelegramValid = validateTelegram(telegram)
          Console.log("Telegram valid: " ++ (isTelegramValid ? "true" : "false"))

          // Set appropriate error messages
          Console.log("Setting error messages if needed")
          if (!isEmailValid) {
            setEmailError(_ => Some("Please enter a valid email address"))
            Console.log("Set email error")
          }
          if (!isWebsiteValid) {
            setWebsiteError(_ => Some("Please enter a valid website URL"))
            Console.log("Set website error")
          }
          if (!isGithubValid) {
            setGithubError(_ => Some("Please enter a valid GitHub username"))
            Console.log("Set github error")
          }
          if (!isAvatarValid) {
            setAvatarError(_ => Some("Please enter a valid URL for avatar"))
            Console.log("Set avatar error")
          }
          if (!isTwitterValid) {
            setTwitterError(_ => Some("Please enter a valid X (Twitter) username"))
            Console.log("Set twitter error")
          }
          if (!isTelegramValid) {
            setTelegramError(_ => Some("Please enter a valid Telegram username"))
            Console.log("Set telegram error")
          }

          Console.log("Combined validation result: " ++ (isEmailValid && isWebsiteValid && isGithubValid && isAvatarValid && isTwitterValid && isTelegramValid ? "true" : "false"))
          if (isEmailValid && isWebsiteValid && isGithubValid && isAvatarValid && isTwitterValid && isTelegramValid) {
            Console.log("All validations passed, proceeding with form submission")

            setError(_ => None)
            setLoading(_ => true)

            let walletClient = buildWalletClient()->Option.getExn
            let {name} = Option.getExn(primaryName)

            let (initialDescription, initialLocation, initialTwitter, initialTelegram, initialGithub, initialWebsite, initialEmail, initialAvatar) = profile

            // Encode each field using setText only if it has changed
            let calls = []
            switch (description, initialDescription) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "description", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "description", value))
            | _ => ()
            }
            switch (location, initialLocation) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "location", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "location", value))
            | _ => ()
            }
            switch (twitter, initialTwitter) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "twitter", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "twitter", value))
            | _ => ()
            }
            switch (telegram, initialTelegram) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "telegram", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "telegram", value))
            | _ => ()
            }
            switch (github, initialGithub) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "github", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "github", value))
            | _ => ()
            }
            switch (website, initialWebsite) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "website", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "website", value))
            | _ => ()
            }
            switch (email, initialEmail) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "email", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "email", value))
            | _ => ()
            }
            switch (avatar, initialAvatar) {
            | (Some(value), Some(initial)) if value != initial =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "avatar", value))
            | (Some(value), None) =>
              calls->Array.push(OnChainOperations.encodeSetText(name, "avatar", value))
            | _ => ()
            }

            // Save profile to blockchain
            try {
              Console.log("Attempting to save to blockchain")
              let _ = await OnChainOperations.multicallWithNodeCheck(walletClient, name, calls)
              Console.log("Successfully saved to blockchain")
              setLoading(_ => false)
              // Call onSave with the updated profile data
              onSave((description, location, twitter, telegram, github, website, email, avatar))
            } catch {
            | Exn.Error(e) => {
                let errorMessage = Exn.message(e)->Option.getOr("Unknown error")
                Console.log("Error saving to blockchain: " ++ errorMessage)
                setLoading(_ => false)
                
                // Check if the error is a user rejection
                let isUserRejection = switch errorMessage {
                | message if String.includes(message, "User denied") => true
                | message if String.includes(message, "user rejected") => true
                | message if String.includes(message, "User rejected") => true
                | message if String.includes(message, "rejected transaction") => true
                | message if String.includes(message, "cancelled") => true
                | message if String.includes(message, "canceled") => true
                | _ => false
                }
                
                // Only set error if it's not a user rejection
                if (!isUserRejection) {
                  setError(_ => Some(errorMessage))
                }
              }
            }
          }
        } catch {
        | Exn.Error(e) => {
            Console.log("Unexpected error in form submission: " ++ Exn.message(e)->Option.getOr("Unknown error"))
            setLoading(_ => false)
            setError(_ => Some(Exn.message(e)->Option.getOr("An unexpected error occurred")))
          }
        | _ => {
            Console.log("Unknown error type in form submission")
            setLoading(_ => false)
            setError(_ => Some("An unexpected error occurred"))
          }
        }
      }


      <div className="p-8">
        <div className="w-full max-w-xl mx-auto">
          <div className="bg-white rounded-custom shadow-lg overflow-hidden">
            <div className="p-8 py-6 border-b border-gray-200 relative">
              <h1 className="text-3xl font-bold text-gray-900"> {React.string("Edit Profile")} </h1>
              <div className="text-sm text-gray-500">
                {React.string("All fields are optional")}
              </div>
              <button
                onClick={_ => onCancel()}
                className="p-1 hover:bg-gray-100 rounded-full transition-colors absolute right-8 top-1/2 -translate-y-1/2">
                <Icons.Close />
              </button>
            </div>
            <div className="p-8">
              <form onSubmit={e => handleSubmit(e)->ignore}>
                <div className="space-y-6">
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Description")}
                    </label>
                    <textarea
                      value={description->Option.getOr("")}
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setDescription(_ => value === "" ? None : Some(value))
                      }}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      rows={4}
                      placeholder="About yourself..."
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Avatar")}
                    </label>
                    <input
                      type_="text"
                      value={avatar->Option.getOr("")}
                      onChange={event => setAvatar(_ => ReactEvent.Form.target(event)["value"])}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="https://"
                    />
                    <div className="text-xs text-gray-400 mt-2">
                      {React.string(" (Optional) Upload your avatar using an IPFS pinning service such as ")}
                      <a href="https://pinata.cloud/" target="_blank" rel="noopener noreferrer" className="hover:text-gray-600 underline">
                        {React.string("https://pinata.cloud/")}
                      </a>
                      {React.string(".")}
                    </div>
                    {switch avatarError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Location")}
                    </label>
                    <input
                      type_="text"
                      value={location->Option.getOr("")}
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setLocation(_ => value === "" ? None : Some(value))
                      }}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="City, Country"
                    />
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("X (Twitter)")}
                    </label>
                    <input
                      type_="text"
                      value={twitter->Option.getOr("")}
                      onChange={event => setTwitter(_ => ReactEvent.Form.target(event)["value"])}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="@username"
                    />
                    {switch twitterError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Telegram")}
                    </label>
                    <input
                      type_="text"
                      value={telegram->Option.getOr("")}
                      onChange={event => setTelegram(_ => ReactEvent.Form.target(event)["value"])}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="@username"
                    />
                    {switch telegramError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("GitHub Username")} 
                    </label>
                    <input
                      type_="text"
                      value={github->Option.getOr("")}
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setGithub(_ => value === "" ? None : Some(value))
                      }}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="username"
                    />
                    <div className="text-xs text-gray-400 mt-2">
                      {React.string("https://github.com/")}
                      <span className="text-gray-600 font-bold">{React.string("username")}</span>
                    </div>
                    {switch githubError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Website")}
                    </label>
                    <input
                      type_="url"
                      value={website->Option.getOr("")}
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setWebsite(_ => value === "" ? None : Some(value))
                      }}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="https://"
                    />
                    {switch websiteError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  <div>
                    <label className="block text-sm font-medium mb-2 text-gray-700">
                      {React.string("Email")}
                    </label>
                    <input
                      type_="email"
                      value={email->Option.getOr("")}
                      onChange={event => {
                        let value = ReactEvent.Form.target(event)["value"]
                        setEmail(_ => value === "" ? None : Some(value))
                      }}
                      className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
                      placeholder="your@email.com"
                    />
                    {switch emailError {
                      | Some(message) =>
                        <div className="mt-1 text-sm text-red-600"> {React.string(message)} </div>
                      | None => React.null
                    }}
                  </div>
                  {switch error {
                    | Some(message) =>
                      <div className="mt-4 text-sm text-red-600"> {React.string(message)} </div>
                    | None => React.null
                  }}
                  <div className="flex justify-end space-x-4 mt-8">
                    <button
                      type_="submit"
                      disabled={loading}
                      className={`rounded-xl bg-zinc-800 px-6 py-3 font-semibold text-white hover:bg-zinc-700 ${loading
                      ? "opacity-50 cursor-not-allowed"
                      : "hover:bg-zinc-500"} focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-blue-500`}>
                      {React.string(loading ? "Saving..." : "Save Profile")}
                    </button>
                  </div>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    }
}

module ProfileField = {
  @react.component
  let make = (~icon: React.element, ~label: string, ~value: option<string>) => {
    <div
      className="flex items-center space-x-3 rounded-lg p-5">
      <div className="flex items-center justify-center w-10 h-10 rounded-lg">
        {React.cloneElement(
          icon,
          {
          "className": "w-5 h-5 text-gray-600",
        },
        )}
      </div>
      <div className="flex-1">
        <div className="text-sm font-medium text-gray-400 mb-1"> {React.string(label)} </div>
        <div className="text-gray-800 break-words mr-5">
          {switch (label, value) {
            | ("Location", Some(v)) => 
              <a href={`https://maps.google.com/?q=${v}`} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all" target="_blank">{React.string(v)}</a>
            | ("X", Some(v)) => 
              <a href={`https://x.com/${v->String.replace("@", "")}`} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all" target="_blank">{React.string(v)}</a>
            | ("Telegram", Some(v)) => 
              <a href={`https://t.me/${v->String.replace("@", "")}`} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all" target="_blank">{React.string(v)}</a>
            | ("GitHub", Some(v)) =>
              <a href={`https://github.com/${v}`} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all" target="_blank">{React.string(v)}</a>
            | ("Website", Some(v)) when String.startsWith(v, "http") =>
              <a href={v} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all" target="_blank">{React.string(v)}</a>
            | ("Email", Some(v)) when String.indexOf(v, "@") > 0 =>
              <a href={`mailto:${v}`} className="text-gray-600 text-zinc-800 hover:text-zinc-600 transition-colors underline break-all">{React.string(v)}</a>
            | (_, Some(v)) =>
              React.string(v)
            | (_, None) => <span className="text-gray-400 italic"> {React.string("Not provided")} </span>
          }}
        </div>
      </div>
    </div>
  }
}



module ViewProfile = {
  @react.component
  let make = (
    ~profile: (
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
    option<string>,
  ),
    ~setIsEditing: (bool => bool) => unit,
  ) => {
      let (showDropdown, setShowDropdown) = React.useState(() => false)
      let (description, location, twitter, telegram, github, website, email, avatar) = profile
      let {primaryName} = NameContext.use()

      let {name, expires} = switch primaryName {
        | Some(pn) => pn
        | None => {name: "", expires: 0, fullName: ""}
      }

      <div className="w-full max-w-xl mx-auto relative p-8">


        // profile card
        <div className="bg-white rounded-custom shadow-lg mt-16 relative">
          // header
          <div className="p-8 py-6 rounded-custom shadow-md" style={ReactDOM.Style.make(~backgroundColor=stringToRgba(name, 0.2), ())}>
            // dropdown menu in top right corner
            <div className="absolute top-4 right-4 z-10" >
              <div className="relative flex-shrink-0">
                <button
                  className="p-2 rounded-lg hover:bg-gray-100 focus:outline-none"
                  onClick={_ => setShowDropdown(prev => !prev)}>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth="2"
                      d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"
                    />
                  </svg>
                </button>
                <div
                  className={"absolute right-0 mt-2 w-48 rounded-lg shadow-xl bg-white/95 backdrop-blur-sm border border-gray-100 " ++ (
                    showDropdown ? "" : "hidden"
                  )}>
                  <div className="py-1">
                    <button
                      className="block w-full px-4 py-2.5 text-sm text-gray-700 hover:bg-gray-50 transition-colors duration-150 ease-in-out text-left"
                      onClick={_ => {
                        setShowDropdown(_ => false)
                        setIsEditing(_ => true)
                      }}>
                      {React.string("Edit Profile")}
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div className="flex flex-col mb-4 items-center">
              // avatar
              <div className="flex justify-center -mt-20 mb-3 relative">
                <div className="w-32 h-32 rounded-full border-4 border-white overflow-hidden relative bg-gray-100 shadow">
                  <div className="flex justify-center items-center absolute inset-0">
                    <Icons.Spinner className="w-5 h-5 text-zinc-600" />
                  </div>


                  {
                    switch avatar {
                    | Some(value) => <img src={value} alt="Profile Avatar" className="w-full h-full object-cover absolute inset-0 opacity-0 transition-opacity duration-300 rounded-full" onLoad={e => {
                      let target = ReactEvent.Image.target(e)
                      target["classList"]["remove"]("opacity-0")
                    }}/>
                    | None => <div
                      dangerouslySetInnerHTML={"__html": toSvg(name, 120, {backColor: "#ffffff", padding: 0.13})}
                      className="w-full h-full object-cover absolute inset-0 transition-opacity duration-300 rounded-full"
                    />
                  }
                  }

                </div>
              </div>
              // name line
              <div className="flex justify-center items-center w-full relative">
                <h1
                  className="text-3xl font-bold text-gray-900 max-w-[90%] truncate text-center"
                  title={`${name}.${Constants.sld}`}>
                  {React.string(`${name}.${Constants.sld}`)}
                </h1>
              </div>
              <div className="text-xs text-gray-500 mt-1">
                {React.string("Expiry: ")}
                {React.string(expires->Utils.timestampToDate->Date.toLocaleDateString)}
              </div>
              <div className="text-center leading-relaxed  py-2">
                {switch description {
                  | Some(desc) => React.string(desc)
                  | None => <div className="text-gray-400">{React.string("No description")}</div>
                }}
              </div>
            </div>
          </div>

          // body
          <div className="grid grid-cols-1 pb-4 pt-5">
            <ProfileField
              icon={<svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M17.657 16.657L13.414 20.9a1.998 1.998 0 01-2.827 0l-4.244-4.243a8 8 0 1111.314 0z"
                />
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M15 11a3 3 0 11-6 0 3 3 0 016 0z"
                />
              </svg>}
              label="Location"
              value={location}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                />
              </svg>}
              label="X"
              value={twitter}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.514.26l.204-2.98 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.87 4.326-2.962-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.535-.196 1.006.128.832.941z"
                />
              </svg>}
              label="Telegram"
              value={telegram}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  fillRule="evenodd"
                  d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                  clipRule="evenodd"
                />
              </svg>}
              label="GitHub"
              value={github}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"
                />
              </svg>}
              label="Website"
              value={website}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>}
              label="Email"
              value={email}
            />
          </div>
        </div> // end of profile card
      </div>
    }
}

module NotConnected = {
  @react.component
  let make = () => {
    React.useEffect0(() => {
      RescriptReactRouter.push(Router.toUrl(Router.Home))
      None
    })
    React.null
  }
}

module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

@val external document: Dom.document = "document"
@send external querySelector: (Dom.document, string) => Dom.element = "querySelector"
@send external click: Dom.element => unit = "click"

let loadProfile = async (name: string) => {
  let description = await OnChainOperations.getText(name, "description")
  let location = await OnChainOperations.getText(name, "location")
  let twitter = await OnChainOperations.getText(name, "twitter")
  let telegram = await OnChainOperations.getText(name, "telegram")
  let github = await OnChainOperations.getText(name, "github")
  let website = await OnChainOperations.getText(name, "website")
  let email = await OnChainOperations.getText(name, "email")
  let avatar = await OnChainOperations.getText(name, "avatar")

  (description, location, twitter, telegram, github, website, email, avatar)
}

@react.component
let make = () => {
  let {primaryName} = NameContext.use()
  let account = UseAccount.use()
  let (isEditing, setIsEditing) = React.useState(() => false)
  let (profile, setProfile) = React.useState(() => (None, None, None, None, None, None, None, None))
  let (loading, setLoading) = React.useState(() => true)

  // Redirect to home if disconnected
  React.useEffect1(() => {
    if !account.isConnected {
      RescriptReactRouter.push(Router.toUrl(Router.Home))
    }
    None
  }, [account.isConnected])

  let loadProfileData = async () => {
    switch primaryName {
    | Some({name}) => {
      try {
        let profileData = await loadProfile(name)
        setProfile(_ => profileData)
      } catch {
      | Exn.Error(e) =>
        Console.error(`Failed to load profile: ${Exn.message(e)->Option.getOr("Unknown error")}`)
    }
      setLoading(_ => false)
    }
    | None => setLoading(_ => false)
  }
  }

  React.useEffect1(() => {
    loadProfileData()->ignore
    None
  }, [primaryName])

  let onSave = profile => {
    setProfile(_ => profile)
    setIsEditing(_ => false)
  }

  switch (primaryName, loading) {
  | (None, false) => <NotConnected />
  | (Some(_), false) =>
    isEditing
    ? <ProfileForm
      onCancel={() => setIsEditing(_ => false)} onSave={onSave} profile
    />
    : <ViewProfile profile setIsEditing />
  | (_, true) =>
    <div className="flex justify-center items-center">
      <Icons.Spinner className="w-5 h-5 text-zinc-600" />
    </div>
}
}

