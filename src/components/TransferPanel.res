open OnChainOperationsCommon
type window
@val external win: window = "window"
@send external alert: (window, string) => unit = "alert"

type transferStep = {
  label: string,
  status: [#NotStarted | #InProgress | #Completed | #Failed],
}

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

  let (currentStep, setCurrentStep) = React.useState(() => 0)
  let (stepStatuses, setStepStatuses) = React.useState(() => [
    {label: "Set Address", status: #NotStarted},
    {label: "Set Name", status: #NotStarted},
    {label: "Reclaim Token", status: #NotStarted},
    {label: "Transfer Token", status: #NotStarted},
  ])

  let updateStepStatus = (index, status) => {
    setStepStatuses(prev =>
      prev->Belt.Array.mapWithIndex((i, step) =>
        if i == index {
          {...step, status}
        } else {
          step
        }
      )
    )
  }

  let handleTransfer = async () => {
    if isWalletConnected {
      let walletClient = buildWalletClient()
      let walletClientUnwrapped = walletClient->Option.getUnsafe
      let currentAddr = await currentAddress(walletClientUnwrapped)
      let primaryName = await OnChainOperations.name(currentAddr)

      if primaryName == "" {
        alert(win, "You must set a primary subname before transferring.")
      } else {
        setIsWaitingForConfirmation(_ => true)
        if isReclaim {
          Console.log(`Reclaiming ${name}`)
          // let tokenId = BigInt.fromString(keccak256(name))
          // OnChainOperations.reclaim(walletClient->Option.getUnsafe, tokenId)->ignore
        } else {
          Console.log(`Transferring ${name} to ${recipientAddress}`)
          try {
            let walletClient = walletClient->Option.getUnsafe
            let currentAddress = await currentAddress(walletClient)
            let tokenId = BigInt.fromString(keccak256(name))

            updateStepStatus(0, #InProgress)
            await OnChainOperations.setAddr(walletClient, name, recipientAddress)
            updateStepStatus(0, #Completed)
            setCurrentStep(_ => 1)

            updateStepStatus(1, #InProgress)
            let primaryName = await OnChainOperations.name(currentAddress)
            await OnChainOperations.setName(walletClient, primaryName)
            updateStepStatus(1, #Completed)
            setCurrentStep(_ => 2)

            updateStepStatus(2, #InProgress)
            await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress)
            updateStepStatus(2, #Completed)
            setCurrentStep(_ => 3)

            updateStepStatus(3, #InProgress)
            await OnChainOperations.safeTransferFrom(
              walletClient,
              currentAddress,
              getAddress(recipientAddress),
              tokenId,
            )
            updateStepStatus(3, #Completed)
            setCurrentStep(_ => 4)

            onSuccess({
              action: Types.Transfer,
              newExpiryDate: None,
            })
          } catch {
          | error => {
              updateStepStatus(currentStep, #Failed)
              Js.Console.error(error)
            }
          }
        }
        setIsWaitingForConfirmation(_ => false)
      }
    }
  }

  <div className="bg-white rounded-custom shadow-lg overflow-hidden">
    <div className="p-4 sm:p-6 max-w-2xl mx-auto">
      <div className="flex justify-between items-center mb-8">
        <div className="flex items-center gap-3">
          <button
            onClick={_ => onBack()}
            className="p-2 hover:bg-gray-100 rounded-full transition-colors"
            type_="button">
            <div className="w-6 h-6 text-gray-600">
              <Icons.Back />
            </div>
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
        onClick={_ => handleTransfer()->ignore}
        disabled={isWaitingForConfirmation || (!isReclaim && recipientAddress == "")}
        className="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400">
        {React.string(
          isWaitingForConfirmation ? "Processing..." : isReclaim ? "Reclaim" : "Transfer",
        )}
      </button>
    </div>
  </div>
}
