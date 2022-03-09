// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "../IERC_DualRoles.sol";
import "./IWrapNFT.sol";

contract WrapNFT721 is ERC721,IERC_DualRoles,IWrapNFT{

    using EnumerableSet for EnumerableSet.UintSet;

    mapping (address => EnumerableSet.UintSet) _tokensOfUser;

    mapping (address => EnumerableSet.UintSet) _tokensOfOwner;

    mapping (uint256 => address) internal _users;

    mapping (uint256 => uint256) internal _userEndTime;
    
    address private _originalAddress ;
    address private _doNFTAddress;

    constructor(string memory name_, string memory symbol_) ERC721(name_,symbol_){}

    function setUser(uint256 tokenId, address user, uint64 expires) public {
        require(_isApprovedOrOwner(msg.sender, tokenId),"ERC721: transfer caller is not owner nor approved");
        require(expires == 0 || expires > block.timestamp,"Error:expires <= block.timestamp");
        address from = _users[tokenId];
        if (from != address(0)){
            _tokensOfUser[from].remove(tokenId);
        }
        if (user != address(0)){
            _tokensOfUser[user].add(tokenId);
        }
        _users[tokenId] = user;
        _userEndTime[tokenId] = expires;
        emit UpdateUser(tokenId,user,expires);
    }

    function userExpires(uint256 tokenId) public view returns(uint256){
        require(_exists(tokenId), "ERC721: operator query for nonexistent token");
        return _userEndTime[tokenId];
    }

    function userOf(uint256 tokenId)public view virtual returns(address user){
        if(_userEndTime[tokenId] == 0 || _userEndTime[tokenId] > block.timestamp){
            user = _users[tokenId]; 
        }
        if(user == address(0)){
            user = ownerOf(tokenId);
        }
    }
    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function tokensOfUser(address user) public view returns(uint256[] memory) {
        require(user != address(0), "ERC721: tokensOfUser query for the zero address");
        return _tokensOfUser[user].values();
    }

    function tokensOfUser(address user,uint256 startIndex,uint256 endIndex) public view returns(uint256[] memory result){
        require(user != address(0), "ERC721: tokensOfUser query for the zero address");
        uint256 length = _tokensOfUser[user].length();
        if(endIndex==0 || endIndex >= length){
            endIndex = length - 1;
        }
        require(startIndex < endIndex, "Error:startIndex >= endIndex");
        uint256 i;
        result = new uint256[](endIndex - startIndex + 1);
        for (uint256 index = startIndex; index <= endIndex; index++) {
            result[i] = _tokensOfUser[user].at(index);
            i++;
        }
    }

    function balanceOfUser(address user) public view returns(uint256){
        require(user != address(0), "ERC721: balanceOfUser query for the zero address");
        return _tokensOfUser[user].length();
    }

    /**
     * @dev Return the entire set in an array
     *
     * WARNING: This operation will copy the entire storage to memory, which can be quite expensive. This is designed
     * to mostly be used by view accessors that are queried without any gas fees. Developers should keep in mind that
     * this function has an unbounded cost, and using it as part of a state-changing function may render the function
     * uncallable if the set grows to a point where copying to memory consumes too much gas to fit in a block.
     */
    function tokensOfOwner(address owner) public view returns(uint256[] memory){
        require(owner != address(0), "ERC721: tokensOfUser query for the zero address");
        return _tokensOfOwner[owner].values();
    }

    function tokensOfOwner(address owner,uint256 startIndex,uint256 endIndex) public view returns(uint256[] memory result){
        require(owner != address(0), "ERC721: tokensOfUser query for the zero address");
        uint256 length = _tokensOfOwner[owner].length();
        if(endIndex==0 || endIndex >= length){
            endIndex = length - 1;
        }
        require(startIndex < endIndex, "Error:startIndex >= endIndex");
        uint256 i;
        result = new uint256[](endIndex - startIndex + 1);
        for (uint256 index = startIndex; index <= endIndex; index++) {
            result[i] = _tokensOfOwner[owner].at(index);
            i++;
        }
    }


    function initOriginalAddress(address originalAddress_) public{
        require(_originalAddress == address(0),"inited already");
        require(IERC165(originalAddress_).supportsInterface(type(IERC721).interfaceId),"not ERC721");
        _originalAddress = originalAddress_;
    }

    function originalAddress() public view returns(address){
        return _originalAddress;
    }

    function stake(uint256 tokenId) public{
        require(onlyApprovedOrOwner(msg.sender,_originalAddress,tokenId),"only approved or owner");
        address lastOwner = ERC721(_originalAddress).ownerOf(tokenId);
        ERC721(_originalAddress).safeTransferFrom(lastOwner, address(this), tokenId);
        _mint(lastOwner, tokenId);
        emit Stake(msg.sender,_originalAddress,tokenId);
    }

    function redeem(uint256 tokenId) public{
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner nor approved");
        ERC721(_originalAddress).safeTransferFrom(address(this),ownerOf(tokenId), tokenId);
        _burn(tokenId);
        emit Redeem(msg.sender,_originalAddress,tokenId);
    }

    function onlyApprovedOrOwner(address spender,address nftAddress,uint256 tokenId) internal view returns(bool){
        address owner = ERC721(nftAddress).ownerOf(tokenId);
        require(owner != address(0),"ERC721: operator query for nonexistent token");
        return (spender == owner || ERC721(nftAddress).getApproved(tokenId) == spender || ERC721(nftAddress).isApprovedForAll(owner, spender));
    }

    function originalOwnerOf(uint256 tokenId) public view virtual returns (address) {
        if(ownerOf(tokenId) == address(0)){
            return ERC721(_originalAddress).ownerOf(tokenId);
        }
        return ownerOf(tokenId);
    }


}
