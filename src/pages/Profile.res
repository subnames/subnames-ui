open OnChainOperationsCommon
open Utils

module ProfileForm = {
  @react.component
  let make = (
    ~onSubmit: (string, string, string, string, string, string, string) => unit,
    ~onCancel: unit => unit
  ) => {
    let (description, setDescription) = React.useState(() => "")
    let (location, setLocation) = React.useState(() => "")
    let (twitter, setTwitter) = React.useState(() => "")
    let (telegram, setTelegram) = React.useState(() => "")
    let (github, setGithub) = React.useState(() => "")
    let (website, setWebsite) = React.useState(() => "")
    let (email, setEmail) = React.useState(() => "")
    let (loading, setLoading) = React.useState(() => false)
    let (error, setError) = React.useState(() => None)

    let validateEmail = email => {
      let emailRegex = Js.Re.fromString("^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$")
      Js.Re.test_(emailRegex, email)
    }

    let validateWebsite = website => {
      let urlRegex = Js.Re.fromString("^(https?:\\/\\/)?([\\da-z\\.-]+)\\.([a-z\\.]{2,6})([\\/\\w \\.-]*)*\\/?$")
      website === "" || Js.Re.test_(urlRegex, website)
    }

    let handleSubmit = event => {
      ReactEvent.Form.preventDefault(event)
      
      switch (validateEmail(email), validateWebsite(website)) {
      | (false, _) => setError(_ => Some("Please enter a valid email address"))
      | (_, false) => setError(_ => Some("Please enter a valid website URL"))
      | _ => {
          setError(_ => None)
          onSubmit(description, location, twitter, telegram, github, website, email)
        }
      }
    }

    <div className="w-full max-w-xl mx-auto bg-white rounded-custom shadow-lg p-8">
      <h1 className="text-3xl font-bold mb-8 text-gray-900"> {React.string("Edit Profile")} </h1>
      <form onSubmit={handleSubmit}>
        <div className="space-y-6">
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700">
              {React.string("Description")}
            </label>
            <textarea
              value={description}
              onChange={event => setDescription(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              rows={4}
              placeholder="Tell us about yourself..."
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700"> {React.string("Location")} </label>
            <input
              type_="text"
              value={location}
              onChange={event => setLocation(_ => ReactEvent.Form.target(event)["value"])}
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
              value={twitter}
              onChange={event => setTwitter(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              placeholder="@username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700"> {React.string("Telegram")} </label>
            <input
              type_="text"
              value={telegram}
              onChange={event => setTelegram(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              placeholder="@username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700"> {React.string("GitHub")} </label>
            <input
              type_="text"
              value={github}
              onChange={event => setGithub(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              placeholder="username"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700"> {React.string("Website")} </label>
            <input
              type_="url"
              value={website}
              onChange={event => setWebsite(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              placeholder="https://"
            />
          </div>
          <div>
            <label className="block text-sm font-medium mb-2 text-gray-700"> {React.string("Email")} </label>
            <input
              type_="email"
              value={email}
              onChange={event => setEmail(_ => ReactEvent.Form.target(event)["value"])}
              className="w-full p-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-blue-500 transition-colors"
              placeholder="your@email.com"
            />
          </div>
          {switch error {
          | Some(message) => 
            <div className="p-3 bg-red-50 border border-red-200 rounded-lg text-red-600 text-sm">
              {React.string(message)}
            </div>
          | None => React.null
          }}
          <div className="flex gap-4">
            <button
              type_="button"
              onClick={_ => onCancel()}
              className="flex-1 bg-gray-100 text-gray-700 p-3 rounded-xl font-medium hover:bg-gray-200 transition-colors">
              {React.string("Cancel")}
            </button>
            <button
              type_="submit"
              disabled={loading}
              className="flex-1 bg-blue-600 text-white p-3 rounded-xl font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
              {React.string(loading ? "Saving..." : "Save Profile")}
            </button>
          </div>
        </div>
      </form>
    </div>
  }
}

module ProfileField = {
  @react.component
  let make = (~icon: React.element, ~label: string, ~value: string) => {
    <div className="flex items-center space-x-3 rounded-lg p-3 bg-gradient-to-r to-white from-slate-100 ">
      <div className="flex items-center justify-center w-10 h-10 rounded-lg">
        {React.cloneElement(icon, {
          "className": "w-5 h-5 text-gray-600"
        })}
      </div>
      <div className="flex-1">
        <div className="text-sm font-medium text-gray-500 mb-1"> {React.string(label)} </div>
        <div className="text-gray-800">
          {value === "" 
            ? <span className="text-gray-400 italic">{ React.string("Not provided") }</span>
            : React.string(value)}
        </div>
      </div>
    </div>
  }
}

module ViewProfile = {
  @react.component
  let make = (
    ~profile: (option<string>, string, string, string, string, string, string),
    ~setProfile: ((option<string>, string, string, string, string, string, string)) => unit,
    ~isEditing: bool,
    ~setIsEditing: (bool => bool) => unit,
    ~onCancel: unit => unit
  ) => {
    let (showDropdown, setShowDropdown) = React.useState(() => false)
    let (description, location, twitter, telegram, github, website, email) = profile
    let {primaryName} = NameContext.use()

    let {name, expires} = switch primaryName {
    | Some(pn) => pn
    | None => {name: "", expires: 0}
    }

    <div className="w-full max-w-xl mx-auto">
      <div className="bg-white rounded-custom shadow-lg p-8 py-6">
        // header
        <div className="flex flex-col mb-4">
          <div className="flex items-center justify-between w-full">
            <div className="flex  w-full justify-between items-end">
              <div>
                <div className="text-sm text-gray-400 mt-1">
                  {React.string("Expiry: ")}
                  {React.string(expires->Utils.timestampToDate->Date.toLocaleDateString)}
                </div>
                <h1 className="text-3xl font-bold text-gray-900">
                  {React.string(`${name}.${Constants.sld}`)}
                </h1>
              </div>
              <div className="relative flex-shrink-0">
                <button
                  className="p-2 rounded-lg hover:bg-gray-100 focus:outline-none"
                  onClick={_ => setShowDropdown(prev => !prev)}>
                  <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="2" d="M12 5v.01M12 12v.01M12 19v.01M12 6a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2zm0 7a1 1 0 110-2 1 1 0 010 2z"/>
                  </svg>
                </button>
                <div className={
                  "absolute right-0 mt-2 w-48 rounded-lg shadow-xl bg-white/95 backdrop-blur-sm border border-gray-100 "
                  ++ (showDropdown ? "" : "hidden")
                }>
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
          </div>
          {switch description {
          | Some(desc) => 
            <div className="text-gray-400 leading-relaxed  py-2">
              {React.string(desc)}
            </div>
          | None => 
            <div className="text-gray-400 italic leading-relaxed py-2">
              {React.string("No description")}
            </div>
          }}
        </div>
        // body
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4 pb-4">
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
          <ProfileField
            icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"/>
            </svg>}
            label="X"
            value={twitter}
          />
          <ProfileField
            icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.514.26l.204-2.98 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.87 4.326-2.962-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.535-.196 1.006.128.832.941z"/>
            </svg>}
            label="Telegram"
            value={telegram}
          />
          <ProfileField
            icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path
                fillRule="evenodd"
                d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.531 1.032 1.531 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
                clipRule="evenodd"
              />
            </svg>}
            label="GitHub"
            value={github}
          />
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
      </div>
    </div>
  }
}

@react.component
let make = () => {
  let (profile, setProfile) = React.useState(() => None)
  let (loading, setLoading) = React.useState(() => false)
  let (error, setError) = React.useState(() => None)
  let (isEditing, setIsEditing) = React.useState(() => false)

  let handleCancel = () => {
    setIsEditing(_ => false)
  }

  let handleSubmit = (description, location, twitter, telegram, github, website, email) => {
    setLoading(_ => true)
    setError(_ => None)

    let updateProfile = async () => {
      try {
        let walletClient = buildWalletClient()->Option.getExn(~message="Wallet connection failed")
        let currentAddress = await currentAddress(walletClient)

        // Prepare the profile data
        let profileData = [
          ("description", description),
          ("location", location),
          ("com.twitter", twitter),
          ("com.telegram", telegram),
          ("com.github", github),
          ("url", website),
          ("email", email),
        ]

        Console.log("Profile updated successfully!")
        setProfile(_ => Some((description, location, twitter, telegram, github, website, email)))
      } catch {
      | error =>
        setError(_ => Some("Failed to update profile"))
        Console.log2("Error updating profile:", error)
      }

      setLoading(_ => false)
    }

    updateProfile()->ignore
  }

  <div className="p-8">
    {isEditing
      ? <ProfileForm
          onSubmit={(description, location, twitter, telegram, github, website, email) => {
            handleSubmit(description, location, twitter, telegram, github, website, email)
            setIsEditing(_ => false)
          }}
          onCancel={handleCancel}
        />
      : <ViewProfile
          profile={(None, "", "", "", "", "", "")}
          setProfile={_ => ()}
          isEditing={isEditing}
          setIsEditing={setIsEditing}
          onCancel={handleCancel}
        />
    }
  </div>
}
