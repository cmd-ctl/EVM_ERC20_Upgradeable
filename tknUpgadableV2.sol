// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./tknUpgradable.sol";

contract TokenUpgradeableV2 is TokenUpgradeable {

    // New functions

    function version() public pure override returns (string memory) {
        return "v2.0";
    }

    function helloUpgrade() public pure returns (string memory) {
        return "Token upgraded successfully!";
    }
}
