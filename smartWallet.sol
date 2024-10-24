//SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

contract mySmartContractWallet {
    address payable public owner;
    mapping(address => uint256) public allowance;
    mapping(address => bool) public isAllowedToSend;
    mapping(address => bool) public guardians;
    mapping(address => mapping(address => bool)) nextOwnerGuardianVotedBool;
    address payable nextOwner;
    uint256 guardiansResetCount;
    uint256 public constant confirmationFromGuardiansForReset = 3;

    constructor() {
        owner = payable(msg.sender);
    }

    function setGuardian(address _guardian, bool isGuardian) public {
        require(msg.sender == owner, "You are not the owner, Aborting!!!");
        guardians[_guardian] = isGuardian;
    }

    function proposeNewOwner(address payable newOwner) public {
        require(
            guardians[msg.sender],
            "You are not guardian of this wallet, Aborting!!!"
        );

        require(
            nextOwnerGuardianVotedBool[newOwner][msg.sender] == false,
            "You already voted, Aborting!!!"
        );
        if (newOwner != nextOwner) {
            nextOwner = newOwner;
            guardiansResetCount = 0;

            guardiansResetCount++;

            if (guardiansResetCount >= confirmationFromGuardiansForReset) {
                owner = nextOwner;
                nextOwner = payable(address(0));
            }
        }
    }

    function setAllowance(address _for, uint256 _amount) public {
        require(msg.sender == owner, "You are not the owner, Aborting!!!");
        allowance[msg.sender] = _amount;

        if (_amount > 0) {
            isAllowedToSend[_for] = true;
        } else {
            isAllowedToSend[_for] = false;
        }
    }

    function transfer(
        address payable _to,
        uint256 _amount,
        bytes memory _payload
    ) public returns (bytes memory) {
        //   require(msg.sender == owner, "You are not an owner, Aborting!!!");

        if (msg.sender != owner) {
            require(
                allowance[msg.sender] >= _amount,
                "You are sending more than you are allowed to, Aborting!!!"
            );

            require(
                isAllowedToSend[msg.sender],
                "You are not allowed to send anything from this smart contract, Aborting!!!"
            );
            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(
            _payload
        );
        require(success, "Aborting, call was not successfull");
        return returnData;
    }

    receive() external payable {}
}
