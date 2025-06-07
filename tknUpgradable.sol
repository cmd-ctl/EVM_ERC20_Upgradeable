// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/security/PausableUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract TokenUpgradeable is ERC20Upgradeable, OwnableUpgradeable, PausableUpgradeable, AccessControlUpgradeable, UUPSUpgradeable {

    uint256 public maxSupply;
    bool public fixSupply = false;
    
    mapping(address => bool) public blacklist;

    bytes32 public constant MODERATOR = keccak256("MODERATOR");
    bytes32 public constant ACCOUNTANT = keccak256("ACCOUNTANT");

    event BlacklistAdded(address indexed wallet);
    event BlacklistRemoved(address indexed wallet);
    event AdminBurn(address indexed wallet, uint256 amount);
    event MaxSupplyChanged(uint256 newMaxSupply);
    event MaxSupplyFixed(bool);
    event Minted(address wallet, uint256 amount);
    event Burned(address sender, uint256 amount);

    constructor() {
        _disableInitializers();
    }

    function initialize() public initializer {
        __ERC20_init("TKN Name", "TKN");
        __Ownable_init(msg.sender);
        __Pausable_init();
        __AccessControl_init();
        __UUPSUpgradeable_init();

        _mint(msg.sender, 1000000000 * 1e18);
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MODERATOR, msg.sender);
        _grantRole(ACCOUNTANT, msg.sender);

        maxSupply = 1000000000 * 1e18;
    }

    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}

    function mint(uint256 amount) external onlyRole(ACCOUNTANT) {
        require((amount + totalSupply()) <= maxSupply, "Increase maxSupply limits");
        _mint(msg.sender, amount);
        emit Minted(msg.sender, amount);

    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
        emit Burned(msg.sender, amount);
    }

// --- BLACK LIST ---

    function blacklistAdd(address wallet) external onlyRole(MODERATOR) {
        blacklist[wallet] = true;
        emit BlacklistAdded(wallet);
    }

    function blacklistRemove(address wallet) external onlyRole(MODERATOR) {
        blacklist[wallet] = false;
        emit BlacklistRemoved(wallet);
    }

// --- --- --- ---

    function transfer(address to, uint256 value) public override whenNotPaused returns (bool) {
        require(!blacklist[msg.sender], "Sender is blacklisted");
        require(!blacklist[to], "Recipient is blacklisted");
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(address from, address to, uint256 value) public override whenNotPaused returns (bool) {
        require(!blacklist[from], "Sender is blacklisted");
        require(!blacklist[to], "Recipient is blacklisted");
        _transfer(from, to, value);

        uint256 currentAllowance = allowance(from, msg.sender);
        require(currentAllowance >= value, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(from, msg.sender, currentAllowance - value);
        }

        return true;
    }

// --- SUPPLY CONTROL ---

    function setMaxTokens(uint256 newMax) external onlyRole(ACCOUNTANT) {
        require(fixSupply == false, "Max Supply Fixed");
        require(newMax > totalSupply(), "You need to burn some first");
        maxSupply = newMax;
        emit MaxSupplyChanged(maxSupply);
    }

    function fixMaxSupply () external onlyOwner whenNotPaused returns(bool) {
        fixSupply = true;
        emit MaxSupplyFixed(fixSupply);
        return fixSupply;
    }

// --- EMERGENCY FUNCTIONS ---

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function adminBurn(address wallet, uint256 amount) external onlyOwner {
        require(balanceOf(wallet) >= amount, "Not enough tokens to burn");
        require(blacklist[wallet], "Wallet is not in blacklist");
        _burn(wallet, amount);
        emit AdminBurn(wallet, amount);
    }

// --- GRANT ROLES ---

    function moderatorAdd(address wallet) external onlyOwner {
        grantRole(MODERATOR, wallet);
    }

    function moderatorRemove(address wallet) external onlyOwner {
        revokeRole(MODERATOR, wallet);
    }

    function accountantAdd(address wallet) external onlyOwner {
        grantRole(ACCOUNTANT, wallet);
    }

    function accountantRemove(address wallet) external onlyOwner {
        revokeRole(ACCOUNTANT, wallet);
    }

// --- --- --- ---


    function version() public pure virtual returns (string memory) {
        return "v1.0";
    }

}
