// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.5.0;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/SupplyChain.sol";

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

contract TestSupplyChain {

    // Test for failing conditions in this contracts:
    // https://truffleframework.com/tutorials/testing-for-throws-in-solidity-tests

    SupplyChain public supplyChain;
    ThrowProxy public throwproxy;

    // Run before each test function
    function beforeEach() public {
        throwProxy = new ThrowProxy(address(supplyChain));

        supplyChain = new SupplyChain();
        supplyChain.addItem("widget", 1000);
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testBuyerSendsNotEnoughFunds() public payable {

        // prime the proxy
        SupplyChain(address(throwProxy)).buyItem(0);

        bool r = throwProxy.execute.gas(200000)();

        Assert.isTrue(r, "buyer should send enough funds");
    }

    // test for purchasing an item that is not for Sale
    // function testPurchasedItemNotForSale() public {}

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}
