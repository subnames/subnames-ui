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
  let make = (~steps: array<transferStep>, ~currentStep: int, ~allStepsCompleted: bool, ~transactionRejected: bool, ~onClose: unit => unit) => {
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white px-8 py-6 rounded-custom shadow-lg w-full max-w-sm mx-4">
        <div className="flex items-center justify-between mb-5">
          <h1 className="text-lg font-semibold text-gray-900"> {React.string("Transfer Progress")} </h1>
          {if allStepsCompleted || transactionRejected {
            <button
              onClick={_ => onClose()}
              className="rounded-full transition-colors duration-150 flex items-center justify-center"
              type_="button">
              <div className="hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300  flex items-center justify-center">
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
        
        <div className="mt-5 text-center">
          {allStepsCompleted || transactionRejected 
            ? <button
                onClick={_ => onClose()}
                className="w-full px-4 py-2 bg-zinc-800 hover:bg-zinc-700 active:bg-zinc-900 text-white rounded-xl font-medium transition-colors shadow-sm hover:shadow-md"
                type_="button">
                {React.string("Close")}
              </button>
            : <div className="text-sm text-gray-500">
                {React.string("Don't close or refresh this window.")}
              </div>
          }
        </div>
      </div>
    </div>
  }
}


  type transferOperationResult = {
    value: unit,
    txHash: option<string>,
  }
  type transferOperation = () => promise<transferOperationResult>
@react.component
let make = (
  ~name: string,
  ~receiver: option<string>,
  ~onCancel: unit => unit,
  ~onSuccess: Types.actionResult => unit,
  ~buttonType: [#back | #close]=#back,
) => {
  let {primaryName} = NameContext.use()
  let (recipientAddress, setRecipientAddress) = React.useState(_ => receiver->Option.getOr(""))
  let (isWaitingForConfirmation, setIsWaitingForConfirmation) = React.useState(() => false)
  let (allStepsCompleted, setAllStepsCompleted) = React.useState(() => false)
  let (transactionRejected, setTransactionRejected) = React.useState(() => false)

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
    
    // Define a helper function to execute a step with proper error handling
    let executeStep = async (stepIndex: int, stepName, operation: transferOperation) => {
      try {
        // Console.log(`Starting step ${stepIndex}: ${stepName}`)
        updateStepStatus(stepIndex, #InProgress)
        let result = await operation()
        updateStepStatus(stepIndex, #Completed, ~txHash=result.txHash)
        setCurrentStep(_ => stepIndex + 1)
        result.value
      } catch {
        | Exn.Error(error) => {
          let errorMessage = Exn.message(error)->Option.getOr("Unknown error")
          Console.log(`Error in step ${Int.toString(stepIndex)} (${stepName}): ${errorMessage}`)
          updateStepStatus(stepIndex, #Failed)
          
          // Check if it's a transaction receipt error
          if (String.includes(errorMessage, "TransactionReceiptNotFoundError")) {
            Console.log("This is a transaction receipt error. The transaction might have actually succeeded on-chain.")
            Console.log("You can safely try again or check the transaction status on the blockchain explorer.")
          }

          setTransactionRejected(_ => true)

          Console.error(error)
          Exn.raiseError(errorMessage)
        }
      }
    }
    
      let walletClient = buildWalletClient()->Option.getExn(~message="Wallet connection failed")
      let currentAddress = await currentAddress(walletClient)
      let tokenId = BigInt.fromString(keccak256(name))

      // Step 1: Set Address
      await executeStep(0, "Set Address", async () => {
        let currentAddrOnChain = await L2Resolver.getAddr(name)
        
        switch currentAddrOnChain {
        | Some(addr) if addr == getAddress(recipientAddress) => {
            // Skip setAddr step if the address is already set correctly
            Console.log(`Address for ${name} is already set to ${recipientAddress}, skipping setAddr step`)
            {value: (), txHash: None}
          }
        | _ => {
            // Address needs to be updated
            let hash = await L2Resolver.setAddr(walletClient, name, recipientAddress)
            {value: (), txHash: Some(hash)}
          }
        }
      })

      // Step 2: Clear Name
      await executeStep(1, "Clear Name", async () => {
        if primaryName->Option.isSome && (primaryName->Option.getExn).name == name {
          let hash = await L2Resolver.setName(walletClient, "")
          {value: (), txHash: Some(hash)} 
        } else {
          Console.log(`This name is not primary, skipping clear name step`)
          {value: (), txHash: None}
        }
      })

      // Step 3: Reclaim Token
      await executeStep(2, "Reclaim Token", async () => {
        // Verify that the reclaim operation was successful by checking the new owner
        let newOwner = await Registry.getOwner(tokenId)
        let normalizedNewOwner = getAddress(newOwner)
        let normalizedRecipient = getAddress(recipientAddress)
        
        if (normalizedNewOwner !== normalizedRecipient) { // has not been reclaimed
          let hash = await BaseRegistrar.reclaim(walletClient, tokenId, recipientAddress)
          {value: (), txHash: Some(hash)}
        } else {
          // Skip reclaim step if the token is already owned by the recipient
          Console.log(`Token for ${name} is already owned by ${recipientAddress}, skipping reclaim step`)
          {value: (), txHash: None}
        }
      })

      // Step 4: Transfer Token
      await executeStep(3, "Transfer Token", async () => {
        // Check if the token already belongs to the recipient
        let currentTokenOwner = await BaseRegistrar.getTokenOwner(name)
        let normalizedCurrentTokenOwner = getAddress(currentTokenOwner)
        let normalizedRecipient = getAddress(recipientAddress)
        Console.log(`Current token owner: ${normalizedCurrentTokenOwner}`)
        
        if (normalizedCurrentTokenOwner !== normalizedRecipient) {
          // Only transfer if the token is not already owned by the recipient
          let hash = await BaseRegistrar.safeTransferFrom(
            walletClient,
            currentAddress,
            normalizedRecipient,
            tokenId,
          )
          {value: (), txHash: Some(hash)}
        } else {
          // Skip transfer if the token is already owned by the recipient
          Console.log(`Token for ${name} is already owned by ${recipientAddress}, skipping transfer step`)
          {value: (), txHash: None}
        }
      })
      
      setAllStepsCompleted(_ => true)
  }

  <>
    <div className="fixed inset-0 flex items-center justify-center z-40">
      <div className="fixed inset-0 bg-black bg-opacity-50" />
      {if isWaitingForConfirmation {
        <StepProgress 
          steps=stepStatuses 
          currentStep 
          allStepsCompleted
          transactionRejected
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

            // header
            <div className="flex justify-between">
              <div className="flex gap-3">
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
                <div>
                  <h1 className="text-xl font-semibold text-gray-900 truncate">
                    {React.string(`Transfer`)}
                  </h1>
                  <div className="mt-0">
                    <span className="text-sm text-gray-500">{React.string(`${name}.${Constants.sld}`)}</span>
                  </div>
                </div>
              </div>
              {switch buttonType {
              | #close => 
                <div className="self-center">
                  <button
                    onClick={_ => onCancel()}
                    className="rounded-full transition-colors hover:text-gray-500 dark:text-gray-500 dark:hover:text-gray-300"
                    type_="button">
                    <Icons.Close />
                  </button>
                </div>
              | #back => React.null
              }}
            </div>

            <div className="border-t border-gray-200 my-4 -mx-8"></div>

            <div className="mb-8 mx-[1px]">
              <label className="block text-gray-700 text-sm font-medium mb-2">{React.string("To:")}</label>
              <input
                type_="text"
                value={recipientAddress}
                onChange={e => setRecipientAddress(ReactEvent.Form.target(e)["value"])}
                className="w-full px-3 py-2 rounded-md border border-gray-300 shadow-sm focus:outline-none focus:ring-zinc-500 focus:border-zinc-500 font-medium text-lg"
                placeholder="0x..."
                disabled={recipientAddress != ""}
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
