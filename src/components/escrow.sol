pragma solidity >=0.7.0 <0.9.0;

contract Escrow{
    enum State {NOT_INITIATED, AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE}

    State public currState;

    bool public isdonorIn;
    bool public ischarityIn;

    uint public donation;

    address public donor;
    address payable public charity;

    modifier onlydonor(){
        require(msg.sender == donor, "Only donor can call");
        _;
    }

    modifier escrowNotStarted(){
        require(currState == State.NOT_INITIATED);
        _;
    }

    constructor(address _donor, address payable _charity, uint _donation){
        donor = _donor;
        charity = _charity;
        donation = _donation*(1 ether);
    }

    function initContract() escrowNotStarted public{
        if(msg.sender == donor){
            isdonorIn = true;
        }
        if(msg.sender == charity){
            ischarityIn = true;
        }
        if(isdonorIn && ischarityIn){
            currState = State.AWAITING_PAYMENT;
        }
    }

    function deposit() onlydonor public payable{
        require(currState == State.AWAITING_PAYMENT, "Already paid");
        require(msg.value == donation, "Wrong deposit amount");
        currState = State.AWAITING_DELIVERY;
    }

    function confirmDelivery() onlydonor payable public{
        require(currState == State.AWAITING_DELIVERY, "Cannot confirm delivery");
        charity.transfer(donation);
        currState = State.COMPLETE;
    }

    function withdraw() onlydonor payable public{
        require(currState == State.AWAITING_DELIVERY, "Cannot withdraw");
        payable(msg.sender).transfer(donation);
        currState = State.COMPLETE;
    }
}