## Abstract

[EIP-4907](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-4907.md) is an extension of [EIP-721](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md). It proposes an additional role **user** and a valid duration indicator **expires**. It allows users and developers manage the use right more simple and efficient.

## Motivation

Some NFTs have certain utilities. For example, virtual land can be "used" to build scenes, and NFTs representing game assets can be "used" in-game. In some cases, the owner and user may not always be the same. There may be an owner of the NFT that rents it out to a “user”. The actions that a “user” should be able to take with an NFT would be different from the “owner” (for instance, “users” usually shouldn’t be able to sell ownership of the NFT).  In these situations, it makes sense to have separate roles that identify whether an address represents an “owner” or a “user” and manage permissions to perform actions accordingly.

Some projects already use this design scheme under different names such as “operator” or “controller” but as it becomes more and more prevalent, we need a unified standard to facilitate collaboration amongst all applications.

Furthermore, applications of this model (such as renting) often demand that user addresses have only temporary access to using the NFT. Normally, this means the owner needs to submit two on-chain transactions, one to list a new address as the new user role at the start of the duration and one to reclaim the user role at the end. This is inefficient in both labor and gas and so an “expires” function is introduced that would facilitate the automatic end of a usage term without the need of a second transaction.

## Test
### Tools
* [Visual Studio Code](https://code.visualstudio.com/)
* [Solidity](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity) - Solidity support for Visual Studio code
* [Truffle](https://truffleframework.com/) - the most popular development framework for Ethereum

### Install
```
npm install
```

### Test
```
truffle test
```