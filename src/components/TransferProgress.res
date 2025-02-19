type step = {
  label: string,
  status: [#NotStarted | #InProgress | #Completed | #Failed]
}

type steps = array<step>

@react.component
let make = (~currentStep: int, ~steps: steps) => {
  let totalSteps = Belt.Array.length(steps)
  let progress = (currentStep + 1) * 100 / totalSteps

  <div className="w-full">
    <div className="mb-4">
      <div className="h-2 w-full bg-gray-200 rounded-full">
        <div 
          className="h-full bg-blue-600 rounded-full transition-all duration-500 ease-in-out"
          style={ReactDOM.Style.make(~width=`${progress->Belt.Int.toString}%`, ())}
        />
      </div>
    </div>
    <div className="flex justify-between">
      {steps->Belt.Array.mapWithIndex((index, step) => {
        let statusClass = switch step.status {
        | #NotStarted => "text-gray-500"
        | #InProgress => "text-blue-600 font-medium animate-pulse"
        | #Completed => "text-green-600"
        | #Failed => "text-red-600"
        }

        let icon = switch step.status {
        | #NotStarted => "○"
        | #InProgress => "◎"
        | #Completed => "●"
        | #Failed => "×"
        }

        <div key={index->Belt.Int.toString} className="flex flex-col items-center">
          <div className={`text-sm ${statusClass}`}>
            {React.string(icon)}
          </div>
          <div className={`text-xs mt-1 ${statusClass}`}>
            {React.string(step.label)}
          </div>
        </div>
      })->React.array}
    </div>
  </div>
}
