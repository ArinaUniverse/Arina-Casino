const LCTContract = artifacts.require("LCT");


module.exports = async function(callback) {

    LCT = await LCTContract.deployed();

    console.log(LCT.address)

    //await inq("0x08A9fEaEfa545787f8E2D8c9C3f5e7343261d620")
    let base = 1e8

    let price = await LCT.buyPrice.call(3);
    console.log("招財貓價格為:"+price.toString()+"CHIPS");
    let r = await LCT.buyLCT(3, price.toString()*base,{from:"0xb933D68e872300308C3Fd3B38a2657D6BE6a9a11"}); 
    console.log(r)

    // let price = await LCT.sellPrice.call(3);
    // console.log("招財貓價格為:"+price.toString()+"CHIPS");

    await inq("0xb933D68e872300308C3Fd3B38a2657D6BE6a9a11")

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

}