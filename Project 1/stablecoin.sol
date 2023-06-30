// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract nUSD {
    string public name = "nUSD Stablecoin";
    string public symbol = "nUSD";
    uint8 public decimals = 18;
    
    mapping(address => uint256) public balances;
    uint256 public totalSupply;
    AggregatorV3Interface private priceFeed;
    
    constructor(address _priceFeedAddress) {
        priceFeed = AggregatorV3Interface(_priceFeedAddress);
    }
    
    event Deposit(address indexed account, uint256 ethAmount, uint256 nusdAmount);
    event Redeem(address indexed account, uint256 nusdAmount, uint256 ethAmount);
    
    function deposit() external payable {
        require(msg.value > 0, "ETH amount must be greater than zero.");
        
        uint256 ethPrice = getETHPrice();
        uint256 nusdAmount = (msg.value * 50 * 10**decimals) / (ethPrice * 100);
        balances[msg.sender] += nusdAmount;
        totalSupply += nusdAmount;
        
        emit Deposit(msg.sender, msg.value, nusdAmount);
    }
    
    function redeem(uint256 nusdAmount) external {
        require(nusdAmount > 0, "nUSD amount must be greater than zero.");
        require(balances[msg.sender] >= nusdAmount, "Insufficient nUSD balance.");
        
        uint256 ethPrice = getETHPrice();
        uint256 ethAmount = (nusdAmount * 2 * ethPrice) / (10**decimals);
        
        balances[msg.sender] -= nusdAmount;
        totalSupply -= nusdAmount;
        
        (bool success, ) = msg.sender.call{value: ethAmount}("");
        require(success, "ETH transfer failed.");
        
        emit Redeem(msg.sender, nusdAmount, ethAmount);
    }
    
    function getETHPrice() private view returns (uint256) {
        (, int256 price, , , ) = priceFeed.latestRoundData();
        require(price > 0, "Invalid price");
        return uint256(price);
    }
}

// Contract Address = 0x457042Bc9996c3fBe9A989C66e39DC10d8c0237f
// On Goerli Testnet contract is deployed