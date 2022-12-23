// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;

import "./utils/Pool.sol";
import "../src/UniswapV3Pool.sol";
import "./utils/Tick.sol";
import {encodePriceSqrt} from "./utils/Math.sol";
import "../src/libraries/LowGasSafeMath.sol";

contract UniswapV3PoolTest is PoolFixture {

    using LowGasSafeMath for int256;
    
    UniswapV3Pool uniswapV3PoolTest;

    function setUp() public virtual override {
        super.setUp();
        address pool = uniswapV3Factory.createPool(address(tokens[0]), address(tokens[1]), FEE_MEDIUM);
        uniswapV3PoolTest = UniswapV3Pool(pool);

        vm.deal(trader, 100 ether);
        vm.deal(wallet, 100 ether);
        for (uint256 i = 0; i < tokens.length; i++) {
            tokens[i].approve(address(uniswapV3PoolTest), type(uint256).max);
            vm.prank(trader);
            tokens[i].approve(address(uniswapV3PoolTest), type(uint256).max);
            tokens[i].transfer(trader, 1_000_000 * 1 ether);
        }
    }

    function testInitial() public {
        assertEq(uniswapV3PoolTest.factory(), address(uniswapV3Factory));
        assertEq(uniswapV3PoolTest.token0(), address(tokens[0]));
        assertEq(uniswapV3PoolTest.token1(), address(tokens[1]));
        assertEq(uniswapV3PoolTest.tickSpacing(), uniswapV3Factory.feeAmountTickSpacing(FEE_MEDIUM));
        assertEqUint(uniswapV3PoolTest.fee(), FEE_MEDIUM);
        assertEqUint(uniswapV3PoolTest.maxLiquidityPerTick(), tickSpacingToMaxLiquidityPerTick(TICK_MEDIUM));
    }

    function testPreviouslyInitializedPool() public {
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 1));
        vm.expectRevert(bytes('AI')); // Already Initialized
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 1));
    }

    function testInitializeOutOfBounds() public {
        vm.expectRevert(bytes('R'));
        uniswapV3PoolTest.initialize(MIN_SQRT_RATIO - 1);
        vm.expectRevert(bytes("R"));
        uniswapV3PoolTest.initialize(MAX_SQRT_RATIO);
    }

    function testInitializeMinSqrtRatio() public {
        uniswapV3PoolTest.initialize(MIN_SQRT_RATIO);
        ( ,int24 tick, , , , , ) = uniswapV3PoolTest.slot0();
        assertEq(tick, MIN_TICK);
    }

    function testInitializeMaxSqrtRatio() public {
        uniswapV3PoolTest.initialize(MAX_SQRT_RATIO  - 1);
        ( ,int24 tick, , , , , ) = uniswapV3PoolTest.slot0();
        assertEq(tick, MAX_TICK - 1);
    }

    function testInitializePoolSuccess() public {
        uint160 price = encodePriceSqrt(1, 2);

        vm.expectEmit(true, true, false, false);
        emit Initialize(price, -6932);
        uniswapV3PoolTest.initialize(price);

        (uint160 sqrtPriceX96, int24 tick, uint16 observationIndex, , , , ) = uniswapV3PoolTest.slot0();
        assertEqUint(sqrtPriceX96, price);
        assertEqUint(observationIndex, 0);
        assertEq(tick, -6932);

        (uint32 blockTimestamp, int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128, bool initialized) = uniswapV3PoolTest.observations(0);
        assertEq(tickCumulative, 0);
        assertEqUint(secondsPerLiquidityCumulativeX128, 0);
        assertEq(initialized, true);
    }

    function testIncreaseObservationCardinality() public {
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 1));
        vm.expectEmit(true, true, false, false);
        emit IncreaseObservationCardinalityNext(1, 2);
        uniswapV3PoolTest.increaseObservationCardinalityNext(2);

        ( , , , uint16 observationCardinality, uint16 observationCardinalityNext, , ) = uniswapV3PoolTest.slot0();
        assertEqUint(observationCardinality, 1);
        assertEqUint(observationCardinalityNext, 2);
    }

    function testIncreaseObservationCardinalityBeforeInitialize() public {
        vm.expectRevert(bytes("LOK"));
        uniswapV3PoolTest.increaseObservationCardinalityNext(2);
    }

    function testIncreaseObservationCardinalitySkip() public {
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 1));
        uniswapV3PoolTest.increaseObservationCardinalityNext(3);
        uniswapV3PoolTest.increaseObservationCardinalityNext(2);

        ( , , , uint16 observationCardinality, uint16 observationCardinalityNext, , ) = uniswapV3PoolTest.slot0();
        assertEqUint(observationCardinality, 1);
        assertEqUint(observationCardinalityNext, 3);
    }

    function testMintBeforeInitialize(int24 tickSpacing) public {
        vm.expectRevert(bytes("LOK"));
        uniswapV3PoolTest.mint(wallet, tickSpacing, -tickSpacing, 1, bytes('0x'));
    }

    function testUnsuccessfulMint() public {
        uniswapV3PoolTest.initialize(encodePriceSqrt(1, 10));

        vm.expectRevert(bytes("TLU"));
        uniswapV3PoolTest.mint(wallet, 1, 0, 1, bytes('0x'));

        vm.expectRevert(bytes("TLM"));
        uniswapV3PoolTest.mint(wallet, MIN_TICK-1, 0, 1, bytes('0x'));

        vm.expectRevert(bytes("TUM"));
        uniswapV3PoolTest.mint(wallet, 0, MAX_TICK + 1, 1, bytes('0x'));

        uint128 maxLiquidity = uniswapV3PoolTest.maxLiquidityPerTick();
        vm.expectRevert(bytes('LO'));
        uniswapV3PoolTest.mint(wallet, 0, 20, maxLiquidity + 1, bytes('0x'));
    }



}