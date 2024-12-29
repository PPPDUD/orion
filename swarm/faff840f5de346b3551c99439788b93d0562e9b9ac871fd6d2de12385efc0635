// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract OrionKitty is ERC20, Ownable { // Contract name changed
    uint256 public constant MAX_SUPPLY = 1000000 * 10**18;

    constructor() ERC20("Orion Kitty", "ORKY") Ownable(msg.sender) { // Name and symbol set
        _mint(msg.sender, MAX_SUPPLY);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual {
        require(to != address(0), "ERC20: transfer to the zero address");

        uint256 size;
        assembly {
            size := extcodesize(to)
        }
        require(size == 0, "ERC20: transfer to a contract address is not allowed");
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        _spendAllowance(sender, _msgSender(), amount);
        _transfer(sender, recipient, amount);
        return true;
    }

    function renounceOwnership() public virtual override onlyOwner {
        _transferOwnership(address(0));
    }
}