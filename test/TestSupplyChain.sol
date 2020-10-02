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
    UserAgent seller;
    UserAgent buyer;

    // Run before each test function
    function beforeEach() public {
        supplyChain = new SupplyChain();
        throwProxy = new ThrowProxy(address(supplyChain));
        seller = new  UserAgent();
        buyer = (new UserAgent).value(1000)();

        // Common operations
        //SupplyChain(address(throwProxy)).addItem("widget2", 50 wei);
        supplyChain.addItem("widget2", 50 wei);
        seller.addItem(supplyChain, "widget", 99 wei);
        buyer.fetchItem(supplyChain, 0);
    }

    // buyItem

    // test for failure if user does not send enough funds
    function testBuyerSendsNotEnoughFunds() public payable {

        //seller.addItem(supplyChain, "butter", 888 wei);
        //buyer.fetchItem(supplyChain, 1);

        //buyer.buyItem(supplyChain, 0, 100 wei);
        //buyer.buyItem(supplyChain, 0, 100 wei);
        //Assert.equal(uint(5), uint(4), "Stop");

        //Assert.isFalse(r, "buyer should send enough funds");
    }

    // test for purchasing an item that is not for Sale
    function testPurchasedItemNotForSale() public {
        // seller.addItem(supplyChain, "butter", 888 wei);
        // buyer.buyItem(supplyChain, 0, 100 wei);
        //buyer.buyItem(supplyChain, 0, 100 wei);
        //supplyChain.buyItem(4);
        SupplyChain(address(throwProxy)).buyItem(4);

        bool r = throwProxy.execute.gas(2000000)();

        //Assert.isFalse(r, "Should be false");
        Assert.isFalse(r, "Should be false");
    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}


/// Helper Functions

// Fake Contract User
contract UserAgent {

    event LogFetchedPrice(uint indexed price);

    constructor() public payable {}

    function addItem(SupplyChain _supplyChain, string memory _item, uint _price) public {
        _supplyChain.addItem(_item, _price);
    }

    function shipItem(SupplyChain _supplyChain, uint _sku) public {
        _supplyChain.shipItem(_sku);
    }

    function buyItem(SupplyChain _supplyChain, uint _sku, uint amount) public {
        _supplyChain.buyItem.value(amount)(_sku);
    }

    function receiveItem(SupplyChain _supplyChain, uint _sku) public {
        _supplyChain.receiveItem(_sku);
    }

    function fetchItem(SupplyChain _supplyChain, uint _sku) public {
        (,,uint price,,,) = _supplyChain.fetchItem(_sku);

        emit LogFetchedPrice(price);
    }

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
