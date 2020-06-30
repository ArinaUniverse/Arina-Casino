const FruitSlot = artifacts.require("FruitSlot");
const poolsContract = artifacts.require("pool");
console.log("xxx")



module.exports = async function(callback) {
    console.log("yyy")

    // var mocha = require('mocha')

    // var describe = mocha.describe
    // var it = mocha.it
    // console.log(describe)
    // console.log(it)

    //var describe = require("mocha.describe")

    // describe("gas test", async () => {
        console.log("zzz")
        // before(async () =>{
        //     let f = await FruitSlot.deployed();
        //     let pool = await poolsContract.deployed();
        //     await pool.donateToPool(f.address,{from:accounts[9], value: (80*10**18).toString()})
        //     await pool.donateToPool(f.address,{from:accounts[8], value: (80*10**18).toString()})
        //     await pool.donateToPool(f.address,{from:accounts[7], value: (80*10**18).toString()})
        // });

        for (let index = 0; index < 1; index++) {

        
            it("start", async () => {
                let f = await FruitSlot.deployed();
                await f.startGame();
                console.log("aaa");
                
            })
        
            it("bet", async () => {
                let f = await FruitSlot.deployed();
                await f.BetGame(0,{value: (1*10**18).toString()});
                await f.BetGame(1,{value: (1*10**18).toString()});
                await f.BetGame(2,{value: (1*10**18).toString()});
                await f.BetGame(3,{value: (1*10**18).toString()});
                await f.BetGame(4,{value: (1*10**18).toString()});
                // await f.BetGame(5,{value: (2*10**18).toString()});
                // await f.BetGame(6,{value: (3*10**18).toString()});
                //await f.BetGame(7,{value: (6*10**18).toString()});
        
                // await f.BetGame(2,{value: (1*10**18).toString()});
                // await f.BetGame(4,{value: (3*10**18).toString()});
                // await f.BetGame(7,{value: (2*10**18).toString()});
                console.log("bbb");
            })
        
            it("spin", async () => {
                let f = await FruitSlot.deployed();
                let r = await f.RunSpin();
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
        
        
    // })
    callback()
}