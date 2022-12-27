// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/CountersUpgradeable.sol";
import "@openzeppelin/contracts/interfaces/IERC721.sol";
import "@openzeppelin/contracts-upgradeable/security/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

interface Luctq {
    function mintNFT(address recipient) external returns (uint256);

    function mintNFT(address recipient, string memory tokenURI) external returns (uint256);

    function burnNFT(uint256 tokenId) external;

    function setBaseURI(string memory baseURI) external;

    function tokenURI(uint256 tokenId) external view returns (string memory);

    function lastestTokenId() external view returns (uint256);

    function setTokenURI(uint256 tokenId, string memory tokenURI) external;

    function setApproveOperator(address operator, bool isApproved) external;

    function withdrawNFT(uint tokenId, string memory tokenURI, address recipient) external returns (uint256);


}

contract LuctqSale is Initializable, ReentrancyGuardUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    using CountersUpgradeable for CountersUpgradeable.Counter;

    IERC721 private _mintPassNFT;
    Luctq private _luctqNFT;

    bool private _isReadySale;
    mapping(uint256 => uint16) private _usedMintPass;
    mapping(uint256 => uint256[]) private _mintPassMapping;

    uint256 public _maxSaleAmount;
    CountersUpgradeable.Counter private _currentSaleAmount;
    uint256 public _price;
    uint16 public _nftPerPass;
    address payable public _wallet;

    event NFTPurchased(address beneficiary, uint256 mintPassId);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(uint256 maxSaleAmount, uint256 price, uint16 nftPerPass, address mintPassNFT, address luctqNFT, address wallet) initializer public {
        require(maxSaleAmount > 0, "maxSaleAmount must be greater than 0");
        require(price > 0, "Price must be greater than 0");
        require(nftPerPass > 0, "nftPerPass must be greater than 0");
        require(mintPassNFT != address(0), "mintPassNFT is the zero address");
        require(luctqNFT != address(0), "moonBeastNFT is the zero address");
        require(wallet != address(0), "wallet is the zero address");

        __Ownable_init();
        __UUPSUpgradeable_init();

        _maxSaleAmount = maxSaleAmount;
        // _currentSaleAmount = 0;
        _price = price;
        _nftPerPass = nftPerPass;
        _mintPassNFT = IERC721(mintPassNFT);
        _luctqNFT = Luctq(luctqNFT);
        _wallet = payable(wallet);
        _isReadySale = false;
    }
    function buyNFT(uint256[] calldata mintPassIds, uint16 amount) public nonReentrant payable {
        require(_isReadySale, "Whitelist round not ready");
        require(amount > 0, "Amount must be greater than 0");
        uint256 leftNFT = _maxSaleAmount - _currentSaleAmount.current();
        require(leftNFT >= amount, string(abi.encodePacked("Exceeded the number of NFTs for this sale round. ", Strings.toString(leftNFT), leftNFT > 1 ? " NFTs" : " NFT", " left")));
        address beneficiary = msg.sender;
        uint16 _boughtNFT = 0;
        _validateAmountBuyNFT(beneficiary, mintPassIds, amount);
        _preValidatePurchase(amount, beneficiary, msg.value);
         for (uint256 i = 0; i < mintPassIds.length; i++) {
            uint256 mintPassId = mintPassIds[i];
            for (uint16 j = 0; j < _nftPerPass; j++) {
                require(_currentSaleAmount.current() <= _maxSaleAmount, "Exceeded the number of NFTs for this sale round");
                if (_boughtNFT < amount && _usedMintPass[mintPassId] < _nftPerPass) {
                    uint256 tokenId = _luctqNFT.mintNFT(beneficiary);
                    _currentSaleAmount.increment();
                    _boughtNFT += 1;
                    _usedMintPass[mintPassId] += 1;
                    _mintPassMapping[mintPassId].push(tokenId);
                }
            }
            emit NFTPurchased(beneficiary, mintPassId);
        }

    }

    function checkMintPass(uint256 passId) public view returns (bool) {
        return _usedMintPass[passId] >= _nftPerPass;
    }

    
    function getMintPassUsage(uint256 mintPassId, uint8 index) public view returns (uint256) {
        require(index <= _mintPassMapping[mintPassId].length, "Out of array range");
        return _mintPassMapping[mintPassId][index];
    }

    function getMintPassAvailableSlots(uint256 mintPassId) public view returns (uint16) {
        return _nftPerPass - _usedMintPass[mintPassId];
    }

    function getContractBalance() public view returns (uint256) {
        uint256 glmr = address(this).balance;
        return glmr;
    }

    function getAvailableSlots() public view returns (uint256) {
        return _maxSaleAmount - _currentSaleAmount.current();
    }

    function withdrawTokenByOwner() external onlyOwner {
        require(address(this).balance > 0, "Contract balance is 0 GLMR");
        payable(_wallet).transfer(address(this).balance);
    }

    function setMaxSaleAmount(uint256 maxSaleAmount) external onlyOwner {
        require(maxSaleAmount > 0, "MaxSaleAmount must be greater than 0");
        require(maxSaleAmount > _currentSaleAmount.current(), "MaxSaleAmount must be greater than _currentSaleAmount");
        _maxSaleAmount = maxSaleAmount;
    }

    function getReadySale() public view returns (bool) {
        return _isReadySale;
    }

    function setReadySale(bool value) external onlyOwner {
        _isReadySale = value;
    }

    function setPrice(uint256 price) external onlyOwner {
        require(price > 0, "Price must be greater than 0");
        _price = price;
    }

    function setNftPerPass(uint16 value) external onlyOwner {
        require(value > 0, "NftPerPass must be greater than 0");
        _nftPerPass = value;
    }

    function setWallet(address payable wallet) external onlyOwner {
        require(wallet != address(0), "Wallet is the zero address");
        _wallet = wallet;
    }

    function setMintPassNFT(address mintPass) external onlyOwner {
        require(mintPass != address(0), "MintPassNFT is the zero address");
        _mintPassNFT = IERC721(mintPass);
    }

    function setLuctqNFT(address luctq) external onlyOwner {
        require(luctq != address(0), "LuctqNFT is the zero address");
        _luctqNFT = Luctq(luctq);
    }

    function _preValidatePurchase(uint256 amount, address beneficiary, uint256 valueSent) internal view {
        require(amount > 0, "You need at least one mint pass to mint NFT");
        require(beneficiary != address(0), "Beneficiary is the zero address");
        require(_price * amount == valueSent, "The value you sent is invalid");
    }
    
    function _validateMintPass(uint256 mintPassId, address beneficiary) internal view {
        require(_mintPassNFT.ownerOf(mintPassId) == beneficiary, "You don't own all these mint passes");
        require(_usedMintPass[mintPassId] < _nftPerPass, string(abi.encodePacked("MintPassNFT #", Strings.toString(mintPassId), " used 2/2 turn of Mint")));
    }

    function _validateAmountBuyNFT(address beneficiary, uint256[] calldata mintPassIds, uint16 amount) internal view {
        uint16 availableSlot = 0;
        for (uint256 i = 0; i < mintPassIds.length; i++) {
            uint256 mintPassId = mintPassIds[i];
            _validateMintPass(mintPassId, beneficiary);

            availableSlot += _nftPerPass - _usedMintPass[mintPassId];
        }

        require(availableSlot >= amount, "Insufficient Mint Pass");
    }
    function _authorizeUpgrade(address newImplementation) internal onlyOwner override {}
}