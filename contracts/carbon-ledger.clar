;; Tokenized Carbon Credits Smart Contract
;; This contract allows for the creation, transfer, and retirement of carbon credits.

;; Define constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant INITIAL_SUPPLY u1000000) ;; Initial supply of carbon credits
(define-data-var total-supply uint INITIAL_SUPPLY) ;; Track total supply as a variable

;; Data maps for tracking balances and allowances
(define-map balances principal uint)
(define-map allowances {owner: principal, spender: principal} uint)

;; Data map for carbon credit metadata
(define-map credit-metadata uint {vintage: (string-utf8 10), 
                                  project-type: (string-utf8 50), 
                                  location: (string-utf8 50),
                                  verified: bool})

;; Define errors
(define-constant ERR_NOT_OWNER (err u1))
(define-constant ERR_INSUFFICIENT_BALANCE (err u2))
(define-constant ERR_INSUFFICIENT_ALLOWANCE (err u3))
(define-constant ERR_INVALID_AMOUNT (err u4))
(define-constant ERR_METADATA_EXISTS (err u5))
(define-constant ERR_METADATA_NOT_FOUND (err u6))

;; Initialize the contract
(define-public (initialize)
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
        (map-set balances CONTRACT_OWNER INITIAL_SUPPLY)
        (ok true)
    )
)

;; Mint new carbon credits (only contract owner can mint)
(define-public (mint (recipient principal) (amount uint))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (let ((current-balance (default-to u0 (map-get? balances recipient)))
              (new-balance (+ current-balance amount))
              (current-supply (var-get total-supply))
              (new-supply (+ current-supply amount)))
            (map-set balances recipient new-balance)
            (var-set total-supply new-supply)
            (print {event: "mint", recipient: recipient, amount: amount})
            (ok true)
        )
    )
)

;; Transfer carbon credits from the sender to a recipient
(define-public (transfer (recipient principal) (amount uint))
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (let ((sender-balance (default-to u0 (map-get? balances tx-sender))))
            (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
            (map-set balances tx-sender (- sender-balance amount))
            (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
            (print {event: "transfer", sender: tx-sender, recipient: recipient, amount: amount})
            (ok true)
        )
    )
)

;; Approve an allowance for a spender
(define-public (approve (spender principal) (amount uint))
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (map-set allowances {owner: tx-sender, spender: spender} amount)
        (print {event: "approve", owner: tx-sender, spender: spender, amount: amount})
        (ok true)
    )
)

;; Transfer carbon credits on behalf of an owner using an allowance
(define-public (transfer-from (owner principal) (recipient principal) (amount uint))
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (let ((allowance (default-to u0 (map-get? allowances {owner: owner, spender: tx-sender})))
              (owner-balance (default-to u0 (map-get? balances owner))))
            (asserts! (>= allowance amount) ERR_INSUFFICIENT_ALLOWANCE)
            (asserts! (>= owner-balance amount) ERR_INSUFFICIENT_BALANCE)
            (map-set allowances {owner: owner, spender: tx-sender} (- allowance amount))
            (map-set balances owner (- owner-balance amount))
            (map-set balances recipient (+ (default-to u0 (map-get? balances recipient)) amount))
            (print {event: "transfer", sender: owner, recipient: recipient, amount: amount})
            (ok true)
        )
    )
)

;; Retire carbon credits (burn them permanently)
(define-public (retire (amount uint))
    (begin
        (asserts! (> amount u0) ERR_INVALID_AMOUNT)
        (let ((sender-balance (default-to u0 (map-get? balances tx-sender)))
              (current-supply (var-get total-supply))
              (new-supply (- current-supply amount)))
            (asserts! (>= sender-balance amount) ERR_INSUFFICIENT_BALANCE)
            (map-set balances tx-sender (- sender-balance amount))
            (var-set total-supply new-supply)
            (print {event: "retire", owner: tx-sender, amount: amount})
            (ok true)
        )
    )
)

;; Add metadata for a batch of carbon credits
(define-public (add-metadata (batch-id uint) 
                             (vintage (string-utf8 10)) 
                             (project-type (string-utf8 50))
                             (location (string-utf8 50))
                             (verified bool))
    (begin
        (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_NOT_OWNER)
        (asserts! (is-none (map-get? credit-metadata batch-id)) ERR_METADATA_EXISTS)
        (map-set credit-metadata batch-id {
            vintage: vintage,
            project-type: project-type,
            location: location,
            verified: verified
        })
        (print {event: "metadata-added", batch-id: batch-id})
        (ok true)
    )
)

;; Get the balance of a principal
(define-read-only (get-balance (owner principal))
    (default-to u0 (map-get? balances owner))
)

;; Get the allowance of a spender for an owner
(define-read-only (get-allowance (owner principal) (spender principal))
    (default-to u0 (map-get? allowances {owner: owner, spender: spender}))
)

;; Get the total supply
(define-read-only (get-total-supply)
    (var-get total-supply)
)

;; Get metadata for a batch of carbon credits
(define-read-only (get-metadata (batch-id uint))
    (match (map-get? credit-metadata batch-id)
        metadata metadata
        (err ERR_METADATA_NOT_FOUND)
    )
)