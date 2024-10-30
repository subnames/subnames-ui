let calculate = async (name, years) => {
  Console.log(`years: ${Int.toString(years)}`)
  Console.log(`name: ${name}`)
  let duration = years * Constants.secondsPerYear
  Console.log(`duration: ${Int.toString(duration)}`)
  let priceInWei = await ReadContract.registerPrice(name, duration)
  Console.log(`price: ${BigInt.toString(priceInWei)}`)
  Float.toFixed(BigInt.toFloat(priceInWei) /. 10e18, ~digits=8)
}
