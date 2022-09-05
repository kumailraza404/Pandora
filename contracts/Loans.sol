//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import {IERC20} from "./IERC20.sol";
import {ERC20Token} from "./ERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract Loans {
    using SafeMath for uint256;

    address public immutable lpToken;
    address public immutable usdt;
    uint256 public totalDeposits;
    uint256 public totalBorrows;

    mapping(address => uint256) public usersBorrowed;

    constructor() {
        ERC20Token lpTokenContract = new ERC20Token("KUMAIL", "KUM");
        lpToken = address(lpTokenContract);

        ERC20Token usdtContract = new ERC20Token("TETHER", "USDT");
        usdt = address(usdtContract);
    }

    function getExchangeRate() public returns (uint256) {
        uint256 totalUSDT = totalDeposits + totalBorrows;
        uint256 totalLP = IERC20(lpToken).totalSupply();
        return totalUSDT.div(totalLP);
    }

    function lend(uint256 amount) external {
        IERC20(usdt).transferFrom(msg.sender, address(this), amount);
        uint256 lpTobeMinted = amount.div(getExchangeRate());
        IERC20(lpToken).mint(lpTobeMinted, msg.sender);

        totalDeposits += amount;
    }

    function unLend(uint256 amount) external {
        IERC20(lpToken).burnFrom(amount, msg.sender);
        uint256 tokensToBeTransfered = amount.mul(getExchangeRate());
        totalDeposits -= tokensToBeTransfered;

        IERC20(usdt).transfer(msg.sender, tokensToBeTransfered);
    }

    function borrow() external payable {
        uint256 amountOut = msg.value.mul(80).div(100);

        usersBorrowed[msg.sender] = amountOut;
        totalDeposits -= amountOut;
        totalBorrows += amountOut;

        IERC20(usdt).transfer(msg.sender, amountOut);
    }

    function repay() external {}
}
