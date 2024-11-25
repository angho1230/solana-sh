#!/bin/bash

set -euo pipefail

if ! cd solana; then
    echo "Error: 'solana' directory does not exist or is inaccessible."
    exit 1
fi
echo "Running setup.sh..."
if ! ./multinode-demo/setup.sh; then
    echo "Error: setup.sh failed."
    exit 1
fi
echo "Copying faucet.json to ./config/..."
if [ ! -f ../faucet.json ]; then
    echo "Error: 'faucet.json' not found in the parent directory."
    exit 1
fi
if ! cp ../faucet.json ./config/faucet.json; then
    echo "Error: Failed to copy faucet.json to ./config/."
    exit 1
fi

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <entrypoint> <known-validator>"
    exit 1
fi

ENTRYPOINT="$1"
KNOWN_VALIDATOR="$2"

echo "Running validator-x.sh with entrypoint: $ENTRYPOINT and known-validator: $KNOWN_VALIDATOR..."
if ! ./multinode-demo/validator-x.sh --entrypoint "$ENTRYPOINT" --known-validator "$KNOWN_VALIDATOR"; then
    echo "Error: validator-x.sh failed."
    exit 1
fi

echo "Both setup.sh and validator-x.sh completed successfully."

