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

contract Schatch is Manager, ConnectChips{
   
    using SafeMath for uint;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    //事件
    event game_1Result(address indexed player,uint no,uint getMoney);      //遊戲一結果
    event game_2Result(address indexed player,uint[4] no,uint getMoney);   //遊戲二結果
    event finalResult(address indexed player,uint getMoney);
    
    mapping(address => info) playerInfo;
    
    struct info{

        uint money1;        //玩家gmae1獎勵
        uint money2;        //玩家gmae2獎勵
        uint game1;         //gmae1 結果
        uint[4] game2;      //gmae2 結果
    }

    function startGame(uint value) public {

        require(value == 100e8, "Pay value error");
        payToGame(value);
        bytes32 random = keccak256(abi.encodePacked(now, rand()));

        uint getMoney;                      //獲得獎金
        uint game1No;                       //遊戲1的牌
        uint totalPay;                      //總共需支付金額
        uint[6] memory options;             //每個級距牌數
        uint[4] memory game2No;             //遊戲2的牌
        uint[4] memory random_2;            

        uint random_1 = uint8(random[5]) % 100;
  
        random_2[0] = uint8(random[10]) % 100;
        random_2[1] = uint8(random[13]) % 100;
        random_2[2] = uint8(random[17]) % 100;
        random_2[3] = uint8(random[21]) % 100;        
        
        if( random_1 >= 0 && random_1 <= 2){                // 3%
            getMoney = 2000;
            game1No = 0;
        }else if( random_1 >= 3 && random_1 <= 9){          // 7%
            getMoney = 1000;
            game1No = 1;
        }else if( random_1 >= 10 && random_1 <= 24){        // 15%
            getMoney = 200;
            game1No = 2;
        }else if( random_1 >= 25 && random_1 <= 59){        // 35%    
            getMoney = 100;
            game1No = 3;
        }else{                                              // 40%
            getMoney = 0;
            game1No = 4;
        }
           
        
        emit game_1Result(msg.sender, game1No, getMoney);
        playerInfo[msg.sender].money1 = getMoney;
        playerInfo[msg.sender].game1 = game1No;
        
        for(uint8 i = 0 ; i < 4 ; i++){
            
            if(random_2[i] >= 0 && random_2[i] <= 1 ){              // 2%
                options[0]++;    
                game2No[i] = 0;
            }else if( random_2[i] >= 2 && random_2[i] <= 6){        // 5%
                options[1]++;
                game2No[i] = 1;
            }else if( random_2[i] >= 7 && random_2[i] <= 14){       // 8%    
                options[2]++;
                game2No[i] = 2;
            }else if( random_2[i] >= 15 && random_2[i] <= 29){      // 15%
                options[3]++;
                game2No[i] = 3;
            }else if( random_2[i] >= 30 && random_2[i] <= 54){      // 25%
                options[4]++;
                game2No[i] = 4;
            }else{                                                  // 45%
                options[5]++;
                game2No[i] = 5;
            }
        }
        
        getMoney = 0;       //game1 獎金清空
        
        if(options[0] >= 3){
            getMoney = 300000;        
        }else if(options[1] >= 3){
            getMoney = 30000;        
        }else if(options[2] >= 3){
            getMoney = 10000;        
        }else if(options[3] >= 3){
            getMoney = 5000;        
        }else if(options[4] >= 3){
            getMoney = 1000;        
        }else if(options[5] >= 3){
            getMoney = 100;        
        }
        totalPay = playerInfo[msg.sender].money1.add(playerInfo[msg.sender].money2);
        emit game_2Result(msg.sender, game2No, getMoney);
        playerInfo[msg.sender].money2 = getMoney;
        playerInfo[msg.sender].game2 = game2No;
        emit finalResult(msg.sender, totalPay);  

        checkAndSend(totalPay, value, msg.sender);

    }
    
    function inqGameResult(address _player) public view returns(uint _game1 , uint _game1Reward, uint[4] memory _game2 , uint _game2Reward){
    //查詢遊戲資訊

        _game1 = playerInfo[_player].game1;
        _game1Reward = playerInfo[_player].money1;
        _game2 = playerInfo[_player].game2;
        _game2Reward = playerInfo[_player].money2;
    }
    
    
    
}