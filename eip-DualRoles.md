---
eip: <to be assigned>
title: Separate NFT usage rights
description: Add a new role, who has usage right of NFT.The user has the right to use NFT for a specified period of time.
author: EmojiDAO (dev@emojidao.org)
discussions-to: <URL>
status: Draft
type: <Standards Track, Meta, or Informational>
category (*only required for Standards Track): <ERC>
created: 2022-02-25
requires (*optional): <EIP 165 721>
---
This standard proposes an extension to ERC721 Non-Fungible Tokens (NFTs) to separate NFT usage rights.

## Abstract
This standard is an extension of ERC721. 
NFT owners take ownership,NFT users take usage rights.
The owner can change the user and the end time of usage rights.

## Motivation
Owner of the NFT and the real user may not be the same person. Adding the role of user allows others to use this NFT without transferring ownership, increasing the usage of the NFT. Common scenarios like: renting a house, renting a car, OEM, etc.

## Specification
This standard proposes two user roles: the **Owner**, and the **User**.Their rights are as follows:
- An **Owner** has the right to:
  1. Transfer the **Owner** role
  2. Transfer the **User** role

- A **User** has the right to:
  1. use NFT

## Interface
```solidity
// Logged when the user of a token assigns a new user or updates expires
event UpdateUser(uint256 indexed tokenId, address indexed user, uint64 expires);

// set the user role and expires of a token
function setUser(uint256 tokenId, address user, uint64 expires) external ;

// get the user of a token
function userOf(uint256 tokenId) external view returns(address);

// get the user expires of a token
function userExpires(uint256 tokenId) external view returns(uint256);
```


## Rationale
The rationale fleshes out the specification by describing what motivated the design and why particular design decisions were made. It should describe alternate designs that were considered and related work, e.g. how the feature is supported in other languages.

## Backwards Compatibility
As mentioned in the specifications section, this standard can be fully ERC721 compatible by adding an extension function set.

In addition, new functions introduced in this standard have many similarities with the existing functions in ERC721. This allows developers to easily adopt the standard quickly.

## Test Cases
When running the tests, you need to create a test network :

```
truffle develop
nft = await ERC721_DualRoles.new("ERC721_DualRoles","ERC721_DualRoles")
nft.mint(1,accounts[0])
nft.ownerOf(1)
nft.setUser(1,accounts[1],33203038769)
nft.userOf(1)
```

Powered by Truffle and Openzeppelin test helper.

## Reference Implementation
```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC_DualRoles.sol";

contract ERC_DualRoles is ERC721, IERC_DualRoles {
    struct UserInfo 
    {
        address user;   // address of user role
        uint64 expires; // unix timestamp
    }

    mapping (uint256  => UserInfo) internal _users;

    constructor(string memory name_, string memory symbol_)
     ERC721(name_,symbol_)
     {         
     }
    
    function setUser(uint256 tokenId, address user, uint64 expires) public virtual{
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
        UserInfo storage info =  _users[tokenId];
        info.user = user;
        info.expires = expires;
        emit UpdateUser(tokenId,user,expires);
    }

    /**
    * get the user expires of a token.     
    * if there is no user role of a token , it will return 0 
    */
    function userExpires(uint256 tokenId) public view virtual returns(uint256){
        return _users[tokenId].expires;
    }
     
    /**  get the user role of a token */
    function userOf(uint256 tokenId)public view virtual returns(address){
        if( uint256(_users[tokenId].expires) >=  block.timestamp){
            return  _users[tokenId].user; 
        }
        else{
            return address(0);
        }
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 tokenId
    ) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId);

        if (from != to) {
            _users[tokenId].user = address(0);
            _users[tokenId].expires = 0;
            emit UpdateUser(tokenId,address(0),0);
        }
    }

    // for test
    function mint(uint256 tokenId, address to) public {
        _mint(to, tokenId);
    }
} 
```

## Security Considerations
This EIP standard can completely protect the rights of the owner, the owner can change the NFT user and use period at any time.

## Copyright
Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
