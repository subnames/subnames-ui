@react.component
let make = () => {
  let (validSubname, setValidSubname) = React.useState(_ => ("", false))

  let handleValidChange = (value, isValid) => {
    setValidSubname(_ => (value, isValid))
  }

  <div className="p-8">
    <SubnameInput onValidChange={handleValidChange} />
    
    {if snd(validSubname) && fst(validSubname) != "" {
      <p className="mt-4 text-green-600">
        {React.string(`"${fst(validSubname)}" is a valid ENS subname`)}
      </p>
    } else {
      React.null
    }}
  </div>
}
