export const predictionMarketABI = [
  {
    inputs: [],
    name: "marketCount",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    name: "markets",
    outputs: [
      { internalType: "string", name: "question", type: "string" },
      { internalType: "uint256", name: "endTime", type: "uint256" },
      { internalType: "bool", name: "resolved", type: "bool" },
      { internalType: "uint256", name: "yesShares", type: "uint256" },
      { internalType: "uint256", name: "noShares", type: "uint256" },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      { internalType: "string", name: "_question", type: "string" },
      { internalType: "uint256", name: "_duration", type: "uint256" },
    ],
    name: "createMarket",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  // Add other functions from your smart contract here
];
