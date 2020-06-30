const blackJack = artifacts.require("blackJack");

contract("LCT合約", async (accounts) => {

    before(async () => {

        jack = await blackJack.deployed()

        console.log(jack.address)
    })


    it("開始遊戲", () => {
        startGame
    })

})