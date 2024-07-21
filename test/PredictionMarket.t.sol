// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/PredictionMarket.sol";

contract MockV3Aggregator {
    int256 private _price;

    constructor(int256 initialPrice) {
        _price = initialPrice;
    }

    function latestRoundData() external view returns (uint80, int256, uint256, uint256, uint80) {
        return (0, _price, 0, 0, 0);
    }

    function setPrice(int256 newPrice) external {
        _price = newPrice;
    }
}

contract PredictionMarketTest is Test {
    PredictionMarket public predictionMarket;
    MockV3Aggregator public mockPriceFeed;
    address public owner;
    address public user1;
    address public user2;

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);

        mockPriceFeed = new MockV3Aggregator(100 * 10**8);  // $100 with 8 decimal places
        predictionMarket = new PredictionMarket(address(mockPriceFeed));

        predictionMarket.mint(user1, 1000 * 10**18);
        predictionMarket.mint(user2, 1000 * 10**18);
    }

    function testCreateMarket() public {
        string memory question = "Will it rain tomorrow?";
        uint256 duration = 1 days;

        predictionMarket.createMarket(question, duration);

        (string memory storedQuestion, uint256 endTime, bool resolved, , , ,) = predictionMarket.markets(1);

        assertEq(storedQuestion, question, "Question should match");
        assertEq(endTime, block.timestamp + duration, "End time should be set correctly");
        assertEq(resolved, false, "Market should not be resolved initially");
    }

    function testBuyShares() public {
        predictionMarket.createMarket("Test market", 1 days);

        vm.startPrank(user1);
        uint256 initialBalance = predictionMarket.balanceOf(user1);

        predictionMarket.approve(address(predictionMarket), 1000 * 10**18);
        predictionMarket.buyShares(1, true, 100);

        uint256 finalBalance = predictionMarket.balanceOf(user1);
        (,,,, uint256 yesShares, uint256 noShares,) = predictionMarket.markets(1);

        assertEq(yesShares, 100, "Yes shares should be 100");
        assertEq(noShares, 0, "No shares should be 0");
        assertEq(finalBalance, initialBalance - 100 * 10**18, "Balance should decrease by 100 tokens");

        vm.stopPrank();
    }

    function testResolveMarket() public {
        predictionMarket.createMarket("Test market", 1 days);

        vm.warp(block.timestamp + 2 days);

        predictionMarket.resolveMarket(1, 1);  // Resolve as "Yes"

        (,, bool resolved, int256 outcome,,,) = predictionMarket.markets(1);
        assertTrue(resolved, "Market should be resolved");
        assertEq(outcome, 1, "Outcome should be Yes (1)");
    }

    function testClaimRewards() public {
        predictionMarket.createMarket("Test market", 1 days);

        vm.startPrank(user1);
        predictionMarket.approve(address(predictionMarket), 1000 * 10**18);
        predictionMarket.buyShares(1, true, 100);
        vm.stopPrank();

        vm.startPrank(user2);
        predictionMarket.approve(address(predictionMarket), 1000 * 10**18);
        predictionMarket.buyShares(1, false, 100);
        vm.stopPrank();

        vm.warp(block.timestamp + 2 days);
        predictionMarket.resolveMarket(1, 1);  // Resolve as "Yes"

        uint256 initialBalance = predictionMarket.balanceOf(user1);

        vm.prank(user1);
        predictionMarket.claimRewards(1);

        uint256 finalBalance = predictionMarket.balanceOf(user1);
        assertEq(finalBalance, initialBalance + 200 * 10**18, "Balance should increase by 200 tokens");
    }

    function testGetLatestPrice() public {
        uint256 price = predictionMarket.getLatestPrice();
        assertEq(price, 100 * 10**8, "Initial price should be 100");

        mockPriceFeed.setPrice(150 * 10**8);
        price = predictionMarket.getLatestPrice();
        assertEq(price, 150 * 10**8, "Updated price should be 150");
    }

    function testCannotBuySharesWithInsufficientBalance() public {
       predictionMarket.createMarket("Test market", 1 days);

       vm.startPrank(user1);
       uint256 balance = predictionMarket.balanceOf(user1);
       uint256 tooManyShares = balance / (10**18) + 1;

       vm.expectRevert("Insufficient balance");
       predictionMarket.buyShares(1, true, tooManyShares);

       vm.stopPrank();
   }

   function testCannotResolveMarketBeforeEndTime() public {
       predictionMarket.createMarket("Test market", 1 days);

       vm.expectRevert("Market has not ended yet");
       predictionMarket.resolveMarket(1, 1);
   }

   function testCannotClaimRewardsForUnresolvedMarket() public {
       predictionMarket.createMarket("Test market", 1 days);

       vm.startPrank(user1);
       predictionMarket.buyShares(1, true, 100);

       vm.expectRevert("Market not resolved yet");
       predictionMarket.claimRewards(1);

       vm.stopPrank();
   }

   function testFuzzBuyShares(uint256 _amount) public {
       vm.assume(_amount > 0 && _amount <= 1000);  // Assume a reasonable range
       predictionMarket.createMarket("Fuzz test market", 1 days);

       vm.startPrank(user1);
       predictionMarket.approve(address(predictionMarket), _amount * 10**18);
       predictionMarket.buyShares(1, true, _amount);

       (,,,, uint256 yesShares,,) = predictionMarket.markets(1);
       assertEq(yesShares, _amount, "Yes shares should match bought amount");

       vm.stopPrank();
   }
}