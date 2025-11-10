#!/bin/bash
# Bundle ABIs from example/out to daosys_frontend/public/local-abis.json

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$EXAMPLE_DIR/../lib/daosys_frontend"

echo "=== Bundling ABIs for DaoSys Frontend ==="
echo "Example directory: $EXAMPLE_DIR"
echo "Frontend directory: $FRONTEND_DIR"
echo ""

# Check if example/out exists
if [ ! -d "$EXAMPLE_DIR/out" ]; then
    echo "Error: $EXAMPLE_DIR/out not found. Run 'forge build' first."
    exit 1
fi

# Check if frontend exists
if [ ! -d "$FRONTEND_DIR" ]; then
    echo "Error: Frontend not found at $FRONTEND_DIR"
    exit 1
fi

# Bundle ABIs using the frontend's bundler with custom out-dir
cd "$FRONTEND_DIR"
echo "Running ABI bundler..."
node scripts/bundle-local-abis.js --out-dir="$EXAMPLE_DIR/out"

echo "Running contractlist bundler..."
node scripts/bundle-contractlists.js --schema-dir="$EXAMPLE_DIR/schema"

if [ $? -eq 0 ]; then
    echo ""
    echo "=== ABIs bundled successfully ==="
    echo "Manifest written to: $FRONTEND_DIR/public/local-abis.json"
    echo "Contractlists written to: $FRONTEND_DIR/public/contractlists/index.json"
else
    echo ""
    echo "Error: ABI bundling failed"
    exit 1
fi
