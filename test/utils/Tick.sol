pragma solidity ^0.7.6;

import '../../src/libraries/TickMath.sol';

uint24 constant FEE_LOW = 500;
uint24 constant FEE_MEDIUM = 3000;
uint24 constant FEE_HIGH = 10000;

int24 constant TICK_LOW = 10;
int24 constant TICK_MEDIUM = 60;
int24 constant TICK_HIGH = 200;

int24 constant MIN_TICK = -887272;
int24 constant MAX_TICK = -MIN_TICK;

uint160 constant MIN_SQRT_RATIO = 4295128739;
uint160 constant MAX_SQRT_RATIO = 1461446703485210103287273052203988822378723970342;

function getMinTick(int24 tickSpacing) pure returns (int24) {
    return (TickMath.MIN_TICK / tickSpacing) * tickSpacing;
}

function getMaxTick(int24 tickSpacing) pure returns (int24) {
    return (TickMath.MAX_TICK / tickSpacing) * tickSpacing;
}

function tickSpacingToMaxLiquidityPerTick(int24 tickSpacing) pure returns (uint128) {
    int24 minTick = (TickMath.MIN_TICK / tickSpacing) * tickSpacing;
    int24 maxTick = (TickMath.MAX_TICK / tickSpacing) * tickSpacing;
    uint24 numTicks = uint24((maxTick - minTick) / tickSpacing) + 1;
    return type(uint128).max / numTicks;
}