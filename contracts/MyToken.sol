// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OrionKitty is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;
    mapping(address => uint256) public lastTransactionTime;
    uint256 public constant TRANSACTION_COOLDOWN = 15;

    error TransactionCooldownNotComplete(uint256 remainingCooldown);
    error TransferToContractOrNonExistentAccount();

    constructor() ERC20("Orion Kitty", "ORKY") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 size;
        assembly { size := extcodesize(to) }
        if (size != 0) revert TransferToContractOrNonExistentAccount();
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        if (msg.sender != owner()) {
            uint256 timeElapsed = block.timestamp.sub(lastTransactionTime[msg.sender]);
            if (timeElapsed < TRANSACTION_COOLDOWN) {
                uint256 remainingCooldown = TRANSACTION_COOLDOWN.sub(timeElapsed);
                revert TransactionCooldownNotComplete(remainingCooldown);
            }
            lastTransactionTime[msg.sender] = block.timestamp;
        }

        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        if (sender != owner()) {
            uint256 timeElapsed = block.timestamp.sub(lastTransactionTime[sender]);
            if (timeElapsed < TRANSACTION_COOLDOWN) {
                uint256 remainingCooldown = TRANSACTION_COOLDOWN.sub(timeElapsed);
                revert TransactionCooldownNotComplete(remainingCooldown);
            }
            lastTransactionTime[sender] = block.timestamp;
        }

        _spendAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function renounceOwnership() public virtual override onlyOwner {
        _transferOwnership(address(0));
    }
}