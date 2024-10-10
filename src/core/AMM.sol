// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

// import "../interfaces/";
import "../libraries/tokens/ERC20.sol";
import {FixedPointMathLib as Math} from "../libraries/utils/FixedPointMathLib.sol";

/* 
* Collateral Conversion Model
# Glossary of variables and terms
# =======================
# ticks, segments - price ranges where liquidity is deposited
# x - coin which is being borrowed, typically stablecoin
# y - collateral coin (for example, wETH)
# A - amplification, the measure of how concentrated the tick is
# rate - interest rate
# rate_mul - rate multiplier, 1 + integral(rate * dt)
# active_segm - current segment. Other segments are either in one or other coin, but not both
# min_segm - segments below this are definitely empty
# max_segm - segments above this are definitely empty
# segments_x[n], segments_y[n] - amounts of coin x or y deposited in segment n
# user_shares[user,n] / total_shares[n] - fraction of n'th segment owned by a user
# p_oracle - external oracle price (can be from another AMM)
# p (as in get_p) - current price of AMM. It depends not only on the balances (x,y) in the segment and active_segment, but also on p_oracle
# p_current_up, p_current_down - the value of p at constant p_oracle when y=0 or x=0 respectively for the segment n
# p_oracle_up, p_oracle_down - edges of the segment when p=p_oracle (steady state), happen when x=0 or y=0 respectively, for segment n.
# * Grid of segments is set for p_oracle values such as:
#   * p_oracle_up(n) = base_price * ((A - 1) / A)**n
#   * p_oracle_down(n) = p_oracle_up(n) * (A - 1) / A = p_oracle_up(n+1)
# * p_current_up and p_oracle_up change in opposite directions with n
# * When intereste is accrued - all the grid moves by change of base_price
#
# Bonding curve reads as:
# (f + x) * (g + y) = Inv = p_oracle * A**2 * y0**2
# =======================
*/

interface PriceOracle {
    function price() external view returns (uint256);
    // function priceW() external nonpayable returns (uint256);
}

contract AMM {

    int256 public constant MAX_TICKS = 50;
    uint256 public constant MAX_TICKS_UINT = 50;
    int256 public constant MAX_SKIP_TICKS = 1024;

    struct UserTicks {
        int256 ns; // packs n1 and n2, each is int128
        uint256[MAX_TICKS/2] ticks; // share fractions packed 2 per slot
    }

    struct DetailedTrade {
        uint256 inAmount;
        uint256 outAmount;
        int256 n1;
        int256 n2;
        uint256[MAX_TICKS_UINT] ticksIn;
        uint256 adminFee;
    }


    ERC20 public immutable STABLECOIN;  // x
    ERC20 COLLATERAL_TOKEN; // y
    address public immutable CONTROLLER;
    address public MARKET_OPERATOR;
    //PriceOracle
    address public ORACLE;
    
    uint256 COLLATERAL_PRECISION;
    uint256 BASE_PRICE;
    uint256 public immutable A;
    uint256 immutable Aminus1;
    uint256 immutable A2;
    uint256 immutable Aminus12;
    uint256 immutable SQRT_SEGM_RATIO; // sqrt(A / (A - 1))
    int256 immutable LOG_A_RATIO;   // ln(A / (A - 1))
    uint256 immutable MAX_ORACLE_DN_POW; // (A / (A - 1)) ** 50

    uint256 public fee;
    uint256 public adminFee;
    uint256 public rate;
    uint256 rateTime;
    uint256 rateMul;
    int256 public activeSegm;
    int256 public minSegm;
    int256 public maxSegm;

    uint256 admin_fees_x;
    uint256 admin_fees_y;

    uint256 oldPO;
    uint256 oldDfee;
    uint256 prePOTime;
    uint256 constant PREV_P_O_DELAY = 2 * 60; // s = 2min
    uint256 constant MAX_P_O_CHG = 12500 * 10 ** 14; // <= 2**(1/3) - max relative change to have fee < 50%

    mapping(int256 => uint256) public segmsX;
    mapping(int256 => uint256) public segmsY;

    mapping(int256 => uint256) totalShares;
    mapping(address => UserTicks) userShares;
    uint256 public constant DEAD_SHARES = 1000;

    //public lmHook = LMGauge;

    constructor(address _controller, ERC20 _stablecoin, uint256 _A) {
        CONTROLLER = _controller;
        STABLECOIN = _stablecoin;
        A = _A;

        Aminus1 = A - 1;
        A2 = Math.powMod256(A, 2);
        Aminus12 = Math.powMod256(Aminus1, 2);

        SQRT_SEGM_RATIO = Math.sqrt(Math.unsafeDiv( 10 ** 36 * _A, (_A - 1)));

        // log(A / (A - 1))
        uint256 x = 10**18 * _A / (_A - 1);
        uint256 res = 0;

        for (uint256 i; i <= 8; i++) {
            uint256 t = 2 ** (7 - i);
            uint256 p = 2 ** t;

            if ( x >= p * 10**18){
                x /= p;
                res += t * 10**18;
            }
        }
        uint256 d = 10 ** 18;
        for (uint256 i; i <= 59; i++) {
            if (x >= 2 * 10**18){
                res += d;
                x /= 2;
            }
            x = x * x / 10**18;
            d /= 2;
        }
        // now res = log2(x)
        // ln(x) = log2(x) / log2(e)
        LOG_A_RATIO = int256(res * 10**18 / 1442695040888963328);

        // (A / (A - 1)) ** 50
        uint256 pow = 10 ** 18;
        for (uint256 i; i <= 50; i++) {
            pow = Math.unsafeDiv(pow ** A, Aminus1);
        }
        MAX_ORACLE_DN_POW = pow;
    }

    function initialize(
        address market,
        PriceOracle oracle,
        ERC20 collateral,
        uint256 basePrice,
        uint256 _fee,
        uint256 _adminFee) external {
        
    }

    // --- external view functions ---

    function coins(uint256 i) external view returns (ERC20) {

    }

    // --- internal functions --- 
    


}