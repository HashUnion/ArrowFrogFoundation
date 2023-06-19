// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract FundSharesToken is ERC20, Ownable {
    constructor(address owner_) ERC20("FundShares", "FS") {
        _transferOwnership(owner_);
    }

    function decimals() public view virtual override returns (uint8) {
        return 6;
    }

    function mint(address to_, uint256 amount_) external onlyOwner {
        _mint(to_, amount_);
    }

    function burn(address from_, uint256 amount_) external onlyOwner {
        _burn(from_, amount_);
    }
}
