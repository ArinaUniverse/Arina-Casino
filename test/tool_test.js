const LCTContract = artifacts.require("LCT");
const fake_game = artifacts.require("fake_game");
const poolsContract = artifacts.require("pool");

const tool = require("../qihsin.js")

contract("tool測試", async (accounts) => {
    tool.setAccount(accounts)
    tool.setContract([LCTContract, fake_game , poolsContract])
    tool.setContractName(["LCT", "fake", "pool"])
    
    it("test", async () => {
        await tool.showAccounts()
    })

    it("test", async () => {
        await tool.showContracts()
    })

    it("test", async () => {
        let r =await tool.readline()

        console.log(r)
        
    })

    
})