pragma solidity >=0.5.0 <0.6.0;

import "./math.sol";
// import "./debug.sol";

interface ILCT {
    function inqRegistered(address player) external view returns(bool);
    function inqReferrer(address player) external view returns(address);
    function inqTeam() external view returns(address);
}

interface Ichip {
    function LCTadr() external view returns (address);
    //function sendToPlayer(address to, uint value) external;
    function distribute(uint value, bool toPlayer) external;
    function inqChips(address _address) external view returns(uint);
    function totPool() external view returns(uint);
    function transferCHIPS(address from, address to, uint value) external;
}

contract ConnectChips is math{

    address chipAddr;

    function () external payable{}

    function chip() public view returns(address){
        require(chipAddr != address(0), "pool address is not set");
        return chipAddr;
    }

    function setChip(address newChip) public{
        chipAddr = newChip;
    }

    function distribute(uint value, bool toPlayer) public{
        Ichip(chip()).distribute(value, toPlayer);
    }

    function sendToPlayer(address to, uint value) public{
        //Ichip(chip()).sendToPlayer(to, value);
        Ichip(chip()).transferCHIPS(address(this), to, value);
    }

    function payToGame(uint value) internal{
        Ichip(chip()).transferCHIPS(msg.sender, address(this), value);
    }
    
    function inqTeam() public view returns (address){
        return ILCT(LCTadr()).inqTeam();
    }

    function LCTadr() public view returns (address){
        return Ichip(chip()).LCTadr();
    }

    function inqRegistered(address player) public view returns(bool){
        return ILCT(LCTadr()).inqRegistered(player);
    }

    function inqReferrer(address player) public view returns(address){
        return ILCT(LCTadr()).inqReferrer(player);
    }

    function totPool() public view returns(uint){
        return Ichip(chip()).totPool();
    }

    function inqCHIPS(address _address) internal view returns(uint){
        Ichip(chip()).inqChips(_address);
    }

    function checkAndSend(uint profit, uint bet, address to) public{
        
        if(profit >= bet){ //此時玩家為贏
            
            // uint divided = 0;
            // sendToPlayer(msg.sender, divided); //為了讓輸贏的gas相似

            sendToPlayer(to, profit);

            uint referrerProfit = 0;
            if(inqRegistered(msg.sender)){  //玩家有註冊
                sendToPlayer(inqReferrer(msg.sender), referrerProfit);
            }else{
                sendToPlayer(inqTeam(), referrerProfit);
            }

        }else{ //此時玩家為輸

            sendToPlayer(to, profit);

            uint distri = bet.sub(profit);

            uint referrerProfit = distri.percent(10);
            uint newDistri = distri.percent(90);

            distribute(newDistri, true);

            if(inqRegistered(msg.sender)){  //玩家有註冊
                sendToPlayer(inqReferrer(msg.sender), referrerProfit);
            }else{
                sendToPlayer(inqTeam(), referrerProfit);
            }
        }

    }

}