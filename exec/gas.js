const FruitSlot = artifacts.require("FruitSlot");

module.exports = async function(callback) {
    let f = await FruitSlot.deployed();

    // function send(func) {
    //     return new Promise(async(resolve, reject) => {
    //         func.on('transactionHash', (hash) =>{
    //             console.log("送出交易,hash為:"+hash)
    //         }).on('confirmation', (confirmationNumber, receipt) =>{
    //             console.log("transaction done");
    //             resolve(receipt)
    //         }).on('error', error =>{
    //             console.log(error)
    //             reject()
    //         })
    //     });
    // }

    function send(func) {
        return new Promise(async(resolve, reject) => {
            let r = await func
            resolve(r)
        });
    }

    function startGame() {
        return new Promise((resolve, reject) => {
            f.startGame()
            .on('transactionHash', function(hash){
                console.log("送出交易,hash為:"+hash)
            }).on('confirmation', (confirmationNumber, r) => {
                console.log("gas: "+r.receipt.cumulativeGasUsed+ "/" + r.receipt.gasUsed);
                console.log("startGame done")
                resolve(r)
            }).on('error', error =>{
                console.log(error)
                //reject()
            })
        });
    }

    function BetGame() {
        return new Promise((resolve, reject) => {
            f.BetGame(0,{value: (1*10**18).toString()})
            .on('transactionHash', function(hash){
                console.log("送出交易,hash為:"+hash)
            })
            .on('confirmation', (confirmationNumber, r) =>{
                console.log("bet done")
                console.log("gas: "+r.receipt.cumulativeGasUsed+ "/" + r.receipt.gasUsed);
                resolve(r)
            }).on('receipt', function(receipt){
                console.log("xxx")
            })
            .on('error', error => {
                console.log(error)
                //reject()
            })
            //await f.BetGame(0,{value: (1*10**18).toString()});
            // await f.BetGame(1,{value: (1*10**18).toString()});
            // await f.BetGame(2,{value: (1*10**18).toString()});
            // await f.BetGame(3,{value: (1*10**18).toString()});
            // await f.BetGame(4,{value: (1*10**18).toString()});
            // await f.BetGame(5,{value: (2*10**18).toString()});
            // await f.BetGame(6,{value: (3*10**18).toString()});
            //await f.BetGame(7,{value: (6*10**18).toString()});
    
            // await f.BetGame(2,{value: (1*10**18).toString()});
            // await f.BetGame(4,{value: (3*10**18).toString()});
            // await f.BetGame(7,{value: (2*10**18).toString()});
        });
    }

    function spin() {
        return new Promise((resolve, reject) => {
            f.RunSpin().on('transactionHash', function(hash){
                console.log("送出交易,hash為:"+hash)
            })
            .on('confirmation', (confirmationNumber, r) =>{
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
                console.log("RunSpin done")
                resolve(r);
            }).on('error', function(){
                console.error
                //reject()
            })
        })
    }

    for (let index = 0; index < 1; index++) {
        
        console.log("===================== run"+ (index+1) + " ======================")

        // let a = await send(f.startGame())
        // console.log(a);
        let b = await send(f.BetGame(0,{value: (1*10**18).toString()}))
        console.log(b);
        let c = await send(f.spin())
        console.log(c);
        
        // await startGame()
        // await BetGame()
        // await spin()
        callback()
    }
    
    
}