pragma solidity >=0.5.0 <0.6.0;
import "./math.sol";

library LCTBase{

    struct lctbase{
        uint[] _gold;
        uint[] _silver;
        uint[] _copper;
    }

    function gold(lctbase storage l) internal view returns(uint[] memory){
        return l._gold;
    }

    function goldAmount(lctbase storage l) internal view returns(uint){
        return l._gold.length;
    }

    function plusGold(lctbase storage l, uint tokenId) internal{
        l._gold.push(tokenId);
    }

    function delGold(lctbase storage l, uint tokenId) internal{
        delItem(l._gold, tokenId);
    }


    function silver(lctbase storage l) internal view returns(uint[] memory){
        return l._silver;
    }

    function silverAmount(lctbase storage l) internal view returns(uint){
        return l._silver.length;
    }

    function plusSilver(lctbase storage l, uint tokenId) internal{
        l._silver.push(tokenId);
    }

    function delSilver(lctbase storage l, uint tokenId) internal{
        delItem(l._silver, tokenId);
    }


    function copper(lctbase storage l) internal view returns(uint[] memory){
        return l._copper;
    }

    function copperAmount(lctbase storage l) internal view returns(uint){
        return l._copper.length;
    }

    function plusCopper(lctbase storage l, uint tokenId) internal{
        l._copper.push(tokenId);
    }

    function delCopper(lctbase storage l, uint tokenId) internal{
        delItem(l._copper, tokenId);
    }


    function delItem(uint[] storage a, uint tokenId) internal{
        uint i;
        for (i = 0; i < a.length; i++) {
            if (a[i] == tokenId) {
                break;
            }
        }
        assert(i < a.length);

        a[i] = a[a.length - 1];
        delete a[a.length - 1];
        a.length--;
    }

}


library LCTInfo {

    using SafeMath for uint;

    struct amount{
        uint gold;
        uint silver;
        uint copper;
    }

    function current(amount storage a, uint8 typ) internal view returns (uint256) {

        if(typ == 1){
            return a.copper;
        }else if(typ == 2){
            return a.silver;
        }else if(typ == 3){
            return a.gold;
        }else{
            revert("Cat type error");
        }
    }

    function increment(amount storage a, uint8 typ) internal {
        
        if(typ == 1){
            a.copper += 1;
        }else if(typ == 2){
            a.silver += 1;
        }else if(typ == 3){
            a.gold += 1;
        }else{
            revert("Cat type error");
        }
    }

    function decrement(amount storage a, uint8 typ) internal {

        if(typ == 1){
            a.copper = a.copper.sub(1);
        }else if(typ == 2){
            a.silver = a.silver.sub(1);
        }else if(typ == 3){
            a.gold = a.gold.sub(1);
        }else{
            revert("Cat type error");
        }
    }
}