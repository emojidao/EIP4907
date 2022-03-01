const ERC721_DualRoles = artifacts.require("ERC721_DualRoles");

module.exports = function (deployer) {
  deployer.deploy(ERC721_DualRoles,"DualRoles","DualRoles");
};
