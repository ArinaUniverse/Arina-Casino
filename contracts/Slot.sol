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

contract Tanslot is Manager, ConnectChips{
    
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    mapping(address => uint8[9]) beforeSlotNum;          //前端抓取的值
    // mapping(address => uint8[9]) afterSlotNum;        //轉換過比對的值
    event slotNum(address indexed _player, uint8[9] slotNumber); //紀錄開獎結果
    event slotResult(address indexed _player, uint value);
    
    address public test_node = 0x083748b1666caa85c2AbEF2027873b0d573DB3F7;

    
    //uint jackpot;
    
    function() external payable{}
    
    function slotting(uint value) public{

        payToGame(value.mul(9).div(10));
        Ichip(chip()).transferCHIPS(msg.sender, address(0), value.div(10)); //到jackpot
        //require((address(this).balance.sub(jackpot)) > msg.value.mul(160),"you need to pay more value");

        //uint _money = value;
        
        bytes32 random = bytes32(rand());
        uint8[9] memory slot;               //存放9個隨機數
        uint8[4] memory odds;               //統計各賠率次數
        uint payTAN;
        uint cnt = 0;
        bool isLotto = false;
        
        slot[0] = uint8(random[2]) % 20;
        slot[1] = uint8(random[5]) % 20;
        slot[2] = uint8(random[7]) % 20;
        slot[3] = uint8(random[9]) % 20;
        slot[4] = uint8(random[11]) % 20;
        slot[5] = uint8(random[14]) % 20;
        slot[6] = uint8(random[16]) % 20;
        slot[7] = uint8(random[19]) % 20;
        slot[8] = uint8(random[22]) % 20;
        
        beforeSlotNum[msg.sender] = slot;
        emit slotNum(msg.sender,slot);
         
        slot[0] = transferParm(slot[0]);
        slot[1] = transferParm(slot[1]);
        slot[2] = transferParm(slot[2]);
        slot[3] = transferParm(slot[3]);
        slot[4] = transferParm(slot[4]);
        slot[5] = transferParm(slot[5]);
        slot[6] = transferParm(slot[6]);
        slot[7] = transferParm(slot[7]);
        slot[8] = transferParm(slot[8]);
        
        
        for(uint8 i=0; i < slot.length; i++){                //9個數都為0
        
            if(slot[i] == 0){
                cnt = cnt.add(1);
            }
        }

        if(cnt >= 7){
            uint jackpotValue = inqCHIPS(address(0));
            Ichip(chip()).transferCHIPS(address(0), msg.sender, jackpotValue); //到jackpot
        }
        
        if( slot[0] == slot[1] && slot[1] == slot[2]){
            if(slot[0] == 0 ){
                odds[0]++;
            }else if(slot[0] == 1){
                odds[1]++;
            }else if(slot[0] == 2 || slot[0] == 3){
                odds[2]++;
            }else if(slot[0] == 4 || slot[0] == 5 || slot[0] == 6){
                odds[3]++;
            }
        }
         
        if( slot[3] == slot[4] && slot[4] == slot[5]){
            if(slot[3] == 0 ){
                odds[0]++;
            }else if(slot[3] == 1){
                odds[1]++;
            }else if(slot[3] == 2 || slot[3] == 3){
                odds[2]++;
            }else if(slot[3] == 4 || slot[3] == 5 || slot[3] == 6){
                odds[3]++;
            }
        }
        
        if( slot[6] == slot[7] && slot[7] == slot[8]){
            if(slot[6] == 0 ){
                odds[0]++;
            }else if(slot[6] == 1){
                odds[1]++;
            }else if(slot[6] == 2 || slot[6] == 3){
                odds[2]++;
            }else if(slot[6] == 4 || slot[6] == 5 || slot[6] == 6){
                odds[3]++;
            }
        }
        
        if( slot[0] == slot[4] && slot[4] == slot[8]){
            if(slot[0] == 0 ){
                odds[0]++;
            }else if(slot[0] == 1){
                odds[1]++;
            }else if(slot[0] == 2 || slot[0] == 3){
                odds[2]++;
            }else if(slot[0] == 4 || slot[0] == 5 || slot[0] == 6){
                odds[3]++;
            }
        }
         
        if( slot[2] == slot[4] && slot[4] == slot[6]){
            if(slot[2] == 0 ){
                odds[0]++;
            }else if(slot[2] == 1){
                odds[1]++;
            }else if(slot[2] == 2 || slot[2] == 3){
                odds[2]++;
            }else if(slot[2] == 4 || slot[2] == 5 || slot[2] == 6){
                odds[3]++;
            }
        }
         
        if( slot[0] == slot[3] && slot[3] == slot[6]){
            if(slot[0] == 0 ){
                odds[0]++;
            }else if(slot[0] == 1){
                odds[1]++;
            }else if(slot[0] == 2 || slot[0] == 3){
                odds[2]++;
            }else if(slot[0] == 4 || slot[0] == 5 || slot[0] == 6){
                odds[3]++;
            }
        }
         
        if( slot[1] == slot[4] && slot[4] == slot[7]){
            if(slot[1] == 0 ){
                odds[0]++;
            }else if(slot[1] == 1){
                odds[1]++;
            }else if(slot[1] == 2 || slot[1] == 3){
                odds[2]++;
            }else if(slot[1] == 4 || slot[1] == 5 || slot[1] == 6){
                odds[3]++;
            }
        }
        
        if( slot[2] == slot[5] && slot[5] == slot[8]){
            if(slot[2] == 0 ){
                odds[0]++;
            }else if(slot[2] == 1){
                odds[1]++;
            }else if(slot[2] == 2 || slot[2] == 3){
                odds[2]++;
            }else if(slot[2] == 4 || slot[2] == 5 || slot[2] == 6){
                odds[3]++;
            }
        }
        
        
        if(odds[0] !=0){
            payTAN = value.mul(odds[0]).mul(20);
            emit slotResult(msg.sender, payTAN);
            checkAndSend(payTAN, value, msg.sender);
            isLotto = true;
        }
        
        if(odds[1] !=0){
            payTAN = value.mul(odds[1]).mul(10);
            emit slotResult(msg.sender, payTAN);
            checkAndSend(payTAN, value, msg.sender);
            isLotto = true;
        }
        
        if(odds[2] !=0){
            payTAN = value.mul(odds[2]).mul(8);
            emit slotResult(msg.sender, payTAN);
            checkAndSend(payTAN, value, msg.sender);
            isLotto = true;
        }
        
        if(odds[3] !=0){
            payTAN = value.mul(odds[3]).mul(2);
            emit slotResult(msg.sender, payTAN);
            checkAndSend(payTAN, value, msg.sender);
            isLotto = true;
        }
        

        // afterSlotNum[msg.sender] = slot;
        
    }
    
    function transferParm(uint8 _parm) private pure returns(uint8 newSlot){
        if(_parm == 0){
            newSlot = 0;
        }else if(_parm == 1 || _parm == 2){
            newSlot = 1;
        }else if(_parm >=3 && _parm <= 5){
            newSlot = 2;
        }else if(_parm >=6 && _parm <= 8){
            newSlot = 3;
        }else if(_parm >=9 && _parm <= 13){
            newSlot = 4;
        }else if(_parm >=14 && _parm <= 18){
            newSlot = 5;
        }else{
            newSlot = 6;
        }
    }

    function inquireJackpot() public view returns(uint){            //查詢大獎池
        return inqCHIPS(address(0));
    }

    function inquireTAN() public view returns(uint){                //查詢副本餘額
        return address(this).balance;
    }
    
    function inquire_beforeNumber(address _player) public view returns(uint8[9] memory){    //查詢玩家上次開獎結果(轉換前)
        return beforeSlotNum[_player];
    }
 
    // function inquire_afterNumber(address _player) public view returns(uint8[9]){    //查詢玩家上次開獎結果(轉換後)
    //     return afterSlotNum[_player];
    // }
    
}