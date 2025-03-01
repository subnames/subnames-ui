open OnChainOperationsCommon

type window
@val external win: window = "window"
@send external alert: (window, string) => unit = "alert"

type transferStep = {
  label: string,
  status: [#NotStarted | #InProgress | #Completed | #Failed],
  txHash: option<string>,
}

// Status icon components for the StepProgress
module StatusIcon = {
  module NotStarted = {
    @react.component
    let make = (~className="w-6 h-6") => {
      <svg className viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="9" stroke="currentColor" strokeWidth="2" />
      </svg>
    }
  }

  module InProgress = {
    @react.component
    let make = (~className="w-6 h-6") => {
      <svg className={`${className} animate-spin`} viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="2" />
        <path
          className="opacity-75"
          fill="currentColor"
          d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
        />
      </svg>
    }
  }

  module Completed = {
    @react.component
    let make = (~className="w-6 h-6") => {
      <svg className viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="9" fill="currentColor" fillOpacity="0.2" stroke="currentColor" strokeWidth="2" />
        <path
          d="M8 12L11 15L16 9"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    }
  }

  module Failed = {
    @react.component
    let make = (~className="w-6 h-6") => {
      <svg className viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
        <circle cx="12" cy="12" r="9" fill="currentColor" fillOpacity="0.2" stroke="currentColor" strokeWidth="2" />
        <path
          d="M15 9L9 15M9 9L15 15"
          stroke="currentColor"
          strokeWidth="2"
          strokeLinecap="round"
          strokeLinejoin="round"
        />
      </svg>
    }
  }
}

module StepProgress = {
  @react.component
  let make = (~steps: array<transferStep>, ~currentStep: int) => {
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white p-8 rounded-xl shadow-xl w-full max-w-md mx-4">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-semibold text-gray-900"> {React.string("Transfer Progress")} </h2>
          <div className="text-sm font-medium text-gray-500">
            {React.string(`Step ${(currentStep + 1)->Int.toString} of ${steps->Array.length->Int.toString}`)}
          </div>
        </div>

        <div className="space-y-6">
          {steps
          ->Belt.Array.mapWithIndex((index, step) => {
            let isActive = index == currentStep
            let isPast = index < currentStep
            
            let statusColor = switch step.status {
            | #NotStarted => "text-gray-400"
            | #InProgress => "text-blue-600"
            | #Completed => "text-green-600"
            | #Failed => "text-red-600"
            }
            
            let bgColor = switch step.status {
            | #NotStarted => ""
            | #InProgress => "bg-blue-50"
            | #Completed => "bg-green-50"
            | #Failed => "bg-red-50"
            }
            
            let borderColor = switch step.status {
            | #NotStarted => "border-gray-200"
            | #InProgress => "border-blue-200"
            | #Completed => "border-green-200"
            | #Failed => "border-red-200"
            }
            
            let statusIcon = switch step.status {
            | #NotStarted => <StatusIcon.NotStarted className="w-6 h-6" />
            | #InProgress => <StatusIcon.InProgress className="w-6 h-6" />
            | #Completed => <StatusIcon.Completed className="w-6 h-6" />
            | #Failed => <StatusIcon.Failed className="w-6 h-6" />
            }
            
            <div 
              key={Belt.Int.toString(index)} 
              className={`p-4 rounded-lg border ${borderColor} ${bgColor} transition-all duration-200`}>
              <div className="flex items-center gap-4">
                <div className={`flex-shrink-0 ${statusColor}`}> {statusIcon} </div>
                <div className="flex-1">
                  <div className={`font-medium ${statusColor} text-base`}> 
                    {React.string(step.label)} 
                  </div>
                  {switch step.status {
                  | #InProgress => 
                    <div className="text-sm text-blue-600 mt-1">
                      {React.string("Processing...")}
                    </div>
                  | #Completed => 
                    <div className="text-sm text-green-600 mt-1">
                      {React.string("Completed")}
                    </div>
                  | #Failed => 
                    <div className="text-sm text-red-600 mt-1">
                      {React.string("Failed")}
                    </div>
                  | _ => React.null
                  }}
                </div>
              </div>
              
              {switch (step.status, step.txHash) {
              | (#Completed, Some(hash)) =>
                <div className="mt-2 pt-2 border-t border-green-200">
                  <div className="flex items-center justify-between">
                    <span className="text-xs text-gray-500">{React.string("Transaction Hash:")}</span>
                    <a
                      href={`https://sepolia.etherscan.io/tx/${hash}`}
                      target="_blank"
                      className="text-xs text-blue-600 hover:text-blue-800 underline ml-2 truncate max-w-[200px]">
                      {React.string(hash)}
                    </a>
                  </div>
                </div>
              | _ => React.null
              }}
            </div>
          })
          ->React.array}
        </div>
        
        <div className="mt-6 text-center text-sm text-gray-500">
          {React.string("This process may take a few minutes to complete.")}
        </div>
      </div>
    </div>
  }
}

@react.component
let make = (
  ~name: string,
  ~receiver: option<string>,
  ~onCancel: unit => unit,
  ~onSuccess: Types.actionResult => unit,
  ~buttonType: [#back | #close]=#back,
) => {
  let (recipientAddress, setRecipientAddress) = React.useState(_ => receiver->Option.getOr(""))
  let (isWaitingForConfirmation, setIsWaitingForConfirmation) = React.useState(() => false)

  let (currentStep, setCurrentStep) = React.useState(() => 0)
  let (stepStatuses, setStepStatuses) = React.useState(() => [
    {label: "Set Address", status: #NotStarted, txHash: None},
    {label: "Clear Name", status: #NotStarted, txHash: None},
    {label: "Reclaim Token", status: #NotStarted, txHash: None},
    {label: "Transfer Token", status: #NotStarted, txHash: None},
  ])

  React.useEffect1(() => {
    switch receiver {
    | Some(addr) => setRecipientAddress(_ => addr)
    | None => ()
    }
    None
  }, [receiver])

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
    setIsWaitingForConfirmation(_ => true)
    Console.log(`Transferring ${name} to ${recipientAddress}`)
    try {
      let walletClient = buildWalletClient()->Option.getExn(~message="Wallet connection failed")
      let currentAddress = await currentAddress(walletClient)
      let tokenId = BigInt.fromString(keccak256(name))

      // Check if the current address is already set to the recipient address
      let currentAddrOnChain = await OnChainOperations.getAddr(name)
      
      // set address
      switch currentAddrOnChain {
      | Some(addr) if addr == getAddress(recipientAddress) => {
          // Skip setAddr step if the address is already set correctly
          Console.log(`Address for ${name} is already set to ${recipientAddress}, skipping setAddr step`)
          updateStepStatus(0, #Completed, ~txHash=None)
          setCurrentStep(_ => 1)
        }
      | _ => {
          // Address needs to be updated
          updateStepStatus(0, #InProgress)
          let hash = await OnChainOperations.setAddr(walletClient, name, recipientAddress)
          updateStepStatus(0, #Completed, ~txHash=Some(hash))
          setCurrentStep(_ => 1)
        }
      }

      // clear name
      updateStepStatus(1, #InProgress)
      let hash2 = await OnChainOperations.setName(walletClient, "")
      updateStepStatus(1, #Completed, ~txHash=Some(hash2))
      setCurrentStep(_ => 2)

      // reclaim name
      updateStepStatus(2, #InProgress)
      
      // Verify that the reclaim operation was successful by checking the new owner
      let newOwner = await OnChainOperations.getOwner(tokenId)
      let normalizedNewOwner = getAddress(newOwner)
      let normalizedRecipient = getAddress(recipientAddress)
      
      if (normalizedNewOwner !== normalizedRecipient) { // has not been reclaimed
        let hash3 = await OnChainOperations.reclaim(walletClient, tokenId, recipientAddress)
        updateStepStatus(2, #Completed, ~txHash=Some(hash3))
      } else {
        // Skip reclaim step if the token is already owned by the recipient
        Console.log(`Token for ${name} is already owned by ${recipientAddress}, skipping reclaim step`)
        updateStepStatus(2, #Completed, ~txHash=None)
      }
      setCurrentStep(_ => 3)

      // transfer name token
      updateStepStatus(3, #InProgress)
      
      // Check if the token already belongs to the recipient
      let currentTokenOwner = await OnChainOperations.getTokenOwner(name)
      let normalizedCurrentTokenOwner = getAddress(currentTokenOwner)
      Console.log(`Current token owner: ${normalizedCurrentTokenOwner}`)
      
      if (normalizedCurrentTokenOwner !== normalizedRecipient) {
        // Only transfer if the token is not already owned by the recipient
        let hash4 = await OnChainOperations.safeTransferFrom(
          walletClient,
          currentAddress,
          normalizedRecipient,
          tokenId,
        )
        updateStepStatus(3, #Completed, ~txHash=Some(hash4))
      } else {
        // Skip transfer if the token is already owned by the recipient
        Console.log(`Token for ${name} is already owned by ${recipientAddress}, skipping transfer step`)
        updateStepStatus(3, #Completed, ~txHash=None)
      }
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
    setIsWaitingForConfirmation(_ => false)
  }

  <>
    <div className="fixed inset-0 flex items-center justify-center z-40">
      <div className="fixed inset-0 bg-black bg-opacity-50" />
      {if isWaitingForConfirmation {
        <StepProgress steps=stepStatuses currentStep />
      } else {
        <div
          className="bg-white rounded-custom shadow-lg overflow-hidden relative z-50 max-w-2xl w-full mx-4">
          <div className="p-6 max-w-2xl mx-auto">
            <div className="flex justify-between items-center mb-6">
              <div className="flex items-center gap-3">
                {switch buttonType {
                | #back => 
                  <button
                    onClick={_ => onCancel()}
                    className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                    type_="button">
                    <div className="w-6 h-6 text-gray-600">
                      <Icons.Back />
                    </div>
                  </button>
                | #close => React.null
                }}
                <h2 className="text-xl font-semibold text-gray-900">
                  {React.string(`Transfer Your Subname: ${name}`)}
                </h2>
              </div>
              {switch buttonType {
              | #close => 
                <button
                  onClick={_ => onCancel()}
                  className="p-2 hover:bg-gray-100 rounded-full transition-colors"
                  type_="button">
                  <div className="w-6 h-6 text-gray-600">
                    <Icons.Close />
                  </div>
                </button>
              | #back => React.null
              }}
            </div>
            <div className="mb-8 mx-[1px]">
              <label className="block text-gray-700 text-sm font-medium mb-2">{React.string("To:")}</label>
              <input
                type_="text"
                value={recipientAddress}
                onChange={e => setRecipientAddress(ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 rounded-md border border-gray-300 shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 font-medium text-lg"
                placeholder="0x..."
              />
            </div>
            <button
              onClick={_ => handleTransfer()->ignore}
              disabled={isWaitingForConfirmation || recipientAddress == ""}
              className="w-full py-4 px-6 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-2xl font-medium text-lg transition-colors shadow-sm hover:shadow-md">
              {React.string(isWaitingForConfirmation ? "Processing..." : "Transfer")}
            </button>
          </div>
        </div>
      }}
    </div>
  </>
}
