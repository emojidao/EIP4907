---
eip: <to be assigned>
title: ERC-721 User And Expires Extension
description: Standard interface extension for ERC-721 user and expires.
author: EmojiDAO (dev@emojidao.org)
discussions-to: <URL>
status: Draft
type: <Standards Track>
category (*only required for Standards Track): <ERC>
created: 2022-03-11
requires (*optional): <EIP 165 721>
---
This standard proposes an extension to ERC721 Non-Fungible Tokens (NFTs) to separate NFT usage rights.

## Abstract
This standard is an extension of ERC721. It proposes an additional role **user** and a valid duration indicator **expires**. It allows users and developers manage the use right more simple and efficient.

## Motivation
Some NFTs have certain utilities. In-game NFTs can be used to play, virtual land can be used to build scenes, music NFT can be used to enjoy , etc. But in some cases, the owner and user may not be the same person. People may invest in an NFT with utility, but they may not have time or ability to use it. So separating use right from ownership makes a lot of sense.

Nowadays, many NFTs are managed by adding the role of **controller/operator** . People in  these roles can perform specific usage actions but can’t approve or transfer the NFT like an owner. If owner plans to set someone as **controller/operator** for a certain period of time, owner needs to submit two on-chain transactions, at the start time and the end time. 

It is conceivable that with the further expansion of NFT application, the problem of usage rights management will become more common, so it is necessary to establish a unified standard to facilitate collaboration among all applications.

By adding **user**, it enables multiple protocols to integrate and build on top of usage rights, while **expires** facilitates automatic ending of each usage without second transaction on chain.

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
Many developers are trying to develop based on the NFT utility, and some of them have added roles already, but there are some key problems need to be solved.  The advantages of this standard are below.

### Clear Permissions Management
Usage rights are part of ownership, so **owner** can modify **user** at any time, while **user** is only granted some specific permissions, such as **user** usually does not have permission to make permanent changes to NFT's Metadata.

NFTs may be used in multiple applications, and adding the user role to  NFTs  makes it easier for the application to make special grants of rights.

### Simple On-chain Time Management
Most NFTs do not take into account the expiration time even though the role of the user is added, resulting in the need for the owner to manually submit on-chain transaction to cancel the user rights, which does not allow accurate on-chain management of the use time and will waste gas.

The usage right often corresponds to a specific time, such as deploying scenes on land, renting game props, etc. Therefore, it can reduce the on-chain transactions and save gas with **expires**.

### Easy Third-Party Integration
The standard makes it easier for third-party protocols to manage NFT usage rights without permission from the NFT issuer or the NFT application.

## Backwards Compatibility
As mentioned in the specifications section, this standard can be fully ERC721 compatible by adding an extension function set.

In addition, new functions introduced in this standard have many similarities with the existing functions in ERC721. This allows developers to easily adopt the standard quickly.

## Test Cases
When running the tests, you need to create a test network :

```
truffle develop
nft = await ERC_DualRoles.new("ERC_DualRoles","ERC_DualRoles")
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
