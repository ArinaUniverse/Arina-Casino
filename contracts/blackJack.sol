pragma solidity >=0.5.0 <0.6.0;

import "./math.sol";
import "./ConnectChips.sol";

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

contract blackJack is Manager, ConnectChips{
    using SafeMath for uint;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    
    mapping(address => info) player_info;
    
    //事件
    event startResult(address indexed player,uint8 result);             //開局結果(result => 0=都沒有/1=都有平手/2=只有玩家21點/3=只有莊家21點)
    event playerStartCards(address indexed player,uint playerCard1,uint8 playerCard2);   //玩家發牌的點數
    event playerHit(address indexed player,uint count,uint8 newCard);   //玩家發牌的點數
    event playTotal(address indexed player,uint8[] playerCard);         //玩家手上牌的總點數
    event bankCard1(address indexed player,uint8 bankerCard1);          //莊家第一張牌
    event bankCard2(address indexed player,uint8 bankerCard2);          //莊家第二張牌
    event bankTotal(address indexed player,uint8[] bankerCard);         //莊家手上牌的總點數
    event gameOver(uint8 result,uint8 playerCard,uint8 bankerCard);     //比賽結果  result => 1 = 贏  2 = 輸  3 = 平手
    
    struct info{
        uint money;
        uint8[]  Banker_Card;
        uint8[]  Player_Card;
        bool[52]  check_Num;
        bool Banker_InGame;
        bool Player_InGame;
        bool endGame;
    }
    

    function startGame(uint value) public{
        
        payToGame(value);

        require(!player_info[msg.sender].Player_InGame && !player_info[msg.sender].Banker_InGame,
        "Player in game");
        require(!player_info[msg.sender].endGame,"Game not over");
        require(value <= 10000e8 && value >= 100e8, "Not enough money");
        player_info[msg.sender].money = value;
        uint8 ran_num;
        uint8[4] memory new_num;
        uint8 play_total;
        uint8 bank_total;
        uint8 cnt = 0;
        
        do{
            ran_num = uint8(rand()) % 52 + 1;
            
            if(!player_info[msg.sender].check_Num[ran_num - 1]){
                player_info[msg.sender].check_Num[ran_num - 1] = true;
                new_num[cnt] = ran_num;
                cnt++;
            }
             
        }while(cnt < 4);

        player_info[msg.sender].Banker_Card.push(new_num[0]);
        player_info[msg.sender].Banker_Card.push(new_num[1]);
        player_info[msg.sender].Player_Card.push(new_num[2]);
        player_info[msg.sender].Player_Card.push(new_num[3]);

  
        emit playerStartCards(msg.sender,player_info[msg.sender].Player_Card[0],player_info[msg.sender].Player_Card[1]);
        emit bankCard1(msg.sender,player_info[msg.sender].Banker_Card[0]);
        play_total = transform(player_info[msg.sender].Player_Card);
        bank_total = transform(player_info[msg.sender].Banker_Card);
        
        if(play_total == 21 && bank_total!= 21){        //只有玩家21點
            // player_info[msg.sender].Banker_InGame = true;
            player_info[msg.sender].endGame = true;
            emit startResult(msg.sender,2);
        }else if(play_total == 21 && bank_total == 21){ //玩家莊家都21點
            // player_info[msg.sender].Banker_InGame = true;
            player_info[msg.sender].endGame = true;
            emit startResult(msg.sender,1);
        }else if(play_total != 21 && bank_total == 21){ //只有莊家21點
            // player_info[msg.sender].Player_InGame = true;
            player_info[msg.sender].endGame = true;
            emit startResult(msg.sender,3);
        }else{
            player_info[msg.sender].Player_InGame = true;
            emit startResult(msg.sender,0);
        }

        //sendPool(msg.value);
    }

    function Player_Hit() public {                  //玩家補牌
        require(player_info[msg.sender].Player_InGame,"player isn't in game");
        require(!player_info[msg.sender].endGame,"The game is over");
        uint8 cnt = 0;
        uint8 total = 0;
        uint8 ran_num;

        do{
            ran_num = uint8(rand()) % 52 + 1;

            if(!player_info[msg.sender].check_Num[ran_num - 1]){
                player_info[msg.sender].check_Num[ran_num - 1] = true;
                player_info[msg.sender].Player_Card.push(ran_num);
                cnt++;
            }
        }while(cnt < 1);
    
        total = transform(player_info[msg.sender].Player_Card);
        emit playerHit(msg.sender, player_info[msg.sender].Player_Card.length, ran_num);
        if(total > 21){
            player_info[msg.sender].endGame = true;
        }
    }
    
    function Player_Stand() public {                //玩家發牌結束，等待莊家發牌
        require(player_info[msg.sender].Player_InGame,"player isn't in game");
        require(!player_info[msg.sender].endGame,"Game over");
        emit playTotal(msg.sender,player_info[msg.sender].Player_Card);
        emit bankCard2(msg.sender,player_info[msg.sender].Banker_Card[1]);
        player_info[msg.sender].Player_InGame = false;
        player_info[msg.sender].Banker_InGame = true;

    }
    
    function Banker_ShowCard() public {
        require(player_info[msg.sender].Banker_InGame,"player isn't in stand");
        uint8 bank_total = 0;
        uint8 player_total = 0;

        bank_total = transform(player_info[msg.sender].Banker_Card);
      
        player_total = transform(player_info[msg.sender].Player_Card);
        
        if(bank_total < player_total && bank_total <= 17){
            do{
                Banker_Hit();
            }while(transform(player_info[msg.sender].Banker_Card) < player_total && transform(player_info[msg.sender].Banker_Card) <= 17);
            
        }
        emit bankTotal(msg.sender,player_info[msg.sender].Banker_Card);
        player_info[msg.sender].endGame = true;
        player_info[msg.sender].Banker_InGame = false;
    }
    
    function Banker_Hit() private {                  //莊家補牌
        // require(player_info[msg.sender].Banker_InGame,"Banker isn't in game");
        uint8 cnt = 0;
        uint8 total = 0;
        uint8 bank_total = 0;
        uint8 player_total = 0;
 
        bank_total =  transform(player_info[msg.sender].Banker_Card);
        player_total = transform(player_info[msg.sender].Player_Card);
        
        // require(bank_total < player_total,"require player_total > bank_total"); //莊家點數必須小於玩家點數
        
        do{
            uint8 ran_num = uint8(rand()) % 52 + 1;
            
            if(!player_info[msg.sender].check_Num[ran_num - 1]){
                player_info[msg.sender].check_Num[ran_num - 1] = true;
                player_info[msg.sender].Banker_Card.push(ran_num);
                cnt++;
            }
        }while(cnt < 1);

        total = transform(player_info[msg.sender].Banker_Card);
        
        if(total > 21){     //莊家爆掉，玩家獲勝
            player_info[msg.sender].endGame = true;
            player_info[msg.sender].Banker_InGame = false;
            
        }
    }
    
    function transform(uint8[] memory arr) private pure returns(uint8){        //玩家手中牌子點數加總
        uint8 total = 0;
        uint Ace11 = 1;
        bool checkAce = false;
 
        for(uint8 i = 0 ; i < arr.length; i++){
           if(arr[i] % 13 > 10 || arr[i] % 13 == 0){
                arr[i] = 10;
           }else if(arr[i] % 13 == 1){
                if((total + 11) > 21){
                    arr[i] = 1;
                }else{
                    arr[i] = 11;
                    checkAce = true;
                }
           }else{
                arr[i] = arr[i] % 13;
           }
           total+= arr[i];
           if(total > 21 && checkAce && Ace11 == 1){
                total = total - 10;
                Ace11 = Ace11.sub(1);
           }
        }
        return total;
    }
    
    function EndGame() public {
        uint betValue = player_info[msg.sender].money;
        require(player_info[msg.sender].endGame,"The game isn't over yet");
        uint8 playerTotal = transform(player_info[msg.sender].Player_Card);
        uint8 bankerTotal = transform(player_info[msg.sender].Banker_Card);

        if(playerTotal > bankerTotal && playerTotal < 22){  //玩家贏
            if(playerTotal == 21){
                checkAndSend(betValue.mul(3), betValue, msg.sender);
                //msg.sender.transfer(player_info[msg.sender].money.mul(3));
            }else{
                checkAndSend(betValue.mul(2), betValue, msg.sender);
                //msg.sender.transfer(player_info[msg.sender].money.mul(2));
            }
            emit gameOver(1,playerTotal,bankerTotal);
        }else if(bankerTotal > 21){                         //莊家爆點，玩家贏
            checkAndSend(betValue.mul(2), betValue, msg.sender);
            //msg.sender.transfer(player_info[msg.sender].money.mul(2));
            emit gameOver(1,playerTotal,bankerTotal);
        }
        else if(bankerTotal == playerTotal){                //平手
            checkAndSend(betValue, betValue, msg.sender);
            //msg.sender.transfer(player_info[msg.sender].money);
            emit gameOver(3,playerTotal,bankerTotal);
        }else{
            checkAndSend(0, betValue, msg.sender);
            emit gameOver(2,playerTotal,bankerTotal);       //玩家輸
        }
        clearData();
    }
    
    function clearData() private {                    //結束遊戲清空
    
        player_info[msg.sender].money = 0;
        player_info[msg.sender].Player_Card.length = 0;
        player_info[msg.sender].Banker_Card.length = 0;
        for(uint8 i = 0 ; i < player_info[msg.sender].check_Num.length; i++){
           if(player_info[msg.sender].check_Num[i] != false){
                player_info[msg.sender].check_Num[i] = false;
            }
        }
   
        player_info[msg.sender].Banker_InGame = false;
        player_info[msg.sender].Player_InGame = false;
        player_info[msg.sender].endGame = false;
    }
    
    function inquireBankerCard1(address _address) public view returns(uint8 card1){     //查看莊家第一張牌
        card1 = player_info[_address].Banker_Card[0];
    }
    
    function inquireBankerCard2(address _address) public view returns(uint8 card2){     //查看莊家第二張牌
        require(player_info[_address].Banker_InGame,"Banker not in game");
        card2 = player_info[_address].Banker_Card[1];
    }

    function inquirePlayer(address _address) public view returns(uint8[] memory, uint8){
       uint8 total = transform(player_info[_address].Player_Card);

       return (player_info[_address].Player_Card,total);
    }
    
    function inquireBanker(address _address) public view returns(uint8[] memory, uint8){
        require(player_info[_address].endGame,"Game not over");
        uint8 total = transform(player_info[_address].Banker_Card);

        return (player_info[_address].Banker_Card,total);
    }
    
    function inquireETH() public view returns(uint){
        return address(this).balance;
    }
    
    function withdraw_allETH() public onlyManager{
        manager.toPayable().transfer(address(this).balance);
    }
  
}