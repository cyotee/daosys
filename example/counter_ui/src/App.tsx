import { useMemo, useState } from 'react'
import { WagmiConfig, configureChains, createConfig } from 'wagmi'
import { InjectedConnector } from 'wagmi/connectors/injected'
import { publicProvider } from 'wagmi/providers/public'
import type { Chain } from 'wagmi/chains'

import CounterUi from './CounterUi'

const anvil: Chain = {
  id: 31337,
  name: 'Anvil',
  network: 'anvil',
  nativeCurrency: { name: 'Ether', symbol: 'ETH', decimals: 18 },
  rpcUrls: {
    default: { http: ['http://127.0.0.1:8545'] },
    public: { http: ['http://127.0.0.1:8545'] }
  }
}

export default function App() {
  const [contractAddress, setContractAddress] = useState<string>('')

  const { chains, publicClient, webSocketPublicClient } = configureChains(
    [anvil],
    [publicProvider()]
  )

  const config = useMemo(() => {
    return createConfig({
      autoConnect: true,
      connectors: [new InjectedConnector({ chains })],
      publicClient,
      webSocketPublicClient
    })
  }, [chains, publicClient, webSocketPublicClient])

  return (
    <WagmiConfig config={config}>
      <div style={{ maxWidth: 860, margin: '24px auto', fontFamily: 'system-ui, sans-serif' }}>
        <h1>Counter Diamond UI (Contractlist-driven)</h1>
        <p style={{ opacity: 0.8 }}>
          This is a custom UI specific to the Counter example. It uses a wagmi-declare contractlist to render
          function controls.
        </p>

        <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
          <label style={{ width: 140 }}>Contract address</label>
          <input
            value={contractAddress}
            onChange={e => setContractAddress(e.target.value)}
            placeholder="0x..."
            style={{ flex: 1, padding: 8 }}
          />
        </div>

        <div style={{ marginTop: 16 }}>
          <CounterUi chainId={31337} contractAddress={contractAddress} />
        </div>
      </div>
    </WagmiConfig>
  )
}
