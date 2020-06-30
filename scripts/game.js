const LCTContract = artifacts.require("LCT");
// const fake_game = artifacts.require("fake_game");
const chipsContract = artifacts.require("Chips");
const FruitSlot = artifacts.require("FruitSlot");
const blackJack = artifacts.require("blackJack");

const fishing = artifacts.require("FishingGame");
const Tanslot = artifacts.require("Tanslot");

const tool = require("../qihsin.js")

describe("LCT合約", async () => {
    before(async() => {
        accounts = await web3.eth.getAccounts()
        
        chips = await chipsContract.deployed();
        LCT = await LCTContract.deployed();
        slot = await Tanslot.deployed();
        fruit = await FruitSlot.deployed();
        jack = await blackJack.deployed();

        console.log(chips.address)
        console.log(fruit.address)
        console.log(jack.address)

        
        tool.setAccountName(["manager", "LCT player1", "game player1", "LCT player2",
            "game player2", "pretty girl"])
        tool.setAccount([accounts[0], accounts[1], accounts[2], accounts[3], 
            accounts[4], accounts[5]])
        tool.setContract([chips, LCT, slot, fruit, jack])
        tool.setContractName(["chips", "LCT", "slot", "fruit", "jack"])

        chips.sendChips(accounts[1], 888888e8)
        chips.sendChips(accounts[2], 888888e8)
        chips.sendChips(accounts[3], 888888e8)
        chips.sendChips(accounts[4], 888888e8)
        chips.sendChips(accounts[5], 888888e8)

        chips.sendChips(LCT.address, 200000e8);
        chips.sendChips(slot.address, 200000e8);
        chips.sendChips(fruit.address, 200000e8);
        chips.sendChips(jack.address, 200000e8);

    })


    async function inqChips(){

        console.log("\n\nChips查詢:\n");
        
        let a1 = chips.inqChips.call(accounts[0]);
        let a2 = chips.inqChips.call(accounts[1]);
        let a3 = chips.inqChips.call(accounts[2]);
        let a4 = chips.inqChips.call(accounts[3]);
        let a5 = chips.inqChips.call(accounts[4]);

        let l = chips.inqChips.call(LCT.address);
        let s = chips.inqChips.call(slot.address);
        let f = chips.inqChips.call(fruit.address);
        let j = chips.inqChips.call(jack.address);

        let r = await Promise.all([a1,a2,a3,a4,a5,l,s,f,j]);
        let base = 1e8
        console.log(`玩家1有${r[0]/base}CHIPS`);
        console.log(`玩家2有${r[1]/base}CHIPS`);
        console.log(`玩家3有${r[2]/base}CHIPS`);
        console.log(`玩家4有${r[3]/base}CHIPS`);
        console.log(`玩家5有${r[4]/base}CHIPS`);
        console.log(`LCT合約有${r[5]/base}CHIPS`);
        console.log(`slot合約有${r[6]/base}CHIPS`);
        console.log(`FruitSlot合約有${r[7]/base}CHIPS`);
        console.log(`blackJack合約有${r[8]/base}CHIPS`);
    }

    async function inq(address) {
        // let LCT = await LCTContract.deployed();
        let cat1 = await (LCT.inqOwnLCT.call(address, 1));
        console.log("銅貓id:"+cat1.toString())
        let cat2 = await (LCT.inqOwnLCT.call(address, 2));
        console.log("銀貓id:"+cat2.toString())
        let cat3 = await (LCT.inqOwnLCT.call(address, 3));
        console.log("金貓id:"+cat3.toString())

        let cat1a = await (LCT.inqOwnLCTAmount.call(address, 1));
        console.log("銅貓有"+cat1a.toString()+"個")
        let cat2a = await (LCT.inqOwnLCTAmount.call(address, 2));
        console.log("銀貓有"+cat2a.toString()+"個")
        let cat3a = await (LCT.inqOwnLCTAmount.call(address, 3));
        console.log("金貓有"+cat3a.toString()+"個")

        let cat1t = await (LCT.inqToTLCTAmount.call(1));
        console.log("銅貓總共有:"+cat1t.toString())
        let cat2t = await (LCT.inqToTLCTAmount.call(2));
        console.log("銀貓總共有:"+cat2t.toString())
        let cat3t = await (LCT.inqToTLCTAmount.call(3));
        console.log("金貓總共有:"+cat3t.toString())
    }

    // it("開始前查詢", async () => {     
    //     console.log("=======================開始前查詢=============================");
    //     await inqchip();
    //     await tool.showAccounts();
    //     await tool.showContracts();
    // })

    it("註冊", async () => {     
        await LCT.register("0x89B1c05F3044Fd5dE877A0f7b273C4636fD75e1b", {from:accounts[0]}); 
        await LCT.register(accounts[0], {from:accounts[5]}); 
        await LCT.register(accounts[5], {from:accounts[2]}); 
        
    })

    it("空地址餘額", async () => {
        console.log("空地址餘額為"+ (await tool.getBalance("0x0000000000000000000000000000000000000000")));
    })

    it("查詢註冊", async () => {    
        
        let LCT = await LCTContract.deployed();

        for (let index = 0; index < 6; index++) {
            let r = await LCT.inqRegistered(accounts[index]); 
            if(r){
                let rr = await LCT.inqReferrer(accounts[index]); 
                console.log(index +"號玩家註有註冊, 邀請人為"+rr);
            }else{
                console.log(index +"號玩家未註冊");
            }
        }
    })

    it("查詢CHIPS", async() => {
        await inqChips()
    })

    it("買招財貓", async () => {

        let base = 1e8

        let price = await LCT.buyPrice.call(3);
        console.log("招財貓價格為:"+price.toString()+"CHIPS");
        await LCT.buyLCT(3, price.toString()*base, {from:accounts[1]}); 

        let price2 = await LCT.buyPrice.call(2);
        console.log("招財貓價格為:"+price2.toString()+"CHIPS");
        await LCT.buyLCT(2, price2.toString()*base, {from:accounts[1]}); 
    })

    it("買招財貓2", async () => {

        let base = 1e8

        let buyTyp = 1;
        let price = await LCT.buyPrice.call(buyTyp);
        console.log("招財貓價格為:"+price.toString() +"CHIPS");
        await LCT.buyLCT(1, price.toString()*base,{from:accounts[3]}); 
    })

    it("查詢擁有招財貓", async () => {
        await inq(accounts[1])
    })

    it("買招財貓後查詢", async () => {     
        console.log("=======================買招財貓後查詢=============================");
        //await inqchip();
        await inqChips()
    })

    it("查詢權益基數", async () => {

        let EquityBaseReleased = await chips.inqEquityBaseReleased.call();
        console.log("發行權益基數:"+EquityBaseReleased);
        
        let EquityBaseBurned = await chips.inqEquityBaseBurned.call();
        console.log("銷毀權益基數:"+EquityBaseBurned);

        let Equity = await chips.inqEquity.call(accounts[0]);
        console.log(accounts[0]+"權益基數:"+Equity);

        let Equity1 = await chips.inqEquity.call(accounts[1]);
        console.log(accounts[1]+"權益基數:"+Equity1);

        let Equity2 = await chips.inqEquity.call(accounts[2]);
        console.log(accounts[2]+"權益基數:"+Equity2);
        
        let Equity3 = await chips.inqEquity.call(accounts[3]);
        console.log(accounts[3]+"權益基數:"+Equity3);

        let Equity4 = await chips.inqEquity.call(accounts[4]);
        console.log(accounts[4]+"權益基數:"+Equity4);
        
    })

    for (let i = 0; i < 5; i++) {
        
        it("玩家玩遊戲", async () => {

            await slot.slotting(800e8, {from:accounts[2]});

        })

        it("玩家玩遊戲", async () => {

            let r = await fruit.RunSpin(1200e8, [0, 1, 0, 2, 3, 2, 4],{from:accounts[4]});
            let event = r.receipt.logs;
            //console.log("gas: "+r.receipt.cumulativeGasUsed+ "/" + r.receipt.gasUsed);
            for (let index = 0; index < event.length; index++) {
                if(event[index].event == "betResult"){
                    let player =  event[index].args.player;
                    let type =  event[index].args._type;
                    let bonus =  event[index].args.bonus;
                    console.log(player, type.toString(), (bonus.toString()/1e8)+"CHIPS")
                }
                
            }

        })
    }

    it("遊戲後查詢", async () => {

        console.log("========================遊戲後查詢============================");        
        await inqChips()
    })    

    it("販售招財貓", async () => {
        await LCT.sellLCT(1,{from:accounts[1]});
    })

    it("查詢權益基數", async () => {
        
        let chips = await chipsContract.deployed();

        let EquityBaseReleased = await chips.inqEquityBaseReleased.call();
        console.log("發行權益基數:"+EquityBaseReleased);
        
        let EquityBaseBurned = await chips.inqEquityBaseBurned.call();
        console.log("銷毀權益基數:"+EquityBaseBurned);

        let Equity = await chips.inqEquity.call(accounts[0]);
        console.log(accounts[0]+"權益基數:"+Equity);

        let Equity1 = await chips.inqEquity.call(accounts[1]);
        console.log(accounts[1]+"權益基數:"+Equity1);

        let Equity2 = await chips.inqEquity.call(accounts[2]);
        console.log(accounts[2]+"權益基數:"+Equity2);
        
        let Equity3 = await chips.inqEquity.call(accounts[3]);
        console.log(accounts[3]+"權益基數:"+Equity3);

        let Equity4 = await chips.inqEquity.call(accounts[4]);
        console.log(accounts[4]+"權益基數:"+Equity4);
        
    })

    it("販售後查詢", async () => {
        console.log("========================提領後查詢============================"); 
        // await inqchip();
        await inqChips()
    })

    it("查詢擁有招財貓", async () => {
        inq(accounts[1])
        inq(accounts[2])
        inq(accounts[3])
    })


})