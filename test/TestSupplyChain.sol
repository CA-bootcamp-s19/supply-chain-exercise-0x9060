// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

/// TESTING

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    uint public initialBalance = 2 ether;
    SupplyChain supplyChain;
    ThrowProxy throwProxy;

    // Run before each test
    function beforeEachAgain() public {
        supplyChain = new SupplyChain();
        throwProxy = new ThrowProxy(address(supplyChain));

        // Common operations
        supplyChain.addItem("lemmings", 500 ether);
        supplyChain.addItem("widget", 50 wei);
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testBuyerSendsNotEnoughFunds() public payable {
        SupplyChain(address(throwProxy)).buyItem(0);
        bool r = throwProxy.execute.gas(2000000)();
        Assert.isFalse(r, "Should be false");
    }

    // test for purchasing an item that is not for Sale
    function testPurchasedItemNotForSale() public {
        SupplyChain(address(throwProxy)).buyItem(1);
        bool r = throwProxy.execute.gas(2000000)();
        Assert.isFalse(r, "Should be false");
    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}


// Proxy for testing Throws
contract ThrowProxy {
    address public target;
    bytes data;

    constructor(address _target) public {
        target = _target;
    }

    // prime the data using fallback
    function() external {
        data = msg.data;
    }

    function execute() public returns(bool) {
        (bool ret, ) = target.call(data);
        return ret;
    }
}
