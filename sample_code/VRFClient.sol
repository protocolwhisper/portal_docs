// SPDX-License-Identifier: Apache-2.0

/*
 * Copyright 2022, Portal Oracle Foundation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC777/ERC777.sol";

contract PRTLToken is ERC777 {
    constructor(uint256 initialSupply, address[] memory defaultOperators)
        ERC777("Portal Token", "PRTL", defaultOperators)
    {
        _mint(msg.sender, initialSupply, "", "");
    }
}

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/utils/introspection/IERC1820Registry.sol";

contract VRFClientBase {
    // Reference to the ERC1820 Registry contract available on all chains
    IERC1820Registry internal constant _ERC1820_REGISTRY =
        IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    constructor() {
        // Tell erc1820 registry that this contract can send PRTL 
        _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this), // account
            keccak256("ERC777TokensSender"), // interfaceHash
            address(this) // implementer
        );
        // Tell erc1820 registry that this contract can receive PRTL 
         _ERC1820_REGISTRY.setInterfaceImplementer(
            address(this), // account
            keccak256("ERC777TokensRecipient"), // interfaceHash
            address(this) // implementer
        );
    }
    
    // The required interface so this contract can send PRTL
    function tokensToSend(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        // insert logic here to run before contract sends PRTL
    }

    // The required interface so this contract can receive PRTL
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external {
        // when tokens arrive at this contract…
    }
}

contract VRFClient is VRFClientBase {
    address owner;
    uint256 public diceRoll;
    uint256 constant NUM_SIDES = 6;
    event DiceRolled(bytes32 _randomness, uint256 _diceRoll);

    // For referencing VRFServiceOIC and PRTLToken contracts
    address VRFServiceOICAddress; 
    PRTLToken PRTL;

    constructor(address _VRFServiceOICAddress, address _PRTLTokenAddress) VRFClientBase() {
        owner = msg.sender;
        VRFServiceOICAddress = _VRFServiceOICAddress;
        PRTL = PRTLToken(_PRTLTokenAddress);
    }

    // This function makes a VRF request to the VRFServiceOIC contract.
    // The contract's PRTL is locked in the VRFServiceOIC until the VRF
    // request is fulfilled, at which point any excess PRTL is refunded. 
    // @ _workerId: the id of the worker enclave that will fulfill the request
    // @ _fullVerify: if true will run verification on-chain (~2M gas), else 
    // accepts the result as is since verification was run by the node off-chain.
    function requestVRF(uint32 _workerId, bool _fullVerify) external onlyOwner {
        // The amount of PRTL to lock as part of this VRF request
        uint256 _prtlAmount = 5000000000000000000; // 5 PRTL
        require(PRTL.balanceOf(address(this)) >= _prtlAmount, "Contract has insufficient PRTL!");
        
        // max amount of gas allocated to callback function - remaining gas is refunded as PRTL
        uint32 _maxCallbackGas = 200000;
        
        // address of the contract with the 'rawFulfillVRF(bytes32)' callback function
        address _callbackAddr = address(this);

        // Encode the parameters as bytes which are forwarded with the PRTL
        bytes memory payload = abi.encode(_workerId, _maxCallbackGas, _callbackAddr, _fullVerify);

        // Send PRTL to the OIC contract to be locked and initiate the VRF request
        PRTL.send(VRFServiceOICAddress, _prtlAmount, payload);
    }

    // The function the VRFServiceOIC will call to fulfill the request
    function rawFulfillVRF(bytes32 _randomness) external {
        require(msg.sender == VRFServiceOICAddress, "Only Enclave can fulfill");
        // call the user defined callback()
        fulfillVRF(_randomness);
    }

    // This is the user's callback function. Only the specified VRFServiceOIC contract 
    // can call this function. Any logic to consume the _randomness is implemented here:
    function fulfillVRF(bytes32 _randomness) internal {
        // random dice roll between [1,NUM_SIDES]
        diceRoll = (uint256(_randomness) % NUM_SIDES) + 1;

        // Perform some action using result
        // - mint nft
        // - run lottery
        // - game action
        // ...  

        // Emit an event to notify a frontend
        emit DiceRolled(_randomness, diceRoll);
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
}