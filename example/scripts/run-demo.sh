#!/bin/bash
# Full demo script for Hello Diamond example
# This script runs the complete pipeline: build, deploy, bundle ABIs, start frontend

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLE_DIR="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$EXAMPLE_DIR/../lib/daosys_frontend"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning:${NC} $1"
}

print_error() {
    echo -e "${RED}Error:${NC} $1"
}

echo ""
echo "=============================================="
echo "       Hello Diamond - Full Demo Pipeline"
echo "=============================================="
echo ""

# Step 1: Build contracts
print_step "Step 1: Building contracts..."
cd "$EXAMPLE_DIR"
forge build
echo ""

# Step 2: Run tests
print_step "Step 2: Running tests..."
forge test
echo ""

# Step 3: Check if Anvil is running
print_step "Step 3: Checking for local Anvil node..."
if curl -s -X POST -H "Content-Type: application/json" \
    --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
    http://127.0.0.1:8545 > /dev/null 2>&1; then
    echo "Anvil is running on http://127.0.0.1:8545"
else
    print_warning "Anvil is not running!"
    echo ""
    echo "Please start Anvil in another terminal:"
    echo "  anvil"
    echo ""
    echo "Then re-run this script."
    exit 1
fi
echo ""

# Step 4: Deploy contracts
print_step "Step 4: Deploying Greeter Diamond to Anvil..."
DEPLOY_OUTPUT=$(forge script script/DeployGreeter.s.sol --rpc-url http://127.0.0.1:8545 --broadcast 2>&1)
echo "$DEPLOY_OUTPUT"

# Extract Greeter Diamond address from output
GREETER_ADDRESS=$(echo "$DEPLOY_OUTPUT" | grep "GreeterDiamond:" | tail -1 | awk '{print $NF}')

if [ -z "$GREETER_ADDRESS" ]; then
    print_error "Could not extract Greeter Diamond address from deployment output"
    exit 1
fi

echo ""
echo -e "${GREEN}Greeter Diamond deployed at:${NC} $GREETER_ADDRESS"
echo ""

# Step 5: Bundle ABIs for frontend
print_step "Step 5: Bundling ABIs for frontend..."
cd "$FRONTEND_DIR"

# Install frontend dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

# Bundle ABIs
node scripts/bundle-local-abis.js --out-dir="$EXAMPLE_DIR/out"

# Bundle contractlists
node scripts/bundle-contractlists.js --schema-dir="$EXAMPLE_DIR/schema"
echo ""

# Step 6: Print summary and instructions
echo ""
echo "=============================================="
echo "              Demo Ready!"
echo "=============================================="
echo ""
echo "Deployed contracts:"
echo "  Greeter Diamond: $GREETER_ADDRESS"
echo ""
echo "To interact with the frontend:"
echo ""
echo "  1. Start the frontend (in lib/daosys_frontend):"
echo "     npm run dev"
echo ""
echo "  2. Open http://localhost:3000 in your browser"
echo ""
echo "  3. Connect your wallet:"
echo "     - Add network: Anvil Local"
echo "     - RPC URL: http://127.0.0.1:8545"
echo "     - Chain ID: 31337"
echo "     - Import account with private key:"
echo "       0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
echo ""
echo "  4. Enter the Greeter Diamond address:"
echo "     $GREETER_ADDRESS"
echo ""
echo "  5. Interact:"
echo "     - getMessage() - Read current greeting"
echo "     - setMessage() - Update the greeting"
echo ""
echo "=============================================="
