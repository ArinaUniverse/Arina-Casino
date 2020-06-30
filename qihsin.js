//qihsin test module

module.exports = {
    setAccount: setAccount,
    setContract: setContract,
    setAccountName, setAccountName,
    setContractName: setContractName,
    getBalance: getBalance,
    showAccounts: showAccounts,
    showContracts: showContracts,
    readline: readline
}


Accounts = []
AccountsName = []
Contracts = []
ContractsName = []

function setContract(contract) {
    for (let index = 0; index < contract.length; index++) {
        Contracts[index] = contract[index].address;
        //ContractsName[index] = contract[index].name;
    }
}

function setContractName(name) {
    for (let index = 0; index < name.length; index++) {
        ContractsName[index] = name[index]
    }
}

function setAccount(accounts) {
    for (let index = 0; index < accounts.length; index++) {
        Accounts[index] = accounts[index]
    }
}

function setAccountName(name) {
    for (let index = 0; index < name.length; index++) {
        AccountsName[index] = name[index]
    }
}

async function showContracts() {
    console.log("\n\n合約列表:\n")
    let b = await showBalance(Contracts)
    let show = {}

    for (let i = 0; i < Contracts.length; i++) {
        if(ContractsName.length == 0){
            show[i] = {"address":Contracts[i], "balance":b[i]}
        }else{
            show[ContractsName[i]] = {"address":Contracts[i], "balance":b[i]}
        }
    }
    console.table(show);
}

async function showAccounts() {
    console.log("\n\n帳戶列表:\n")
    let b = await showBalance(Accounts)
    let show = {}

    for (let i = 0; i < Accounts.length; i++) {
        if(AccountsName.length == 0){
            show[i] = {"address":Accounts[i], "balance":b[i]}
        }else{
            show[AccountsName[i]] = {"address":Accounts[i], "balance":b[i]}
        }
    }
    console.table(show);
}

async function showBalance(list) {
    return new Promise(async(resolve) => {
        var p = []
        for (let i = 0; i < list.length; i++) {
            p.push(getBalance(list[i]))
        }
        let b = await Promise.all(p);
        resolve(b)
    });
}

function getBalance(address, pos) {
    pos = (typeof pos !== 'undefined') ?  pos:2
    return new Promise((resolve) => {
        web3.eth.getBalance(address).then(value => {
            resolve(formatFloat(value/(10**18), pos))
        });
    })
}

function formatFloat(num, pos){
    var size = Math.pow(10, pos)
    return Math.round(num * size)/size
}

function readline(show){
    const read = require('readline').createInterface({
        input: process.stdin,
        output: process.stdout,
        historySize: 0
    })

    show = (typeof show !== 'undefined') ?  show:"Please input\n"
    return new Promise(async (resolve, reject) => {
        read.question(show,(readValue) => {
            resolve(readValue);
        })
    })
}