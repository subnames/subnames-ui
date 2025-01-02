open OnChainOperationsCommon

@react.component
let make = (
  ~name: string,
  ~isWalletConnected: bool,
  ~onBack: unit => unit,
  ~onSuccess: Types.actionResult => unit,
) => {
  let (recipientAddress, setRecipientAddress) = React.useState(_ => "")
  let (isWaitingForConfirmation, setIsWaitingForConfirmation) = React.useState(() => false)
  let (onChainStatus, setOnChainStatus) = React.useState(() => OnChainOperations.Simulating)
  let (isReclaim, setIsReclaim) = React.useState(_ => false)

  let handleTransfer = () => {
    if isWalletConnected {
      let walletClient = buildWalletClient()
      setIsWaitingForConfirmation(_ => true)
        if isReclaim {
          OnChainOperations.reclaimSubname(walletClient->Option.getUnsafe, name)->ignore
        } else {
          OnChainOperations.transferSubname(walletClient->Option.getUnsafe, name, recipientAddress)->ignore
        }
      setIsWaitingForConfirmation(_ => false)
      onSuccess({
        action: Types.Transfer,
        newExpiryDate: None,
      })
    }
  }

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-4 sm:p-6 max-w-2xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center gap-3">
          <button
            onClick={_ => onBack()}
            className="text-gray-400 hover:text-gray-500">
            <Icons.Back />
          </button>
          <h2 className="text-xl font-semibold text-gray-900">
            {React.string(isReclaim ? "Reclaim Subname" : "Transfer Subname")}
          </h2>
        </div>
      </div>

      {if !isReclaim {
        <div className="mb-6">
          <label className="block text-sm font-medium text-gray-700 mb-2">
            {React.string("Recipient Address")}
          </label>
          <input
            type_="text"
            value=recipientAddress
            onChange={e => setRecipientAddress(ReactEvent.Form.target(e)["value"])}
            className="w-full px-3 py-2 border border-gray-300 rounded-md shadow-sm focus:outline-none focus:ring-indigo-500 focus:border-indigo-500"
            placeholder="0x..."
          />
        </div>
      } else {
        <div className="mb-6 text-gray-700">
          {React.string("Click Reclaim to sync the Registry ownership with your NFT ownership.")}
        </div>
      }}

      <button
        onClick={_ => handleTransfer()}
        disabled={isWaitingForConfirmation || (!isReclaim && recipientAddress == "")}
        className="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400">
        {React.string(
          isWaitingForConfirmation
            ? "Processing..."
            : isReclaim
            ? "Reclaim"
            : "Transfer",
        )}
      </button>

    </div>
  </div>
}
