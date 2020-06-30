
const LCTContract = artifacts.require("LCT");
const Chips = artifacts.require("Chips");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");

const FishingGame = artifacts.require("FishingGame");
const Tanslot = artifacts.require("Tanslot");
const Schatch = artifacts.require("Schatch");

module.exports = async function(deployer) {

    let LCT = await LCTContract.deployed();

    let _FruitSlot = await FruitSlot.deployed();
    let _blackJack = await blackJack.deployed();
    let fishing = await FishingGame.deployed();
    let slot = await Tanslot.deployed();
    let schatch = await Schatch.deployed();
    

    console.log("LCT: "+ LCT.address)
    console.log("chips: "+ Chips.address)
    console.log("fruitSlot: "+ _FruitSlot.address)
    console.log("blackJack: "+_blackJack.address)
    console.log("fishing: "+fishing.address)
    console.log("slot: "+slot.address)
    console.log("schatch: "+schatch.address)

}