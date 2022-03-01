// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10; 

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "./IERC721_DualRoles.sol";

contract ERC721_DualRoles is ERC721, IERC721_DualRoles {
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
