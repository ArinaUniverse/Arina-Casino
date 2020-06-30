pragma solidity >= 0.5.0;

//debug 0.2.0

contract tool{
    function addressToString(address _addr) public pure returns(string memory) {
        bytes32 value = bytes32(uint256(_addr));
        bytes memory alphabet = "0123456789abcdef";
    
        bytes memory str = new bytes(42);
        str[0] = "0";
        str[1] = "x";
        for (uint i = 0; i < 20; i++) {
            str[2+i*2] = alphabet[uint(uint8(value[i + 12] >> 4))];
            str[3+i*2] = alphabet[uint(uint8(value[i + 12] & 0x0f))];
        }
        return string(str);
    }

    function uintToString(uint u) public pure returns (string memory str) {
        uint _u = u;
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (_u != 0) {
            uint remainder = _u % 10;
            _u = _u / 10;
            reversed[i++] = byte(uint8(48 + remainder));
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

    function strConcat(string memory _a, string memory _b) public pure returns (string memory){
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
 
        string memory ret = new string(
            _ba.length + _bb.length);
        bytes memory bret = bytes(ret);
        uint x = 0;
        for (uint i = 0; i < _ba.length; i++) bret[x++] = _ba[i];
        for (uint j = 0; j < _bb.length; j++) bret[x++] = _bb[j];

        return string(ret);
    }

}

contract debug is tool{

    function check(uint a, uint b, uint c) internal pure{
        string memory str = strConcat(strConcat(strConcat(strConcat(strConcat(
            "[debug]", uintToString(a) ), ","), uintToString(b)), ","), uintToString(c));

        revert(str);
    }

    function check(address x, uint b, uint c) internal pure{
        string memory str = strConcat(strConcat(strConcat(strConcat(strConcat(
            "[debug]", addressToString(x) ), ","), uintToString(b)), ","), uintToString(c));

        revert(str);
    }

    function check(uint a) internal pure{
        check(a, 0, 0);
    }

    function check(uint a, uint b) internal pure{
        check(a, b, 0);
    }

    function check(address x) internal pure{
        check(x, 0, 0);
    }

    function check(address x, uint b) internal pure{
        check(x, b, 0);
    }

}