open OnChainOperationsCommon

type window
@val external win: window = "window"
@send external alert: (window, string) => unit = "alert"

let shortenHash = (hash: string): string => {
  let length = String.length(hash)
  if length <= 10 {
    hash
  } else {
    let start = String.slice(~start=0, ~end=6, hash)
    let end = String.slice(~start=length - 4, ~end=length, hash)
    `${start}...${end}`
  }
}

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
  let make = (~steps: array<transferStep>, ~currentStep: int, ~allStepsCompleted: bool, ~onClose: unit => unit) => {
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white px-8 py-6 rounded-custom shadow-lg w-full max-w-sm mx-4">
        <div className="flex items-center justify-between mb-5">
          <h1 className="text-lg font-semibold text-gray-900"> {React.string("Transfer Progress")} </h1>
          {if allStepsCompleted {
            <button
              onClick={_ => onClose()}
              className="p-2 hover:bg-gray-100 rounded-full transition-colors">
              <div className="w-4 h-4 text-gray-600">
                <Icons.Close />
              </div>
            </button>
          } else {
            <div className="text-xs font-medium text-gray-500">
              {React.string(`${(currentStep + 1)->Int.toString}/${steps->Array.length->Int.toString}`)}
            </div>
          }}
        </div>
        <div className="border-b border-gray-200 mb-4 -mx-8"></div>

        <div className="space-y-2">
          {steps
          ->Belt.Array.mapWithIndex((index, step) => {
            let statusColor = switch step.status {
            | #NotStarted => "text-gray-400"
            | #InProgress => "text-blue-600"
            | #Completed => "text-green-600"
            | #Failed => "text-red-600"
            }
            
            let borderColor = switch step.status {
            | #NotStarted => "border-gray-100"
            | #InProgress => "border-blue-200"
            | #Completed => "border-green-200"
            | #Failed => "border-red-200"
            }
            
            let statusIcon = switch step.status {
            | #NotStarted => <StatusIcon.NotStarted className="w-4 h-4" />
            | #InProgress => <StatusIcon.InProgress className="w-4 h-4" />
            | #Completed => <StatusIcon.Completed className="w-4 h-4" />
            | #Failed => <StatusIcon.Failed className="w-4 h-4" />
            }
            
            let _statusText = switch step.status {
            | #InProgress => <span className="text-xs text-blue-600 ml-1">{React.string("Processing")}</span>
            | _ => React.null
            }
            
            <div 
              key={Belt.Int.toString(index)} 
              className={`py-2 px-2 rounded border-l-0 ${borderColor} transition-all duration-200`}>
              <div className="flex items-center">
                <div className={`flex-shrink-0 ${statusColor}`}> {statusIcon} </div>
                <div className="flex-1 ml-2">
                  <div className="flex items-center">
                    <span className={`text-sm ${statusColor}`}>{React.string(step.label)}</span>
                    // {statusText}
                  </div>
                </div>
                
                {switch (step.status, step.txHash) {
                | (#Completed, Some(hash)) =>
                  <a
                    href={`https://sepolia.etherscan.io/tx/${hash}`}
                    target="_blank"
                    className="text-xs text-blue-600 hover:text-blue-800 ml-auto">
                    <span className="underline">{React.string(`${shortenHash(hash)}`)}</span>
                  </a>
                | _ => React.null
                }}
              </div>
            </div>
          })
          ->React.array}
        </div>
        
        <div className="border-t border-gray-200 mt-4 -mx-8"></div>
        
        <div className="mt-5 text-center text-sm text-gray-500">
          {React.string(allStepsCompleted ? "All steps completed successfully." : "Don't close or refresh this window.")}
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
  let (allStepsCompleted, setAllStepsCompleted) = React.useState(() => false)

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
      setAllStepsCompleted(_ => true)
    } catch {
    | error => {
        updateStepStatus(currentStep, #Failed)
        Js.Console.error(error)
      }
    }
  }

  <>
    <div className="fixed inset-0 flex items-center justify-center z-40">
      <div className="fixed inset-0 bg-black bg-opacity-50" />
      {if isWaitingForConfirmation {
        <StepProgress 
          steps=stepStatuses 
          currentStep 
          allStepsCompleted 
          onClose={() => {
            setIsWaitingForConfirmation(_ => false)
            onSuccess({
              action: Types.Transfer,
              newExpiryDate: None,
            })
          }} 
        />
      } else {
        <div
          className="bg-white rounded-custom shadow-lg overflow-hidden relative z-50 max-w-2xl w-full mx-4">
          <div className="pt-6 pb-8 px-8 max-w-2xl mx-auto">
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
                  {React.string(`Transfer \`${name}\``)}
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
