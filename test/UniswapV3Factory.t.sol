// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.7.6;

import "forge-std/Test.sol";
import "../src/UniswapV3Factory.sol";
import "./utils/Tick.sol";
import "./utils/GetCode.sol";

contract UniswapV3FactoryTest is Test {

    UniswapV3Factory public uniswapV3FactoryTest;
    address[2] public TEST_ADDRESSES;
    address internal constant OTHER = address(0xDEAD);

    // Factory Contract Events
    event PoolCreated(address indexed token0, address indexed token1, uint24 indexed fee, int24 tickSpacing, address pool);
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    function setUp() public {
        uniswapV3FactoryTest = new UniswapV3Factory();
        TEST_ADDRESSES[0] = address(1);
        TEST_ADDRESSES[1] = address(2);
    }

    function testInitial() public {
        // Check owner
        assertEq(uniswapV3FactoryTest.owner(), address(this));

        // Check bytecode size of factory contract
        // bytes memory factoryBytecode = GetCode.at(address(uniswapV3FactoryTest));
        // assertEq(factoryBytecode.length, 24198);

        // Check bytecode size of pool contract
        // address poolAddress = uniswapV3FactoryTest.createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], FEE_MEDIUM);
        // bytes memory poolBytecode = GetCode.at(poolAddress);
        // assertEq(poolBytecode.length, 21838);

        // Check mapping of fees and tick spacing
        assertEq(uniswapV3FactoryTest.feeAmountTickSpacing(FEE_LOW), TICK_LOW);
        assertEq(uniswapV3FactoryTest.feeAmountTickSpacing(FEE_MEDIUM), TICK_MEDIUM);
        assertEq(uniswapV3FactoryTest.feeAmountTickSpacing(FEE_HIGH), TICK_HIGH);
    }

    function createPool(address tokenA, address tokenB, uint24 feeAmount) public returns (bool) {
        vm.expectEmit(true, true, true, false);
        address poolAddress = uniswapV3FactoryTest.createPool(tokenA, tokenB, feeAmount);
        int24 tickSpacing = uniswapV3FactoryTest.feeAmountTickSpacing(feeAmount);
        emit PoolCreated(tokenA, tokenB, feeAmount, tickSpacing, poolAddress);
        return true;
    }

    function testPoolCreation() public {
        bool lowFeePoolSuccess = createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], FEE_LOW);
        bool mediumFeePoolSuccess = createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], FEE_MEDIUM);
        bool highFeePoolSuccess = createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], FEE_HIGH);
    }

    function testFailDuplicateTokenPool() public {
        createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[0], FEE_LOW);
    }

    function testFailZeroAddressPool() public {
        createPool(address(0), TEST_ADDRESSES[0], FEE_LOW);
        createPool(TEST_ADDRESSES[0], address(0), FEE_LOW);
        createPool(address(0), address(0), FEE_LOW);
    }

    function testFailFeeAmountInactive() public {
        createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], 250);
    }

    function testsetOwner() public {
        // Check whether OwnerChanged event is emitted
        vm.expectEmit(true, true, false, false);
        uniswapV3FactoryTest.setOwner(OTHER);
        emit OwnerChanged(address(this), OTHER);

        // Check whether new owner address is correct
        assertEq(uniswapV3FactoryTest.owner(), OTHER);

        // Ensure previous owner unable to change ownership
        vm.expectRevert();
        uniswapV3FactoryTest.setOwner(address(0));
    }

    function testSetOwnerFromUnauthorizedAddress() public {
        vm.expectRevert();
        vm.startPrank(OTHER);
        uniswapV3FactoryTest.setOwner(address(0));
    }

    function testEnableFeeAmountFromUnauthorizedAddress() public {
        vm.expectRevert();
        vm.startPrank(OTHER);
        uniswapV3FactoryTest.enableFeeAmount(100, 2);
    }

    function testInvalidFeeAmount() public {
        vm.expectRevert();
        uniswapV3FactoryTest.enableFeeAmount(1000000, 10);
    }

    function testInvalidTickSpacing() public {
        vm.expectRevert();
        uniswapV3FactoryTest.enableFeeAmount(500, 0);
        vm.expectRevert();
        uniswapV3FactoryTest.enableFeeAmount(500, 16384); // Tick capped at 16384
    }

    function testEnableExisingFeeAmount() public {
        uniswapV3FactoryTest.enableFeeAmount(100, 5);
        vm.expectRevert();
        uniswapV3FactoryTest.enableFeeAmount(100, 5);
    }

    function testEnableFeeAmount() public {
        // Check for FeeAmountEnabled event emitted
        vm.expectEmit(true, true, false, false);
        uniswapV3FactoryTest.enableFeeAmount(100, 5);
        emit FeeAmountEnabled(100, 5);

        // Check whether mapping is updated
        assertEq(uniswapV3FactoryTest.feeAmountTickSpacing(100), 5);

        // Check whether pool can be created with new fee amount
        address poolContract = uniswapV3FactoryTest.createPool(TEST_ADDRESSES[0], TEST_ADDRESSES[1], 100);
    }
}