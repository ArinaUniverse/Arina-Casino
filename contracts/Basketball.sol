pragma solidity >=0.5.0 <0.6.0;

import "./connectChips.sol";

contract Manager{

    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Is not owner");
        _;
    }

    function transferownership(address _new_manager) public onlyManager {
        manager = _new_manager;
    }
}

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

contract Basketball is Manager, ConnectChips{
    
    using SafeMath for uint;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    
    mapping(address => role) private player_Info;
    
    //事件
    event noResult(address indexed player,uint8 no,uint8 PAType, uint8 PResult, uint8 AIAType, uint8 AIResult);
    event finalResult(address indexed player,uint8 playerTotal, uint8 oppTotal, uint8 result); //比賽結果  result => 1 = 贏  2 = 輸  3 = 平手
     
    struct info{
        uint8 _type;
        uint8 speed;
        uint8 shooting;
        uint8 jumping;
        uint8 defense;
        uint8 avatar;
    }
    
    struct role{
        info self;             //玩家能力
        info opponent;         //對手能力
        bool starGame;
        bool betGame;
        uint8 count;           //局數
        uint8[] PScore;
        uint8[] AIScore;
        uint8[] PType;
        uint8[] AIType;
        uint8[] PResult;
        uint8[] AIResult;
        uint8 PtotScore;       //玩家總分
        uint8 AItotScore;      //對手總分
        uint betMoney;
    }
    
    function() external payable{}

    function getRandom() private view returns (uint256) {
        uint256[1] memory m;
        assembly {
            if iszero(staticcall(not(0), 0xC327fF1025c5B3D2deb5e3F0f161B3f7E557579a,0, 0x0, m, 0x20)) {
                revert(0, 0)
            }
        }
        return m[0];
    }
    
    function StartGame(uint8 _type) public {
        require(!player_Info[msg.sender].starGame);
        require(_type >= 0 && _type < 4,"Your type is wrong");
        uint8 _speed;
        uint8 _shooting;
        uint8 _jumping;
        uint8 _defense;
        uint8 _avatar;
        uint8 oppType = uint8(getRandom() % 4);
        
        (_speed, _shooting, _jumping, _defense, _avatar) = typeToInfo(_type);   //賦予玩家素質
        player_Info[msg.sender].self._type = _type;
        player_Info[msg.sender].self.speed = _speed;
        player_Info[msg.sender].self.shooting = _shooting;
        player_Info[msg.sender].self.jumping = _jumping;
        player_Info[msg.sender].self.defense = _defense;
        player_Info[msg.sender].self.avatar = _avatar;
        
        (_speed, _shooting, _jumping, _defense, _avatar) = typeToInfo(oppType); //賦予對手素質
        player_Info[msg.sender].opponent._type = oppType;
        player_Info[msg.sender].opponent.speed = _speed;
        player_Info[msg.sender].opponent.shooting = _shooting;
        player_Info[msg.sender].opponent.jumping = _jumping;
        player_Info[msg.sender].opponent.defense = _defense;
        player_Info[msg.sender].opponent.avatar = _avatar;
        
        player_Info[msg.sender].PScore.length = 0;
        player_Info[msg.sender].AIScore.length = 0;
        player_Info[msg.sender].PType.length = 0;
        player_Info[msg.sender].AIType.length = 0;
        player_Info[msg.sender].PResult.length = 0;
        player_Info[msg.sender].AIResult.length = 0;
        
        player_Info[msg.sender].PtotScore = 0;
        player_Info[msg.sender].AItotScore = 0;
        player_Info[msg.sender].count = 0;
        player_Info[msg.sender].betMoney = 0;
        
        
        player_Info[msg.sender].starGame = true;
    }
    
    
    function BetGame() public payable {                         //下注
        require(player_Info[msg.sender].starGame);
        require(!player_Info[msg.sender].betGame);
        require(msg.value >= 1 ether && msg.value <= 10 ether);
        player_Info[msg.sender].betMoney = msg.value;
        player_Info[msg.sender].betGame = true;
  
    }
    
    function Attack(uint8 _atkType) public {                    //攻擊
        
        require(player_Info[msg.sender].betGame);
        require(_atkType >=0 && _atkType < 3);
        require(player_Info[msg.sender].count < 5);
        
        player_Info[msg.sender].count++;                        //場次+1
        
        uint8 opp_atkType = uint8(getRandom() % 3);             //對手攻擊類型
        uint8 _speed;
        uint8 _shooting;
        uint8 _jumping;
        uint8 _def;
        uint8 _PScore = 0;
        uint8 _AIScore = 0;
        uint8 pResult;
        uint8 aiResult;
         
        _speed = player_Info[msg.sender].self.speed;
        _shooting = player_Info[msg.sender].self.shooting;
        _jumping = player_Info[msg.sender].self.jumping;
        _def = player_Info[msg.sender].opponent.defense;
        
        if(_atkType == 0){
            (pResult,_PScore) = TwoShooting(_speed,_shooting,_jumping,_def);
        }else if(_atkType == 1){
            (pResult,_PScore) = ThreeShooting(_speed,_shooting,_jumping,_def);
        }else if(_atkType == 2){
            (pResult,_PScore) = SlamDunk(_speed,_shooting,_jumping,_def);
        }
        
        _speed = player_Info[msg.sender].opponent.speed;
        _shooting = player_Info[msg.sender].opponent.shooting;
        _jumping = player_Info[msg.sender].opponent.jumping;
        _def = player_Info[msg.sender].self.defense;
        
        if(opp_atkType == 0){
            (aiResult,_AIScore) = TwoShooting(_speed,_shooting,_jumping,_def);
        }else if(opp_atkType == 1){
            (aiResult,_AIScore) = ThreeShooting(_speed,_shooting,_jumping,_def);
        }else if(opp_atkType == 2){
            (aiResult,_AIScore) = SlamDunk(_speed,_shooting,_jumping,_def);
        }
        
        emit noResult(msg.sender,player_Info[msg.sender].count,_atkType, pResult, opp_atkType, aiResult);
        
        player_Info[msg.sender].PtotScore = player_Info[msg.sender].PtotScore.add(_PScore);     //玩家分數累計
        player_Info[msg.sender].AItotScore = player_Info[msg.sender].AItotScore.add(_AIScore);  //敵人分數累計
        
        player_Info[msg.sender].PScore.push(_PScore);           //該局玩家分數放入陣列
        player_Info[msg.sender].PType.push(_atkType);
        player_Info[msg.sender].PResult.push(pResult);
        
        player_Info[msg.sender].AIScore.push(_AIScore);         //該局敵人分數放入陣列
        player_Info[msg.sender].AIType.push(opp_atkType);
        player_Info[msg.sender].AIResult.push(aiResult);
        
        if(player_Info[msg.sender].count == 5){
            EndGame();
        }
        

    }
    
    function TwoShooting(uint8 _speed,uint8 _shooting, uint8 _jumping, uint8 _def) private view returns(uint8 result, uint8 caller_score){ 
    //2分射籃    
        uint[4] memory random;

        random[0] = getRandom();
        random[1] = getRandom();
        random[2] = getRandom();
        random[3] = getRandom();
           

        uint16 caller_Atk = 0;
        uint16 opp_Def = 0;
        
        caller_Atk = caller_Atk.add(uint16(_speed).mul(uint16(random[0]) % 51 + 30).div(100));
        caller_Atk = caller_Atk.add(uint16(_shooting).mul(uint16(random[1]) % 31 + 60).div(100));
        caller_Atk = caller_Atk.add(uint16(_jumping).mul(uint16(random[2]) % 51 + 30).div(100));
        
        opp_Def = uint16(_def).mul(uint16(random[3]) % 31 + 70).div(100);
        if((caller_Atk - opp_Def) >= 100){
            caller_score = 2;
            result = 1;
        }else{
            caller_score = 0;
            result = 0;
        }

    }
    
    function ThreeShooting(uint8 _speed,uint8 _shooting, uint8 _jumping, uint8 _def) private view returns(uint8 result, uint8 caller_score){ 
    //3分線射籃   
        uint[4] memory random;

        random[0] = getRandom();
        random[1] = getRandom();
        random[2] = getRandom();
        random[3] = getRandom();

        uint16 caller_Atk = 0;
        uint16 opp_Def = 0;
        
        caller_Atk = caller_Atk.add(uint16(_speed).mul(uint16(random[0]) % 41 + 10).div(100));
        caller_Atk = caller_Atk.add(uint16(_shooting).mul(uint16(random[1]) % 61 + 40).div(100));
        caller_Atk = caller_Atk.add(uint16(_jumping).mul(uint16(random[2]) % 31 + 20).div(100));
        
        opp_Def = uint16(_def).mul(uint16(random[3]) % 31 + 50).div(100);
        if((caller_Atk - opp_Def) >= 100){
            caller_score = 3;
            result = 1;
        }else{
            caller_score = 0;
            result = 0;
        }

    }
    
    function SlamDunk(uint8 _speed,uint8 _shooting, uint8 _jumping, uint8 _def) private view returns(uint8 result, uint8 caller_score){ 
    //禁區灌籃   
        uint[4] memory random;

        random[0] = getRandom();
        random[1] = getRandom();
        random[2] = getRandom();
        random[3] = getRandom();

        uint16 caller_Atk = 0;
        uint16 opp_Def = 0;
        
        caller_Atk = caller_Atk.add(uint16(_speed).mul(uint16(random[0]) % 31 + 50).div(100));
        caller_Atk = caller_Atk.add(uint16(_shooting).mul(uint16(random[1]) % 11 + 20).div(100));
        caller_Atk = caller_Atk.add(uint16(_jumping).mul(uint16(random[2]) % 51 + 50).div(100));
        
        opp_Def = uint16(_def).mul(uint16(random[3]) % 31 + 50).div(100);
        if((caller_Atk - opp_Def) >= 100){
            caller_score = 2;
            result = 1;
        }else{
            caller_score = 0;
            result = 0;
        }

    }
    
    function EndGame() private{
        require(player_Info[msg.sender].count == 5);
        uint8 PtotScore = player_Info[msg.sender].PtotScore;
        uint8 AItotScore = player_Info[msg.sender].AItotScore;
        uint8 subScore;
        uint8 winRate;
        
        if(PtotScore == AItotScore){                        //平手拿回本金
            msg.sender.transfer(player_Info[msg.sender].betMoney);
            emit finalResult(msg.sender,PtotScore,AItotScore,3);
        }else if(PtotScore > AItotScore){                   //玩家獲勝
            subScore = PtotScore - AItotScore;
            if(subScore < 4){
                winRate = 1;
            }else if(subScore < 7){
                winRate = 2;
            }else if(subScore < 10){
                winRate = 3;
            }else if(subScore < 13){
                winRate = 4;
            }else if(subScore < 16){
                winRate = 5;
            }
            emit finalResult(msg.sender,PtotScore,AItotScore,1);
            msg.sender.transfer(player_Info[msg.sender].betMoney.mul(winRate));
        }else{
             emit finalResult(msg.sender,PtotScore,AItotScore,2);
        }
 
        
        player_Info[msg.sender].starGame = false;
        player_Info[msg.sender].betGame = false;
    
    }
    
    function typeToInfo(uint8 _type) private view returns(uint8 _speed, uint8 _shooting, uint8 _jumping, uint8 _defense, uint8 _avatar){
    //產生素質    
        uint random1 = getRandom();
        uint random2 = getRandom();
        uint random3 = getRandom();
        uint random4 = getRandom();
        
        if(_type == 0){
            _speed = uint8(random1) % 21 + 70;
            _shooting = uint8(random2) % 21 + 70;
            _jumping = uint8(random3) % 21 + 70;
            _defense = uint8(random4) % 21 + 70;
            
        }else if(_type == 1){
            _speed = uint8(random1) % 21 + 60;
            _shooting = uint8(random2) % 21 + 80;
            _jumping = uint8(random3) % 21 + 60;
            _defense = uint8(random4) % 21 + 40;
        }else if(_type == 2){
            _speed = uint8(random1) % 21 + 60;
            _shooting = uint8(random2) % 31 + 40;
            _jumping = uint8(random3) % 21 + 80;
            _defense = uint8(random4) % 11 + 80;
        }else if(_type == 3){
            _speed = uint8(random1) % 21 + 80;
            _shooting = uint8(random2) % 11 + 60;
            _jumping = uint8(random3) % 21 + 60;
            _defense = uint8(random4) % 21 + 60;
        }
        
        _avatar = uint8(random1.div(10)) % 10;

    }
    
    //inquire
    function inquireETH() public view returns(uint){
        return address(this).balance;
    }
    
    function inquireProcess(address _address) public view returns(uint8){
        if(!player_Info[_address].starGame && !player_Info[_address].betGame){
            return 0;
        }else if(player_Info[_address].starGame){
            return 1;
        }else if(player_Info[_address].betGame && player_Info[_address].PScore.length == 0){
            return 2;
        }
    }
    
    function inquireGame(address _address, uint8 no) public view returns(uint8 _no, uint8 _PScore, uint8 _PAType,uint8 _PResult,uint8 _AIScore, uint8 _AIAType,uint8 _AIResult){
        require(_no < player_Info[_address].PScore.length && _no < 5);
        
        _no = no; 
        _PScore = player_Info[_address].PScore[no];
        _PAType = player_Info[_address].PType[no];
        _PResult = player_Info[_address].PResult[no];
        _AIScore = player_Info[_address].AIScore[no];
        _AIAType = player_Info[_address].AIType[no];
        _AIResult = player_Info[_address].AIResult[no];
    }
    
    function inquireSelf(address _address) public view returns(uint8 _type, uint8 _speed, uint8 _shooting,uint8 _jumping, uint8 _defense,uint8 _avatar,uint8 _PtotScore){
        _type = player_Info[_address].self._type;
        _speed = player_Info[_address].self.speed;
        _shooting = player_Info[_address].self.shooting;
        _jumping = player_Info[_address].self.jumping;
        _defense = player_Info[_address].self.defense;
        _avatar = player_Info[_address].self.avatar;
        _PtotScore = player_Info[_address].PtotScore;
    }
    
    function inquireOpp(address _address) public view returns(uint8 _type,uint8 _speed, uint8 _shooting,uint8 _jumping, uint8 _defense,uint8 _avatar,uint8 _AItotScore){
        _type = player_Info[_address].opponent._type;
        _speed = player_Info[_address].opponent.speed;
        _shooting = player_Info[_address].opponent.shooting;
        _jumping = player_Info[_address].opponent.jumping;
        _defense = player_Info[_address].opponent.defense;
        _avatar = player_Info[_address].opponent.avatar;
        _AItotScore = player_Info[_address].AItotScore;
    }
    
    //================================test
    // function inqTest() public view returns(uint8 _cnt,bool _starGame, bool _betGame){

    //     _cnt = player_Info[msg.sender].count;
    //     _starGame = player_Info[msg.sender].starGame;
    //     _betGame = player_Info[msg.sender].betGame;
  
    // }

    //Manager
    function withdraw_allETH() public onlyManager{
        manager.toPayable().transfer(address(this).balance);
    }
    

}














