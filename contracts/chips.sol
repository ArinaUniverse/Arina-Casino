pragma solidity >=0.5.0 <0.6.0;

import "./Manager.sol";
import "./newMath.sol";
import "./debug.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;

        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != 0x0 && codehash != accountHash);
    }

    function toPayable(address account)
        internal
        pure
        returns (address payable)
    {
        return address(uint160(account));
    }
}

interface ILCT {
    function inqEquityBaseReleased() external view returns (uint256);
    function inqEquityBaseBurned() external view returns (uint256);
    function inqEquity(address player) external view returns (uint256);
}

contract chipBase is Manager, math, debug {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event ReceivedTokens(address _from, uint256 _value, address _token, bytes _extraData);

    string public name = "Arina Chips";
    string public symbol = "AC";
    uint public decimals = 8;

    using Address for address;

    address LCT;
    address arina;
    address server;

    function() external payable {}

    function setServer(address serverAddr) external onlyManager {
        server = serverAddr;
    }

    function serverAdr() public view returns (address) {
        require(server != address(0), "Address of server is null");
        return server;
    }

    modifier onlyServer {
        require(msg.sender == serverAdr(), "You are not the server");
        _;
    }

    function LCTadr() public view returns (address) {
        require(LCT != address(0), "LCT is null");
        return LCT;
    }

    function setLCT(address _LCT) external onlyManager {
        LCT = _LCT;
    }

    function setArina(address _arina) external onlyManager {
        arina = _arina;
    }

    function arinaAdr() public view returns (address) {
        require(arina != address(0), "arina is null");
        return arina;
    }

    function inqEquityBaseReleased() public view returns (uint256) {
        return ILCT(LCT).inqEquityBaseReleased();
    }

    function inqEquityBaseBurned() public view returns (uint256) {
        return ILCT(LCT).inqEquityBaseBurned();
    }

    function inqEquity(address player) public view returns (uint256) {
        return ILCT(LCT).inqEquity(player);
    }

}

