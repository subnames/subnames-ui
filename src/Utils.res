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

@module("date-fns")
external addDays: (Date.t, int) => Date.t = "addDays"

@module("date-fns")
external formatDistanceToNow: (Date.t, {"addSuffix": bool}) => string = "formatDistanceToNow"

let distanceToExpiry: Date.t => string = date => {
  formatDistanceToNow(date, {"addSuffix": true})
}

let timestampToDate: int => Date.t = timestamp => {
  let floatTimestamp = Int.toFloat(timestamp)
  Date.fromTime(floatTimestamp *. 1000.0)
}

let timestampStringToDate: string => Date.t = timestamp => {
  let intTimestamp = Int.fromString(timestamp)->Option.getExn
  timestampToDate(intTimestamp)
}

let getString = (jsonObj, fieldName) => {
  jsonObj
  ->Dict.get(fieldName)
  ->Option.flatMap(JSON.Decode.string)
  ->Option.getExn(~message="Failed to decode ${fieldName}")
}

let getObject = (jsonObj, fieldName, f) => {
  jsonObj
  ->Dict.get(fieldName)
  ->Option.flatMap(JSON.Decode.object)
  ->Option.map(f)
  ->Option.getExn(~message="Failed to decode ${fieldName}")
}

let getArray = (jsonObj, fieldName, f) => {
  jsonObj
  ->Dict.get(fieldName)
  ->Option.flatMap(JSON.Decode.array)
  ->Option.map(f)
  ->Option.getExn(~message="Failed to decode ${fieldName}")
}
