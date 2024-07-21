// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract PredictionMarket is ERC20, Ownable {
    struct Market {
        string question;
        uint256 endTime;
        bool resolved;
        int256 outcome;
        uint256 yesShares;
        uint256 noShares;
        uint256 totalStake;
    }

    mapping(uint256 => Market) public markets;
    uint256 public marketCount;

    mapping(uint256 => mapping(address => uint256)) public userYesShares;
    mapping(uint256 => mapping(address => uint256)) public userNoShares;

    AggregatorV3Interface internal priceFeed;

    event MarketCreated(uint256 indexed marketId, string question, uint256 endTime);
    event SharesPurchased(uint256 indexed marketId, address user, bool isYes, uint256 amount);
    event MarketResolved(uint256 indexed marketId, int256 outcome);
    event RewardsClaimed(uint256 indexed marketId, address user, uint256 amount);
    event MarketCancelled(uint256 indexed marketId);

    constructor(address _priceFeed) ERC20("Prediction Token", "PRED") Ownable(msg.sender) {
        priceFeed = AggregatorV3Interface(_priceFeed);
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function createMarket(string memory _question, uint256 _duration) external onlyOwner {
        marketCount++;
        markets[marketCount] = Market({
            question: _question,
            endTime: block.timestamp + _duration,
            resolved: false,
            outcome: 0,
            yesShares: 0,
            noShares: 0,
            totalStake: 0
        });

        emit MarketCreated(marketCount, _question, block.timestamp + _duration);
    }

    function buyShares(uint256 _marketId, bool _isYes, uint256 _amount) external {
        require(_marketId <= marketCount && _marketId > 0, "Invalid market ID");
        require(!markets[_marketId].resolved, "Market already resolved");
        require(block.timestamp < markets[_marketId].endTime, "Market has ended");

        uint256 stake = _amount * (10**decimals());
        require(balanceOf(msg.sender) >= stake, "Insufficient balance");

        _transfer(msg.sender, address(this), stake);
        markets[_marketId].totalStake += stake;

        if (_isYes) {
            userYesShares[_marketId][msg.sender] += _amount;
            markets[_marketId].yesShares += _amount;
        } else {
            userNoShares[_marketId][msg.sender] += _amount;
            markets[_marketId].noShares += _amount;
        }

        emit SharesPurchased(_marketId, msg.sender, _isYes, _amount);
    }

    function claimRewards(uint256 _marketId) external {
        require(markets[_marketId].resolved, "Market not resolved yet");
        
        uint256 reward;
        if (markets[_marketId].outcome > 0) {
            reward = userYesShares[_marketId][msg.sender];
            userYesShares[_marketId][msg.sender] = 0;
        } else {
            reward = userNoShares[_marketId][msg.sender];
            userNoShares[_marketId][msg.sender] = 0;
        }

        require(reward > 0, "No rewards to claim");

        uint256 totalShares = markets[_marketId].outcome > 0 ? markets[_marketId].yesShares : markets[_marketId].noShares;
        uint256 tokenReward = (reward * markets[_marketId].totalStake) / totalShares;

        _transfer(address(this), msg.sender, tokenReward);

        emit RewardsClaimed(_marketId, msg.sender, tokenReward);
    }

    function resolveMarket(uint256 _marketId, int256 _outcome) external onlyOwner {
        require(_marketId <= marketCount && _marketId > 0, "Invalid market ID");
        require(!markets[_marketId].resolved, "Market already resolved");
        require(block.timestamp >= markets[_marketId].endTime, "Market has not ended yet");

        markets[_marketId].resolved = true;
        markets[_marketId].outcome = _outcome;

        emit MarketResolved(_marketId, _outcome);
    }

    function cancelMarket(uint256 _marketId) external onlyOwner {
       require(_marketId <= marketCount && _marketId > 0, "Invalid market ID");
       require(!markets[_marketId].resolved, "Market already resolved");
       require(block.timestamp < markets[_marketId].endTime, "Market has ended");

       markets[_marketId].resolved = true;
       markets[_marketId].outcome = 0; // 0 indicates cancelled

       // Refund all participants
       uint256 totalShares = markets[_marketId].yesShares + markets[_marketId].noShares;
       for (uint256 i = 0; i < totalShares; i++) {
           address participant = getParticipant(_marketId, i);
           uint256 refund = (userYesShares[_marketId][participant] + userNoShares[_marketId][participant]) * (10**decimals());
           _transfer(address(this), participant, refund);
       }

       emit MarketCancelled(_marketId);
   }

   function getParticipant(uint256 _marketId, uint256 _index) internal view returns (address) {
       // Implementation depends on how you want to store/retrieve participants
   }
   
    function getLatestPrice() public view returns (uint256) {
        (,int256 price,,,) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price feed response");
        return uint256(price);
    }
}