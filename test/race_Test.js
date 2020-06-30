const raceContract = artifacts.require("race_test");
const read = require('readline').createInterface({
    input: process.stdin,
    output: process.stdout,
    historySize: 0
})

function readline(show){
    return new Promise(async (resolve, reject) => {
        read.question(show,(readValue) => {
            resolve(readValue);
        })
    })
}

contract("測試", async (accounts) => {
    var result = {};

    it("創建比賽", async () => {
        console.log("\n\n============創建測試============\n");
        //let race = await raceContract.at("0x322Fe5D0238c93B2073934c93A97edE03C8FDCf5");
        //let race = await raceContract.at("0xCe74Fd83dCC6bEbcF42e7e247aB27d1AB7eaB7cf");
        let race = await raceContract.deployed();
        
        let length = await readline(
            'Please choice a race(enter 1,2,3,4) \n <1> 1200m, <2> 1800m <3> 2400m, <4> 3200m \n')
        await race.generateRace(length);
        let gameInfo = await race.inqGameInfo(accounts[0]);
        console.log("< 比賽距離: "+gameInfo.raceDistance+"m >");
        console.log("<參賽馬匹數: "+gameInfo.horsesAmount+">");
        let horsesInfo = {};
        for (let i = 0; i < gameInfo.horsesAmount; i++) {
            let horseInfo = await race.inqRaceHorsesInfo.call(accounts[0], i+1);
            horsesInfo["NO."+(i+1)] = 
            {"speed":horseInfo.speed.words[0], 
            "stamina":horseInfo.stamina.words[0],
            "sprint":horseInfo.sprintForce.words[0],
            "avatar":horseInfo.avatar.words[0]};
        }
        console.table(horsesInfo);
        //(uint8 speed, uint8 stamina, uint8 sprintForce, uint8 avatar)

        let NO = await readline('Please choice a horse. \n')
        await race.startRace(NO, { from: accounts[0], value: 10 ** 18 });        
        
    })

    for(let i = 1; i < 25; i++) {
        it("比賽過程", async () => {
            //let race = await raceContract.at("0x322Fe5D0238c93B2073934c93A97edE03C8FDCf5");
            //let race = await raceContract.at("0xCe74Fd83dCC6bEbcF42e7e247aB27d1AB7eaB7cf");
            let race = await raceContract.deployed();
            let w = await race.inqWinner.call(accounts[0]);
            if(w.words[0] == 0){
                console.log("\n\n============round"+i+"============\n");
                let round = {};
                let r = await race.inqTotRunDistance.call(accounts[0]);
                let roundarray = [];
                for (let j = 0; j < r.length; j++) {
                    const element = r[j];
                    round["NO."+(j+1)] = (element.words[0]);
                    roundarray.push(element.words[0]);
                }
                let maxNumber = Math.max(...roundarray);
                console.log("round"+i,"NO."+(roundarray.indexOf(maxNumber)+1)+"領先");
                result["round"+i] = round;

                await race.addBlock();
            }else{
                console.log("冠軍出爐: 冠軍為 NO."+w.words[0]);
                
            }
        })
    }

    it("比賽過程", async () => {
        let race = await raceContract.deployed();

        // let h1 = await race.inqRunHistory(accounts[0], 1);
        // console.log(h1);
        // let h2 = await race.inqRunHistory(accounts[0], 2);
        // console.log(h2);
        console.table(result);
        //let race = await raceContract.at("0x322Fe5D0238c93B2073934c93A97edE03C8FDCf5");
        //let race = await raceContract.at("0xCe74Fd83dCC6bEbcF42e7e247aB27d1AB7eaB7cf");
        
        let r = await race.endGame();
        console.log("比賽結束");
    })

    it("清空查詢", async () => {
        let race = await raceContract.deployed();

        let gameInfo = await race.inqGameInfo(accounts[0]);
        console.log(gameInfo);
        
    })
});


