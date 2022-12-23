// SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Luctq is ERC721, Ownable {
    using Counters for Counters.Counter;
    using Strings for string;
    using Strings for uint256;
    Counters.Counter private _tokenId;
    // Optional mapping for token URIs
    mapping(uint => string) private _tokenURIs;
    // Mapping for list address can opera MoonBeast NFT
    mapping(address => bool) public _approveOperators;
    // Base URI
    string private _baseURIExtended = "https://gateway.pinata.cloud/ipfs/QmTBxFm3SU3pmWQgGzb2ApZe9oMD6amZCAkyVa6HyvMDxB/";
    constructor() ERC721("Luctq", "LNFT") {}

    // mint NFT to address with token URI

    function mintNFT(address recipient, string memory newTokenURI) public isAprrovedOperatorOrOwner returns (uint256) {
        uint256 newItemId = _tokenId.current();
        _tokenId.increment();
        _safeMint(recipient, newItemId);
        setTokenURI(newItemId, newTokenURI);

        return newItemId;
    }

    function mintNFT(address recipient) public   isAprrovedOperatorOrOwner returns (uint256) {
        uint256 newItemId = _tokenId.current();
        _tokenId.increment();
        _safeMint(recipient, newItemId);

        return newItemId;
    }

    function burnNFT(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    // token URI
    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIExtended;
    }
    
    function setTokenURI(uint256 tokenId, string memory newTokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = newTokenURI;
    }

    function setBaseURI(string memory baseURI) external onlyOwner { 
        _baseURIExtended = baseURI;
    }

    function setTokenURIByIdRange(uint256 startId, uint256 endId, string memory baseURI) external onlyOwner {
        require(startId < endId, "MoonBeast: StartID must be less than EndID");
        for (uint256 i = startId; i < endId; i++) {
            string memory concatenatedTokenURI = string(abi.encodePacked(baseURI, i.toString(), ".json"));
            setTokenURI(i, concatenatedTokenURI);
        }
    }

    function tokenURI(uint256 tokenId) public view override returns(string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        string memory _baseURI_ = _baseURI();
        string memory _tokenURI_ = _tokenURIs[tokenId];

        if (bytes(_baseURI_).length > 0 && bytes(_tokenURI_ ).length == 0) {
            return string(abi.encodePacked(_baseURI_, tokenId.toString(), ".json"));
        }
        return _tokenURI_ ;
    }

    function lastestTokenId() public view returns (uint256) {
        return _tokenId.current();
    }

    function setApprovedOperator(address operator, bool isApproved) external onlyOwner {
        require(operator != address(0), "MoonBeast: operator is the zero address");
        _approveOperators[operator] = isApproved;
    }

    function withdrawNFT(uint256 tokenId, string memory _tokenURI, address receiver) external onlyOwner returns (uint256) {
        setTokenURI(tokenId, _tokenURI);
        safeTransferFrom(_msgSender(), receiver, tokenId);
        return tokenId;
    }

    function isContentOwned(uint256 tokenId) public view returns (bool) {
        return _exists(tokenId);
    }

    // function modifier

    modifier isAprrovedOperatorOrOwner() {
        require(msg.sender == owner() || _approveOperators[msg.sender] == true, "Ownable: caller is not the owner or is approved");    
        _;
    }

} 