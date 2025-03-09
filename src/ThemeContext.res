open Webapi.Dom
type theme = Light | Dark

type contextValue = {
  theme: theme,
  setTheme: (theme => theme) => unit,
}

let context = React.createContext({
  theme: Light,
  setTheme: _ => (),
})

module Provider = {
  let make = React.Context.provider(context)
}

let useTheme = () => React.useContext(context)

// Helper function to apply theme to document
let applyTheme = (theme: theme) => {
  switch theme {
  | Dark => Element.setClassName(document->Document.documentElement, "dark")
  | Light => Element.setClassName(document->Document.documentElement, "light")
  }
}

// Helper function to get initial theme from localStorage or system preference
let getInitialTheme = () => {
  Light
}
