// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Referral Module
/// @notice Valdo vartotojų referalų sąsają su paprastomis funkcijomis nustatyti, peržiūrėti ir atšaukti refererį.
/// Ši versija yra patobulinta, įtraukiant papildomas apsaugas ir pagalbinę funkciją.
contract ReferralModule {
    // Saugo refererio adresą kiekvienam vartotojui
    mapping(address => address) public referrerOf;

    event ReferrerSet(address indexed user, address indexed referrer);
    event ReferrerCleared(address indexed user);

    /// @notice Nustato refererį skambinančiam vartotojui.
    /// @param referrer Adresas, kurį vartotojas nori nustatyti kaip refererį.
    function setReferrer(address referrer) external {
        require(referrer != address(0), "zero referrer");
        require(referrer != msg.sender, "self");
        require(referrerOf[msg.sender] == address(0), "already set");
        referrerOf[msg.sender] = referrer;
        emit ReferrerSet(msg.sender, referrer);
    }

    /// @notice Grąžina dabartinį vartotojo refererį.
    /// @param user Vartotojo adresas.
    /// @return Address refererio adresas (arba address(0), jei nenustatytas).
    function getReferrer(address user) external view returns (address) {
        return referrerOf[user];
    }

    /// @notice Patikrina, ar vartotojui nustatytas refereris.
    /// @param user Vartotojo adresas.
    /// @return bool True, jei refereris nustatytas, false – jei nenurodytas.
    function isReferrerSet(address user) external view returns (bool) {
        return referrerOf[user] != address(0);
    }

    /// @notice Leidžia vartotojui atšaukti refererį, jei jis nori.
    function clearMyReferrer() external {
        require(referrerOf[msg.sender] != address(0), "not set");
        referrerOf[msg.sender] = address(0);
        emit ReferrerCleared(msg.sender);
    }
}