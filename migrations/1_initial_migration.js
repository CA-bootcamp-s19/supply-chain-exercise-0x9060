// SPDX-License-Identifier: GPL-3.0-or-later
var Migrations = artifacts.require("./Migrations.sol");

module.exports = function(deployer) {
  deployer.deploy(Migrations);
};
