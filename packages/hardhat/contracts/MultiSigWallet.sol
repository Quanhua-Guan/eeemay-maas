// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "./MultiSigMagician.sol";

contract MultiSigWallet {
    using ECDSA for bytes32;

    // keep a reference to the magician, for message forwarding
    MultiSigMagician private magician;

    // event Deposit with sender, ether amount, wallet balance
    event Deposit(
        address indexed sender,
        uint256 amount,
        uint256 balance
    );

    // event ExecuteTrasaction with executer(must be owner), receiver address,
    // ether amount, custom data(bytes), nonce, the execution hash and the execution result(bytes).
    event ExecuteTransaction(
        address indexed owner,
        address indexed to,
        uint256 value,
        bytes data,
        uint256 nonce,
        bytes32 hash,
        bytes result
    );

    // event OwnerChanged with related owner address, wheather added(true for added, false for removed)
    event OwnerChanged(address indexed owner, bool added);

    // keep owners' addresses
    address[] public owners;

    // use mapping to keep wheather a address is one of the owners' addresses
    mapping(address => bool) public isOwner;

    // multiSigs wallet should has a minimum signatures required when execute transaction
    uint256 public signaturesRequired;

    // the nonce
    uint256 public nonce;

    // the chainId
    uint256 public chainId;

    // modifier onlyOwner (one of the owners can execute)
    modifier onlyOwner() {
        require(isOwner[msg.sender], "not owner");
        _;
    }

    // modifier onlySelf (only the contract itself can execute)
    modifier onlySelf() {
        require(msg.sender == address(this), "not self(the contract itself)");
        _;
    }

    // modifier atLeast1Signatures (this is a multiSigs wallet, 0 signatures
    // required is meaningless and dangerous)
    modifier atLeast1Signatures(uint256 _signaturesRequired) {
        require(_signaturesRequired > 0, "at least 1 signatures required");
        _;
    }

    // the constructor, with chainId, owners' addresses(length should be >= 1), signatures required (should be >= 1), the magician contract address.
    // it should be payable, because when deploy the contract we want to send some ether to it.
    constructor(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired,
        address payable _multiSigMagician
    ) payable atLeast1Signatures(_signaturesRequired) {
        uint256 ownersCount = _owners.length;
        require(ownersCount > 0, "at least 1 owners required");
        require(
            _signaturesRequired <= ownersCount,
            "signatures required can't be greater than owners count"
        );

        chainId = _chainId;
        signaturesRequired = _signaturesRequired;
        magician = MultiSigMagician(_multiSigMagician);

        for (uint256 i = 0; i < ownersCount; i++) {
            address owner = _owners[i];

            require(owner != address(0), "invalid address(0)");
            require(!isOwner[owner], "duplicate owner address");

            isOwner[owner] = true;
            owners.push(owner);

            emit OwnerChanged(owner, true);
        }
    }

    /// === flowing function can only be executed by the contract itself === ///

    // add new Owner to this multisig wallet, with the new owner address, new signatures required when execute transaction.
    // can only be executed by the contract itself (use the onlySelf modifier)
    function addOwner(address _owner, uint256 _signaturesRequired)
        public
        onlySelf
        atLeast1Signatures(_signaturesRequired)
    {
        require(_owner != address(0), "invalid address(0)");
        require(!isOwner[_owner], "owner address already registered as owner");

        isOwner[_owner] = true;
        owners.push(_owner);

        require(
            _signaturesRequired <= owners.length,
            "signatures required cannot be greater than owners count"
        );
        signaturesRequired = _signaturesRequired;

        emit OwnerChanged(_owner, true);
        magician.emitOwners(address(this), owners, signaturesRequired);
    }

    // remove Owner from this multisig wallet, whih the owner address, new signatures required when execute transaction.
    // can only be executed by the contract itself
    function removeOwner(address _owner, uint256 _signaturesRequired)
        public
        onlySelf
        atLeast1Signatures(_signaturesRequired)
    {
        require(isOwner[_owner], "not a owner");
        uint256 ownersCount = owners.length;
        require(
            _signaturesRequired <= ownersCount - 1,
            "signatures required cannot be greater than owners count"
        );
        signaturesRequired = _signaturesRequired;

        delete isOwner[_owner];
        for (uint256 i = 0; i < ownersCount; i++) {
            address owner = owners[i];
            if (owner == _owner) {
                owners[i] = owners[ownersCount - 1];
                owners.pop();
                break;
            }
        }

        emit OwnerChanged(_owner, false);
        magician.emitOwners(address(this), owners, signaturesRequired);
    }

    // update signatures required when execute transactions for this wallet
    // can only be executed by the contract itself
    function updateSignaturesRequired(uint256 _signaturesRequired)
        public
        onlySelf
        atLeast1Signatures(_signaturesRequired)
    {
        require(
            _signaturesRequired <= owners.length,
            "signatures required cannot be greater than owners count"
        );
        signaturesRequired = _signaturesRequired;
    }

    /// === the tranction execution function === ///

    // execute transaction function, only for owner, with receiver address, ether amount, custom data
    // and signatures arr(should be sorted by the signer's address, ascending).
    function executeTransaction(
        address payable _receiver,
        uint256 _value,
        bytes calldata _data,
        bytes[] calldata _signatures
    ) public onlyOwner returns (bytes memory) {
        bytes32 _hash = getTransactionHash(nonce, _receiver, _value, _data);

        nonce++;

        // verify signature (recover signer's address with the hash and signature, then check if the address is one of the owners)
        uint256 validSignature;
        address duplicateGuard;

        for (uint256 i = 0; i < _signatures.length; i++) {
            bytes memory signature = _signatures[i];
            address recoveredAddress = recover(_hash, signature);

            require(
                duplicateGuard < recoveredAddress,
                "duplicate or unordered signatures"
            );
            duplicateGuard = recoveredAddress;

            if (isOwner[recoveredAddress]) {
                validSignature += 1;
            }
        }

        require(
            validSignature >= signaturesRequired,
            "not enough count of signatures"
        );

        (bool success, bytes memory result) = _receiver.call{value: _value}(
            _data
        );
        require(success, "call failed");

        emit ExecuteTransaction(
            msg.sender,
            _receiver,
            _value,
            _data,
            nonce - 1,
            _hash,
            result
        );

        return result;
    }

    /// === hash calculation & signer recovery functions === ///

    // getTransactionHash function with nonce, to address, ether amount, custom data
    // return bytes32 data
    function getTransactionHash(
        uint256 _nonce,
        address _receiver,
        uint256 value,
        bytes calldata data
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    address(this),
                    chainId,
                    _nonce,
                    _receiver,
                    value,
                    data
                )
            );
    }

    // recover signer address
    function recover(bytes32 _hash, bytes memory _signature)
        public
        pure
        returns (address)
    {
        return _hash.toEthSignedMessageHash().recover(_signature);
    }

    /// === the receive and fallback functions === ///

    // receive
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    // fallback
    fallback() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }
}
