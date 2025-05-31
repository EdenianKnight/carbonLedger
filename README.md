# Carbon Credits Smart Contract

A secure and efficient smart contract for tokenizing, tracking, and managing carbon credits on the Stacks blockchain using Clarity.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Contract Architecture](#contract-architecture)
- [Installation](#installation)
- [Usage](#usage)
- [API Reference](#api-reference)
- [Security Features](#security-features)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [License](#license)

## Overview

The Carbon Credits Smart Contract enables the creation, management, and retirement of tokenized carbon credits on the Stacks blockchain. This contract implements a secure token standard specifically designed for environmental assets, providing transparency and immutability for carbon credit transactions.

### Key Benefits

- **Transparency**: All transactions are recorded on-chain and publicly verifiable
- **Immutability**: Carbon credit history cannot be altered once recorded
- **Efficiency**: Automated compliance and settlement processes
- **Traceability**: Complete audit trail from creation to retirement
- **Security**: Implements best practices for smart contract security

## Features

### Core Functionality

- **Token Creation**: Mint new carbon credits with configurable supply
- **Transfer System**: Secure peer-to-peer transfers with allowance mechanism
- **Retirement Process**: Permanent removal of credits from circulation
- **Metadata Management**: Attach rich metadata to credit batches
- **Balance Tracking**: Real-time balance queries for all participants

### Advanced Features

- **Batch Metadata**: Store vintage, project type, location, and verification status
- **Allowance System**: Delegate transfer permissions to third parties
- **Event Logging**: Comprehensive event system for off-chain monitoring
- **Owner Controls**: Administrative functions for contract management
- **Safe Math**: Overflow/underflow protection for all arithmetic operations

## Contract Architecture

### Data Structures

```clarity
;; Balance tracking
(define-map balances principal uint)

;; Allowance system
(define-map allowances {owner: principal, spender: principal} uint)

;; Metadata storage
(define-map credit-metadata uint {
    vintage: (string-utf8 10),
    project-type: (string-utf8 50),
    location: (string-utf8 50),
    verified: bool
})
```

### Error Codes

| Code | Constant | Description |
|------|----------|-------------|
| u1   | ERR_NOT_OWNER | Caller is not the contract owner |
| u2   | ERR_INSUFFICIENT_BALANCE | Insufficient token balance |
| u3   | ERR_INSUFFICIENT_ALLOWANCE | Insufficient allowance |
| u4   | ERR_INVALID_AMOUNT | Invalid amount (zero or negative) |
| u5   | ERR_METADATA_EXISTS | Metadata already exists for batch |
| u6   | ERR_METADATA_NOT_FOUND | Metadata not found for batch |
| u7   | ERR_ARITHMETIC_OVERFLOW | Arithmetic overflow detected |

## Installation

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) - Clarity development environment
- [Stacks CLI](https://docs.stacks.co/docs/cli) - For deployment and interaction
- Node.js 16+ (for testing and tooling)

### Setup

1. Clone the repository:

```bash
git clone https://github.com/your-org/carbon-credits-contract.git
cd carbon-credits-contract
```

Initialize Clarinet project:

```bash
clarinet new carbon-ledger
cd carbon-ledger
```

Add the contract to your Clarinet.toml:

```toml
[contracts.carbon-ledger]
path = "contracts/carbonLedger.clar"
```

Install dependencies:

```bash
npm install
```

## Usage

### Contract Deployment

Deploy to local testnet:

```bash
clarinet console
>> (contract-deploy .carbon-ledger tx-sender)
```

Initialize the contract:

```bash
>> (contract-call? .carbon-ledger initialize)
```

### Basic Operations

#### Minting Credits

```clarity
;; Mint 1000 credits to a recipient (owner only)
(contract-call? .carbon-ledger mint 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u1000)
```

#### Transferring Credits

```clarity
;; Transfer 100 credits to another user
(contract-call? .carbon-ledger transfer 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7 u100)
```

#### Retiring Credits

```clarity
;; Permanently retire 50 credits
(contract-call? .carbon-ledger retire u50)
```

#### Adding Metadata

```clarity
;; Add metadata for a credit batch
(contract-call? .carbon-ledger add-metadata 
    u1 
    u"2023" 
    u"Reforestation" 
    u"Brazil Amazon" 
    true)
```

### Query Operations

#### Check Balance

```clarity
;; Get balance for an address
(contract-call? .carbon-ledger get-balance 'SP2J6ZY48GV1EZ5V2V5RB9MP66SW86PYKKNRV9EJ7)
```

#### Get Total Supply

```clarity
;; Get current total supply
(contract-call? .carbon-ledger get-total-supply)
```

#### Retrieve Metadata

```clarity
;; Get metadata for batch ID 1
(contract-call? .carbon-ledger get-metadata u1)
```

## API Reference

### Public Functions

#### `initialize()`

Initializes the contract with the initial supply allocated to the contract owner.

**Returns:** `(response bool uint)`

#### `mint(recipient: principal, amount: uint)`

Creates new carbon credits and assigns them to the specified recipient.

**Parameters:**

- `recipient`: Principal to receive the minted credits
- `amount`: Number of credits to mint (must be > 0)

**Returns:** `(response bool uint)`

**Restrictions:** Contract owner only

#### `transfer(recipient: principal, amount: uint)`

Transfers credits from the caller to the recipient.

**Parameters:**

- `recipient`: Principal to receive the credits
- `amount`: Number of credits to transfer

**Returns:** `(response bool uint)`

#### `approve(spender: principal, amount: uint)`

Approves a spender to transfer credits on behalf of the caller.

**Parameters:**

- `spender`: Principal authorized to spend credits
- `amount`: Maximum amount the spender can transfer

**Returns:** `(response bool uint)`

#### `transfer-from(owner: principal, recipient: principal, amount: uint)`

Transfers credits from owner to recipient using a pre-approved allowance.

**Parameters:**

- `owner`: Principal whose credits are being transferred
- `recipient`: Principal receiving the credits
- `amount`: Number of credits to transfer

**Returns:** `(response bool uint)`

#### `retire(amount: uint)`

Permanently removes credits from circulation.

**Parameters:**

- `amount`: Number of credits to retire

**Returns:** `(response bool uint)`

#### `add-metadata(batch-id: uint, vintage: string-utf8, project-type: string-utf8, location: string-utf8, verified: bool)`

Adds metadata to a batch of carbon credits.

**Parameters:**

- `batch-id`: Unique identifier for the credit batch
- `vintage`: Year the credits were generated
- `project-type`: Type of carbon offset project
- `location`: Geographic location of the project
- `verified`: Whether the credits are verified by a standard

**Returns:** `(response bool uint)`

**Restrictions:** Contract owner only

### Read-Only Functions

#### `get-balance(owner: principal)`

Returns the credit balance for a given principal.

**Returns:** `uint`

#### `get-allowance(owner: principal, spender: principal)`

Returns the allowance amount for a spender.

**Returns:** `uint`

#### `get-total-supply()`

Returns the current total supply of credits.

**Returns:** `uint`

#### `get-metadata(batch-id: uint)`

Returns metadata for a specific batch ID.

**Returns:** `(response (optional {vintage: (string-utf8 10), project-type: (string-utf8 50), location: (string-utf8 50), verified: bool}) uint)`

## Security Features

### Safe Mathematics

- **Overflow Protection**: All additions check for overflow conditions
- **Underflow Protection**: All subtractions validate sufficient balance
- **Input Validation**: All user inputs are validated before processing

### Access Controls

- **Owner Restrictions**: Critical functions limited to contract owner
- **Permission Checks**: Comprehensive authorization validation
- **State Validation**: Contract state consistency checks

### Best Practices

- **Fail-Fast Validation**: Input validation at function entry points
- **Atomic Operations**: State changes are atomic and consistent
- **Event Logging**: Comprehensive event emission for monitoring
- **Error Handling**: Detailed error codes for debugging

## Testing

### Unit Tests

Run the test suite:

```bash
clarinet test
```

### Integration Tests

Test against local testnet:

```bash
clarinet integrate
```

### Test Coverage

The contract includes comprehensive tests covering:

- Basic token operations (mint, transfer, retire)
- Allowance system functionality
- Metadata management
- Security validations
- Error conditions
- Edge cases

## Deployment

### Testnet Deployment

1. Configure your deployment settings in `deployments/default.devnet-plan.yaml`
2. Deploy to testnet:

```bash
clarinet deployments apply -p deployments/default.testnet-plan.yaml
```

### Mainnet Deployment

1. Audit the contract thoroughly
2. Configure mainnet deployment parameters
3. Deploy with appropriate security measures:

```bash
clarinet deployments apply -p deployments/default.mainnet-plan.yaml
```

### Post-Deployment

1. Verify contract deployment
2. Initialize the contract
3. Set up monitoring and alerting
4. Configure frontend integration

## Contributing

We welcome contributions to improve the Carbon Credits Smart Contract. Please follow these guidelines:

### Development Process

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

### Code Standards

- Follow Clarity best practices
- Include comprehensive comments
- Maintain consistent formatting
- Add appropriate test coverage

### Security

- Report security vulnerabilities privately
- Include security considerations in code reviews
- Follow responsible disclosure practices

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For questions, issues, or support:

- **Issues**: [GitHub Issues](https://github.com/your-org/carbon-credits-contract/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/carbon-credits-contract/discussions)
- **Email**: <support@yourproject.com>

## Acknowledgments

- Stacks Foundation for the Clarity language
- Open source contributors and reviewers
- Carbon credit standards organizations
- Environmental sustainability community

---

**Disclaimer**: This smart contract is provided as-is. Users should conduct their own security audits and due diligence before using in production environments. The authors assume no responsibility for any losses or damages resulting from the use of this contract.
