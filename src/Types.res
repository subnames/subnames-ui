type action =
  | Register
  | Extend(Date.t)

type actionResult = {
  action: action,
  newExpiryDate: Date.t,
}

type state = {
  name: string,
  panel: string,
  action: action,
  result: option<actionResult>,
}