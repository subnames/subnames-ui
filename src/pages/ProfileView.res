
open OnChainOperationsCommon

@module("../color.mjs") external stringToRgba: (string, float) => string = "default"
type config = {
  backColor: string,
  padding: float
}
@module("jdenticon") external toSvg: (string, int, config) => string = "toSvg"


module UseAccount = {
  type account = {
    address: option<string>,
    isConnected: bool,
  }
  @module("wagmi")
  external use: unit => account = "useAccount"
}

let loadProfile = async (name: string) => {
  let description = await L2Resolver.getText(name, "description")
  let location = await L2Resolver.getText(name, "location")
  let twitter = await L2Resolver.getText(name, "twitter")
  let telegram = await L2Resolver.getText(name, "telegram")
  let github = await L2Resolver.getText(name, "github")
  let website = await L2Resolver.getText(name, "website")
  let email = await L2Resolver.getText(name, "email")
  let avatar = await L2Resolver.getText(name, "avatar")

  (description, location, twitter, telegram, github, website, email, avatar)
}

let getNameExpiry = async (name: string) => {
  try {
    let expiry = await BaseRegistrar.nameExpires(name)
    expiry
  } catch {
  | Exn.Error(e) => {
      Console.error(`Failed to get name expiry: ${Exn.message(e)->Option.getOr("Unknown error")}`)
      0n
    }
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

@react.component
let make = (~name: string) => {
  let account = UseAccount.use()
  let (profile, setProfile) = React.useState(() => (None, None, None, None, None, None, None, None))
  let (loading, setLoading) = React.useState(() => true)
  let (expires, setExpires) = React.useState(() => 0n)
  let (isOwner, setIsOwner) = React.useState(() => false)
  let (isEditing, setIsEditing) = React.useState(() => false)
    
  // Check if the connected wallet is the owner
  React.useEffect(() => {
    let checkOwnership = async () => {
      if account.isConnected {
        try {
          let owner = await BaseRegistrar.getTokenOwner(name)
          let currentAddress = await getCurrentAddress()
          switch currentAddress {
          | Some(currentAddr) => {
              let isOwner = String.toLowerCase(owner) == String.toLowerCase(currentAddr)
              setIsOwner(_ => isOwner)
            }
          | None => setIsOwner(_ => false)
          }
        } catch {
        | Exn.Error(e) => {
            Console.error(`Failed to check ownership: ${Exn.message(e)->Option.getOr("Unknown error")}`)
            setIsOwner(_ => false)
          }
        }
      } else {
        setIsOwner(_ => false)
      }
    }
      
    checkOwnership()->ignore
    None
  }, (account.isConnected, name))
    
  // Load profile data
  React.useEffect1(() => {
    let loadProfileData = async () => {
      try {
        let profileData = await loadProfile(name)
        setProfile(_ => profileData)
          
        let expiryBigInt = await getNameExpiry(name)
        setExpires(_ => expiryBigInt)
      } catch {
      | Exn.Error(e) => {
          Console.error(`Failed to load profile: ${Exn.message(e)->Option.getOr("Unknown error")}`)
        }
      }
      setLoading(_ => false)
    }
      
    loadProfileData()->ignore
    None
  }, [name])
    
  let onSave = profile => {
    setProfile(_ => profile)
    setIsEditing(_ => false)
  }
    
  switch loading {
  | true => 
    <div className="flex justify-center items-center h-64">
      <Icons.Spinner className="w-8 h-8 text-zinc-600" />
    </div>
  | false => 
    isEditing && isOwner
    ? <ProfileForm
        onCancel={() => setIsEditing(_ => false)} 
        onSave={onSave} 
        profile
      />
    : <div className="w-full max-w-xl mx-auto relative p-8">
        // profile card
        <div className="bg-white rounded-custom shadow-lg mt-16 relative">
          // header
          <div className="p-8 py-6 rounded-custom shadow-md" style={ReactDOM.Style.make(~backgroundColor=stringToRgba(name, 0.2), ())}>
            // dropdown menu in top right corner (only for owner)
            {isOwner 
              ? <div className="absolute top-4 right-4 z-10" >
                  <div className="relative flex-shrink-0">
                    <button
                      className="p-2 rounded-lg hover:bg-gray-100 focus:outline-none"
                      onClick={_ => setIsEditing(_ => true)}>
                      <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path
                          strokeLinecap="round"
                          strokeLinejoin="round"
                          strokeWidth="2"
                          d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"
                        />
                      </svg>
                    </button>
                  </div>
                </div>
              : React.null
            }

            <div className="flex flex-col mb-4 items-center">
              // avatar
              <div className="flex justify-center -mt-20 mb-3 relative">
                <div className="w-32 h-32 rounded-full border-4 border-white overflow-hidden relative bg-gray-100 shadow">
                  <div className="flex justify-center items-center absolute inset-0">
                    <Icons.Spinner className="w-5 h-5 text-zinc-600" />
                  </div>

                  {
                    switch profile {
                    | (_, _, _, _, _, _, _, Some(value)) => 
                        <img src={value} alt="Profile Avatar" className="w-full h-full object-cover absolute inset-0 opacity-0 transition-opacity duration-300 rounded-full" onLoad={e => {
                          let target = ReactEvent.Image.target(e)
                          target["classList"]["remove"]("opacity-0")
                        }}/>
                    | _ => 
                        <div
                          dangerouslySetInnerHTML={"__html": toSvg(name, 120, {backColor: "#ffffff", padding: 0.15})}
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
              <div className="text-center leading-relaxed py-2">
                {switch profile {
                  | (Some(desc), _, _, _, _, _, _, _) => React.string(desc)
                  | _ => <div className="text-gray-400">{React.string("No description")}</div>
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
              value={switch profile {
                | (_, Some(loc), _, _, _, _, _, _) => Some(loc)
                | _ => None
              }}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z"
                />
              </svg>}
              label="X"
              value={switch profile {
                | (_, _, Some(tw), _, _, _, _, _) => Some(tw)
                | _ => None
              }}
            />
            <div className="border-t border-gray-100 my-3 mx-6"></div>
            <ProfileField
              icon={<svg className="w-5 h-5" fill="currentColor" viewBox="0 0 24 24">
                <path
                  d="M12 0c-6.627 0-12 5.373-12 12s5.373 12 12 12 12-5.373 12-12-5.373-12-12-12zm5.894 8.221l-1.97 9.28c-.145.658-.537.818-1.084.508l-3-2.21-1.446 1.394c-.14.14-.26.26-.514.26l.204-2.98 5.56-5.022c.24-.213-.054-.334-.373-.121l-6.87 4.326-2.962-.924c-.64-.203-.658-.64.135-.954l11.566-4.458c.535-.196 1.006.128.832.941z"
                />
              </svg>}
              label="Telegram"
              value={switch profile {
                | (_, _, _, Some(tg), _, _, _, _) => Some(tg)
                | _ => None
              }}
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
              value={switch profile {
                | (_, _, _, _, Some(gh), _, _, _) => Some(gh)
                | _ => None
              }}
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
              value={switch profile {
                | (_, _, _, _, _, Some(ws), _, _) => Some(ws)
                | _ => None
              }}
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
              value={switch profile {
                | (_, _, _, _, _, _, Some(em), _) => Some(em)
                | _ => None
              }}
            />
          </div>
        </div> // end of profile card
      </div>
  }
}
