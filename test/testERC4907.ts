import { expect } from "chai";
import { ethers } from "hardhat";
import { makeInterfaceId } from "@openzeppelin/test-helpers";
import { ERC4907Demo } from "../typechain/ERC4907Demo";
const INTERFACES = {
    ERC165: [
        'supportsInterface(bytes4)',
    ],
    ERC721: [
        'balanceOf(address)',
        'ownerOf(uint256)',
        'approve(address,uint256)',
        'getApproved(uint256)',
        'setApprovalForAll(address,bool)',
        'isApprovedForAll(address,address)',
        'transferFrom(address,address,uint256)',
        'safeTransferFrom(address,address,uint256)',
        'safeTransferFrom(address,address,uint256,bytes)',
    ],
    ERC4907: [
        'setUser(uint256,address,uint64)',
        'userOf(uint256)',
        'userExpires(uint256)',
    ],
};

const firstTokenId = 1;
const secondTokenId = 2;
const nonExistentTokenId = 9999;


describe("Test ERC4907", function () {
    let owner, approved, operator, other, user;
    let contract: ERC4907Demo;
    let interfaceId: string;
    let timestamp: number;
    let expires: number;
    let receipt;

    async function onSetUserSuccessful(receipt_, tokenId_, user_, expires_: number) {
        await receipt_.wait();
        if (timestamp <= expires_) {
            expect(await contract.userOf(tokenId_)).equal(user_);
        } else {
            expect(await contract.userOf(tokenId_)).equal(ethers.constants.AddressZero);
        }
        expect(await contract.userExpires(tokenId_)).equal(expires_);
        expect(await contract.ownerOf(tokenId_)).to.be.equal(owner);
        await expect(receipt_).to.emit(contract, "UpdateUser").withArgs(tokenId_, user_, expires_);
    }

    async function onBurnSuccessful(receipt_, tokenId_) {
        await receipt_.wait();
        expect(await contract.userOf(tokenId_)).equal(ethers.constants.AddressZero);
        expect(await contract.userExpires(tokenId_)).equal(0);
        await expect(contract.ownerOf(tokenId_)).to.be.revertedWith("ERC721: invalid token ID");
        await expect(receipt_).to.emit(contract, "UpdateUser").withArgs(tokenId_, ethers.constants.AddressZero, 0);
    }

    beforeEach(async function () {
        [owner, approved, operator, other, user] = await ethers.getSigners();
        const ERC4907Demo = await ethers.getContractFactory("ERC4907Demo");
        contract = await ERC4907Demo.deploy("4907", "4907");
        await contract.mint(firstTokenId, owner.address);
        await contract.mint(secondTokenId, owner.address);
        await contract.connect(owner).approve(approved.address, firstTokenId);
        await contract.connect(owner).setApprovalForAll(operator.address, true);

        const blockNumBefore = await ethers.provider.getBlockNumber();
        const blockBefore = await ethers.provider.getBlock(blockNumBefore);
        timestamp = blockBefore.timestamp;
        expires = blockBefore.timestamp + 86400 * 180;

    });

    describe("should support interfaces", function () {
        it("should support interfaces : ERC165", async function () {
            interfaceId = makeInterfaceId.ERC165(INTERFACES.ERC165);
            expect(await contract.supportsInterface(interfaceId)).equal(true);
        });
        it("should support interfaces : ERC721", async function () {
            interfaceId = makeInterfaceId.ERC165(INTERFACES.ERC721);
            expect(await contract.supportsInterface(interfaceId)).equal(true);
        });
        it("should support interfaces : ERC4907", async function () {
            interfaceId = makeInterfaceId.ERC165(INTERFACES.ERC4907);
            expect(await contract.supportsInterface(interfaceId)).equal(true);
        });
    });

    describe("setUser : user can use the NFT until expires", function () {
        it("should success when called by the owner", async function () {
            receipt = await contract.connect(owner).setUser(firstTokenId, user.address, expires);
            onSetUserSuccessful(receipt, firstTokenId, user.address, expires);
        });
        it("should success when called by the approved", async function () {
            receipt = await contract.connect(approved).setUser(firstTokenId, user.address, expires);
            onSetUserSuccessful(receipt, firstTokenId, user.address, expires);
        });
        it("should success when called by the operator", async function () {
            receipt = await contract.connect(operator).setUser(firstTokenId, user.address, expires);
            onSetUserSuccessful(receipt, firstTokenId, user.address, expires);
        });
        it("should fail when called by other", async function () {
            await expect(contract.connect(other).setUser(firstTokenId, user.address, expires)).to.be.revertedWith("ERC721: transfer caller is not owner nor approved");
        });

    });

    describe("cancel user by set user to ZeroAddress or set expires to 0", function () {
        it("should success when called by the owner", async function () {
            receipt = await contract.connect(owner).setUser(firstTokenId, ethers.constants.AddressZero, 0);
            onSetUserSuccessful(receipt, firstTokenId, ethers.constants.AddressZero, 0);
        });
        it("should success when called by the approved", async function () {
            receipt = await contract.connect(approved).setUser(firstTokenId, ethers.constants.AddressZero, 0);
            onSetUserSuccessful(receipt, firstTokenId, ethers.constants.AddressZero, 0);
        });
        it("should success when called by the operator", async function () {
            receipt = await contract.connect(operator).setUser(firstTokenId, ethers.constants.AddressZero, 0);
            onSetUserSuccessful(receipt, firstTokenId, ethers.constants.AddressZero, 0);
        });
        it("should fail when called by other", async function () {
            await expect(contract.connect(other).setUser(firstTokenId, ethers.constants.AddressZero, 0)).to.be.revertedWith("ERC721: transfer caller is not owner nor approved");
        });

    });

    describe("Burn", function () {
        it("should success when called by the owner", async function () {
            receipt = await contract.connect(owner).burn(firstTokenId);
            onBurnSuccessful(receipt, firstTokenId);
        });
        it("should fail when called by the approved", async function () {
            await expect(contract.connect(approved).burn(firstTokenId)).to.be.revertedWith("caller is not token owner");
        });
        it("should success when called by the operator", async function () {
            await expect(contract.connect(operator).burn(firstTokenId)).to.be.revertedWith("caller is not token owner");
        });
        it("should fail when called by other", async function () {
            await expect(contract.connect(other).burn(firstTokenId)).to.be.revertedWith("caller is not token owner");
        });
    });






});