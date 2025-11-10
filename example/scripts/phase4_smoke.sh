#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
EXAMPLE_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)
DAOSYS_DIR=$(cd "${EXAMPLE_DIR}/.." && pwd)
WAGMI_DECLARE_DIR="${DAOSYS_DIR}/lib/wagmi-declare"

echo "== Phase 4 smoke: forge build =="
(
  cd "${EXAMPLE_DIR}"
  forge build
)

echo "== Phase 4 smoke: forge test =="
(
  cd "${EXAMPLE_DIR}"
  forge test
)

echo "== Phase 4 smoke: build @daosys/wagmi-declare (dist CLI) =="
(
  cd "${WAGMI_DECLARE_DIR}"
  npm run build
)

echo "== Phase 4 smoke: regenerate Counter ABI (from CounterTarget artifact) =="
(
  cd "${EXAMPLE_DIR}"
  node -e "const fs=require('fs'); const j=JSON.parse(fs.readFileSync('out/CounterTarget.sol/CounterTarget.json','utf8')); fs.writeFileSync('schema/counter.abi.json', JSON.stringify(j.abi, null, 2));"
)

echo "== Phase 4 smoke: regenerate Counter contractlist =="
(
  cd "${EXAMPLE_DIR}"
  node "${WAGMI_DECLARE_DIR}/dist/cli.mjs" generate \
    --abi "${EXAMPLE_DIR}/schema/counter.abi.json" \
    --chain-id 31337 \
    --name "Counter Diamond" \
    --hook-name "useCounterDiamond" \
    --include-view \
    --output "${EXAMPLE_DIR}/schema/counter.contractlist.json"
)

echo "== Phase 4 smoke: validate Counter contractlist =="
(
  cd "${EXAMPLE_DIR}"
  node "${WAGMI_DECLARE_DIR}/dist/cli.mjs" validate --file "${EXAMPLE_DIR}/schema/counter.contractlist.json"
)

echo "== Phase 4 smoke: build Counter UI =="
(
  cd "${EXAMPLE_DIR}"
  npm --prefix "${EXAMPLE_DIR}/counter_ui" run build
)

echo "== Phase 4 smoke: OK =="
