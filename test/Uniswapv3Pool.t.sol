// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;

import "./utils/Pool.sol";
import "../src/UniswapV3Pool.sol";
import "./utils/Tick.sol";
import {encodePriceSqrt} from "./utils/Math.sol";
import "../src/libraries/LowGasSafeMath.sol";
import "../src/libraries/LowGasSafeMath.sol";

contract UniswapV3PoolTest is PoolFixture {

    using LowGasSafeMath for int256;

    UniswapV3Pool uniswapV3PoolTest;

    function setUp() public virtual override {
        super.setUp();
        address pool = uniswapV3Factory.createPool(address(tokens[0]), address(tokens[1]), FEE_MEDIUM);
        uniswapV3PoolTest = UniswapV3Pool(pool);
    }

    function testInitial() public {
        assertEq(uniswapV3PoolTest.factory(), address(uniswapV3Factory));
        assertEq(uniswapV3PoolTest.token0(), address(tokens[0]));
        assertEq(uniswapV3PoolTest.token1(), address(tokens[1]));
        assertEq(uniswapV3PoolTest.tickSpacing(), uniswapV3Factory.feeAmountTickSpacing(FEE_MEDIUM));
        // assertEq(uniswapV3PoolTest.fee(), FEE_MEDIUM);
        // assertEq(uniswapV3PoolTest.maxLiquidityPerTick(), Tick.tickSpacingToMaxLiquidityPerTick(TICK_MEDIUM));
    }

    function testInitialize() public {
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 1));
    }

    function testInitializeMinSqrtRatio() public {
        uniswapV3PoolTest.initialize(MIN_SQRT_RATIO);
    }

    function testInitializeMaxSqrtRatio() public {
        uniswapV3PoolTest.initialize(MAX_SQRT_RATIO  - 1);
    }

}