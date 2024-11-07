@react.component
let make = (~registeredName: string, ~onRegisterAnother: unit => unit) => {
  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-6">
      <div className="flex flex-col items-center text-center">
        <div className="mb-4">
          <Icons.Success className="w-16 h-16 text-green-500" />
        </div>
        <h2 className="text-2xl font-bold mb-2">
          {React.string("Registration Successful!")}
        </h2>
        <p className="text-lg text-gray-700 mb-6">
          <Confetti recycle=false />
          {React.string(`${registeredName}.${Constants.sld}`)}
        </p>
        <button
          onClick={_ => onRegisterAnother()}
          className="py-3 px-6 bg-zinc-800 hover:bg-zinc-700 text-white rounded-2xl font-medium">
          {React.string("Register Another Name")}
        </button>
      </div>
    </div>
  </div>
} 