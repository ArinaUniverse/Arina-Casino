const FishingGame = artifacts.require("FishingGame");

contract("fishing", async (accounts) => {
    let fishing;
    before(async() =>{
        fishing = await FishingGame.deployed();
    })

    it("address", async() => {
        console.log(fishing.address);
    })

    it("selectRod", async() => {
        await fishing.selectRod(0 ,0);
    })

    it("selectBait", async() => {
        await fishing.selectBait(0, 0);
    })

    it("Fishing", async() => {
        await fishing.Fishing();
    })

})

module.exports = contract;