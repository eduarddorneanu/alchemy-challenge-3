// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

struct Character {
  uint256 level;
  uint256 speed;
  uint256 strength;
  uint256 life;
}

contract ChainBattles is ERC721URIStorage {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => Character) public tokenIdToCharacter;

    constructor() ERC721("Chain Battles", "CBTLS") {}

    function random(uint number) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,  
        msg.sender))) % number;
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newItemId = _tokenIds.current();
        uint256 randomNumber = 0;
        _safeMint(msg.sender, newItemId);
        tokenIdToCharacter[newItemId].level = 1;
        randomNumber = random(5);
        tokenIdToCharacter[newItemId].speed = randomNumber;
        randomNumber = random(25);
        tokenIdToCharacter[newItemId].strength = randomNumber;
        randomNumber = random(250);
        tokenIdToCharacter[newItemId].life = randomNumber;
        _setTokenURI(newItemId, getTokenURI(newItemId));
    }

    function getCharacter(uint256 tokenId) public view returns (Character memory) {
        Character memory character = tokenIdToCharacter[tokenId];
        return character;
    }

    function train(uint256 tokenId) public {
        require(_exists(tokenId));
        require(
            ownerOf(tokenId) == msg.sender,
            "You must own this NFT to train it!"
        );
        tokenIdToCharacter[tokenId].level = tokenIdToCharacter[tokenId].level + 1;
        tokenIdToCharacter[tokenId].speed = tokenIdToCharacter[tokenId].speed + 2;
        tokenIdToCharacter[tokenId].strength = tokenIdToCharacter[tokenId].strength + 2;
        tokenIdToCharacter[tokenId].life = tokenIdToCharacter[tokenId].life + 10;
        _setTokenURI(tokenId, getTokenURI(tokenId));
    }

    function generateCharacter(uint256 tokenId)
        public
        view
        returns (string memory)
    {
        Character memory character = getCharacter(tokenId);
        bytes memory svg = abi.encodePacked(
            '<svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMinYMin meet" viewBox="0 0 350 350">',
            "<style>.base { fill: white; font-family: serif; font-size: 14px; }</style>",
            '<rect width="100%" height="100%" fill="black" />',
            '<text x="50%" y="30%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Warrior",
            "</text>",
            '<text x="50%" y="40%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Levels: ",
            character.level.toString(),
            "</text>",
            '<text x="50%" y="50%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Speed: ",
            character.speed.toString(),
            "</text>",
            '<text x="50%" y="60%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Strength: ",
            character.strength.toString(),
            "</text>",
            '<text x="50%" y="70%" class="base" dominant-baseline="middle" text-anchor="middle">',
            "Life: ",
            character.life.toString(),
            "</text>",
            "</svg>"
        );
        return
            string(
                abi.encodePacked(
                    "data:image/svg+xml;base64,",
                    Base64.encode(svg)
                )
            );
    }

    function getTokenURI(uint256 tokenId) public view returns (string memory) {
        bytes memory dataURI = abi.encodePacked(
            "{",
            '"name": "Chain Battles #',
            tokenId.toString(),
            '",',
            '"description": "Battles on chain",',
            '"image": "',
            generateCharacter(tokenId),
            '"',
            "}"
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,",
                    Base64.encode(dataURI)
                )
            );
    }
}
