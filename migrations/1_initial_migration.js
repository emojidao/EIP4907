const ERC_DualRoles = artifacts.require("ERC_DualRoles");

module.exports = function (deployer) {
  deployer.deploy(ERC_DualRoles,"DualRoles","DualRoles");
};
