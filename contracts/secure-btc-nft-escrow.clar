;; Title: SecureBTC NFT Escrow Protocol
;;
;; Summary:
;; A secure escrow system for NFT transactions on the Stacks Layer 2 blockchain with
;; Bitcoin settlement guarantees. Facilitates trustless NFT transfers between buyers and sellers
;; with built-in receipt verification and timeout protection.
;;
;; Description:
;; This contract enables secure peer-to-peer NFT transactions by implementing a robust escrow 
;; protocol that protects both buyers and sellers. NFTs are held in contract escrow during 
;; the transaction process with configurable timeout periods and receipt confirmation.
;; The protocol supports explicit transaction status tracking, receipt verification, and 
;; automatic refund capabilities if transactions expire, all while maintaining full Bitcoin 
;; security compliance.

;; NFT Trait Definition
(define-trait nft-trait
  (
    ;; Transfer an NFT from one principal to another
    (transfer (uint principal principal) (response bool uint))
  )
)

;; Error Codes
(define-constant ERR-NOT-AUTHORIZED u100)
(define-constant ERR-ESCROW-EXPIRED u101)
(define-constant ERR-INVALID-TRANSFER u102)
(define-constant ERR-NFT-NOT-RECEIVED u103)
(define-constant ERR-INAVALID-ADDRESS u104)
(define-constant ERR-INVALID-PRICE u105)

;; Contract Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ESCROW-TIMEOUT u500)  ;; Approximate 3-day timeout in blocks

;; NFT Receipt Tracking Mapping
(define-map nft-receipts
  {
    nft-contract: principal,
    nft-id: uint
  }
  {
    received: bool,
    received-at-block: uint
  }
)

;; Escrow Transaction Mapping
(define-map escrow-transactions
  {
    nft-contract: principal,
    nft-id: uint
  }
  {
    seller: principal,
    buyer: principal,
    price: uint,
    status: (string-ascii 20),
    expiry-block: uint
  }
)

;; Core Functions

;; Confirm receipt of an NFT in the escrow system
(define-public (confirm-nft-receipt 
  (nft-contract principal)
  (nft-id uint)
)
  (begin
    ;; Only seller can confirm receipt
    (asserts! (is-eq tx-sender (get seller (unwrap! 
      (map-get? escrow-transactions 
        {
          nft-contract: nft-contract, 
          nft-id: nft-id
        }
      ) 
      (err ERR-INVALID-TRANSFER)
    ))) (err ERR-NOT-AUTHORIZED))
    (asserts! (is-valid-nft-contract nft-contract) (err ERR-INAVALID-ADDRESS))
    (asserts! (> nft-id u0) (err ERR-INVALID-TRANSFER))

    ;; Mark NFT as received
    (map-set nft-receipts 
      {
        nft-contract: nft-contract,
        nft-id: nft-id
      }
      {
        received: true,
        received-at-block: block-height
      }
    )

    ;; Emit Receipt Confirmation Event
    (print {
      notification: "nft-receipt-confirmed",
      payload: {
        nft-contract: nft-contract,
        nft-id: nft-id,
        seller: tx-sender
      }
    })

    (ok true)
  )
)