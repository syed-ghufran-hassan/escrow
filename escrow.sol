// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter; // A third-party arbitrator

    // State variables to track the status of the escrow
    enum State { Created, Locked, Released, InDispute }
    State public state;

    // Events to log state changes
    event EscrowCreated(address indexed _buyer, address indexed _seller, address indexed _arbiter);
    event FundsLocked();
    event FundsReleased();
    event FundsInDispute();

    // Modifier to ensure that only the buyer can call a function
    modifier onlyBuyer() {
        require(msg.sender == buyer, "Only buyer can call this function");
        _;
    }

    // Modifier to ensure that only the seller can call a function
    modifier onlySeller() {
        require(msg.sender == seller, "Only seller can call this function");
        _;
    }

    // Modifier to ensure that only the arbiter can call a function
    modifier onlyArbiter() {
        require(msg.sender == arbiter, "Only arbiter can call this function");
        _;
    }

    // Modifier to ensure that the contract is in a specific state
    modifier inState(State _state) {
        require(state == _state, "Invalid state");
        _;
    }

    // Constructor to initialize the escrow contract
    constructor(address _seller, address _arbiter) {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = State.Created;

        emit EscrowCreated(buyer, seller, arbiter);
    }

    // Function to lock funds in the escrow
    function lockFunds() public onlyBuyer inState(State.Created) payable {
        state = State.Locked;
        emit FundsLocked();
    }

    // Function to release funds to the seller
    function releaseFunds() public onlySeller inState(State.Locked) {
        state = State.Released;
        payable(seller).transfer(address(this).balance);
        emit FundsReleased();
    }

    // Function to raise a dispute and involve the arbiter
    function raiseDispute() public onlyBuyer inState(State.Locked) {
        state = State.InDispute;
        emit FundsInDispute();
    }

    // Function for the arbiter to resolve the dispute and release funds
    function resolveDispute() public onlyArbiter inState(State.InDispute) {
        state = State.Released;
        payable(seller).transfer(address(this).balance);
        emit FundsReleased();
    }
}