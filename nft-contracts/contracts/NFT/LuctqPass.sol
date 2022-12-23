// SPDX-License-Identifier: MIT

pragma solidity ^0.8.1;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract LuctqPass is ERC721Enumerable, Ownable {
    using Strings for string;
    using Strings for uint256;
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIds;

    mapping (uint => string) private _tokenURIs;
    mapping (address => bool) private _mintedList;

    bool public isActiveMintPass = true;
    string private _baseURIExtended;

    constructor() ERC721("Lucta Mint Pass", "LMT") {}
    function mintNFT(bytes32[] calldata key) public returns (uint256) {}

    function burnNFT(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721Burnable: caller is not owner nor approved");
        _burn(tokenId);
    }

    //handle url

    function setBaseURI(string memory baseURI_) external onlyOwner() {
        _baseURIExtended = baseURI_;
    }

    function _setTokenURI(uint256 tokenId, string memory _tokenURI) internal virtual {
        require(_exists(tokenId), "ERC721Metadata: URI set of nonexistent token");
        _tokenURIs[tokenId] = _tokenURI;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return _baseURIExtended;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();

        // If item does not have tokenURI and contract has base URI, concatenate the tokenID to the baseURI.
        if (bytes(base).length > 0 && bytes(_tokenURI).length == 0) {
            return string(abi.encodePacked(base, tokenId.toString(), ".json"));
        }
        // Other cases, return tokenURI
        return _tokenURI;
    }

    function latestTokenId() public view returns (uint256) {
        return _tokenIds.current();
    }

    function setTokenURI(uint256 tokenId, string memory _tokenURI) external onlyOwner returns (uint256) {
        _setTokenURI(tokenId, _tokenURI);
        return tokenId;
    }


}