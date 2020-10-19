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
    function beforeEachAgain() public {
        supplyChain = new SupplyChain();
        seller = new UserAgent();
        buyer = new UserAgent();

        address(buyer).transfer(100);

        // Common operations
        seller.addItem(supplyChain, "lemming", 500 wei);
        seller.addItem(supplyChain, "widget", 50 wei);
    }

    // buyItem

    // test for failure if user does not send enough funds

    // test for purchasing an item that is not for Sale
    function testPurchasedItemNotForSale() public {
	bool r = buyer.buyItem(supplyChain, 5, 1000);
        //SupplyChain(address(throwProxy)).buyItem(1);
        //bool r = throwProxy.execute.gas(2000000)();
        Assert.isFalse(r, "Should be false");
    }

    // shipItem

    // test for calls that are made by not the seller
    // test for trying to ship an item that is not marked Sold

    // receiveItem

    // test calling the function from an address that is not the buyer
    // test calling the function on an item not marked Shipped

}


// Contract User
contract UserAgent {

    constructor() public payable {}

    function () external payable {}

    function addItem(SupplyChain _supplyChain, string memory _item, uint _price) public {
        _supplyChain.addItem(_item, _price);
    }

    function shipItem(SupplyChain _supplyChain, uint _sku) public {
        _supplyChain.shipItem(_sku);
    }

    function buyItem(SupplyChain _supplyChain, uint _sku, uint amount) public returns (bool) {
        (bool success, ) = address(_supplyChain).call.value(amount)(abi.encodeWithSignature("buyItem(uint256)", _sku));
        return success;
    }

    function receiveItem(SupplyChain _supplyChain, uint _sku) public {
        _supplyChain.receiveItem(_sku);
    }

    function fetchItem(SupplyChain _supplyChain, uint _sku) public {
        (,,uint price,,,) = _supplyChain.fetchItem(_sku);
    }

}
