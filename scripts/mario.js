const LCTContract = artifacts.require("LCT");
const chipsContract = artifacts.require("Chips");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");

const fishing = artifacts.require("FishingGame");
const Tanslot = artifacts.require("Tanslot");

module.exports = async function(callback) {
    mario = await FruitSlot.deployed();

    await mario.RunSpin(100e8, [1,0,0,0,0,0,0])
}