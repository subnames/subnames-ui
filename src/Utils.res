let useDebounce = (callback, delay) => {
  let timeoutRef = React.useRef(None)

  value => {
    // Clear existing timeout
    switch timeoutRef.current {
    | Some(timeout) => Js.Global.clearTimeout(timeout)
    | None => ()
    }

    // Set new timeout
    let timeout = Js.Global.setTimeout(() => {
      callback(value)
    }, delay)

    timeoutRef.current = Some(timeout)
  }
}