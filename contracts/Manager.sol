pragma solidity >= 0.5.0;

contract Manager{

    address public superManager = 0x151E1a9f5234E50cc7FFc2aD7da73A31d77CeA1b;
    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager || msg.sender == superManager,
			"You are not a manager");
        _;
    }

    modifier onlySuperManager{
        require(msg.sender == superManager, "You are not a superManager");
        _;
    }

    function changeSuperManager(address new_superManager) public onlySuperManager{
        superManager = new_superManager;
    }

    function changeManager(address new_manager) public onlyManager{
        manager = new_manager;
    }

    function withdraw() external onlyManager{
        (msg.sender).transfer(address(this).balance);
    }
}