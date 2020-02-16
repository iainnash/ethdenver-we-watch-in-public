const IOTActivity = artifacts.require("./IOTActivity.sol");

module.exports = async function(deployer) {
  await deployer.deploy(IOTActivity);
};
