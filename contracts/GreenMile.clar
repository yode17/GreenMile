;; GreenMile - Carbon Offset Tracking for Logistics
;; Tracks fuel consumption, calculates emissions, and manages carbon credit purchases

;; Constants
(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_COMPANY_NOT_FOUND (err u101))
(define-constant ERR_INVALID_AMOUNT (err u102))
(define-constant ERR_INSUFFICIENT_BALANCE (err u103))
(define-constant ERR_COMPANY_EXISTS (err u104))
(define-constant ERR_INVALID_INPUT (err u105))

;; Carbon emission factor (kg CO2 per liter of fuel)
(define-constant CARBON_FACTOR u2640) ;; 2.64 kg CO2/liter * 1000 for precision

;; Input validation constants
(define-constant MAX_DISTANCE u100000) ;; Max 100,000 km per route
(define-constant MAX_FUEL u50000) ;; Max 50,000 liters per route
(define-constant MAX_PRICE u1000000) ;; Max 1M STX per credit
(define-constant MIN_NAME_LENGTH u1)
(define-constant MAX_NAME_LENGTH u50)

;; Data Variables
(define-data-var carbon-credit-price uint u50) ;; Price per carbon credit in STX
(define-data-var total-emissions uint u0)
(define-data-var total-offsets uint u0)

;; Data Maps
(define-map companies
  { company: principal }
  {
    name: (string-ascii 50),
    total-fuel: uint,
    total-emissions: uint,
    total-offsets: uint,
    stx-balance: uint,
    registered-at: uint
  }
)

(define-map routes
  { route-id: uint }
  {
    company: principal,
    distance: uint,
    fuel-consumed: uint,
    emissions: uint,
    timestamp: uint
  }
)

(define-map carbon-purchases
  { purchase-id: uint }
  {
    company: principal,
    credits: uint,
    cost: uint,
    timestamp: uint
  }
)

;; Counters
(define-data-var route-counter uint u0)
(define-data-var purchase-counter uint u0)

;; Input validation functions
(define-private (validate-name (name (string-ascii 50)))
  (let ((name-len (len name)))
    (and (>= name-len MIN_NAME_LENGTH) (<= name-len MAX_NAME_LENGTH))
  )
)

(define-private (validate-route-data (distance uint) (fuel-consumed uint))
  (and 
    (> distance u0)
    (> fuel-consumed u0)
    (<= distance MAX_DISTANCE)
    (<= fuel-consumed MAX_FUEL)
  )
)

(define-private (validate-price (price uint))
  (and (> price u0) (<= price MAX_PRICE))
)

;; Public Functions

;; Register a new logistics company
(define-public (register-company (name (string-ascii 50)))
  (let ((company tx-sender))
    (asserts! (validate-name name) ERR_INVALID_INPUT)
    (if (is-some (map-get? companies { company: company }))
      ERR_COMPANY_EXISTS
      (begin
        (map-set companies
          { company: company }
          {
            name: name,
            total-fuel: u0,
            total-emissions: u0,
            total-offsets: u0,
            stx-balance: u0,
            registered-at: block-height
          }
        )
        (ok true)
      )
    )
  )
)

;; Record a route with fuel consumption
(define-public (record-route (distance uint) (fuel-consumed uint))
  (let (
    (company tx-sender)
    (route-id (+ (var-get route-counter) u1))
    (emissions (* fuel-consumed CARBON_FACTOR))
    (company-data (unwrap! (map-get? companies { company: company }) ERR_COMPANY_NOT_FOUND))
  )
    (asserts! (validate-route-data distance fuel-consumed) ERR_INVALID_INPUT)
    (begin
      ;; Update route counter
      (var-set route-counter route-id)

      ;; Store route data
      (map-set routes
        { route-id: route-id }
        {
          company: company,
          distance: distance,
          fuel-consumed: fuel-consumed,
          emissions: emissions,
          timestamp: block-height
        }
      )

      ;; Update company totals
      (map-set companies
        { company: company }
        (merge company-data {
          total-fuel: (+ (get total-fuel company-data) fuel-consumed),
          total-emissions: (+ (get total-emissions company-data) emissions)
        })
      )

      ;; Update global emissions
      (var-set total-emissions (+ (var-get total-emissions) emissions))

      (ok route-id)
    )
  )
)

