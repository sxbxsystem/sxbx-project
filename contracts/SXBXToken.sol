// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts@5.0.2/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts@5.0.2/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts@5.0.2/access/Ownable.sol";

/// @title SXBX Token (initial version)
/// @notice ERC20 su mokesčiu (fee), iždu (treasury), mint/burn ir fee išimtimis.
/// Pastaba: fee logika paprasta; prireikus vėliau pridėsime papildomus modulius.
contract SXBXToken is ERC20, ERC20Burnable, Ownable {
    /// @dev Mokesčio dydis baziniais punktais (bps): 100 bps = 1.00%
    uint16 public feeBps;                // max 1000 (10.00%)
    address public treasury;             // mokesčių gavėjas
    mapping(address => bool) public isFeeExempt;

    event FeeUpdated(uint16 oldFeeBps, uint16 newFeeBps);
    event TreasuryUpdated(address indexed oldTreasury, address indexed newTreasury);
    event FeeExemptSet(address indexed account, bool isExempt);

    /// @param name_  Tokeno pavadinimas
    /// @param symbol_  Simbolis
    /// @param initialSupply  Pradinis kiekis (pilnais wei su 18 dec.)
    /// @param treasury_  Iždo adresas (mokesčių gavėjas)
    /// @param feeBps_  Mokesčio dydis bps (pvz. 50 = 0.50%)
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 initialSupply,
        address treasury_,
        uint16 feeBps_
    ) ERC20(name_, symbol_) Ownable(msg.sender) {
        require(treasury_ != address(0), "treasury=0");
        require(feeBps_ <= 1000, "fee too high"); // max 10%
        treasury = treasury_;
        feeBps = feeBps_;
        isFeeExempt[msg.sender] = true;   // savininkas be mokesčio
        isFeeExempt[treasury_] = true;    // iždas be mokesčio
        _mint(msg.sender, initialSupply);
    }

    /// Admin funkcijos
    function setFeeBps(uint16 newFeeBps) external onlyOwner {
        require(newFeeBps <= 1000, "fee too high");
        emit FeeUpdated(feeBps, newFeeBps);
        feeBps = newFeeBps;
    }

    function setTreasury(address newTreasury) external onlyOwner {
        require(newTreasury != address(0), "treasury=0");
        emit TreasuryUpdated(treasury, newTreasury);
        treasury = newTreasury;
        isFeeExempt[newTreasury] = true;
    }

    function setFeeExempt(address account, bool exempt) external onlyOwner {
        isFeeExempt[account] = exempt;
        emit FeeExemptSet(account, exempt);
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /// OpenZeppelin v5 perrašomas per _update, ne _transfer.
    function _update(address from, address to, uint256 value) internal override {
        if (
            feeBps > 0 &&
            treasury != address(0) &&
            from != address(0) &&
            to != address(0) &&
            !isFeeExempt[from] &&
            !isFeeExempt[to]
        ) {
            uint256 fee = (value * feeBps) / 10000;
            uint256 amountAfterFee = value - fee;
            super._update(from, treasury, fee);
            super._update(from, to, amountAfterFee);
        } else {
            super._update(from, to, value);
        }
    }
}
