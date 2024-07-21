# PredictionMarket

PredictionMarket is a decentralized application (dApp) built on Ethereum that allows users to create and participate in prediction markets. Users can create markets for future events, buy shares in outcomes, and earn rewards for correct predictions.

## Features

- Create prediction markets for future events
- Buy shares in market outcomes
- Resolve markets and claim rewards
- Integration with Chainlink price feeds for oracle data

## Technologies Used

- Solidity
- React
- Ethers.js
- Foundry (for smart contract development and testing)
- IPFS (for decentralized hosting)

## Prerequisites

- Node.js (v14.0.0 or later)
- npm (v6.0.0 or later)
- Foundry
- MetaMask or another Web3 wallet

## Installation

1. Clone the repository:

   ```
   git clone https://github.com/Ferrisama/PredictionMarket.git
   cd PredictionMarket
   ```

2. Install dependencies for the smart contract:

   ```
   forge install
   ```

3. Install dependencies for the frontend:
   ```
   cd prediction-market-frontend
   npm install
   ```

## Smart Contract Deployment

1. Set up your `.env` file with your private key and RPC URL:

   ```
   PRIVATE_KEY=your_private_key_here
   RPC_URL=your_rpc_url_here
   ```

2. Deploy the contract:

   ```
   forge script script/DeployPredictionMarket.s.sol:DeployPredictionMarket --rpc-url $RPC_URL --broadcast --verify
   ```

3. Note the deployed contract address for frontend configuration.

## Frontend Setup

1. Update the contract address in `src/components/PredictionMarket.jsx`:

   ```javascript
   const contractAddress = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
   ```

2. Start the development server:

   ```
   npm run dev
   ```

3. Open `http://localhost:5173` in your browser.

## Usage

1. Connect your Web3 wallet (e.g., MetaMask) to the dApp.
2. Create a new prediction market or participate in existing ones.
3. Buy shares in outcomes you predict will occur.
4. Once a market is resolved, claim your rewards if your prediction was correct.

## Testing

Run the smart contract tests:

```
forge test
```

## Deployment to IPFS

1. Build the frontend:

   ```
   npm run build
   ```

2. Add the `dist` folder to IPFS:

   ```
   ipfs add -r dist
   ```

3. Note the CID of the added directory and access your dApp through an IPFS gateway.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.
