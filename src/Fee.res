let calculate = async (name, years) => {
  let duration = years * 31536000
  let priceInWei = await Controller.registerPrice(name, duration)
  Console.log(`name: "${name}", duration: ${Int.toString(duration)}, price: ${BigInt.toString(priceInWei)}`)
  BigInt.toFloat(priceInWei) /. 1e18
}

let calculateRenew = async (name, years) => {
  let duration = years * 31536000
  let priceInWei = await Controller.rentPrice(name, duration)
  BigInt.toFloat(priceInWei) /. 1e18
}
