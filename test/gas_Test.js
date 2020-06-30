const FruitSlot = artifacts.require("FruitSlot");
const poolsContract = artifacts.require("pool");
const LCTContract = artifacts.require("LCT");

const tool = require("../qihsin.js")

contract("gas test", async (accounts) => {
   

    async function inqPool(){
        let LCT = await LCTContract.deployed();
        let game = await FruitSlot.deployed();
        //let slot = await FruitSlot.deployed();
        //let jack = await blackJack.deployed();
        let pool = await poolsContract.deployed();

        console.log("\n\n資金池列表:\n");
        
        let a1 = pool.pools.call(accounts[0]);
        let a2 = pool.pools.call(accounts[1]);
        let a3 = pool.pools.call(accounts[2]);
        let a4 = pool.pools.call(accounts[3]);
        let a5 = pool.pools.call(accounts[4]);

        let l = pool.pools.call(LCT.address);
        let g = pool.pools.call(game.address);
        // let s = pool.pools.call(slot.address);
        // let j = pool.pools.call(jack.address);
        let p = pool.pools.call(pool.address);

        let r = await Promise.all([a1,a2,a3,a4,a5,l,g,p]);

        console.log("玩家1資金池有"+(r[0]/10**18)+"TAN");
        console.log("玩家2資金池有"+(r[1]/10**18)+"TAN");
        console.log("玩家3資金池有"+(r[2]/10**18)+"TAN");
        console.log("玩家4資金池有"+(r[3]/10**18)+"TAN");
        console.log("玩家5資金池有"+(r[4]/10**18)+"TAN");
        console.log("LCT合約資金池有"+(r[5]/10**18)+"TAN");
        console.log("game合約資金池有"+(r[6]/10**18)+"TAN");
        console.log("玩家總資金池有"+(r[7]/10**18)+"TAN");
    }

    before(async () =>{

        LCT = await LCTContract.deployed();
        f = await FruitSlot.deployed();
        pool = await poolsContract.deployed();

        tool.setAccountName(["manager", "LCT player1", "game player1", "LCT player2",
            "game player2", "pretty girl"])
        tool.setAccount([accounts[0], accounts[1], accounts[2], accounts[3], 
            accounts[4], accounts[5]])
        tool.setContract([LCTContract, f, poolsContract])
        tool.setContractName(["LCT", "fake", "pool"])

        
        //f = await FruitSlot.at("0xC901829BD7969B91D82e90e096E7F45325918918");

        await pool.donateToPool(f.address,{from:accounts[8], value: (800*10**18).toString()})
        await pool.donateToPool(LCT.address,{from:accounts[9], value: (800*10**18).toString()})
               
        // await pool.donateToPool(f.address,{from:accounts[9], value: (80*10**18).toString()})
        // await pool.donateToPool(f.address,{from:accounts[8], value: (80*10**18).toString()})
        // await pool.donateToPool(f.address,{from:accounts[7], value: (80*10**18).toString()})

        console.log("=======================開始前查詢=============================");
        await inqPool();
        await tool.showAccounts();
        await tool.showContracts();
    });

    after(async () => {     
        console.log("=======================結束後查詢=============================");
        await inqPool();
        await tool.showAccounts();
        await tool.showContracts();
    })

    it("註冊", async () => {     
        let LCT = await LCTContract.deployed();
        
        await LCT.register("0x89B1c05F3044Fd5dE877A0f7b273C4636fD75e1b", {from:accounts[0]}); 
        await LCT.register(accounts[0], {from:accounts[5]}); 
        await LCT.register(accounts[5], {from:accounts[2]}); 
        
    })

    for (let index = 0; index < 20; index++) {

    
        it("start", async () => {
            //let f = await FruitSlot.deployed();
            await f.startGame();
        })
    
        it("bet", async () => {
            //let f = await FruitSlot.deployed();
            await f.BetGame(0,{value: (1*10**18).toString()});
            await f.BetGame(1,{value: (1*10**18).toString()});
            await f.BetGame(2,{value: (1*10**18).toString()});
            await f.BetGame(3,{value: (1*10**18).toString()});
            // await f.BetGame(4,{value: (1*10**18).toString()});
            // await f.BetGame(5,{value: (1*10**18).toString()});
            // await f.BetGame(6,{value: (1*10**18).toString()});
            // await f.BetGame(7,{value: (1*10**18).toString()});
    
            // await f.BetGame(2,{value: (1*10**18).toString()});
            // await f.BetGame(4,{value: (3*10**18).toString()});
            // await f.BetGame(7,{value: (2*10**18).toString()});
        })
    
        it("spin", async () => {
            //let f = await FruitSlot.deployed();
            //{gas:"300000000"}
            let r = await f.RunSpin({gas:"300000000"});
            //console.log(r);
            //let event = r.receipt.logs[0].args;
            let event = r.receipt.logs;
            console.log("gas: "+r.receipt.cumulativeGasUsed+ "/" + r.receipt.gasUsed);
            for (let index = 0; index < event.length; index++) {
                if(event[index].event == "betResult"){
                    let player =  event[index].args.player;
                    let type =  event[index].args._type;
                    let bonus =  event[index].args.bonus;
                    console.log(player, type.toString(), (bonus.toString())/(10**18)+"TAN")
                }
                
            }
            //console.log(event);
            
        })
        
    }
    
    
})