contract Chips is chipBase {
    event ReturnArinas(address payer, uint256 arinaValue);

    constructor() public {
        server = msg.sender;

        _init(msg.sender);
        playerRevised[msg.sender].current = 150000e8;

        setAward(false, 0, 5000e8);
        setAward(true, 0, 15000e8);
    }

    modifier onlyGame {
        require(isGame[msg.sender], "You are not the game contract");
        _;
    }

    function allowance(address owner, address spender) external view returns (uint256){
        revert("Arina Chips can't transfer");
    }
    function approve(address spender, uint256 amount) external returns (bool){
        revert("Arina Chips can't transfer");
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool){
        revert("Arina Chips can't transfer");
    }

    function transfer(address recipient, uint256 amount) external{
        revert("Arina Chips can't transfer");
    }

    function balanceOf(address account) public view returns (uint256){
        return inqChips(account);
    }

    function totalSupply() external view returns (uint256){
        return totPool();
    }


    function inqGameAmount() public view returns (uint256) {
        return gameAmount;
    }

    function setGame(address game, bool _isGame) external onlyManager {
        if (!isGame[game] && _isGame) {
            isGame[game] = _isGame;
            gameAmount = gameAmount.add(1);
        } else if (isGame[game] && !_isGame) {
            isGame[game] = _isGame;
            gameAmount = gameAmount.sub(1);
        } else {
            revert("Your set already exist");
        }
    }

    mapping(address => bool) public isGame;

    uint256 gameAmount; //game contract amount
    uint256 distriOfGame;
    uint256 distriOfPlayer;
    uint256 total;

    struct balance {
        uint256 receipted; //每次改動權益基數需要接收一次
        uint256 current; //當前餘額
        bool init;
    }

    mapping(address => balance) gameRevised;
    mapping(address => balance) playerRevised;

    function sendChips(address to, uint256 value) external onlyServer {
        //server to player
        _mint(to, value);
    }

    function transferCHIPS(address from, address to, uint256 value) external onlyGame{
        _transferCHIPS(from, to, value);
    }

    function inqChips(address _address) public view returns (uint256) {
        if (isGame[_address]) {
            if (!gameRevised[_address].init) {
                return 0;
            } else {
                uint256 increase = distriOfGame.sub(
                    gameRevised[_address].receipted
                );
                return (gameRevised[_address].current).add(increase);
            }

        } else {
            if (!playerRevised[_address].init) {
                return 0;
            } else {
                uint256 increase = (
                    distriOfPlayer.sub(playerRevised[_address].receipted)
                )
                    .mul(inqEquity(_address));
                return (playerRevised[_address].current).add(increase);
            }
        }
    }

    function _mint(address to, uint256 value) private {
        _update(to);
        if (isGame[to]) {
            gameRevised[to].current = gameRevised[to].current.add(value);
        } else {
            playerRevised[to].current = playerRevised[to].current.add(value);
        }
        emit Transfer(address(this), to, value);
    }

    function _init(address _address) private {
        if (isGame[_address]) {
            if (!gameRevised[_address].init) {
                gameRevised[_address].receipted = distriOfGame;
                gameRevised[_address].init = true;
            }
        } else {
            if (!playerRevised[_address].init) {
                playerRevised[_address].receipted = distriOfPlayer;
                playerRevised[_address].init = true;
            }
        }
    }

    function _transferCHIPS(address from, address to, uint256 value) private {
        _update(from);
        _update(to);
        if (isGame[from]) {
            gameRevised[from].current = gameRevised[from].current
            .sub(value, "chips transfer error");
        } else {
            playerRevised[from].current = playerRevised[from].current
            .sub(value,"chips transfer error");
        }

        if (isGame[to]) {
            gameRevised[to].current = gameRevised[to].current.add(value);
        } else {
            playerRevised[to].current = playerRevised[to].current.add(value);
        }

        emit Transfer(from, to, value);
        
    }

    function _distribute2Game(uint256 value) private {
        uint256 poolAdd = value.div(gameAmount);
        distriOfGame = distriOfGame.add(poolAdd);
    }

    function _distribute2Player(uint256 value) private {
        uint256 _equity = inqEquityBaseReleased().sub(inqEquityBaseBurned());
        if (_equity != 0) {
            uint256 increase = value.div(_equity);
            distriOfPlayer = distriOfPlayer.add(increase);
        }
    }

    function _update(address _address) internal {
        _init(_address);
        if (isGame[_address]) {
            uint256 increase = distriOfGame.sub(
                gameRevised[_address].receipted
            );
            gameRevised[_address].current = (gameRevised[_address].current).add(
                increase
            );
            gameRevised[_address].receipted = distriOfGame;
        } else {
            uint256 increase = (
                distriOfPlayer.sub(playerRevised[_address].receipted)
            ).mul(inqEquity(_address));

            playerRevised[_address].current = playerRevised[_address].current.add(increase);
            playerRevised[_address].receipted = distriOfPlayer;
        }
    }

    function totPool() public view returns (uint256) {
        return total;
    }

    function distribute(uint256 value, bool ToPlayer) external {
        //check(msg.sender, value);

        _update(msg.sender);

        if (isGame[msg.sender]) {
            gameRevised[msg.sender].current = gameRevised[msg.sender].current.sub(value);
        } else {
            playerRevised[msg.sender].current = playerRevised[msg.sender].current.sub(value);
        }

        uint256 _totPool = totPool();
        uint256 _distriOfGame;
        uint256 _distriOfPlayer;

        uint256 _percent;

        if (_totPool >= 10000) {
            _percent = 10;
        } else if (_totPool >= 50000) {
            _percent = 20;
        } else if (_totPool >= 100000) {
            _percent = 30;
        } else if (_totPool >= 500000) {
            _percent = 50;
        } else if (_totPool >= 1000000) {
            _percent = 60;
        } else {
            _percent = 0;
        }

        if (ToPlayer) {
            _distriOfPlayer = value.percent(_percent);
            _distriOfGame = value.sub(_distriOfPlayer);
        } else {
            _distriOfGame = value;
        }
        total = total.add(value);
        _distribute2Player(_distriOfPlayer);
        _distribute2Game(_distriOfGame);
    }

    function buyChips() external payable {
        uint256 ratio = 1000; //TAN:AC = 1:1000
        uint256 chips = (msg.value).mul(ratio * 10**8).div(10**18);
        _mint(msg.sender, chips);
    }

    function returnArinas(uint256 value) external {
        uint256 ratio = 120; //AC:arina = 1:120
        _transferCHIPS(msg.sender, address(this), value*10**8);
        uint256 arinaValue = value.div(ratio);
        require(
            IERC20(arinaAdr()).balanceOf(address(this)) >= arinaValue,
            "The contract is not having enough balance"
        );
        IERC20(arinaAdr()).transfer(msg.sender, arinaValue);
        emit ReturnArinas(msg.sender, arinaValue);
    }

    ////////////////////////award///////////////////////////

    mapping(address => uint256) cooltime;
    mapping(address => uint256) primeTime;
    mapping(bool => Award) award;

    struct Award {
        uint256 tan;
        uint256 chips;
    }

    function inqCoolTime(address player) external view returns (uint256) {
        return cooltime[player];
    }

    function inqPrimeTime(address player) external view returns (uint256) {
        return primeTime[player];
    }

    function bePrime(address player) external onlyServer {
        _mint(player, 20000e8);
        primeTime[player] = now.add(30 days);
    }

    function isPrime(address player) public view returns (bool) {
        return now < primeTime[player];
    }

    function isCooldown(address player) public view returns (bool) {
        return now >= cooltime[player];
    }

    function setAward(bool _isPrime, uint256 tan, uint256 chips) public onlyManager{
        award[_isPrime].tan = tan;
        award[_isPrime].chips = chips;
    }

    function awardValue(bool _isPrime)
        private
        view
        returns (uint256 tan, uint256 chips)
    {
        return (award[_isPrime].tan, award[_isPrime].chips);
    }

    function getAward() external {
        require(isCooldown(msg.sender), "You are within cooltime");
        (uint256 tan, uint256 chips) = awardValue(isPrime(msg.sender));
        msg.sender.transfer(tan);
        if (rand(0, 99) == 87) {
            _mint(msg.sender, chips.add(30000e8));
        } else {
            _mint(msg.sender, chips);
        }
        cooltime[msg.sender] = now.add(86400);
    }

}
