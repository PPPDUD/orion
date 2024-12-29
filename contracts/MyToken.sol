// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

contract OrionKitty is ERC20, Ownable {
    using SafeMath for uint256;

    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;
    uint256 public constant MAX_TRANSFER_AMOUNT = 1000 * 10**18;
    mapping(address => uint256) public lastTransactionTime;
    uint256 public constant TRANSACTION_COOLDOWN = 15;

    error TransactionCooldownNotComplete(uint256 remainingCooldown);
    error TransferAmountExceedsLimit();
    error TransferToContractOrNonExistentAccount();

    constructor() ERC20("Orion Kitty", "OKTY") Ownable(msg.sender) {
        _mint(msg.sender, MAX_SUPPLY);
    }

    function _isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    modifier checkTransferLimit(address sender, uint256 amount) {
        if (amount > MAX_TRANSFER_AMOUNT) {
            revert TransferAmountExceedsLimit();
        }
        _;
    }

    function transfer(address recipient, uint256 amount) public override checkTransferLimit(_msgSender(), amount) returns (bool) {
        if (_isContract(recipient)) {
            revert TransferToContractOrNonExistentAccount();
        }

        if (msg.sender != owner()) {
            uint256 timeElapsed = block.timestamp.sub(lastTransactionTime[msg.sender]);
            if (timeElapsed < TRANSACTION_COOLDOWN) {
                uint256 remainingCooldown = TRANSACTION_COOLDOWN.sub(timeElapsed);
                revert TransactionCooldownNotComplete(remainingCooldown);
            }
            lastTransactionTime[msg.sender] = block.timestamp;
        }
        super.transfer(recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override checkTransferLimit(sender, amount) returns (bool) {
        if (_isContract(recipient)) {
            revert TransferToContractOrNonExistentAccount();
        }

        if (sender != owner()) {
            uint256 timeElapsed = block.timestamp.sub(lastTransactionTime[sender]);
            if (timeElapsed < TRANSACTION_COOLDOWN) {
                uint256 remainingCooldown = TRANSACTION_COOLDOWN.sub(timeElapsed);
                revert TransactionCooldownNotComplete(remainingCooldown);
            }
            lastTransactionTime[sender] = block.timestamp;
        }
        super.transferFrom(sender, recipient, amount);
        return true;
    }

    function renounceOwnership() public virtual override onlyOwner {
        _transferOwnership(address(0));
    }
}