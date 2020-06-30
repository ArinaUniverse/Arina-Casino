const LCT = artifacts.require("LCT");

const Chips = artifacts.require("Chips");
const fishing = artifacts.require("FishingGame");
const slot = artifacts.require("Tanslot");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");
const Schatch = artifacts.require("Schatch");

module.exports = function(deployer) {

 
  // deployer.deploy(LCT);
  // deployer.deploy(Chips);

  // deployer.deploy(fishing);
  // deployer.deploy(slot);
  // deployer.deploy(FruitSlot);
  // deployer.deploy(blackJack);
  deployer.deploy(Schatch);

};
