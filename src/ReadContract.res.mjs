// Generated by ReScript, PLEASE EDIT WITH CARE

import * as Viem from "viem";
import * as Ens from "viem/ens";

var registryContract = {
  address: "0xd3E89BB05F63337a450711156683d533db976C85",
  abi: [{
      type: "function",
      name: "recordExists",
      inputs: [{
          name: "node",
          type: "bytes32"
        }],
      outputs: [{
          name: "",
          type: "bool"
        }],
      stateMutability: "view"
    }]
};

var controllerContract = {
  address: "0x50d634E43F5aD7748cf2860760b887655524B593",
  abi: [
    {
      type: "function",
      name: "available",
      inputs: [{
          name: "name",
          type: "string"
        }],
      outputs: [{
          name: "",
          type: "bool"
        }],
      stateMutability: "view"
    },
    {
      type: "function",
      name: "registerPrice",
      inputs: [
        {
          name: "name",
          type: "string"
        },
        {
          name: "duration",
          type: "uint256"
        }
      ],
      outputs: [{
          name: "",
          type: "uint256"
        }],
      stateMutability: "view"
    },
    {
      type: "function",
      name: "renew",
      inputs: [
        {
          name: "name",
          type: "string"
        },
        {
          name: "duration",
          type: "uint256"
        }
      ],
      outputs: [],
      stateMutability: "payable"
    }
  ]
};

var client = Viem.createPublicClient({
      chain: Viem.koi,
      transport: Viem.http("https://koi-rpc.darwinia.network")
    });

async function recordExists(name) {
  var node = Ens.namehash(name + ".ringdao.eth");
  console.log(node);
  return await client.readContract({
              address: registryContract.address,
              abi: registryContract.abi,
              functionName: "recordExists",
              args: [node]
            });
}

async function available(name) {
  return await client.readContract({
              address: controllerContract.address,
              abi: controllerContract.abi,
              functionName: "available",
              args: [name]
            });
}

async function registerPrice(name, duration) {
  var args = [
    name,
    duration
  ];
  return BigInt(await client.readContract({
                  address: controllerContract.address,
                  abi: controllerContract.abi,
                  functionName: "registerPrice",
                  args: args
                }));
}

var secondsPerYear = 31536000;

export {
  registryContract ,
  controllerContract ,
  client ,
  recordExists ,
  available ,
  secondsPerYear ,
  registerPrice ,
}
/* client Not a pure module */
