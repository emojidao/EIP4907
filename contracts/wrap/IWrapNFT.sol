// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


interface IWrapNFT {

    event Stake(address msgSender,address nftAddress,uint256 tokenId);
    event Redeem(address msgSender,address nftAddress,uint256 tokenId);

    function initOriginalAddress(address originalAddress_) external;

    function originalAddress() external view returns(address);

    function stake(uint256 tokenId) external;

    function redeem(uint256 tokenId) external;

}