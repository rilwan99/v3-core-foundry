// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;

import "forge-std/Test.sol";
import "../../src/test/TestERC20.sol";
import "../../src/UniswapV3Factory.sol";
import "../../src/UniswapV3PoolDeployer.sol";

contract PoolFixture is Test {
    TestERC20[] tokens;
    UniswapV3Factory uniswapV3Factory;
    address wallet;
    address trader;


    function setUp() public virtual {

        address token0 = address(new TestERC20(type(uint256).max / 2));
        address token1 = address(new TestERC20(type(uint256).max / 2));
        address token2 = address(new TestERC20(type(uint256).max / 2));

        // Sort the token addresses and push them into the token arrary
        // require(token2 < token1, 'unexpected token ordering 2');
        tokens.push(TestERC20(token1));
        tokens.push(TestERC20(token0));
        // tokens.push(TestERC20(token2));

        uniswapV3Factory = new UniswapV3Factory();
        wallet = vm.addr(1);
        trader = vm.addr(2);
    }

}