;; Purchase carbon credits
(define-public (purchase-carbon-credits (credits uint))
  (let (
    (company tx-sender)
    (cost (* credits (var-get carbon-credit-price)))
    (purchase-id (+ (var-get purchase-counter) u1))
    (company-data (unwrap! (map-get? companies { company: company }) ERR_COMPANY_NOT_FOUND))
  )
    (asserts! (> credits u0) ERR_INVALID_AMOUNT)
    (begin
      ;; Transfer STX for carbon credits
      (try! (stx-transfer? cost company CONTRACT_OWNER))

      ;; Update purchase counter
      (var-set purchase-counter purchase-id)

      ;; Record purchase
      (map-set carbon-purchases
        { purchase-id: purchase-id }
        {
          company: company,
          credits: credits,
          cost: cost,
          timestamp: block-height
        }
      )

      ;; Update company offsets
      (map-set companies
        { company: company }
        (merge company-data {
          total-offsets: (+ (get total-offsets company-data) credits)
        })
      )

      ;; Update global offsets
      (var-set total-offsets (+ (var-get total-offsets) credits))

      (ok purchase-id)
    )
  )
)

;; Auto-purchase carbon credits based on emissions
(define-public (auto-offset-emissions)
  (let (
    (company tx-sender)
    (company-data (unwrap! (map-get? companies { company: company }) ERR_COMPANY_NOT_FOUND))
    (net-emissions (- (get total-emissions company-data) (get total-offsets company-data)))
    (credits-needed (/ net-emissions u1000)) ;; Convert to credits (1 credit = 1000 kg CO2)
  )
    (if (> credits-needed u0)
      (purchase-carbon-credits credits-needed)
      (ok u0)
    )
  )
)

;; Admin function to update carbon credit price
(define-public (set-carbon-price (new-price uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (validate-price new-price) ERR_INVALID_INPUT)
    (var-set carbon-credit-price new-price)
    (ok true)
  )
)

;; Read-only Functions

;; Get company information
(define-read-only (get-company (company principal))
  (map-get? companies { company: company })
)

;; Get route information
(define-read-only (get-route (route-id uint))
  (map-get? routes { route-id: route-id })
)

;; Get carbon purchase information
(define-read-only (get-purchase (purchase-id uint))
  (map-get? carbon-purchases { purchase-id: purchase-id })
)

;; Get company's carbon footprint
(define-read-only (get-carbon-footprint (company principal))
  (match (map-get? companies { company: company })
    company-data (some {
      total-emissions: (get total-emissions company-data),
      total-offsets: (get total-offsets company-data),
      net-emissions: (- (get total-emissions company-data) (get total-offsets company-data))
    })
    none
  )
)

;; Get global statistics
(define-read-only (get-global-stats)
  {
    total-emissions: (var-get total-emissions),
    total-offsets: (var-get total-offsets),
    carbon-credit-price: (var-get carbon-credit-price),
    total-routes: (var-get route-counter),
    total-purchases: (var-get purchase-counter)
  }
)

;; Calculate required credits for full offset
(define-read-only (calculate-offset-cost (company principal))
  (match (map-get? companies { company: company })
    company-data 
    (let (
      (net-emissions (- (get total-emissions company-data) (get total-offsets company-data)))
      (credits-needed (/ net-emissions u1000))
    )
      (some {
        credits-needed: credits-needed,
        cost: (* credits-needed (var-get carbon-credit-price))
      })
    )
    none
  )
)