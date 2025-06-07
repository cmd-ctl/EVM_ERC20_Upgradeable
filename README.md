# TokenUpgradeable

**Upgradeable ERC20 Token** with the following features:

- UUPSUpgradeable pattern
- Role-based access (MODERATOR, ACCOUNTANT, OWNER)
- Blacklist system
- Supply control with fixable maxSupply
- Pausable contract (emergency stop)
- Admin-controlled burn of blacklisted accounts
- Upgradeable via ERC1967Proxy (OpenZeppelin UUPS standard)
- Fully transparent via emitted events

---

## Tech Stack

* Solidity ^0.8.20
* OpenZeppelin Contracts Upgradeable (ERC20, Ownable, Pausable, AccessControl, UUPSUpgradeable)
* Proxy pattern: **ERC1967Proxy** (UUPS pattern)
* Compatible with: **Hardhat**, **Remix**, **Foundry**, **Truffle**

---

## Features

### Token Configuration

* Name: `TKN Name`
* Symbol: `TKN`
* Initial Supply: `1,000,000,000 TKN` (minted to deployer)

---

### Role-based Access

| Role       | Permissions                       |
| ---------- | --------------------------------- |
| OWNER      | Contract owner (full rights)      |
| MODERATOR  | Can manage blacklist              |
| ACCOUNTANT | Can mint tokens, manage maxSupply |

---

### Blacklist

* `blacklistAdd(address)` — block address
* `blacklistRemove(address)` — unblock address
* Blacklisted addresses CANNOT send/receive tokens

---

### Supply Control

* `maxSupply` — Maximum token supply
* `setMaxTokens(uint256 newMax)` — Change maxSupply (before fixed)
* `fixMaxSupply()` — Permanently lock maxSupply (cannot be undone)

---

### Mint / Burn

* `mint(uint256)` — Mint tokens (only ACCOUNTANT, within maxSupply)
* `burn(uint256)` — Self-burn tokens (any user)
* `adminBurn(address wallet, uint256 amount)` — Admin can burn blacklisted tokens

---

### Emergency Controls

* `pause()` — Pause token transfers (only OWNER)
* `unpause()` — Resume transfers

---

### Upgradeability

* UUPSUpgradeable pattern
* `upgradeTo(address newImplementation)` — Upgrade logic (only OWNER)
* Transparent upgrade path

---

### Events

* `Minted(address, uint256)`
* `Burned(address, uint256)`
* `AdminBurn(address, uint256)`
* `BlacklistAdded(address)`
* `BlacklistRemoved(address)`
* `MaxSupplyFixed(bool)`
* `MaxSupplyChanged(uint256)`
* Standard ERC20 Transfer/Approval events

---

## Usage

### Deployment

- Deploy **TokenUpgradeable.sol**
- Deploy **ERC1967Proxy**:

```text
_logic: TokenUpgradeable address
_data: initialize() selector → 0x8129fc1c
```

### Upgrade

- Deploy new version **TokenUpgradeableV2**
- Call `upgradeTo(newImplementation)` from OWNER

---

### Example Interactions

```solidity
mint(1000 * 1e18); // Mint tokens (ACCOUNTANT role)
burn(500 * 1e18);  // Self-burn
pause();          // Emergency pause (OWNER)
fixMaxSupply();   // Permanently lock supply (OWNER)
blacklistAdd(0x...); // Blacklist address (MODERATOR)
```

---

## Security Notes

* **UUPSUpgradeable** protected by `_authorizeUpgrade (onlyOwner)`
* **Minting** controlled by ACCOUNTANT role
* **Blacklist** controlled by MODERATOR role
* **AdminBurn** only affects blacklisted wallets
* **FixMaxSupply** permanently locks supply — increases trust
* **Emergency Pause** available to OWNER

---

## Audit Notes

* Contract storage layout is stable and forward-compatible (UUPS pattern)
* Upgrades MUST preserve storage layout
* Events enable full transparency for users & explorers
* Admin rights clearly separated by roles (OWNER, MODERATOR, ACCOUNTANT)

---

## License

MIT License


