"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const react_1 = require("react");
const wagmi_1 = require("wagmi");
const injected_1 = require("wagmi/connectors/injected");
const public_1 = require("wagmi/providers/public");
const CounterUi_1 = __importDefault(require("./CounterUi"));
const anvil = {
    id: 31337,
    name: 'Anvil',
    network: 'anvil',
    nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
    rpcUrls: {
        default: { http: ['http://127.0.0.1:8545'] },
        public: { http: ['http://127.0.0.1:8545'] }
    }
};
function App() {
    const [contractAddress, setContractAddress] = (0, react_1.useState)('');
    const { chains, publicClient, webSocketPublicClient } = (0, wagmi_1.configureChains)([anvil], [(0, public_1.publicProvider)()]);
    const config = (0, react_1.useMemo)(() => {
        return (0, wagmi_1.createConfig)({
            autoConnect: true,
            connectors: [new injected_1.InjectedConnector({ chains })],
            publicClient,
            webSocketPublicClient
        });
    }, [chains, publicClient, webSocketPublicClient]);
    return (<wagmi_1.WagmiConfig config={config}>
      <div style={{ maxWidth: 860, margin: '24px auto', fontFamily: 'system-ui, sans-serif' }}>
        <h1>Counter Diamond UI (Contractlist-driven)</h1>
        <p style={{ opacity: 0.8 }}>
          This is a custom UI specific to the Counter example. It uses a wagmi-declare contractlist to render
          function controls.
        </p>

        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <label style={{ width: 140 }}>Contract address</label>
          <input value={contractAddress} onChange={e => setContractAddress(e.target.value)} placeholder="0x..." style={{ flex: 1, padding: 8 }}/>
        </div>

        <div style={{ marginTop: 16 }}>
          <CounterUi_1.default chainId={31337} contractAddress={contractAddress}/>
        </div>
      </div>
    </wagmi_1.WagmiConfig>);
}
exports.default = App;
