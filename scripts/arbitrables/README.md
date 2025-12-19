# Kleros Arbitrables Scripts

Scripts for managing and fetching MetaEvidence data for Kleros disputes.

## Overview

This directory contains scripts to:
1. Fetch dispute data from The Graph subgraph
2. Download MetaEvidence files from IPFS
3. Query blockchain event logs for missing MetaEvidence data

## Files

### Data Files
- **disputes.json** - Main data file (symlink to chain-specific file)
- **disputes-ethereum.json** - Ethereum mainnet disputes
- **disputes-gnosis.json** - Gnosis chain disputes
- **ethereum/** - Folder containing Ethereum MetaEvidence data
- **gnosis/** - Folder containing Gnosis MetaEvidence data

### Scripts
- **chain-functions.env** - Chain management functions (source this file)
- **chain-env.sh** - Chain-specific environment variables (create from template)
- **check-new-disputes.sh** - Check for new disputes without modifying files (dry-run)
- **update-disputes.sh** - Fetch new disputes from The Graph and update disputes.json
- **fetch-meta-evidence.sh** - Download MetaEvidence for disputes WITH arbitrableHistory
- **fetch-meta-evidence-from-logs.sh** - Download MetaEvidence for ALL disputes (including those without arbitrableHistory)
- **test-single-event.sh** - Debug tool to test fetching a single MetaEvidence event

## Prerequisites

```bash
# Required
brew install jq

# Optional (for verification)
brew install foundry
```

## Multi-Chain Setup

This directory supports managing disputes from multiple chains (Ethereum, Gnosis, etc.) using symlinks.

### Initial Setup

1. **Create chain-specific configuration:**
```bash
cp chain-env.template.sh chain-env.sh
# Edit chain-env.sh and fill in your actual URLs
# Note: chain-env.sh is in .gitignore and won't be committed
```

2. **Create chain-specific dispute files:**
```bash
# If starting fresh, create empty files
echo '{"data":{"disputes":[]}}' > disputes-ethereum.json
echo '{"data":{"disputes":[]}}' > disputes-gnosis.json

# Create the symlink to your preferred chain
ln -s disputes-ethereum.json disputes.json
```

### Switching Between Chains

```bash
# Load chain functions (once per shell session)
source chain-functions.env

# Show status of all chains
chain

# Switch to a chain (updates symlink + env vars automatically)
chain ethereum
chain gnosis
```

### Working with a Specific Chain

```bash
# Load functions and switch to ethereum
source chain-functions.env
chain ethereum

# Check for new disputes
./check-new-disputes.sh

# Update disputes
./update-disputes.sh

# Fetch MetaEvidence
./fetch-meta-evidence-from-logs.sh

# When done, move folders to organized directory
mv 0x* ethereum/

# Switch to another chain
chain gnosis
```

## Environment Variables

```bash
# Recommended: Use chain-env.sh for per-chain configuration
source chain-env.sh ethereum

# Or set manually:
export DISPUTE_SUBGRAPH="your-graph-endpoint-url"
export RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"

# Optional - enable debug mode
export DEBUG=1
```

## Usage

### 1. Check for New Disputes

Before updating, check what new disputes are available:

```bash
cd arbitrables
export DISPUTE_SUBGRAPH="your-graph-endpoint-url"
./check-new-disputes.sh
```

This will show:
- How many new disputes are available
- The ID range of new disputes
- Statistics about arbitrableHistory presence
- What the total count would be after update

### 2. Update Disputes

Fetch new disputes from The Graph and merge with existing data:

```bash
export DISPUTE_SUBGRAPH="your-graph-endpoint-url"
./update-disputes.sh
```

This will:
- Find the highest dispute ID in disputes.json
- Query The Graph subgraph for disputes with higher IDs
- Merge and sort all disputes by ID
- Create a timestamped backup before updating

### 3. Fetch MetaEvidence Files

#### Option A: For disputes WITH arbitrableHistory

```bash
./fetch-meta-evidence.sh
```

This script:
- Only processes disputes that have `arbitrableHistory` populated
- Fetches MetaEvidence files from IPFS
- Skips duplicate `${arbitrated}-${metaEvidenceId}` combinations
- Also downloads `dynamicScriptURI` and `evidenceDisplayInterfaceURI` if present

#### Option B: For ALL disputes (including event log queries)

```bash
export RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"
./fetch-meta-evidence-from-logs.sh
```

This script:
- Processes ALL disputes
- For disputes with `arbitrableHistory`: fetches directly from IPFS
- For disputes without `arbitrableHistory`: queries blockchain event logs
- Requires an RPC endpoint (Infura, Alchemy, etc.)
- Skips duplicate combinations to avoid re-fetching

### 4. Debug Single Event

Test fetching MetaEvidence for a specific contract and metaEvidenceId:

```bash
export RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"
./test-single-event.sh <contract_address> <metaEvidenceId>

# Example
./test-single-event.sh 0x68c4cc21378301cfdd5702d66d58a036d7bafe28 0
```

## Output Structure

MetaEvidence files are organized in folders:

```
${arbitrated}-${metaEvidenceId}/
├── metaEvidence.json           # Main MetaEvidence file
├── dynamicScript.js            # Optional: dynamic script if specified
└── evidenceDisplayInterface.json  # Optional: display interface if specified
```

Example:
```
0x68c4cc21378301cfdd5702d66d58a036d7bafe28-0/
├── metaEvidence.json
└── dynamicScript.js
```

## Important Notes

### MetaEvidence Event Topic0

The correct MetaEvidence event signature hash is:
```
0x61606860eb6c87306811e2695215385101daab53bd6ab4e9f9049aead9363c7d
```

This corresponds to the Solidity event:
```solidity
event MetaEvidence(uint256 indexed _metaEvidenceID, string _evidence);
```

### The Graph Limitations

- The Graph returns a maximum of 1000 results per query
- The update scripts fetch the latest 1000 disputes and filter client-side
- If there are more than 1000 new disputes since your last update, you'll need to run the update multiple times
- GraphQL ID filtering uses string comparison, so we fetch all recent disputes and filter numerically

### RPC Limitations

- Some RPC providers (like Infura) may have rate limits
- Queries start from block `0x0` which requires archive node access
- Consider using a dedicated RPC endpoint for large-scale fetching

### IPFS Gateway

All IPFS files are fetched through:
```
https://cdn.kleros.link/
```

## Workflow

### Single Chain Workflow

```bash
# 1. Set required environment variables
export DISPUTE_SUBGRAPH="your-graph-endpoint-url"
export RPC="https://mainnet.infura.io/v3/YOUR_API_KEY"

# 2. Check for new disputes
./check-new-disputes.sh

# 3. If new disputes exist, update the file
./update-disputes.sh

# 4. Fetch MetaEvidence for all disputes
./fetch-meta-evidence-from-logs.sh

# 5. The MetaEvidence files are now in folders ready for analysis
ls -la */metaEvidence.json
```

### Multi-Chain Workflow

```bash
# Load chain functions once per shell session
source chain-functions.env

