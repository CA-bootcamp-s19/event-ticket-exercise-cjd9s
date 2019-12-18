pragma solidity ^0.5.0;

    /*
        The EventTicketsV2 contract keeps track of the details and ticket sales of multiple events.
     */
contract EventTicketsV2 {

    /*
        DONE Define an public owner variable. Set it to the creator of the contract when it is initialized.
    */

    address payable public owner = msg.sender;

    uint   PRICE_TICKET = 100 wei;

    /*
        ???? Create a variable to keep track of the event ID numbers.
    */

    uint eventIdNumbers;
    //new uint eventIdNumbers[];
	//uint[] memory a = new uint [](<variable length>);


    uint public idGenerator;

    /*
        DONE Define an Event struct, similar to the V1 of this contract.
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

    /*
        DONE Create a mapping to keep track of the events.
        DONE The mapping key is an integer, the value is an Event struct.
        DONE Call the mapping "events".
    */
    mapping (uint => Event) events;


    event LogEventAdded(string desc, string url, uint ticketsAvailable, uint eventId);
    event LogBuyTickets(address buyer, uint eventId, uint numTickets);
    event LogGetRefund(address accountRefunded, uint eventId, uint numTickets);
    event LogEndSale(address owner, uint balance, uint eventId);

    /*
        Create a modifier that throws an error if the msg.sender is not the owner.
    */
    modifier onlyOwner {
        require (msg.sender == owner, 'message sender not the owner');
        _;
    }

    /*
        DONE Define a function called addEvent().
        DONE This function takes 3 parameters, an event description, a URL, and a number of tickets.
        DONE Only the contract owner should be able to call this function.
        In the function:
            - DONE Set the description, URL and ticket number in a new event.
            - DONE set the event to open
            - DONE set an event ID
            - DONE increment the ID
            - DONE emit the appropriate event
            - DONE return the event's ID
    */
    function addEvent(string memory _eventDescription, string memory _URL, uint _numberOfTickets)
    public
    onlyOwner
    returns (uint)

    {
        uint eventId = eventIdNumbers;
        events[eventId].description = _eventDescription;
        events[eventId].website = _URL;
        events[eventId].totalTickets = _numberOfTickets;
        events[eventId].isOpen = true;

        emit LogEventAdded(_eventDescription, _URL, _numberOfTickets, eventId);
        eventIdNumbers += 1;

        return eventId;
    }

    /*
        DONE Define a function called readEvent().
        DONE This function takes one parameter, the event ID.
        The function returns information about the event this order:
            1. description
            2. URL
            3. tickets available
            4. sales
            5. isOpen
    */
    function readEvent(uint eventId)
    public
    view
    returns(string memory description, string memory website, uint totalTickets, uint sales, bool isOpen)
    {
        string memory desc = events[eventId].description;
        string memory web = events[eventId].website;
        uint total = events[eventId].totalTickets;
        uint sold = events[eventId].sales;
        bool open = events[eventId].isOpen;

        return (desc, web, total, sold, open);
    }

    /*
        DONE Define a function called buyTickets().
        This function allows users to buy tickets for a specific event.
        DONE This function takes 2 parameters, an event ID and a number of tickets.
        The function checks:
            - DONE that the event sales are open
            - DONE that the transaction value is sufficient to purchase the number of tickets
            - DONE that there are enough tickets available to complete the purchase
        The function:
            - DONE increments the purchasers ticket count
            - DONE increments the ticket sale count
            - DONE refunds any surplus value sent
            - DONE emits the appropriate event
    */
    function buyTickets(uint eventId, uint numberOfTickets)
    public
    payable
    {
        require (events[eventId].isOpen == true, 'sales not open');
        require (msg.value >= numberOfTickets * PRICE_TICKET, 'not enough money to buy tickets');
        require (numberOfTickets <= events[eventId].totalTickets - events[eventId].sales, 'not enough tickets available');

        events[eventId].buyers[msg.sender] += numberOfTickets;
        events[eventId].sales += numberOfTickets;
        msg.sender.transfer(msg.value - numberOfTickets*PRICE_TICKET);

        emit LogBuyTickets(msg.sender, eventId, numberOfTickets);
    }
    /*
        DONE Define a function called getRefund().
        This function allows users to request a refund for a specific event.
        DONE This function takes one parameter, the event ID.
        TODO:
            - DONE check that a user has purchased tickets for the event
            - DONE remove refunded tickets from the sold count
            - DONE send appropriate value to the refund requester
            - DONE emit the appropriate event
    */
    function getRefund(uint eventId)
    public
    payable
    {
        require (events[eventId].buyers[msg.sender] > 0, "You don't have any tickets");
        events[eventId].sales -= events[eventId].buyers[msg.sender];
        msg.sender.transfer(events[eventId].buyers[msg.sender]*PRICE_TICKET);
        emit LogGetRefund(msg.sender, eventId, events[eventId].buyers[msg.sender]);

    }
    /*
        DONE Define a function called getBuyerNumberTickets()
        DONE This function takes one parameter, an event ID
        DONE This function returns a uint, the number of tickets that the msg.sender has purchased.
    */
    function getBuyerNumberTickets(uint eventId)
    public
    view
    returns (uint)
    {
        return events[eventId].buyers[msg.sender];
    }

    /*
        DONE Define a function called endSale()
        DONE This function takes one parameter, the event ID
        DONE Only the contract owner can call this function
        TODO:
            - DONE close event sales
            - DONE transfer the balance from those event sales to the contract owner
            - emit the appropriate event
    */
    function endSale(uint eventId)
    public
    payable
    onlyOwner
    {
        events[eventId].isOpen = false;
        owner.transfer(events[eventId].sales*PRICE_TICKET);
        emit LogEndSale(owner, events[eventId].sales*PRICE_TICKET, eventId);
    }
}
