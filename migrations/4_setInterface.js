const LCTContract = artifacts.require("LCT");
const Chips = artifacts.require("Chips");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");

const FishingGame = artifacts.require("FishingGame");
const Tanslot = artifacts.require("Tanslot");
const Schatch = artifacts.require("Schatch");

module.exports = async function(deployer) {
    
    let _Chips = await Chips.deployed();
    //let _Chips = await Chips.at("0x73CFA8FD394574A4DA04Bc077314F8c8AC8B5b3E");
    let LCT = await LCTContract.deployed();
    let _FruitSlot = await FruitSlot.deployed();
    let _blackJack = await blackJack.deployed();
    let fishing = await FishingGame.deployed();
    let slot = await Tanslot.deployed();
    let schatch = await Schatch.deployed();
    
    // await _Chips.setServer("0x9B1e9A028F452F857020e3431c1f25d7C5F2FCDE",{gas:300000})
    // await _Chips.setServer("0x8e69d471ba80b50e33917110a63218AeE0B43544",{gas:300000});
    // await _Chips.setServer("0x4dDFF74d20Aeb24f102A7BD46873eee4FCba5bCA",{gas:300000});
    // await _Chips.setArina("0xfDec5E36C4496b1dEF8FD8b61f57871d67EBf01b",{gas:300000});

    // await _Chips.setGame(fishing.address, true,{gas:300000});
    // await _Chips.setGame(LCT.address, true,{gas:300000});
    // await _Chips.setGame(_FruitSlot.address, true,{gas:300000});
    // await _Chips.setGame(_blackJack.address, true,{gas:300000});
    await _Chips.setGame(schatch.address, true,{gas:300000});
    
    // await fishing.setChip(_Chips.address,{gas:300000});
    // await _Chips.setGame(slot.address, true,{gas:300000});
    // await _Chips.setLCT(LCT.address,{gas:300000});
    // await _FruitSlot.setChip(_Chips.address,{gas:300000});
    // await _blackJack.setChip(_Chips.address,{gas:300000});
    // await LCT.setChip(_Chips.address,{gas:300000});
    // await slot.setChip(_Chips.address,{gas:300000});
    await schatch.setChip(_Chips.address,{gas:300000});
};
