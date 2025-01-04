type action =
  | Register
  | Extend
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