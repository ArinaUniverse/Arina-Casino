pragma solidity >=0.5.0 <0.6.0;

import "./ERC721.sol";
import "./ConnectChips.sol";
import "./debug.sol";

contract Manager{

    address public superManager = 0xAB610a9A42fa6082cf5daE2AF14a56E5b0cf4c14;
    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager || msg.sender == superManager, "Is not manager");
        _;
    }

    function changeManager(address _new_manager) public {
        require(msg.sender == superManager, "Is not superManager");
        manager = _new_manager;
    }
}

contract LCT is Manager, ERC721, ConnectChips, debug{

    address team = 0x89B1c05F3044Fd5dE877A0f7b273C4636fD75e1b;

    mapping(address => uint) $equityBasePlayer; //權益基數(玩家)
    mapping(address => uint) $received; //玩家已領
    mapping(address => bool) $registered;
    mapping(address => address) $referrer;

    uint $equityBaseReleased; //權益基數(發行)
    uint $equityBaseBurned; //權益基數(銷毀)
    uint $createIndex; //創建token的index

    constructor() public{
        $registered[team] = true;
    }

    function inqLCTType(uint TokenId) public view returns(uint8){
        return $luckyCats[TokenId].typ;
    }

    function inqTeam() public view returns(address){
        require(team != address(0), "Team address is null");
        return team;
    }

    function inqToTLCTAmount(uint8 typ) public view returns(uint){
        if(typ == 1){
            return LCTAomunt.current(1);
        }else if(typ == 2){
            return LCTAomunt.current(2);
        }else if(typ == 3){
            return LCTAomunt.current(3);
        }else{
            revert("Cat type error");
        }
    }

    function inqRegistered(address player) public view returns(bool){
        return $registered[player];
    }

    function inqReferrer(address player) public view returns(address){
        require($referrer[player] != address(0), "referrer is null");
        return $referrer[player];
    }

    function register(address referrer) external{
        require($registered[msg.sender] == false, "You have already registered");
        require($registered[referrer] == true, "Your referrer have not registered yet");
        $referrer[msg.sender] = referrer;
        $registered[msg.sender] = true;
    }

    function inqEquityBaseReleased() external view returns (uint){
        return $equityBaseReleased;
    }

    function inqEquityBaseBurned() external view returns (uint){
        return $equityBaseBurned;
    }

    function inqEquity(address player) public view returns (uint) {
        return $equityBasePlayer[player];
    }

    function buyPrice(uint8 typ) public view returns(uint){
        
        uint spacing = $equityBaseReleased/10000;
        if(typ == 1){
            return uint(1000).percent((spacing.mul(5)).add(100));
        }
        else if(typ == 2){
            return uint(9500).percent((spacing.mul(5)).add(100));
        }
        else if(typ == 3){
            return uint(90000).percent((spacing.mul(5)).add(100));
        }
        else{
            revert("Type is error");
        }
    }

    function sellPrice(uint8 typ) public view returns(uint){

        uint coefficient;

        if($equityBaseReleased == 0){
            coefficient == 100;
        }else{
            coefficient = (($equityBaseBurned).div($equityBaseReleased).mul(30)).add(70);
        }

        if(typ == 1){
            return buyPrice(1).percent(80).percent(coefficient);
        }
        else if(typ == 2){
            return buyPrice(2).percent(80).percent(coefficient);
        }
        else if(typ == 3){
            return buyPrice(3).percent(80).percent(coefficient);
        }
        else{
            revert("Type is error");
        }
    }

    function buyLCT(uint8 typ, uint value) public{
        //check(inqCHIPS(msg.sender));
        //require(inqCHIPS(msg.sender) >= value, "CHIPS is not enough");

        /* player => address(this) => pool */
        uint base = 1e8;
        payToGame(value);

        require($registered[msg.sender] = true, "You are not registered yet");

        $createIndex = $createIndex.add(1);

        if(typ == 1){
            require(value == buyPrice(1).mul(base), "Value is not correct");
            $equityBaseReleased = $equityBaseReleased.add(10);
            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].add(10);
        }
        else if(typ == 2){
            require(value == buyPrice(2).mul(base), "Value is not correct");
            $equityBaseReleased = $equityBaseReleased.add(100);
            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].add(100);
        }
        else if(typ == 3){
            require(value == buyPrice(3).mul(base), "Value is not correct");
            $equityBaseReleased = $equityBaseReleased.add(1000);

            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].add(1000);
        }else{
            revert("Type is error");
        }

        $luckyCats[$createIndex].typ = typ;
        _safeMint(msg.sender, $createIndex);

        
        distribute(value.percent(80), false);
        address referrer = $referrer[msg.sender];
        
        if(referrer == address(0)){
            sendToPlayer(team, value.percent(20));

        }else{
            sendToPlayer(referrer, value.percent(10));
            sendToPlayer(team, value.percent(10));
        }
    }

    function sellLCT(uint tokenId) public{

        require(ownerOf(tokenId) == msg.sender, "It's not your token");
        _burn(msg.sender, tokenId);
        uint8 typ = $luckyCats[tokenId].typ;
        uint payValue = sellPrice(typ).mul(10**8);

        if(typ == 1){
            $equityBaseBurned = $equityBaseBurned.add(10);
            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].sub(10);
        }
        else if(typ == 2){
            $equityBaseBurned = $equityBaseBurned.add(100);
            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].sub(100);
        }
        else if(typ == 3){
            $equityBaseBurned = $equityBaseBurned.add(1000);
            $equityBasePlayer[msg.sender] = $equityBasePlayer[msg.sender].sub(1000);
        }
        sendToPlayer(msg.sender, payValue);
        //Ichip(chip()).transferCHIPS(address(this), msg.sender, payValue);
    }

}