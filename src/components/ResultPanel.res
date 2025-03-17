@react.component
let make = (~name: string, ~onRegisterAnother: unit => unit, ~actionResult: Types.actionResult) => {
  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-6">
      <div className="flex flex-col items-center text-center">
        <div className="mb-4">
          <Icons.Success className="w-16 h-16 text-green-500" />
        </div>
        <h2 className="text-2xl font-bold mb-2">
          {switch actionResult.action {
          | Types.Register => React.string("Registration Successful!")
          | Types.Extend => React.string("Extension Successful!")
          | _ => React.null
          }}
        </h2>
        <div className="text-lg text-gray-700 mb-6">
          <Confetti recycle=false />
          <p>
            {React.string(`${name}.${Constants.sld}`)}
          </p>
          <div>
            {switch actionResult.newExpiryDate {
            | Some(expiryDate) => React.string(`Until ${Date.toUTCString(expiryDate)}`)
            | None => React.null
            }}
          </div>
        </div>
        <button
          onClick={_ => onRegisterAnother()}
          className="py-3 px-6 bg-zinc-800 hover:bg-zinc-700 text-white rounded-2xl font-medium">
          {React.string("Go Home")}
        </button>
      </div>
    </div>
  </div>
} 