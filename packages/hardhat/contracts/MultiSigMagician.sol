// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./MultiSigWallet.sol";

/// A magician who can create a new MultiSigWallet for you.
contract MultiSigMagician {
    MultiSigWallet[] public multiSigs;
    mapping(address => bool) existsMultiSig;

    event Create(
        uint256 indexed contractId,
        address indexed contractAddress,
        address creator,
        address[] owners,
        uint256 signaturesRequired
    );

    event Owners(
        address indexed contractAddress,
        address[] owners,
        uint256 indexed signaturesRequired
    );

    constructor() {}

    modifier onlyRegisteredWallet() {
        require(
            existsMultiSig[msg.sender],
            "caller must be create by the MultiSigMagician"
        );
        _;
    }

    function emitOwners(
        address _contractAddress,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) external onlyRegisteredWallet {
        emit Owners(_contractAddress, _owners, _signaturesRequired);
    }

    function create(
        uint256 _chainId,
        address[] memory _owners,
        uint256 _signaturesRequired
    ) public payable {
        uint256 walletId = multiSigs.length;

        MultiSigWallet multiSig = new MultiSigWallet{value: msg.value}(
            _chainId,
            _owners,
            _signaturesRequired,
            payable(address(this)) // pass the magician address to the wallet, the wallet may call `emitOwners` when it's `owners` changes
        );
        address walletAddress = address(multiSig);
        require(!existsMultiSig[walletAddress], "wallet already exists");

        multiSigs.push(multiSig);
        existsMultiSig[address(multiSig)] = true;

        emit Create(
            walletId,
            walletAddress,
            msg.sender,
            _owners,
            _signaturesRequired
        );
        emit Owners(walletAddress, _owners, _signaturesRequired);
    }

    function numberOfMultiSigs() public view returns (uint256) {
        return multiSigs.length;
    }

    function getMultiSig(uint256 _index)
        public
        view
        returns (
            address _walletAddress,
            uint256 _signaturesRequired,
            uint256 _balance
        )
    {
        MultiSigWallet wallet = multiSigs[_index];
        _walletAddress = address(wallet);
        _signaturesRequired = wallet.signaturesRequired();
        _balance = address(wallet).balance;
    }

    receive() external payable {}

    fallback() external payable {}
}

/*
⚽️ GOALS 🥅

[ ] can you edit and deploy the contract with a 2/3 multisig with two of your addresses and the buidlguidl multisig as the third signer? (buidlguidl.eth is like your backup recovery.) 
[ ] can you propose basic transactions with the frontend that sends them to the backend?
[ ] can you “vote” on the transaction as other signers? 
[ ] can you execute the transaction and does it do the right thing?
[ ] can you add and remove signers with a custom dialog (that just sends you to the create transaction dialog with the correct calldata)
[ ] BONUS: for contributing back to the challenges and making components out of these UI elements that can go back to master or be forked to make a formal challenge
[ ] BONUS: multisig as a service! Create a deploy button with a copy paste dialog for sharing so _anyone_ can make a multisig at your url with your frontend
[ ] BONUS: testing lol

 */
