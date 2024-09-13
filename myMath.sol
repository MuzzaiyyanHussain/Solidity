//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract myMath {
    uint256 public myUint;

    function setMyUint(uint256 _myUint) public {
        myUint = _myUint;
    }

    function incrementUint() public {
        myUint++;
    }

    function decrementUint() public {
        myUint--;
    }
}
