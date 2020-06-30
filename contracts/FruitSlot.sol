pragma solidity >=0.5.0 <0.6.0;

import "./ConnectChips.sol";
import "./Manager.sol";

library Address {
    
    function isContract(address account) internal view returns (bool) {

        bytes32 codehash;
        
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        
        assembly { codehash := extcodehash(account) }
        return (codehash != 0x0 && codehash != accountHash);
    }
    
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

contract FruitSlot is Manager, ConnectChips{
    
    using Address for address;
    
    mapping(address => info) player_betInfo;
    
    //事件
    event randomNum(address indexed player,uint8 random);                         //隨機數結果
    event bet(address indexed player,uint8 betNo,uint betMoney);                  //當前下注號碼及金額
    event betResult(address indexed player,uint8 _type, uint bonus);              //開獎結果
    
    struct info{
        uint8 random;               // 0 柑橘  1 比特幣  2 以太幣 ...  8 = 初始值尚未開始
        uint[8] betTypeMoney;
        bool startGame;
        bool betGame;
    }
    
    function startGame() public {
        //require(address(this).balance >= 200 ether,"The contract less than 200 Tan");
        player_betInfo[msg.sender].startGame = true;
        player_betInfo[msg.sender].random = 8;
    }
    
    function RunSpin(uint value, uint8[7] memory betNo) public{

        require(value >= 100e8, "Your value is below the limit");
        uint base = 100e8;

        payToGame(value);
        
        uint8 betCount = 0;
        uint8 _type;
        uint8 Odd;
        uint random = uint8(rand()) % 100;
        uint _bonus;

        for(uint8 i = 0 ; i <= 6 ; i++){
            require(betNo[i] >= 0 && betNo[i] <= 10, "No error");
            player_betInfo[msg.sender].betTypeMoney[i] = uint(betNo[i]).mul(base);
            betCount = betCount.add(betNo[i]);
        }
        
        require(value == uint(betCount).mul(base)," Your bet is true");

        if(random < 3){
            _type = 0;
            Odd = 30;
        }else if(random > 2 && random < 6){
            _type = 1;
            Odd = 20;
        }else if(random > 5 && random < 11){
            _type = 2;
            Odd = 10;
        }else if(random > 10 && random < 18){
            _type = 3;
            Odd = 8;
        }else if(random > 17 && random < 26){
            _type = 4;
            Odd = 5;
        }else if(random > 25 && random < 51){
            _type = 5;
            Odd = 3;
        }else if(random > 50 && random < 81){
            _type = 6;
            Odd = 2;
        }else{
            _type = 7;
            Odd = 0;
        }

        player_betInfo[msg.sender].random = _type;

        uint sumBet;

        for(uint8 i = 0 ; i < 8 ; i++){
            sumBet += player_betInfo[msg.sender].betTypeMoney[i];
        }
        
        if(player_betInfo[msg.sender].betTypeMoney[_type] != 0 && _type < 6){
            _bonus = player_betInfo[msg.sender].betTypeMoney[_type].mul(Odd);
            //check(inqPoolBalance(address(this)),_bonus, sumBet);
            checkAndSend(_bonus, sumBet, msg.sender);
            //msg.sender.transfer(_bonus);
        }else if(player_betInfo[msg.sender].betTypeMoney[_type] != 0 && _type == 6){
            _bonus = player_betInfo[msg.sender].betTypeMoney[6].mul(3).div(2);
            //check(inqPoolBalance(address(this)), _bonus, sumBet);
            checkAndSend(_bonus, sumBet, msg.sender);
            //msg.sender.transfer(_bonus);
        }else{
            _bonus = 0;
            //check(inqPoolBalance(address(this)), _bonus, sumBet);
            checkAndSend(_bonus, sumBet, msg.sender);
        }
        
        emit betResult(msg.sender, _type, _bonus);
        
        //清空資料
        
        player_betInfo[msg.sender].startGame = false;
        player_betInfo[msg.sender].betGame = false;
        for(uint8 i = 0 ; i < 8 ; i++){
            if(player_betInfo[msg.sender].betTypeMoney[i] != 0){
                player_betInfo[msg.sender].betTypeMoney[i] = 0;
            }
        }

    }
    
    function inquireRandom(address _address) public view returns(uint8){        //查詢玩家最新一局開局結果
        return player_betInfo[_address].random;
    }
 
}