open OnChainOperationsCommon

let registryContract = {
  "address": Constants.registryContractAddress,
  "abi": [
    {
      "type": "function",
      "name": "recordExists",
      "inputs": [{"name": "node", "type": "bytes32"}],
      "outputs": [{"name": "", "type": "bool"}],
      "stateMutability": "view",
    },
    {
      "type": "function",
      "name": "owner",
      "inputs": [{"name": "node", "type": "bytes32"}],
      "outputs": [{"name": "", "type": "address"}],
      "stateMutability": "view",
    },
  ],
}

let recordExists: string => promise<bool> = async name => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  Console.log(`domain: "${domain}", node: "${node}"`)
  await readContract(
    publicClient,
    {
      "address": registryContract["address"],
      "abi": registryContract["abi"],
      "functionName": "recordExists",
      "args": [String(node)],
    },
  )
}

let owner: string => promise<string> = async name => {
  let domain = `${name}.${Constants.sld}`
  let node = namehash(domain)
  await readContract(
    publicClient,
    {
      "address": registryContract["address"],
      "abi": registryContract["abi"],
      "functionName": "owner",
      "args": [String(node)],
    },
  )
}

let getOwner = async tokenId => {
  let label = `0x${tokenId->BigInt.toString(~radix=16)->String.padStart(64, "0")}`;

  // Compute the node for the subdomain
  let node = keccak256(
    encodePacked(
      ["bytes32", "bytes32"],
      [Constants.parentNode, label],
    ),
  )
  
  // Get the owner from the registry contract
  await readContract(
    publicClient,
    {
      "address": registryContract["address"],
      "abi": registryContract["abi"],
      "functionName": "owner",
      "args": [String(node)],
    },
  )
}