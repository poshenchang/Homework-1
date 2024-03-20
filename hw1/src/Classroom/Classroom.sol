// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/* Problem 1 Interface & Contract */
contract StudentV1 {
    bool called;

    function register() external returns (uint256) {
        if(called){
            return 123;
        }
        else{
            called = true;
            return 1000;
        }
    }
}

/* Problem 2 Interface & Contract */
interface IClassroomV2 {
    function isEnrolled() external view returns (bool);
}

contract StudentV2{
    function register() external view returns (uint256) {
        if(IClassroomV2(msg.sender).isEnrolled()){
            return 123;
        }
        else{
            return 1000;
        }
    }
}

/* Problem 3 Interface & Contract */
contract StudentV3 {
    function register() external view returns (uint256) {
        if(gasleft() >= 6660){
            return 1000;
        }
        else{
            return 123;
        }
    }
}
