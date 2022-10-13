// SPDX-License-Identifier: MIT
//Pragma
pragma solidity ^0.8.8;
//Imports
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol";

//Error Codes
error FundMe__NotOwner();

//Interfaces, Libraries, Contracts

/** @title A contract for crowd funding
 * @author Mike Novajosky
 * @notice This contract is used to demo a sample funding contract
 * @dev This implements price feeds as out library
 */

contract FundMe {
    //Type declarations
    using PriceConverter for uint256;

    //State Variables
    mapping(address => uint256) public s_addressToAmountFunded;
    address[] public s_funders;
    address public immutable i_owner;
    uint256 public constant MINIMUM_USD = 50 * 10**18;
    AggregatorV3Interface public s_priceFeed;

    modifier onlyOwner() {
        // require(msg.sender == owner);
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    //Functions

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    // receive() external payable {
    //     fund();
    // }

    // fallback() external payable {
    //     fund();
    // }

    /**
    * @notice This function funds the contract
    * @dev This implements price feeds as our library
    */

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= MINIMUM_USD,
            "You need to spend more ETH!"
        );
        // require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "You need to spend more ETH!");
        s_addressToAmountFunded[msg.sender] += msg.value;
        s_funders.push(msg.sender);
    }

    function withdraw() public payable onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // // transfer
        // payable(msg.sender).transfer(address(this).balance);
        // // send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // call
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call failed");
    }

    function cheaperWithdraw() public payable onlyOwner{
        address[] memory funders = s_funders;
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }
}
