# SecureBTC NFT Escrow Protocol

**Secure and trustless NFT escrow system built for the Stacks Layer 2 blockchain with Bitcoin settlement guarantees.**

## Overview

SecureBTC is a Clarity smart contract that enables **secure, decentralized, and trustless escrow transactions for NFTs**, leveraging the Bitcoin-secured Stacks blockchain. It ensures atomic and verifiable NFT exchanges between buyers and sellers with full auditability, timeout protections, and Bitcoin-aligned finality.

## Key Features

- **Secure NFT Escrow**: NFTs are held in a smart contract during transaction finalization.
- **Receipt Verification**: Sellers must confirm receipt before the transfer is completed.
- **Automatic Refunds**: Built-in expiry logic ensures sellers can recover assets if buyers don't complete the transaction.
- **Status Tracking**: Transparent mapping of transaction and receipt statuses.
- **Bitcoin Settlement Security**: All logic executes on the Bitcoin-secured Stacks L2 blockchain.

## Design Summary

This protocol is built to mitigate trust issues in NFT transactions:

- NFTs are **locked in escrow** on transfer initiation.
- Sellers must **explicitly confirm receipt** of the asset on-chain.
- Buyers receive the NFT only after receipt is verified.
- If timeouts are exceeded, the seller may reclaim the NFT via a **refund mechanism**.

## Contract Structure

### Traits

```clarity
(define-trait nft-trait
  (
    (transfer (uint principal principal) (response bool uint))
  )
)
```

This contract uses a generic NFT trait compatible with SIP-009 NFTs.

### Public Functions

| Function | Description |
|---------|-------------|
| `create-nft-escrow` | Initializes an escrow transaction by transferring the NFT to the contract and setting buyer, price, and timeout. |
| `confirm-nft-receipt` | Called by the seller to confirm receipt of the NFT (required before release). |
| `complete-nft-transfer` | Called to complete the transaction by transferring the NFT to the buyer. |
| `refund-nft` | Enables sellers to reclaim NFTs if the escrow timeout expires without buyer action. |

### Read-Only Functions

| Function | Description |
|---------|-------------|
| `get-escrow-status` | Returns escrow transaction details by contract and NFT ID. |
| `get-nft-receipt-status` | Returns whether an NFT has been marked as received. |
| `is-valid-nft-contract` | Verifies if the provided principal represents a valid contract. |

### Storage Mappings

#### `escrow-transactions`

Tracks the core escrow metadata.

```clarity
{
  nft-contract: principal,
  nft-id: uint
} => {
  seller: principal,
  buyer: principal,
  price: uint,
  status: (string-ascii 20),
  expiry-block: uint
}
```

#### `nft-receipts`

Tracks NFT receipt confirmations.

```clarity
{
  nft-contract: principal,
  nft-id: uint
} => {
  received: bool,
  received-at-block: uint
}
```

### Error Codes

| Code | Description |
|------|-------------|
| `u100` | Not authorized |
| `u101` | Escrow expired |
| `u102` | Invalid transfer attempt |
| `u103` | NFT not marked as received |
| `u104` | Invalid address or principal |
| `u105` | Invalid sale price |

## Contract Constants

| Constant | Value | Description |
|----------|-------|-------------|
| `ESCROW-TIMEOUT` | `u500` | ~3 days in blocks |
| `CONTRACT-OWNER` | `tx-sender` | Creator at deploy time |

## Usage Flow

1. **Seller calls** `create-nft-escrow(...)`
2. **Contract holds NFT**
3. **Seller confirms** receipt via `confirm-nft-receipt(...)`
4. **Buyer or automated service** calls `complete-nft-transfer(...)`
5. If the transaction expires, **seller may call** `refund-nft(...)`

## Deployment & Integration

- Compatible with [Clarity](https://docs.stacks.co/docs/write-smart-contracts/clarity-overview) smart contracts.
- Designed for interoperability with SIP-009 NFTs and standard principal verification.
- Trigger events for off-chain services using `print`.

## Testing & Auditing

To ensure trust, thoroughly test and audit the following:

- Boundary conditions for expiry blocks.
- Validity checks on NFT transfer capability.
- Replay or double-claim protections on `confirm-nft-receipt`.

> We strongly recommend third-party audits before mainnet deployment.

## 🙌 Contributing

Pull requests, bug reports, and suggestions are welcome! Please open an issue or fork and submit PRs.
