# FlightSurety

FlightSurety is a sample application project for Udacity's Blockchain course.

## Versions

Truffle v5.0.36 (core: 5.0.36)
Solidity - 0.4.24 (solc-js)
Node v10.15.0
Web3.js v1.2.1

## How to Run

To install, download or clone the repo, then:

`npm install` <br />
`sudo truffle compile` <br />
`ganache-cli -l 999999999999 -m "candy maplcake sugar puddi cream honey rich smooth crumble sweet treat" -e 10000 -a 30`  <br />
`sudo truffle migrate --reset --network development_test_network` <br />
`sudo truffle test test/flightSurety.js --network development_test_network` <br />
`sudo truffle test test/oracles.js --network development_test_network` <br />
`npm run server` <br />
`npm run dapp` <br />

## Develop Client

To view dapp:

`http://localhost:8000`

## Develop Server

`npm run server`
`truffle test ./test/oracles.js`

## Deploy

To build dapp for prod:
`npm run dapp:prod`

Deploy the contents of the ./dapp folder


## Resources

* [How does Ethereum work anyway?](https://medium.com/@preethikasireddy/how-does-ethereum-work-anyway-22d1df506369)
* [BIP39 Mnemonic Generator](https://iancoleman.io/bip39/)
* [Truffle Framework](http://truffleframework.com/)
* [Ganache Local Blockchain](http://truffleframework.com/ganache/)
* [Remix Solidity IDE](https://remix.ethereum.org/)
* [Solidity Language Reference](http://solidity.readthedocs.io/en/v0.4.24/)
* [Ethereum Blockchain Explorer](https://etherscan.io/)
* [Web3Js Reference](https://github.com/ethereum/wiki/wiki/JavaScript-API)
