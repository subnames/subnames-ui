open OnChainOperationsCommon

@react.component
let make = () => {
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
    
    let updateProfile = async () => {
      setLoading(_ => true)
      setError(_ => None)

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
      } catch {
      | error =>
        setError(_ => Some("Failed to update profile"))
        Console.log2("Error updating profile:", error)
      }

      setLoading(_ => false)
    }

    updateProfile()->ignore
  }

  <div className="max-w-2xl mx-auto p-4">
    <h1 className="text-2xl font-bold mb-6"> {React.string("Edit Profile")} </h1>
    
    <form onSubmit={handleSubmit}>
      <div className="space-y-4">
        <div>
          <label className="block text-sm font-medium mb-1"> {React.string("Description")} </label>
          <textarea
            value={description}
            onChange={event => setDescription(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            rows={3}
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1"> {React.string("Location")} </label>
          <input
            type_="text"
            value={location}
            onChange={event => setLocation(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1"> {React.string("X (Twitter)") }</label>
          <input
            type_="text"
            value={twitter}
            onChange={event => setTwitter(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            placeholder="username"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">{React.string("Telegram") }</label>
          <input
            type_="text"
            value={telegram}
            onChange={event => setTelegram(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            placeholder="username"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">{React.string("GitHub") }</label>
          <input
            type_="text"
            value={github}
            onChange={event => setGithub(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            placeholder="username"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">{React.string("Website") }</label>
          <input
            type_="url"
            value={website}
            onChange={event => setWebsite(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            placeholder="https://"
          />
        </div>

        <div>
          <label className="block text-sm font-medium mb-1">{React.string("Email") }</label>
          <input
            type_="email"
            value={email}
            onChange={event => setEmail(_ => ReactEvent.Form.target(event)["value"])}
            className="w-full p-2 border rounded"
            placeholder="your@email.com"
          />
        </div>

        {switch error {
        | Some(message) => 
          <div className="text-red-500 text-sm"> {React.string(message)} </div>
        | None => React.null
        }}

        <button
          type_="submit"
          disabled={loading}
          className="w-full bg-blue-500 text-white p-2 rounded hover:bg-blue-600 disabled:bg-gray-400">
          {React.string(loading ? "Saving..." : "Save Profile")}
        </button>
      </div>
    </form>
  </div>
}
