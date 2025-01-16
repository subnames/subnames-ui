open OnChainOperationsCommon
open Utils

module ProfileForm = {
  @react.component
  let make = (~onSubmit: (string, string, string, string, string, string, string) => unit) => {
    let (description, setDescription) = React.useState(() => "")
    let (location, setLocation) = React.useState(() => "")
    let (twitter, setTwitter) = React.useState(() => "")
    let (telegram, setTelegram) = React.useState(() => "")
    let (github, setGithub) = React.useState(() => "")
    let (website, setWebsite) = React.useState(() => "")
    let (email, setEmail) = React.useState(() => "")
    let (loading, setLoading) = React.useState(() => false)
    let (error, setError) = React.useState(() => None)

    let handleSubmit = event => {
      ReactEvent.Form.preventDefault(event)
      onSubmit(description, location, twitter, telegram, github, website, email)
    }

    <div className="max-w-2xl mx-auto p-6 bg-white rounded-lg shadow-sm">
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
          <button
            type_="submit"
            disabled={loading}
            className="w-full bg-blue-600 text-white p-3 rounded-lg font-medium hover:bg-blue-700 disabled:bg-gray-300 disabled:cursor-not-allowed transition-colors">
            {React.string(loading ? "Saving..." : "Save Profile")}
          </button>
        </div>
      </form>
    </div>
  }
}

module ProfileField = {
  @react.component
  let make = (~icon: React.element, ~label: string, ~value: string) => {
    <div className="flex items-center space-x-3 rounded-lg bg-slate-100 p-3">
      <div className="flex items-center justify-center w-10 h-10 rounded-lg">
        {React.cloneElement(icon, {
          "className": "w-5 h-5 text-gray-600"
        })}
      </div>
      <div className="flex-1">
        <div className="text-sm font-medium text-gray-500 mb-1"> {React.string(label)} </div>
        <div className="text-gray-800 font-medium">
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
  let make = (~profile: (option<string>, string, string, string, string, string, string)) => {
    let (description, location, twitter, telegram, github, website, email) = profile
    let {primaryName} = NameContext.use()

    let {name, expires} = switch primaryName {
    | Some(pn) => pn
    | None => {name: "", expires: 0}
    }

    <div className="w-full max-w-xl mx-auto">
      <div className="bg-white rounded-custom shadow-lg overflow-hidden p-8">
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
              <path
                d="M22.23 5.924c-.807.358-1.672.6-2.582.71a4.526 4.526 0 001.984-2.496 9.037 9.037 0 01-2.866 1.095 4.513 4.513 0 00-7.69 4.116 12.81 12.81 0 01-9.3-4.715 4.513 4.513 0 001.396 6.022 4.493 4.493 0 01-2.043-.564v.057a4.513 4.513 0 003.62 4.425 4.52 4.52 0 01-2.037.077 4.513 4.513 0 004.216 3.134 9.05 9.05 0 01-5.604 1.93c-.364 0-.724-.021-1.08-.063a12.773 12.773 0 006.92 2.029c8.3 0 12.84-6.876 12.84-12.84 0-.195-.004-.39-.013-.583a9.172 9.172 0 002.252-2.336z"
              />
            </svg>}
            label="X (Twitter)"
            value={twitter}
          />
          <ProfileField
            icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
              <path
                d="M16 8.2A4.4 4.4 0 1111.6 12.6 4.4 4.4 0 0116 8.2zM2 2v20h20V2zm18 2.8a6.8 6.8 0 01-6.78 6.8A6.8 6.8 0 014 4.8V4h16z"
              />
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
        // header
        <div className="flex flex-col ">
          {switch description {
          | Some(desc) => 
            <div className="text-gray-600 leading-relaxed">
              {React.string(desc)}
            </div>
          | None => 
            React.null
          }}
          <div className="flex items-center justify-between">
            <div>
              <div className="text-sm text-gray-400 mt-1">
                {React.string("Expiry: ")}
                {React.string(expires->Utils.timestampToDate->Date.toLocaleDateString)}
              </div>
              <h1 className="text-3xl font-bold text-gray-900">
                {React.string(`${name}.${Constants.sld}`)}
              </h1>
            </div>
          </div>
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
    <ViewProfile profile={(None, "", "", "", "", "", "")} />
  </div>
}
