const chipsContract = artifacts.require("Chips");

const FruitSlot = artifacts.require("FruitSlot");
const BlackJack = artifacts.require("blackJack");
const Fishing = artifacts.require("FishingGame");
const Tanslot = artifacts.require("Tanslot");
const LCT = artifacts.require("LCT");


async function sleep(ms = 0) {
    return new Promise(r => setTimeout(r, ms));
}

module.exports = async function(callback) {
    chips = await chipsContract.deployed();
    _LCT = await LCT.deployed();
    console.log("xxx")

    fruitSlot = await FruitSlot.deployed();
    blackJack = await BlackJack.deployed();
    fishing = await Fishing.deployed();
    slot = await Tanslot.deployed();

    console.log(fruitSlot.address)
    console.log(blackJack.address)
    console.log(fishing.address)
    console.log(slot.address)

    console.log(chips.address)

    console.log("ooo")

    //let r = await chips.inqChips.call("0x709b394D94C5d4C9C47409Fa249407D75D0E3501")
    //console.log(r)

    let t = await chips.sendChips("0x709b394D94C5d4C9C47409Fa249407D75D0E3501", 888888e8)
    
    let t1 = await chips.sendChips(fruitSlot.address, 77777e8)
    let t2 = await chips.sendChips(blackJack.address, 77777e8)
    let t3 = await chips.sendChips(fishing.address, 77777e8)
    let t4 = await chips.sendChips(slot.address, 77777e8)
    let t5 = await chips.sendChips(_LCT.address, 77777e8)
    
    await sleep(2000)

    console.log(t)
    console.log(t1)
    console.log(t2)
    console.log(t3)
    console.log(t4)
    console.log(t5)
}

