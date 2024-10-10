// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract MainController {

    //address public constant CORE_OWNER = coreOwner;


    constructor() {

    }

    // --- Getters ---

    function getOwner() external view returns (address) {
        //return CORE_OWNER.owner();
    }

    function getMarketCount() external view returns (uint256) {

    }

    function getCollateralCount() external view returns (uint256) {

    }

    function getAllMarkets() external view returns (address[] memory) {

    }

    function getAllCollaterals() external view returns (address[] memory) {
        
    }

    function getAllMarketsForCollaterals() external view returns (address[] memory) {

    }

    function getMarket(address _collateral, uint256 i) external view returns (address) {

    }

    //Get AMM address for collateral
    function getAMM(address _collateral, uint256 i) external view returns (address) {

    }

    function getCollateral(address _market) external view returns (address) {
        
    }

    function getOraclePrice(address _collateral) external view returns (uint256) {

    }

    function maxBorrowable(uint256 marketOperator, uint256 collAmount, uint256 nSegs) external view returns (uint256) {

    }

    /* 
    * @notice Get the `MarketOperator` and `AMM` implementation contracts used when deploying a market with the given 'A'(amplification coefficient).
    * @return (AMM address, MarketOperator address)
    */
    function getImplementations(uint256 A) external view returns (address[] memory) {
    
    }

    /*
    * @notice Get the hook contracts and active hooks for the given market
    * @return market hooks
     */
    function getMarketHooks(address market) external view returns (address[] memory) {

    }

    function getMarketHookDebt(address market, address hook) external view returns (uint256) {

    }

    function getMonetaryPolicyForMarket(address market) external view returns (uint256) {

    }

    function getStablKeeperActiveDebt() external view returns (uint256) {

    }

    function storedAdminFees() external view returns (uint256) {

    }

    /*
    * @notice Get balance information related to closing a loan
    * @param account The account to close the loan for
    * @param market Market of the loan being closed
    * @return Debt balance change for caller
             * negative value indicates the amount burned to close
             * positive value indicates a surplus from the AMM after closing
            Collateral balance received from AMM
    */
    function getCloseLoanAmounts(address account, address market) external view returns (int256, uint256) {

    }

    /*
    * @notice Get the aggregate hook debt adjustment when creating a new loan
    * @param account Account to open the loan for
    * @param market Market where the loan will be opened
    * @param coll_amount Collateral amount to deposit
    * @param debt_amount Stablecoin amount to mint
    * @return adjustment amount applied to the new debt created
    */
    function onCreateLoanHookAdjustment(address account, address market, uint256 collAmount, uint256 debtAmount) external view returns (int256) {

    }

    function onAdjustLoanHookAdjustment(address account, address market, int256 collChange, int256 debtChange) external view returns (int256) {

    }





}