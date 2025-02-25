open OnChainOperationsCommon
type window
@val external win: window = "window"
@send external alert: (window, string) => unit = "alert"

type transferStep = {
  label: string,
  status: [#NotStarted | #InProgress | #Completed | #Failed],
  txHash: option<string>,
}

module StepProgress = {
  @react.component
  let make = (~steps: array<transferStep>, ~currentStep: int) => {
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-6 rounded-lg shadow-xl w-96">
        <h3 className="text-lg font-semibold mb-4"> {React.string("Transfer Progress")} </h3>
        <div className="space-y-4">
          {steps
          ->Belt.Array.mapWithIndex((index, step) => {
            let statusColor = switch step.status {
            | #NotStarted => "text-gray-400"
            | #InProgress => "text-blue-500"
            | #Completed => "text-green-500"
            | #Failed => "text-red-500"
            }
            let statusIcon = switch step.status {
            | #NotStarted => "⚪"
            | #InProgress => "🔄"
            | #Completed => "✅"
            | #Failed => "❌"
            }
            <div key={Belt.Int.toString(index)} className="flex items-center gap-3">
              <div className={`${statusColor}`}> {React.string(statusIcon)} </div>
              <div className="flex-1 space-y-1">
                <div className={`font-medium ${statusColor}`}> {React.string(step.label)} </div>
                {switch (step.status, step.txHash) {
                | (#Completed, Some(hash)) =>
                  <a
                    href={`https://sepolia.etherscan.io/tx/${hash}`}
                    target="_blank"
                    className="text-xs text-blue-500 hover:text-blue-700 truncate block">
                    {React.string(hash)}
                  </a>
                | _ => React.null
                }}
              </div>
            </div>
          })
          ->React.array}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~name: string,
  ~receiver: option<string>,
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
    {label: "Set Address", status: #NotStarted, txHash: None},
    {label: "Set Name", status: #NotStarted, txHash: None},
    {label: "Reclaim Token", status: #NotStarted, txHash: None},
    {label: "Transfer Token", status: #NotStarted, txHash: None},
  ])

  let updateStepStatus = (index, status, ~txHash=None) => {
    setStepStatuses(prev =>
      prev->Belt.Array.mapWithIndex((i, step) =>
        if i == index {
          {...step, status, txHash}
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
            let hash = await OnChainOperations.setAddr(walletClient, name, recipientAddress)
            updateStepStatus(0, #Completed, ~txHash=Some(hash))
            setCurrentStep(_ => 1)

            updateStepStatus(1, #InProgress)
            // let primaryName = await OnChainOperations.name(currentAddress)
            let hash2 = await OnChainOperations.setName(walletClient, "")
            updateStepStatus(1, #Completed, ~txHash=Some(hash2))
            setCurrentStep(_ => 2)

            updateStepStatus(2, #InProgress)
            let hash3 = await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress)
            updateStepStatus(2, #Completed, ~txHash=Some(hash3))
            setCurrentStep(_ => 3)

            updateStepStatus(3, #InProgress)
            let hash4 = await OnChainOperations.safeTransferFrom(
              walletClient,
              currentAddress,
              getAddress(recipientAddress),
              tokenId,
            )
            updateStepStatus(3, #Completed, ~txHash=Some(hash4))
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

  <>
    <div className="fixed inset-0 flex items-center justify-center z-40">
      <div className="fixed inset-0 bg-black bg-opacity-50" />
      {if isWaitingForConfirmation {
        <StepProgress steps=stepStatuses currentStep />
      } else {
        <div className="bg-white rounded-custom shadow-lg overflow-hidden relative z-50 max-w-2xl w-full mx-4">

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
            {React.string(isReclaim ? "Reclaim Subname" : `Transfer "${name}" to` )}
          </h2>
        </div>
      </div>
      {if !isReclaim {
        <div className="mb-6">
          <input
            type_="text"
            value={receiver->Option.getOr("")}
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
        disabled={isWaitingForConfirmation || (!isReclaim && recipientAddress == "" && receiver->Option.isNone)}
        className="w-full bg-indigo-600 text-white py-2 px-4 rounded-md hover:bg-indigo-700 disabled:bg-gray-400">
        {React.string(
          isWaitingForConfirmation ? "Processing..." : isReclaim ? "Reclaim" : "Transfer",
        )}
      </button>
    </div>
  </div>
      }}
    </div>
  </>
}
