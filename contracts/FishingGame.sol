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

contract FishingGame is Manager, ConnectChips{
    
    using SafeMath for uint;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    
    mapping(address => info) player_Info;
    
    //事件2020
    event everyResult(address indexed player,uint no,uint fishType);               //每次釣到的結果
    event finalResult(address indexed player,uint getMoney);                         //最後釣完的結果

    struct info{
        uint count;         //釣竿的次數
        uint rate;          //釣竿的修正率
        bool finishRod;
        bool finishBait;
        uint payValue;

        uint money;         //玩家執行後獲得得獎勵
        uint[] fishTyp;    //紀錄每次釣到的魚種
    }

    function() external payable{}

    function selectRod(uint value, uint _rod) public{              //選擇釣竿
        payToGame(value);
        //require(address(this).balance >= 200 ether, "The contract less than 200 Tan");

        player_Info[msg.sender].payValue = player_Info[msg.sender].payValue.add(value);
        require(_rod >=  0 && _rod <= 8 ,"Rod number is wrong");
        require(!player_Info[msg.sender].finishRod,"Already selected rod");
        
        //uint payAc;             //支付AC金額
        uint _count;             //可釣次數
        
        if(_rod == 0){          //普通釣竿
            //payAc = 0;
            require(value == 100e8, "Pay value error");
            _count = 1;
        }else if(_rod == 1){    //網子
            //payAc = 100;
            require(value == 300e8, "Pay value error");
            _count = 2;
        }else if(_rod == 2){    //木釣竿
            //payAc = 500;
            require(value == 1200e8, "Pay value error");
            _count = 4;
        }else if(_rod == 3){    //竹釣竿
            //payAc = 2000;
            require(value == 1700e8, "Pay value error");
            _count = 6;
        }else if(_rod == 4){    //筏竿
            //payAc = 3000;
            require(value == 2500e8, "Pay value error");
            _count = 8;
        }else if(_rod == 5){    //大網子
            //payAc = 4000;
            require(value == 3000e8, "Pay value error");
            _count = 10;
        }else if(_rod == 6){    //海釣竿
            //payAc = 6000;
            require(value == 5000e8, "Pay value error");
            _count = 12;
        }else if(_rod == 7){    //骷髏竿
            //payAc = 8000;
            require(value == 7000e8, "Pay value error");
            _count = 14;
        }else{
            //payAc = 10000;      //超級補網
            require(value == 8000e8, "Pay value error");
            _count = 16;
        }
        
        player_Info[msg.sender].count = _count;
        player_Info[msg.sender].finishRod = true;

    }
    
    function selectBait(uint value, uint _bait) public{           //選擇釣餌
        payToGame(value);
        //require(address(this).balance >= 200 ether,"The contract less than 200 Tan");
        player_Info[msg.sender].payValue = player_Info[msg.sender].payValue.add(value);
        require(_bait >= 0 && _bait <= 8, "Bait number is wrong");
        require(!player_Info[msg.sender].finishBait,"Already selected rod");
        
        //uint payAc;             //支付AC金額
        uint _rate;
        
        if(_bait == 0){          //大米
            //payAc = 0;
            require(value == 0, "Pay value error");
            _rate = 0;
        }else if(_bait == 1){    //蚯蚓
            //payAc = 100;
            require(value == 100e8, "Pay value error");
            _rate = 2;
        }else if(_bait == 2){    //乳酪
            //payAc = 500;
            require(value == 300e8, "Pay value error");
            _rate = 4;
        }else if(_bait == 3){    //青蟲
            //payAc = 2000;
            require(value == 1000e8, "Pay value error");
            _rate = 6;
        }else if(_bait == 4){    //活蝦
            // payAc = 3000;
            require(value == 1500e8, "Pay value error");
            _rate = 8;
        }else if(_bait == 5){    //土蠶
            //payAc = 4000;
            require(value == 2000e8, "Pay value error");
            _rate = 10;
        }else if(_bait == 6){    //紅蟲
            //payAc = 6000;
            require(value == 2500e8, "Pay value error");
            _rate = 12;
        }else if(_bait == 7){    //螺螄
            //payAc = 8000;
            require(value == 3000e8, "Pay value error");
            _rate = 14;
        }else{
            //payAc = 10000;      //螢光蚯蚓
            require(value == 4000e8, "Pay value error");
            _rate = 16;
        }
        
        player_Info[msg.sender].rate = _rate;
        player_Info[msg.sender].finishBait = true;
    }
    
    function Fishing() public{
        require(player_Info[msg.sender].finishRod && player_Info[msg.sender].finishBait);
        uint payValue = player_Info[msg.sender].payValue;
        uint fishType;
        // uint8 random;
        uint getMoney = 0;
        
        player_Info[msg.sender].fishTyp.length = 0;
        player_Info[msg.sender].money = 0;
        
        bytes32 randomSeed = keccak256(abi.encodePacked(now, rand()));
        
        
        for(uint i = 0 ; i < player_Info[msg.sender].count ; i++){
            uint random = uint8(randomSeed[i * 2]) % 163 + player_Info[msg.sender].rate;
            if(random > 163){
                random = 163;
            }
        
            if(random < 10){                        //10%
                fishType = 0;
            }else if(random >= 11 && random <= 30){     //20%
                fishType = 1;
                getMoney = getMoney.add(100e8);
            }else if(random >= 31 && random <= 50){     //20%
                fishType = 2;
                getMoney = getMoney.add(100e8);
            }else if(random >= 51 && random <= 68){     //18%
                fishType = 3;
                getMoney = getMoney.add(200e8);
            }else if(random >= 69 && random <= 86){     //18% 
                fishType = 4;
                getMoney = getMoney.add(200e8);
            }else if(random >= 87 && random <= 103){    //17%  
                fishType = 5;
                getMoney = getMoney.add(300e8);
            }else if(random >= 104 && random <= 118){   //15%
                fishType = 6;
                getMoney = getMoney.add(500e8);
            }else if(random >= 119 && random <= 133){   //15%
                fishType = 7;
                getMoney = getMoney.add(500e8);
            }else if(random >= 134 && random <= 145){   //12%
                fishType = 8;
                getMoney = getMoney.add(800e8);
            }else if(random >= 146 && random <= 153){   //8%
                fishType = 9;
                getMoney = getMoney.add(1000e8);
            }else if(random >= 154 && random <= 158){   //5%
                fishType = 10;
                getMoney = getMoney.add(1500e8);
            }else if(random >= 159 && random <= 161){   //3%
                fishType = 11;
                getMoney = getMoney.add(2000e8);
            }else if(random >= 162){                    //2%
                fishType = 12;
                getMoney = getMoney.add(5000e8);
            }
            emit everyResult(msg.sender,i,fishType);
            player_Info[msg.sender].fishTyp.push(fishType); //紀載每次釣到的魚種
        }
    
        if(getMoney != 0){
            // msg.sender .transfer(getMoney);
            checkAndSend(getMoney, payValue, msg.sender);
            player_Info[msg.sender].money = getMoney;
        }
        
        emit finalResult(msg.sender,getMoney);
        
        //清空
        player_Info[msg.sender].count = 0;
        player_Info[msg.sender].rate = 0;
        player_Info[msg.sender].finishRod = false;
        player_Info[msg.sender].finishBait = false;
        player_Info[msg.sender].payValue = 0;
        
    }
    
    function inquireInfo(address _address) public view returns(uint[] memory){         //查詢玩家最新一次釣魚結果結果
        return player_Info[_address].fishTyp;
    }
    
    function inquireMoney(address _address) public view returns(uint){           //查詢玩家執行完後所獲得金額
        return (player_Info[_address].money);
    }
    
}
