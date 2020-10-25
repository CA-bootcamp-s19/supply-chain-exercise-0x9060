// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

/// TESTING

contract TestSupplyChain {

    uint public initialBalance = 1 ether;
    SupplyChain supplyChain;
    UserAgent seller;
    UserAgent buyer;

    constructor() public payable {}

    // Run before each test
    function beforeEach() public {
        supplyChain = new SupplyChain();
        seller = new UserAgent(supplyChain);
        buyer = new UserAgent(supplyChain);

        address(buyer).transfer(1000);

        // Using widget item for all tests
        seller.addItem("widget", 500);
    }

    // buyItem Tests

    // test for failure if user does not send enough funds
    function testBuyerDidNotSendEnoughFunds() public {
	bool r = buyer.buyItem(0, 10);
        Assert.isFalse(r, "Buyer did not send enough funds");
    }


    // test for purchasing an item that is not for Sale
    function testPurchasedItemNotForSale() public {
	bool r = buyer.buyItem(1, 1000);
        Assert.isFalse(r, "Purchased item is not for sale");
    }

    // shipItem Tests

    // test for calls that are made by not the seller
    function testItemShippedByNotSeller() public {
	buyer.buyItem(0, 500);
	bool r = buyer.shipItem(0);
        Assert.isFalse(r, "Purchased item must be shipped by seller");
    }
    
    // test for trying to ship an item that is not marked Sold
    function testShippedItemIsNotSold() public {
	bool r = seller.shipItem(0);
        Assert.isFalse(r, "Shipped item must be sold first");
    }
 
    // receiveItem Tests

    // test calling the function from an address that is not the buyer
    function testItemReceivedByNotBuyer() public {
	buyer.buyItem(0, 500);
	seller.shipItem(0);
	bool r = seller.receiveItem(0);
        Assert.isFalse(r, "Shipped item can only be received by buyer");
    }

    // test calling the function on an item not marked Shipped
    function testReceivedItemIsNotShipped() public {
	buyer.buyItem(0, 500);
	bool r = buyer.receiveItem(0);
        Assert.isFalse(r, "Only shipped items can be received");
    }

}


// Contract User
contract UserAgent {

    SupplyChain thisChain;
    
    constructor(SupplyChain _supplyChain) public payable {
	thisChain = _supplyChain;
    }

    function () external payable {}

    function addItem(string memory _name, uint _price) public returns(bool) {
        (bool success, ) = address(thisChain).call(abi.encodeWithSignature("addItem(string,uint256)", _name, _price));
        return success;
    }

    function shipItem(uint _sku) public returns(bool) {
        (bool success, ) = address(thisChain).call(abi.encodeWithSignature("shipItem(uint256)", _sku));
        return success;
    }

    function buyItem(uint _sku, uint amount) public returns(bool) {
        (bool success, ) = address(thisChain).call.value(amount)(abi.encodeWithSignature("buyItem(uint256)", _sku));
        return success;
    }

    function receiveItem(uint _sku) public returns(bool) {
        (bool success, ) = address(thisChain).call(abi.encodeWithSignature("receiveItem(uint256)", _sku));
        return success;
    }

}
