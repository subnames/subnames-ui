open OnChainOperationsCommon

@react.component
let make = () => {
  let (name, setName) = React.useState(_ => "")
  let (isWaitingForConfirmation, setIsWaitingForConfirmation) = React.useState(() => false)
  let (error, setError) = React.useState(() => None)

  let handleSetName = async _ => {
    switch buildWalletClient() {
    | None => setError(_ => Some("Please connect your wallet first"))
    | Some(walletClient) => {
        try {
          setError(_ => None)
          setIsWaitingForConfirmation(_ => true)
          await ReverseRegistrar.setName(walletClient, name)
          setIsWaitingForConfirmation(_ => false)
        } catch {
        | Js.Exn.Error(obj) => {
            let message = Js.Exn.message(obj)->Option.getOr("Unknown error occurred")
            setError(_ => Some(message))
            setIsWaitingForConfirmation(_ => false)
          }
        }
      }
    }
  }

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-4 sm:p-6 max-w-2xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <h2 className="text-xl font-semibold text-gray-900">
          {React.string("Set Primary Name")}
        </h2>
      </div>

      <div className="mb-6">
        <label className="block text-sm font-medium text-gray-700 mb-2">
          {React.string("Name")}
        </label>
        <input
          type_="text"
          value=name
          onChange={e => setName(ReactEvent.Form.target(e)["value"])}
          className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
          placeholder="Enter name to set as primary"
        />
      </div>

      {switch error {
      | Some(message) =>
        <div className="mb-4 p-4 bg-red-50 border border-red-200 rounded-md text-red-700">
          {React.string(message)}
        </div>
      | None => React.null
      }}

      <button
        onClick={_ => ignore(handleSetName())}
        disabled={isWaitingForConfirmation || name == ""}
        className="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400">
        {React.string(isWaitingForConfirmation ? "Processing..." : "Set Primary Name")}
      </button>
    </div>
  </div>
}