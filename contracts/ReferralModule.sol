// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ReferralModule {
    mapping(address => address) public referrerOf;

    event ReferrerSet(address indexed user, address indexed referrer);

    function setReferrer(address referrer) external {
        require(referrer != msg.sender, "self");
        require(referrerOf[msg.sender] == address(0), "already set");
        referrerOf[msg.sender] = referrer;
        emit ReferrerSet(msg.sender, referrer);
    }

    function getReferrer(address user) external view returns (address) {
        return referrerOf[user];
    }
}
