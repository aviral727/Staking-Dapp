// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Staking {
    address public owner;
    uint public ethUsdPrice;
    uint public usdPrice;
    uint public currentPositionId;
    address public tokenAddress;
    uint public apy;
    uint netStakedTokens;

    mapping(address => Position) public addressToPosition;
    mapping(uint => address) public positionIdToAddress;

    constructor(
        uint currentEthPrice,
        address _tokenAdress,
        uint _apy
    ) payable {
        ethUsdPrice = currentEthPrice;
        apy = _apy;
        tokenAddress = _tokenAdress;
        netStakedTokens = 0;
        currentPositionId = 1;
        owner = msg.sender;
    }

    // struct Token {
    //     uint tokenId;
    //     string name;
    //     string symbol;
    //     address tokenAddress;
    //     uint usdPrice;
    //     uint ethPrice;
    //     uint apy;
    // }

    struct Position {
        address walletAddress;
        uint createDate;
        uint positionId;
        uint tokenQuantity;
        uint usdValue;
        uint ethValue;
        bool open;
    }

    Position[] public positionDB;

    function stakeTokens(uint tokenQuantity) external {
        require(
            addressToPosition[msg.sender].open == false,
            "Close your staked position first"
        );
        IERC20(tokenAddress).transferFrom(
            msg.sender,
            address(this),
            tokenQuantity
        );

        addressToPosition[msg.sender] = Position(
            msg.sender,
            block.timestamp,
            currentPositionId,
            tokenQuantity,
            usdPrice * tokenQuantity,
            (usdPrice * tokenQuantity) / ethUsdPrice,
            true
        );

        addressToPosition[msg.sender].positionId = currentPositionId;
        positionIdToAddress[currentPositionId] = msg.sender;
        currentPositionId += 1;

        netStakedTokens += tokenQuantity;

        // positionDB.push();
    }

    function getPositionIdByAddress() external view returns (uint) {
        return addressToPosition[msg.sender].positionId;
    }

    function getAddressByPositionId(uint _id) external view returns (address) {
        return positionIdToAddress[_id];
    }

    function queryStakedTokens(uint _id) external view returns (uint) {
        return addressToPosition[positionIdToAddress[_id]].tokenQuantity;
    }

    function queryRewards(uint _id) external view returns (uint) {
        uint numberDays = calculateNumberDays(
            addressToPosition[positionIdToAddress[_id]].createDate
        );
        return
            calculateInterest(
                addressToPosition[positionIdToAddress[_id]].ethValue,
                numberDays
            );
    }

    function closePosition() external {
        uint numberDays = calculateNumberDays(
            addressToPosition[msg.sender].createDate
        );

        require(
            addressToPosition[msg.sender].open,
            "You don't have an open position."
        );
        require(
            numberDays > 1,
            "Wait for atleast 1 day before closing your position."
        );

        addressToPosition[msg.sender].open == false;

        IERC20(tokenAddress).transfer(
            msg.sender,
            addressToPosition[msg.sender].tokenQuantity
        );

        uint weiAmount = calculateInterest(
            addressToPosition[msg.sender].ethValue,
            numberDays
        );

        payable(msg.sender).call{value: weiAmount}("");
    }

    function returnPositions() public returns (Position[] memory) {
        for (uint i = 1; i <= currentPositionId; i++) {
            positionDB[i] = addressToPosition[positionIdToAddress[i]];
        }
        return positionDB;
    }

    function calculateInterest(uint value, uint _numberDays)
        public
        view
        returns (uint)
    {
        return (apy * value * _numberDays) / 10000 / 365;
    }

    function modifyCreateDate(uint positionId, uint newCreateDate)
        external
        onlyOwner
    {
        addressToPosition[positionIdToAddress[positionId]]
            .createDate = newCreateDate;
    }

    function calculateNumberDays(uint _createDate) public view returns (uint) {
        return (block.timestamp - _createDate) / 60 / 60 / 24;
    }

    modifier onlyOwner() {
        require(owner == msg.sender, "Only owner may call this function");
        _;
    }
}
