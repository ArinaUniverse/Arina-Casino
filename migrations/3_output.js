var fs = require("fs");
const LCT = artifacts.require("LCT");
const Chips = artifacts.require("Chips");
const fishing = artifacts.require("FishingGame");
const slot = artifacts.require("Tanslot");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");
const Schatch = artifacts.require("Schatch");

module.exports = async function(deployer, network, accounts) {
    if(network == "test" || network == "develop" || network == "g"){
        
    }else{

        let _Chips = await Chips.deployed();
        let _LCT = await LCT.deployed();
        let _fishing = await fishing.deployed();
        let _slot = await slot.deployed();
        let _FruitSlot = await FruitSlot.deployed();
        let _blackJack = await blackJack.deployed();
        let _Schatch = await Schatch.deployed();

        var dt = new Date();

        
            var write = (
                "部屬時間: " + dt + "\n" +
                "部屬網路: " + network + "\n" +

                "\n遊戲合約: \n" +
                "小瑪莉: " + _FruitSlot.address + "\n" +
                "blackJack: " + _blackJack.address + "\n" +
                "釣魚: " + _fishing.address + "\n" +
                "拉霸: " + _slot.address + "\n" +
                "刮刮樂: " + _Schatch.address + "\n" +

                "\n其他合約: \n" +
                "LCT: " + _LCT.address + "\n" +
                "Chips: " + _Chips.address + "\n"
                );

            let ddd = {}
            ddd["<Time>"] = dt
            ddd.fruitSlot = _FruitSlot.address
            ddd.blackJack = _blackJack.address
            ddd.fishing = _fishing.address
            ddd.slot = _slot.address
            ddd.Schatch = _Schatch.address
            ddd.LCT = _LCT.address
            ddd.Chips = _Chips.address
            
            
            // console.log(ddd)

        
            fs.writeFileSync("output/"+network+"/address.json", JSON.stringify(ddd));
            fs.writeFileSync("output/"+network+"/output.txt", write);
            
            var LCTABI = _LCT.abi;
            var ChipsABI = Chips.abi;
            var fishingABI = _fishing.abi;
            var slotABI = _slot.abi;
            var FruitSlotABI = _FruitSlot.abi;
            var blackJackABI = _blackJack.abi;
            var SchatchABI = _Schatch.abi;
            // //var fakeABI = fake.abi;
            
            // //fs.writeFileSync("output/"+network+"/fakeABI.js", JSON.stringify(fakeABI));
            fs.writeFileSync("output/"+network+"/abi/LCT.json", JSON.stringify(LCTABI));
            fs.writeFileSync("output/"+network+"/abi/Chips.json", JSON.stringify(ChipsABI));
            fs.writeFileSync("output/"+network+"/abi/fishing.json", JSON.stringify(fishingABI));
            fs.writeFileSync("output/"+network+"/abi/slot.json", JSON.stringify(slotABI));
            fs.writeFileSync("output/"+network+"/abi/FruitSlot.json", JSON.stringify(FruitSlotABI));
            fs.writeFileSync("output/"+network+"/abi/blackJack.json", JSON.stringify(blackJackABI));
            fs.writeFileSync("output/"+network+"/abi/Schatch.json", JSON.stringify(SchatchABI));

            console.log("完成日誌輸出");
        
        }
}

