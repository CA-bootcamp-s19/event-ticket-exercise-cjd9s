pragma solidity ^0.5.0;

    /*
        The EventTickets contract keeps track of the details and ticket sales of one event.
     */

contract EventTickets {

    /*
        Done Create a public state variable called owner.
        Done Use the appropriate keyword to create an associated getter function.
        Done Use the appropriate keyword to allow ether transfers.
     */
    address payable public owner;

    uint   TICKET_PRICE = 100 wei;

    /*
        DONE Create a struct called "Event".
        DONE The struct has 6 fields: description, website (URL), totalTickets, sales, buyers, and isOpen.
        DONE Choose the appropriate variable type for each field.
        DONE The "buyers" field should keep track of addresses and how many tickets each buyer purchases.
    */
    struct Event {
        string description;
        string website;
        uint totalTickets;
        uint sales;
        mapping (address => uint) buyers;
        bool isOpen;
    }
    Event myEvent;

    /*
        Define 3 logging events.
        DONE LogBuyTickets should provide information about the purchaser and the number of tickets purchased.
        DONE LogGetRefund should provide information about the refund requester and the number of tickets refunded.
        DONE LogEndSale should provide infromation about the contract owner and the balance transferred to them.
    */
    event LogBuyTickets(address purchaser, uint numberOfTicketsPurchased);
    event LogGetRefund(address refundee, uint numberOfTicketsRefunded);
    event LogEndSale(address owner, uint balanceTransferred);

    /*
        DONE Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier verifyOwner() {
        require (msg.sender == owner, "message sender doesn't equal owner address");
        _;
    }

    /*
        Define a constructor.
        DONE The constructor takes 3 arguments, the description, the URL and the number of tickets for sale.
        DONE Set the owner to the creator of the contract.
        DONE Set the appropriate myEvent details.
    */
    constructor(string memory _description, string memory _website, uint _numberOfTicketsForSale) public {
        owner = msg.sender;
        myEvent.description = _description;
        myEvent.website = _website;
        myEvent.totalTickets = _numberOfTicketsForSale;
        myEvent.isOpen = true;
    }
    /*
        DONE Define a function called readEvent() that returns the event details.
        DONE This function does not modify state, add the appropriate keyword.
        DONE The returned details should be called description, website, uint totalTickets, uint sales, bool isOpen in that order.
    */
    function readEvent()
        public
        view
        returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        return (myEvent.description, myEvent.website, myEvent.totalTickets, myEvent.sales, myEvent.isOpen);
    }

    /*
        DONE Define a function called getBuyerTicketCount().
        DONE This function takes 1 argument, an address and
        DONE returns the number of tickets that address has purchased.
    */
    function getBuyerTicketCount (address _purchaserAddress)
        public
        view
        returns (uint _numberOfTicketsPurchased)
    {
        return (myEvent.buyers[_purchaserAddress]);
    }

    /*
        DONE Define a function called buyTickets().
        This function allows someone to purchase tickets for the event.
        DONE This function takes one argument, the number of tickets to be purchased.
        DONE This function can accept Ether.
        Be sure to check:
        DONE    - That the event isOpen
        DONE    - That the transaction value is sufficient for the number of tickets purchased
        DONE    - That there are enough tickets in stock
        Then:
            - DONE add the appropriate number of tickets to the purchasers count
            - DONE account for the purchase in the remaining number of available tickets
            - DONE refund any surplus value sent with the transaction
            - DONE emit the appropriate event
    */
    function buyTickets(uint numberOfTickets)
    public
    payable
    {
        require (myEvent.isOpen == true, 'Sale not open');
        require (msg.value >= numberOfTickets*TICKET_PRICE, 'Not enough money supplied for required tickets');
        require (numberOfTickets <= myEvent.totalTickets - myEvent.sales, 'Not enough tickets to meet order');

        myEvent.buyers[msg.sender] = getBuyerTicketCount(msg.sender) + numberOfTickets;
        myEvent.sales += numberOfTickets;
        msg.sender.transfer(msg.value - numberOfTickets*TICKET_PRICE);
        emit LogBuyTickets(msg.sender, numberOfTickets);
    }
    /*
        DONE Define a function called getRefund().
        This function allows someone to get a refund for tickets for the account they purchased from.
        TODO:
            - DONE Check that the requester has purchased tickets.
            - DONE Make sure the refunded tickets go back into the pool of avialable tickets.
            - DONE Transfer the appropriate amount to the refund requester.
            - DONE Emit the appropriate event.
    */

    function getRefund()
    public
    payable
    {
        require (myEvent.buyers[msg.sender] > 0, 'not owner');
        myEvent.sales -= myEvent.buyers[msg.sender];
        msg.sender.transfer(myEvent.buyers[msg.sender]*TICKET_PRICE);
        emit LogGetRefund(msg.sender, myEvent.buyers[msg.sender]);
    }
    /*
        Define a function called endSale().
        This function will close the ticket sales.
        DONE This function can only be called by the contract owner.
        TODO:
            - DONE close the event
            - DONE transfer the contract balance to the owner
            - emit the appropriate event
    */

    function endSale()
    public
    {
        require (msg.sender == owner, 'not owner');
        myEvent.isOpen = false;
        owner.transfer(myEvent.sales*TICKET_PRICE);
        emit LogEndSale(owner, myEvent.sales*TICKET_PRICE);
    }
}
