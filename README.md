# CDP-stablecoin Experiment
> @nicholaslico

## Summary

具有delta-neutral稳定性与自动抵押转换机制的CDP-based Crypto-Native Money.

## Motivation
> [Solving the Stablecoin Trilemma](https://multicoin.capital/2021/09/02/solving-the-stablecoin-trilemma/) 稳定币三难困境

市场上已有不少的稳定币产品，稳定币是整个crypto行业的基础，是使用率最高的资产。并具有(i) true product-market fit(globally), (ii)the largest potential market, (iii) strongest revenue-generating capacity等特点。值得持续研究。

本项目实验旨在创造一种以现货资产为支撑、以链上和中心化流动性的加密原生合成美元，使用户获得一种全球可访问且抗审查的持有资产的方式。

前置分析
1. 中心化稳定币的风险在于集中托管，胜在比defi更大的规模。所以可以尝试将中心化的相对稳定性与链上原生资产抗审查性相结合。
2. 建立delta中性头寸，合理利用衍生品市场，确保标的资产价格的波动被衍生品头寸的收益或损失所抵消。
3. 这种稳定币是一种合成资产
4. 充分利用市场流动性，进行多层的结构化设计，在stablecoin trilemma取得平衡

## Overview
基于CDP的稳定币实验，具有以下目标特性：
- 利用L2s构建，统一EVM流动性原生跨链
- (抵押品管理) 抵押品和稳定币可自动转换，用来保护抵押品
- 在超额抵押基础上，无限接近1:1的抵押
- 更多的抵押品种类(Exotic collateral types)，同时了引入了更多风险
- 抗风险机制

> - 动态利率设计
> - 通过质押获得收益和积分

## How it works

### $STABL made
> $STABL is created through depositing collateral and opening loans.

STABL是一种基于抵押的稳定币，这就是说STABL的价值由其他资产（如BTC, ETH）的价值支撑，每当有人想要创建STABL时，他们都必须存入一些资产，并将其锁定在智能合约中抵押。存入抵押品以铸造稳定币通常被称为开立抵押债务头寸 (CDP)。
如果抵押品的价值跌破某个阈值，智能合约将自动开始交易部分抵押品，以确保 $STABL 始终由等值的美元支撑。你始终必须存入比铸造金额略多的美元价值抵押品，超额抵押的金额取决于你愿意承担的风险。

> 如果借款人推测未来ETH的价格会上涨，借款人可以用ETH作抵押借入STABL(可杠杆)，将STABL在公开市场上swap，以获得更多的ETH，loop，以获得更多收益。

**STABL和其他CDP-based稳定币的区别**
主要区别在于抵押品转换机制，当用户在协议中创建贷款时，他们的CDP由流动性池中的多个不同的价格段(price segment)构成（multiple ordered columns with staggered prices），如果抵押品价格到达某个价格段，该部分将以特定价格点进行交易。
通过将抵押品分成多个区间，如果达到清算价格 (如在Liquity)，贷款不必立即清算，因为清算价格会“分散”在一定范围内以降低风险。在某个价格区间中可以交易回抵押品，这可以保护用户免受短期价格波动的影响，否则可能会立即清算并关闭他们的贷款，导致即时损失。这使得借贷更加用户友好且更易于管理。
抵押品转换合约会自动平衡头寸，以确保其保持抵押（loan health）。部分抵押品被兑换成可用于偿还贷款的STABL。如果抵押品的价格恢复，智能合约可以自动为用户重新换回抵押品。


### Collateral Conversion Model

当用户设置贷款时，他们决定存入多少抵押品和借入多少$STABL，这两个值决定了当前贷款的Conversion range（转换范围）。
转换范围是您的抵押品可以出售以cover贷款健康的价格范围，反之如果抵押品价格上涨，也可以用于回购抵押品。
如果抵押品的价格下跌得太快以至于您无法提前响应和调整贷款，CCM可以保护抵押品。
转换范围设置得离抵押品的当前价格越远，存入的抵押品越多，借入的$STABL就越多（因此更安全）。

转换区间是一组结构化的价格段(price segment)，每段里都有抵押品的一部分，如果抵押品跌至某个价格段，这些抵押品将被交易成$STABL。
为什么抵押品部分交易成$STABL，有两个方面：
1. 贷款由抵押品支持，如果抵押品的总价值跌得太接近$STABL借贷的金额，与其清算所有东西和关闭贷款，不如将部分转换为$STABL，在需要的范围内，确保贷款仍然得到支持。
2. 同时交易部分抵押资产后获得的$STABL可以保留并包含在抵押品中，这样协议不会在仍有支持的情况下偿还和关闭贷款。

因此，如果用户的抵押品被部分转换，他们的抵押品现在是原始抵押品的一部分加上新增加的$STABL（扣除一部分费用）的组合，它们加在一起仍然可以支付贷款。如果抵押品的价格再次上涨，我们现在有办法使用新的那部分$STABL买回已售出的抵押品，这样可以保护抵押资产价格在短期波动中的损失。当然，如果价格下跌得太远，它并不能阻止完全清算，所以需要将转换范围设置在与当前价格保持在安全距离。

> 示例：

如果你有 10 个WETH，已平均分成 10 个价格区间，并且第一个区间已以每WETH 3000 $STABL的平均汇率转换，那么您的贷款总抵押品现在将为 9 WETH + 3000 STABL。如果价格进一步下跌，下一个价格段被触发并被转换，该区间的平均交易价格为每WETH 2900 STABL，那么你的新抵押品现在将是 8 WETH + 5900 STABL，依此类推。

1. 抵押品可以转换为 STABL，但如果抵押品的价格恢复，也可以从 STABL 转换回原始抵押资产，它是双向的。
2. 转换过程中涉及交易费用。如果贷款进入转换状态，然后因为抵押品价格回升而退出，那么由于这些费用，当前贷款中剩余的抵押品会略少。

#### Price segment
> price segment功能类似于Uniswap V3 range 将流动性集中在两个价格之间。

当创建一笔贷款时，该笔贷款的抵押品会被分散到流动性池中的多个价格段中，通过将抵押品分成不同的段，如果抵押品的价格达到清算价格，贷款就不必完全清算（与其他借贷协议一样），因为清算价格被 "分散 "在一定范围内，以降低风险。
它们可以像在 AMM 流动性池中一样被交易回抵押品中，这取决于价格变动的方向。这可以保护用户免受短期价格波动的影响，否则可能会立即清算并关闭贷款，从而导致即时损失。

随着时间的推移，贷款因为借款利率会产生利息，转换范围也会慢慢上移，以计入增加的债务。

默认情况下，新创建的贷款抵押品分为 10 个价格段。如果抵押物的价格进入了该特定贷款抵押品转换范围的第一个段，则可转换 1/10 的抵押品，以确保贷款仍有足够的价值支持。这会根据价格的变动而改变，因此抵押品可能会被转换 20%、30%、40% 等，也可能会被转换 0%。

在创建贷款时，可以选择不同的段数（4 ~ 50），默认为10。
较少段数可以提高资本效率，但如果抵押品价格下跌到段内，会一次转换更多的抵押品；更多段数则相反，转化会更细的进行，资本效率略低，更适合长期的"set-and-forget"偏好的贷款。

```math
\begin{aligned}
priceSegment \approx \frac{price}{A} \\

upperLimit = basePrice * (\frac{A-1}{A})^n \\

lowerLimit = basePrice * (\frac{A-1}{A})^{n+1}
\end{aligned}
```

其中，
- $basePrice$ 当前市场的基础价格
- $A$ 段数，是一种市场的放大系数（default 10）
- $n$ 段号

### Delta-Neutral Stability
> "Delta" refers to the sensitivity of the derivatives contract to a change in the price of the underlying asset. 

 

---
### Borrwing

#### Loan health

```math
\begin{aligned}
health = \frac{s\times(1-liqD)+p}{debt}-1 \\

p = collateral \times abovePriceSegs \\

s = collateral \times (\frac{softLiqUpperLimit-softLiqLowerLimit}{2})
\end{aligned}
```

其中，
- $s$, 估算将所有存入抵押品按不同价格段进行转换后，有多少$STABL
- $liqD$, 协议设置的清算折扣 (抵押品价值的贴现值)
- $p$, 当前预言机价格减去在清算范围内的最高价格区间设置的价格，乘以抵押品数量。如果贷款已进入抵押品转换（soft liq），则 p 设置为 0
    - $collateral$, 抵押品数量
    - $abovePriceSegs$, 预言机价格与用户软清算区间顶端（upper limit of top segment）的价差。
- $debt$, 当前贷款的债务，包括利息累积


#### Borrow rate
借贷利率(as the interest rate)是在任何给定时间在给定借贷市场中借款$STABL的成本，以 APR（不考虑复利）表示。利率是动态的，根据算法在市场变化时更新。
动态利率的目的是确保$STABL作为稳定币与USD peg的稳定性。
改变特定市场借贷利率主要有三种因素：
1. 当前市场离其债务上限(debt ceiling)有多近，越接近债务上限，利率越高，反之亦然
2. $STABL当前价格，如果STABL价高于1USD，则降低利率，反之亦然
3. Stability Keepers有多少债务，债务越多，利率就越低，反之亦然

**The borrow rate formula**

```math
\begin{aligned}
r=rate0*e^{power}\\

power = \frac{1-price}{sigma}-\frac{DebtFraction}{TargetFraction} \\

DebtFraction = \frac{PegKeeperDebt}{TotalDebt}
\end{aligned}
```

其中：
- $r$ 借贷利率
- $rate0$ 预定义的基准利率
- $price$ `PRICE_ORACLE.price()`，在计算借贷利率的同一网络上
- $sigma$ 由 Governance 配置的变量，它决定了价格与 peg 的距离对借款利率的影响有多大, sigma会改变$STABL depeg时利率上升和下降的速度，如果sigma较高，$STABL depeg时利率上升会较慢。
- $DebtFraction$ Stabl Keepers 的债务与市场债务的比率，在同一网络上计算借贷利率
- $TargetFraction$ 是一个预定义值，用于确定 DebtFraction 对借贷利率的影响有多大
- $StablKeeperDebt$ 是所有 Stabl Keeper 的债务，在同一网络上计算借贷利率
- $TotalDebt$ 是所有市场的债务，在同一个网络上计算借贷利率


### Liquidation & Stability Pool

#### Liquidation logic
在转换模式特性的清算可视为以下几个阶段：
- Soft Liquidation, 当部分抵押品转换为$STABL时
- De-Liquidation, 当$STABL转换回抵押品时
- (Hard) Liqudation, 所有抵押品都转换为$STABL,贷款关闭。


**强制清算(hard liquidation)**

真正的清算发生在当抵押品的价格跌破转换范围，而loan health低于0时发生，协议已无法管理贷款，因为抵押品无法覆盖超过该点的贷款，因此必须自动关闭贷款。这意味着即使抵押品的价格将来回升，转换模式也无法回购抵押品，因为它不再持有您的资金。


**如何防止清算？**

用户可在抵押品价格大幅下降至转换范围时采取主动行动，并在进入抵押品转换模式时积极偿还贷款。如果在贷款中添加更多抵押品，或部分偿还贷款，或两者兼而有之，在转换模式下偿还贷款将使你远离清算。

**如何清算抵押品？**

清算以价格区间为基础，而不是以单个用户为基础。

清算通过套利方式来进行，只要`get_p ≠ price_oracle`就有套利机会。 
- `price_oracle`：从price oracle合约中获取的抵押品价格。
- `get_p`：CCM本身的预言机价格。

**price_oracle decrease (soft liquidation)**
`get_p < price_oracle`, 例如，如果`get_p`为 2000 且`price_oracle`为 2020，套利交易可以以 2000 的价格购买 ETH，然后在协议外以 2020 的价格出售。这个过程会降低区间内的 ETH（因为买入）并增加 STABL（因为卖出）。

**price_oracle increase (de-liquidation)**
`get_p > price_oracle`, 例如，如果`get_p`是2020，而是`price_oracle`2010，套利交易可以在协议外以 2010 的价格购买 ETH，然后在协议中以 2020 的价格出售。

#### Stabl Keeper
StablKeeper的任务就是尽可能将稳定池中的资产金额平衡在50/50，将 $STABL 稳定在peg 1USD。

StablKeeper是专门用于维护STABL挂钩稳定性的合约，StablKeeper仅限于两个操作：从流动性池中depositing and withdrawing

这些合约都与一个特定的流动性池相关联，其中包括 STABL 和另一种fiat-redeemable USD stablecoin。

StablKeepers 的基本思想围绕监控 STABL 的价格和当前池的余额并采取相应的行动。当 STABL 的价格超过 1.0 时，表明向上偏离，StablKeepers 将他们的 STABL 存入当前池，作为交换，他们会收到 LP 代币。此操作增加了池内的 STABL 余额，从而对其价格施加下行压力并有助于稳定挂钩。

相反，如果 STABL 价格跌破 1.0，表明向下偏离，则允许 StablKeepers 销毁他们的 LP 代币并从池中提取 STABL，以减少其中的余额并将价格推回平衡。这种withdrawal机制取决于 StablKeeper 之前是否将 STABL 存入池中，因为合约必须有 LP 代币才能在此过程中销毁。

此外，任何 EOA 或智能合约都可以调用存入和提取 STABL 的`update`函数。




### Earn



## Architecture




### Core contracts

- `core/`: 核心协议合约
- `base/`: 库和所有权逻辑
- `periphery`: 外围辅助合约
- `bridge`: 跨链相关(-LayerZero) 

`core/CCM.sol` - 自动转换抵押品的再平衡做市合约，负责通过套利交易者根据市场条件清算和转换抵押品，每个市场有自己单独的CCM，其他包含抵押品和可借入资产交易对。

`core/MainController.sol` - 主控

`core/MarketOperator.sol` - 借贷市场相关操作

`core/StablKeeper.sol` - 稳定池维护

`core/price_oracles` - price of stablecoin in dollars(Chainlink) 

`core/monetary_policies` - 货币市场参数，利率和相关参数控制


### Flow of [Collateral] in system


### Flow of $STABL in system


## Project Structure