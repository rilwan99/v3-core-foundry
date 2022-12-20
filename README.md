# Uniswap V3 Core - Foundry Edition

This repository contains the core contracts for the Uniswap V3 Protocol, compiled and tested using the [foundry](https://book.getfoundry.sh/) toolchain.

For the periphery contracts, see the [uniswap-v3-periphery](https://github.com/Uniswap/v3-periphery) repository.

To view the periphery contracts modified for building and testing with foundry, view the [v3-periphery-foundry](https://github.com/gakonst/v3-periphery-foundry) repository.

### Foundry Modification
This repository has been modified to also support Foundry Solidity tests.

If you already have Foundry's `forge` installed, first install the dependencies with `yarn`, and then simply run `forge test` to run the Solidity tests under contracts/test folder.