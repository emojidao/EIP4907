# EIP4907
EIP4907 is an extension of ERC-721. It proposes an additional role **user** and a valid duration indicator **expires**. It allows users and developers manage the use right more simple and efficient.

### Tools
* [Visual Studio Code](https://code.visualstudio.com/)
* [Solidity](https://marketplace.visualstudio.com/items?itemName=JuanBlanco.solidity) - Solidity support for Visual Studio code
* [Truffle](https://truffleframework.com/) - the most popular development framework for Ethereum
* [MetaMask](https://metamask.io/) - allows you to run Ethereum dApps right in your browser without running a full Ethereum node.

### Install
```
npm install -g truffle
npm install
truffle compile
truffle develop (to launch Truffle's built-in personal blockchain)
truffle migrate (to deploy contracts in the blockchain)
truffle test (to run unit tests)
npm run dev
```

### Test
```
truffle develop
nft = await ERC4907Demo.new("ERC4907Demo","ERC4907Demo")
nft.mint(1,accounts[0])
nft.ownerOf(1)
nft.userOf(1)
nft.setUser(1,accounts[1],10203038769)
nft.userOf(1)
```

### Additional Resources
* [Official Truffle Documentation](http://truffleframework.com/docs/) for complete and detailed guides, tips, and sample code.