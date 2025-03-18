@react.component
let make = (~name: string, ~onRegisterAnother: unit => unit, ~actionResult: Types.actionResult) => {
  <div className="fixed inset-0 flex items-center justify-center z-40">
    <div className="fixed inset-0 bg-black bg-opacity-60 backdrop-blur-sm dark:bg-opacity-80" />
    <div className="bg-white rounded-custom shadow-2xl overflow-hidden relative z-50 max-w-md w-full mx-4 animate-fadeIn dark:bg-[#1b1b1b] dark:border dark:border-[rgba(255,255,255,0.08)]">
      <div className="pt-6 pb-8 px-8">
        <div className="flex justify-between">
          <div>
            <h1 className="text-xl font-semibold text-gray-900 dark:text-white">
              {switch actionResult.action {
              | Types.Register => React.string("Registration Complete")
              | Types.Extend => React.string("Extension Complete")
              | _ => React.string("Operation Complete")
              }}
            </h1>
            <div className="mt-0">
              <span className="text-sm text-gray-500 dark:text-gray-400">{React.string(`${name}.${Constants.sld}`)}</span>
            </div>
          </div>
          <div className="self-center">
            <button
              onClick={_ => onRegisterAnother()}
              className="rounded-full transition-colors hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300"
              type_="button">
              <Icons.Close/>
            </button>
          </div>
        </div>

        <div className="border-t border-gray-200 my-4 -mx-8 dark:border-[rgba(255,255,255,0.08)]"></div>
        
        <div className="flex flex-col items-center text-center p-6">
          <Confetti recycle=false />
          <div className="mb-6 p-4 bg-green-50 rounded-full dark:bg-green-900/20">
            <Icons.Success className="w-16 h-16 text-green-500 dark:text-green-400" />
          </div>
          
          <h2 className="text-2xl font-bold mb-4 text-gray-900 dark:text-white">
            {switch actionResult.action {
            | Types.Register => React.string("Congratulations!")
            | Types.Extend => React.string("Success!")
            | _ => React.string("Complete!")
            }}
          </h2>
          
          <div className="text-lg mb-6">
            <p className="font-medium text-gray-800 dark:text-gray-200 mb-2">
              {React.string(`${name}.${Constants.sld}`)}
            </p>
            <div className="text-gray-600 dark:text-gray-400">
              {switch actionResult.newExpiryDate {
              | Some(expiryDate) => 
                <div className="flex items-center justify-center gap-2">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" strokeWidth="1.5" stroke="currentColor" className="w-5 h-5">
                    <path strokeLinecap="round" strokeLinejoin="round" d="M6.75 3v2.25M17.25 3v2.25M3 18.75V7.5a2.25 2.25 0 0 1 2.25-2.25h13.5A2.25 2.25 0 0 1 21 7.5v11.25m-18 0A2.25 2.25 0 0 0 5.25 21h13.5A2.25 2.25 0 0 0 21 18.75m-18 0v-7.5A2.25 2.25 0 0 1 5.25 9h13.5A2.25 2.25 0 0 1 21 11.25v7.5" />
                  </svg>
                  {React.string(`Valid until ${Date.toLocaleDateString(expiryDate)}`)}
                </div>
              | None => React.null
              }}
            </div>
          </div>
          
          <button
            onClick={_ => onRegisterAnother()}
            className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md flex items-center justify-center gap-2 dark:bg-zinc-700 dark:hover:bg-zinc-600 dark:active:bg-zinc-800">
            {React.string("Register Another")}
          </button>
        </div>
      </div>
    </div>
  </div>
} 