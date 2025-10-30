// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title BlockTicket - Immutable Ticket Ownership Record
/// @author 
/// @notice Stores and tracks ownership of unique event tickets immutably on-chain
/// @dev Uses ERC721-like logic without importing external libraries

contract BlockTicket {
    struct Ticket {
        uint256 id;
        string eventName;
        address originalOwner;
        address currentOwner;
        uint256 issueDate;
    }

    // Mapping of ticket ID to Ticket details
    mapping(uint256 => Ticket) private tickets;

    // Mapping to track all ownership history
    mapping(uint256 => address[]) private ownershipHistory;

    // Counter for ticket IDs
    uint256 private nextTicketId;

    // Events
    event TicketIssued(uint256 indexed ticketId, string eventName, address indexed owner);
    event OwnershipTransferred(uint256 indexed ticketId, address indexed from, address indexed to);

    /// @notice Issue a new ticket
    /// @param eventName The name of the event
    /// @param to The address receiving the ticket
    function issueTicket(string memory eventName, address to) external {
        require(to != address(0), "Invalid address");

        uint256 ticketId = ++nextTicketId;
        Ticket memory newTicket = Ticket({
            id: ticketId,
            eventName: eventName,
            originalOwner: to,
            currentOwner: to,
            issueDate: block.timestamp
        });

        tickets[ticketId] = newTicket;
        ownershipHistory[ticketId].push(to);

        emit TicketIssued(ticketId, eventName, to);
    }

    /// @notice Transfer ticket ownership
    /// @param ticketId The ID of the ticket
    /// @param to The address receiving the ticket
    function transferTicket(uint256 ticketId, address to) external {
        require(to != address(0), "Invalid recipient");
        require(tickets[ticketId].id != 0, "Ticket does not exist");
        require(msg.sender == tickets[ticketId].currentOwner, "Not ticket owner");

        address from = tickets[ticketId].currentOwner;
        tickets[ticketId].currentOwner = to;
        ownershipHistory[ticketId].push(to);

        emit OwnershipTransferred(ticketId, from, to);
    }

    /// @notice Get current owner of a ticket
    /// @param ticketId The ID of the ticket
    function getCurrentOwner(uint256 ticketId) external view returns (address) {
        require(tickets[ticketId].id != 0, "Ticket does not exist");
        return tickets[ticketId].currentOwner;
    }

    /// @notice Get full ownership history of a ticket
    /// @param ticketId The ID of the ticket
    function getOwnershipHistory(uint256 ticketId) external view returns (address[] memory) {
        require(tickets[ticketId].id != 0, "Ticket does not exist");
        return ownershipHistory[ticketId];
    }

    /// @notice Get ticket details
    /// @param ticketId The ID of the ticket
    function getTicket(uint256 ticketId)
        external
        view
        returns (string memory eventName, address originalOwner, address currentOwner, uint256 issueDate)
    {
        require(tickets[ticketId].id != 0, "Ticket does not exist");
        Ticket memory t = tickets[ticketId];
        return (t.eventName, t.originalOwner, t.currentOwner, t.issueDate);
    }
}
