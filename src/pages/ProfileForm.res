open OnChainOperationsCommon

type p = {
  test: string => bool
}
@module("github-username-regex") external githubUsernameRegex: p = "default"
// Console.log(githubUsernameRegex.test("akiwu"))

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
              className="hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300 rounded-full transition-colors absolute right-8 top-1/2 -translate-y-1/2">
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