let calculate = async (name, years) => {
  let duration = years * 31536000
  let priceInWei = await OnChainOperations.registerPrice(name, duration)
  Console.log(`name: "${name}", duration: ${Int.toString(duration)}, price: ${BigInt.toString(priceInWei)}`)

  Float.toFixed(BigInt.toFloat(priceInWei) /. 10e18, ~digits=8)
}