# 1. Check current status
chain

# 2. Work on Ethereum
chain ethereum
./check-new-disputes.sh
./update-disputes.sh
./fetch-meta-evidence-from-logs.sh

# 3. Move ethereum folders to organized directory
mv 0x* ethereum/ 2>/dev/null || true

# 4. Switch to Gnosis
chain gnosis
./check-new-disputes.sh
./update-disputes.sh
./fetch-meta-evidence-from-logs.sh

# 5. Move gnosis folders to organized directory
mv 0x* gnosis/ 2>/dev/null || true

# 6. View organized data
ls -la ethereum/
ls -la gnosis/
```

## Troubleshooting

### "data type size mismatch, expected 32 got 28"

This error means the topic0 hash is incorrect or truncated. Verify you're using the correct hash (see "MetaEvidence Event Topic0" above).

### "No MetaEvidence event found"

This could mean:
- The metaEvidenceId doesn't exist for that contract
- The RPC node doesn't have full archive access
- The events are on a different chain

### IPFS fetch failures

If IPFS fetches fail:
- Check your internet connection
- Try accessing `https://cdn.kleros.link/ipfs/<hash>` directly in a browser
- The IPFS file might be unavailable or unpinned

## Data Format

### disputes.json structure

```json
{
  "data": {
    "disputes": [
      {
        "id": "0",
        "arbitrated": "0xebcf3bca271b26ae4b162ba560e243055af0e679",
        "metaEvidenceId": "0",
        "arbitrableHistory": {
          "metaEvidence": "/ipfs/Qm.../metaEvidence.json"
        }
      }
    ]
  }
}
```

### MetaEvidence JSON structure

```json
{
  "category": "...",
  "title": "...",
  "description": "...",
  "fileURI": "...",
  "evidenceDisplayInterfaceURI": "/ipfs/...",
  "dynamicScriptURI": "/ipfs/..."
}
```

