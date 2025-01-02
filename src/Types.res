type action =
  | Register
  | Extend(Date.t)
  | Transfer
  | Reclaim

type actionResult = {
  action: action,
  newExpiryDate: option<Date.t>,
}

type state = {
  name: string,
  panel: string,
  action: action,
  result: option<actionResult>,
}