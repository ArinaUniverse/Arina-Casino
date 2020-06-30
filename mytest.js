const truffle  = require("truffle")
//truffle.contracts.collectCompilations().then(console.log)

// truffle.create.contract("./contracts", "chips", "", (r) => {
//     console.log(r);
// })
//console.log(truffle.package.publishable_artifacts.toString())
//console.log(truffle.create.migration.toString());
console.log(truffle.build.build.toString());
// const Artifactor = require("@truffle/artifactor")
// let artifacts = new Artifactor("./")
// console.log(artifacts)