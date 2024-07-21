// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/PredictionMarket.sol";

contract DeployPredictionMarket is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address priceFeedAddress = vm.envAddress("PRICE_FEED_ADDRESS");

        vm.startBroadcast(deployerPrivateKey);

        PredictionMarket predictionMarket = new PredictionMarket(priceFeedAddress);

        console.log("PredictionMarket deployed to:", address(predictionMarket));

        vm.stopBroadcast();
    }
}