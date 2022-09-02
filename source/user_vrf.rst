.. _developer_docs_vrf:

VRF Developer Docs
==================

Currently supported chains
--------------------------
.. csv-table:: Testnets
    :header: "Chain", "RPC Url", "chainId", "Currency", "Explorer", "Faucet"
    :widths: 100, 100, 100, 100, 100, 100

    "`Arbitrum Nitro Goerli Rollup <https://offchainlabs.com/>`_", "https://goerli-rollup.arbitrum.io/rpc", 421613, GoerliETH, "https://goerli-rollup-explorer.arbitrum.io", "https://goerlifaucet.com/"

    "`Optimism Goerli <https://www.optimism.io/>`_", "https://goerli.optimism.io", 420, "ETH", "https://goerli-optimism.etherscan.io/", "https://optimismfaucet.xyz/"



Requirements
------------
`Testnet ETH <https://eips.ethereum.org/EIPS/eip-777>`_ - from one of the supported chains above. 

`MetaMask <https://metamask.io/>`_ - to hold PRTL and testnet ETH and to sign off on transactions.

`Remix IDE <https://remix.ethereum.org/>`_ - to edit and deploy a VRFClient contract and easily interface with the testnet.



What is PRTL?
-------------
PRTL is an `ERC777 <https://eips.ethereum.org/EIPS/eip-777>`_ utility token based on `openzeppelin's implementation <https://docs.openzeppelin.com/contracts/4.x/erc777>`_ that is used to request oracle services.


.. code-block:: javascript

    pragma solidity ^0.8.0;

    import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.0.0/contracts/token/ERC777/ERC777.sol";

    contract PRTLToken is ERC777 {
        constructor(uint256 initialSupply, address[] memory defaultOperators)
            ERC777("Portal Token", "PRTL", defaultOperators)
        {
            _mint(msg.sender, initialSupply, "", "");
        }
    }

Requesting an oracle service is as simple as sending PRTL an Oracle Interface Contract. To get tamperproof randomness via Portal's Verifiable Randomness Function (VRF) service, PRTL should be sent to the VRFServiceOIC contract. Below are the addresses of the PRTLToken and VRFServiceOIC contracts on our supported chains.

Deployed contract addresses
---------------------------
.. csv-table:: Testnet contract addresses
    :header: "Chain", "PRTLToken", "VRFServiceOIC"
    :widths: 100, 100, 100

    "Arbitrum Nitro Goerli Rollup", 0x2BfDD7e69a7D527D000B7A34290e67326E5fb113, 0x6f349f7788Fa254aE99723487D120e2E55409e78 

    "Optimism Goerli", 0x83B4ad3f09087DEF9d8cFe069D56a1e79bB13006, 0x94a00834A8e147B5DA19B9748f1C2AA14488CC05

Getting PRTL
------------

Explore on Remix IDE
--------------------
insert a button?

Breaking down the contract
--------------------------
.. code-block:: javascript

    import "./VRFClientBase.sol";
    import "./PRTLToken.sol";

    contract VRFClient is VRFClientBase {
        address owner;
        uint256 public diceRoll;
        uint256 constant NUM_SIDES = 6;
        event DiceRolled(bytes32 _randomness, uint256 _diceRoll);

        // Hardcoded addresses of the VRFServiceOIC and PRTLToken
        address VRFServiceOICAddress = 0x6f349f7788Fa254aE99723487D120e2E55409e78;
        PRTLToken PRTL = PRTLToken(0x2BfDD7e69a7D527D000B7A34290e67326E5fb113);

        constructor() VRFClientBase() {
            owner = msg.sender;
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


Deploy a VRF client contract
----------------------------

Interacting with the contract
-----------------------------

.. image:: ../images/challenge_face.png


Integrating with your own Dapp
------------------------------
use can modify this
.. code-block:: javascript

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