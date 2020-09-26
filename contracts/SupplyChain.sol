// SPDX-License-Identifier: GPL-3.0-or-later
/*
  This exercise has been updated to use Solidity version 0.5
  Breaking changes from 0.4 to 0.5 can be found here:
  https://solidity.readthedocs.io/en/v0.5.0/050-breaking-changes.html
*/

pragma solidity ^0.5.0;

contract SupplyChain {

    address owner;
    uint skuCount;
    mapping (uint => Item) public items;
    enum State { ForSale, Sold, Shipped, Received }
    struct Item {
        string name;
        uint sku;
        uint price;
        State state;
        address payable seller;
        address payable buyer;
    }

    event LogForSale(uint indexed sku);
    event LogSold(uint indexed sku);
    event LogShipped(uint indexed sku);
    event LogReceived(uint indexed sku);

    /* Create a modifer that checks if the msg.sender is the owner of the contract */
    modifier contractOwner () {
        require(msg.sender == owner, "You're not the contract owner");
        _;
    }

    modifier verifyCaller (address _address) { require (msg.sender == _address); _;}

    modifier paidEnough(uint _price) { require(msg.value >= _price); _;}

    modifier checkValue(uint _sku) {
        _;
        uint _price = items[_sku].price;
        uint amountToRefund = msg.value - _price;
        items[_sku].buyer.transfer(amountToRefund);
    }

    /* For each of the following modifiers, use what you learned about modifiers
       to give them functionality. For example, the forSale modifier should require
       that the item with the given sku has the state ForSale.
       Note that the uninitialized Item.State is 0, which is also the index of the ForSale value,
       so checking that Item.State == ForSale is not sufficient to check that an Item is for sale.
       Hint: What item properties will be non-zero when an Item has been added?
    */
    modifier forSale(uint _sku) {
        require(uint(items[_sku].state) == 0 && items[_sku].price > 0, "Item is not for sale");
        _;
    }

    modifier sold(uint _sku) {
        require(uint(items[_sku].state) == 1, "Item is not sold");
        _;
    }

    modifier shipped(uint _sku) {
        require(uint(items[_sku].state) == 2, "Item is not shipped");
        _;
    }

    modifier received(uint _sku) {
        require(uint(items[_sku].state) == 3, "Item is not received");
        _;
    }


    constructor() public {
        owner = msg.sender;
        skuCount = 0;
    }

    function addItem(string memory _name, uint _price) public returns(bool){
        items[skuCount] = Item({name: _name, sku: skuCount, price: _price, state: State.ForSale, seller: msg.sender, buyer: address(0)});
        emit LogForSale(skuCount);
        skuCount = skuCount + 1;
        return true;
    }

    /* Add a keyword so the function can be paid. This function should transfer money
       to the seller, set the buyer as the person who called this transaction, and set the state
       to Sold. Be careful, this function should use 3 modifiers to check if the item is for sale,
       if the buyer paid enough, and check the value after the function is called to make sure the buyer is
       refunded any excess ether sent. Remember to call the event associated with this function!*/
    function buyItem(uint sku)
        public
        payable
        forSale(sku)
        paidEnough(items[sku].price)
        checkValue(sku)
    {
	items[sku].buyer = msg.sender;
	items[sku].seller.transfer(items[sku].price);
	items[sku].state = State(1);
        emit LogSold(sku);
    }

    /* Add 2 modifiers to check if the item is sold already, and that the person calling this function
       is the seller. Change the state of the item to shipped. Remember to call the event associated with this function!*/
    function shipItem(uint sku)
        public
	sold(sku)
	verifyCaller(items[sku].seller)
    {
	items[sku].state = State(2);
        emit LogShipped(sku);
    }

    /* Add 2 modifiers to check if the item is shipped already, and that the person calling this function
       is the buyer. Change the state of the item to received. Remember to call the event associated with this function!*/
    function receiveItem(uint sku)
        public
	shipped(sku)
	verifyCaller(items[sku].buyer)
    {
	items[sku].state = State(3);
        emit LogReceived(sku);
    }

    /* We have these functions completed so we can run tests, just ignore it :) */
    function fetchItem(uint _sku) public view returns (string memory name, uint sku, uint price, uint state, address seller, address buyer) {
        name = items[_sku].name;
        sku = items[_sku].sku;
        price = items[_sku].price;
        state = uint(items[_sku].state);
        seller = items[_sku].seller;
        buyer = items[_sku].buyer;
        return (name, sku, price, state, seller, buyer);
    }

}
