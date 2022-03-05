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
        require(_isApprovedOrOwner(msg.sender, tokenId),"caller is not owner nor approved");
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

    /**
     * @dev Hook that is called before any token transfer. This includes minting
     * and burning.
     *
     * Calling conditions:
     *
     * - When `from` and `to` are both non-zero, ``from``'s `tokenId` will be
     * transferred to `to`.
     * - When `from` is zero, `tokenId` will be minted for `to`.
     * - When `to` is zero, ``from``'s `tokenId` will be burned.
     * - `from` and `to` are never both zero.
     *
     */
    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual override{
        super._beforeTokenTransfer(from, to, tokenId);
        if (from != to) {
            _users[tokenId].user = address(0);
            _users[tokenId].expires = 0;
            emit UpdateUser(tokenId,address(0),0);
        }
    }

    /**
     * @dev Returns whether `spender` is allowed to use `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwnerOrUser(address spender, uint256 tokenId) internal view virtual returns (bool) {
        return (_isApprovedOrOwner(spender, tokenId) || spender == userOf(tokenId));
    }

    // for test
    function mint(uint256 tokenId, address to) public {
        _mint(to, tokenId);
    }
}
