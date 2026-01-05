import { useMemo, useState } from 'react'
import { useAccount, useConnect, useDisconnect, usePublicClient, useWalletClient } from 'wagmi'
import { createWalletClient, http, type Abi, type Hex } from 'viem'
import { privateKeyToAccount } from 'viem/accounts'
import { foundry } from 'viem/chains'

import { getFactories, getFactoryFunctions, type ContractListArgument } from '@daosys/wagmi-declare'

import contractList from '../../schema/counter.contractlist.json'
import counterAbi from '../../schema/counter.abi.json'

type Props = {
  chainId: number
  contractAddress: string
}

function normalizeNumberInput(v: string): bigint | null {
  if (!v) return null
  try {
    // allow decimal integers
    if (!/^[0-9]+$/.test(v)) return null
    return BigInt(v)
  } catch {
    return null
  }
}

function safeJson(value: unknown): string {
  return JSON.stringify(
    value,
    (_key, v) => (typeof v === 'bigint' ? v.toString() : v),
    2
  )
}

function ArgField({ arg, value, onChange }: { arg: ContractListArgument; value: any; onChange: (v: any) => void }) {
  const label = arg.description || arg.name

  if (arg.type === 'bool') {
    return (
      <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
        <input type="checkbox" checked={!!value} onChange={e => onChange(e.target.checked)} />
        <span>{label}</span>
      </label>
    )
  }

  const placeholder = arg.ui?.placeholder ?? (arg.type === 'address' ? '0x...' : '')

  return (
    <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
      <label style={{ width: 220 }}>{label}</label>
      <input
        value={value ?? ''}
        onChange={e => onChange(e.target.value)}
        placeholder={placeholder}
        style={{ flex: 1, padding: 8 }}
      />
    </div>
  )
}

export default function CounterUi({ chainId, contractAddress }: Props) {
  const { address, isConnected } = useAccount()
  const { connect, connectors, error: connectError, isLoading: connecting, pendingConnector } = useConnect()
  const { disconnect } = useDisconnect()
  const publicClient = usePublicClient({ chainId })
  const { data: walletClient } = useWalletClient({ chainId })

  const [devPrivateKeyInput, setDevPrivateKeyInput] = useState<string>('')
  const [useDevKey, setUseDevKey] = useState<boolean>(false)

  const [selectedFn, setSelectedFn] = useState<string>('getNumber')
  const [formValues, setFormValues] = useState<Record<string, any>>({})
  const [result, setResult] = useState<any>(null)
  const [txHash, setTxHash] = useState<string | null>(null)
  const [error, setError] = useState<string | null>(null)

  const factory = useMemo(() => {
    const factories = getFactories(contractList as any, chainId)
    return factories[0]
  }, [chainId])

  const functions = useMemo(() => {
    if (!factory) return []
    return getFactoryFunctions(factory)
  }, [factory])

  const fn = functions.find(f => f.functionName === selectedFn) ?? functions[0]

  const ready = /^0x[a-fA-F0-9]{40}$/.test(contractAddress)

  const devPrivateKey = useMemo(() => {
    if (!useDevKey) return null
    const v = devPrivateKeyInput.trim()
    return /^0x[a-fA-F0-9]{64}$/.test(v) ? (v as Hex) : null
  }, [devPrivateKeyInput, useDevKey])

  const devAccount = useMemo(() => {
    if (!devPrivateKey) return null
    try {
      return privateKeyToAccount(devPrivateKey)
    } catch {
      return null
    }
  }, [devPrivateKey])

  const devWalletClient = useMemo(() => {
    if (!devAccount) return null
    if (chainId !== 31337) return null
    return createWalletClient({
      account: devAccount,
      chain: foundry,
      transport: http('http://127.0.0.1:8545')
    })
  }, [devAccount, chainId])

  const effectiveWalletClient = walletClient ?? devWalletClient
  const effectiveAddress = address ?? devAccount?.address
  const effectivelyConnected = isConnected || !!devWalletClient

  async function handleCall() {
    setError(null)
    setResult(null)
    setTxHash(null)

    if (!fn) return
    if (!ready) {
      setError('Enter a valid contract address')
      return
    }

    try {
      const abi = counterAbi as unknown as Abi
      const args = (fn.args ?? []).map((a) => {
        const v = formValues[a.name]
        if (a.type === 'uint256' || a.type === 'uint8') {
          const parsed = typeof v === 'string' ? normalizeNumberInput(v) : null
          if (parsed === null) throw new Error(`Invalid number for ${a.name}`)
          return parsed
        }
        return v
      })

      // Heuristic: treat getNumber as read, others as write.
      const isRead = fn.functionName === 'getNumber'

      if (isRead) {
        const data = await publicClient.readContract({
          address: contractAddress as any,
          abi,
          functionName: fn.functionName as any,
          args: args as any
        })
        setResult(data)
        return
      }

      if (!effectiveWalletClient) {
        setError('Connect a wallet (or use Dev Wallet) to send transactions')
        return
      }

      const hash = await effectiveWalletClient.writeContract({
        address: contractAddress as any,
        abi,
        functionName: fn.functionName as any,
        args: args as any
      })

      setTxHash(hash)
      const receipt = await publicClient.waitForTransactionReceipt({ hash })
      setResult(receipt)
    } catch (e: any) {
      setError(e?.message ?? String(e))
    }
  }

  return (
    <div style={{ border: '1px solid #ddd', borderRadius: 8, padding: 16 }}>
      <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: 12 }}>
        <div>
          <div style={{ fontWeight: 700 }}>{factory?.name ?? 'Contract'}</div>
          <div style={{ opacity: 0.7, fontSize: 13 }}>Chain {chainId}</div>
        </div>

        <div>
          {effectivelyConnected ? (
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <div style={{ fontSize: 13, opacity: 0.8 }}>{effectiveAddress}</div>
              <button
                onClick={() => {
                  if (isConnected) disconnect()
                  setUseDevKey(false)
                  setDevPrivateKeyInput('')
                }}
                style={{ padding: '6px 10px' }}
              >
                Disconnect
              </button>
            </div>
          ) : (
            <div style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
              <button
                onClick={() => connect({ connector: connectors[0] })}
                disabled={connecting}
                style={{ padding: '6px 10px' }}
              >
                {connecting ? `Connecting ${pendingConnector?.name ?? ''}...` : 'Connect Wallet'}
              </button>
            </div>
          )}
        </div>
      </div>

      {connectError ? (
        <div style={{ marginTop: 12, color: '#b00020' }}>Wallet error: {connectError.message}</div>
      ) : null}

      <div style={{ marginTop: 12, display: 'grid', gap: 8 }}>
        <label style={{ display: 'flex', gap: 8, alignItems: 'center' }}>
          <input
            type="checkbox"
            checked={useDevKey}
            onChange={e => setUseDevKey(e.target.checked)}
          />
          <span style={{ fontWeight: 600 }}>Dev Wallet (local Anvil)</span>
        </label>
        {useDevKey ? (
          <div style={{ display: 'flex', gap: 12, alignItems: 'center' }}>
            <label style={{ width: 220 }}>Private key</label>
            <input
              value={devPrivateKeyInput}
              onChange={e => setDevPrivateKeyInput(e.target.value)}
              placeholder="0x… (64 hex chars)"
              style={{ flex: 1, padding: 8 }}
            />
          </div>
        ) : null}
        {useDevKey && !devWalletClient ? (
          <div style={{ color: '#b00020', fontSize: 13 }}>
            Enter a valid private key. (Anvil default key #0 works for local testing.)
          </div>
        ) : null}
      </div>

      <div style={{ marginTop: 16, display: 'flex', gap: 12, alignItems: 'center' }}>
        <label style={{ width: 220 }}>Function</label>
        <select value={fn?.functionName} onChange={e => setSelectedFn(e.target.value)} style={{ flex: 1, padding: 8 }}>
          {functions.map(f => (
            <option key={f.functionName} value={f.functionName}>
              {f.label}
            </option>
          ))}
        </select>
      </div>

      <div style={{ marginTop: 12, display: 'grid', gap: 10 }}>
        {(fn?.args ?? []).map(arg => (
          <ArgField
            key={arg.name}
            arg={arg}
            value={formValues[arg.name]}
            onChange={v => setFormValues(prev => ({ ...prev, [arg.name]: v }))}
          />
        ))}
      </div>

      <div style={{ marginTop: 16, display: 'flex', gap: 12, alignItems: 'center' }}>
        <button onClick={handleCall} disabled={!fn} style={{ padding: '8px 12px' }}>
          {fn?.functionName === 'getNumber' ? 'Read' : 'Send'}
        </button>
        {!ready ? <span style={{ opacity: 0.7 }}>Enter a valid address to enable calls</span> : null}
      </div>

      {txHash ? (
        <div style={{ marginTop: 12 }}>
          <div style={{ fontWeight: 600 }}>Tx Hash</div>
          <code style={{ fontSize: 12 }}>{txHash}</code>
        </div>
      ) : null}

      {error ? (
        <div style={{ marginTop: 12, color: '#b00020', whiteSpace: 'pre-wrap' }}>{error}</div>
      ) : null}

      {result !== null ? (
        <div style={{ marginTop: 12 }}>
          <div style={{ fontWeight: 600 }}>Result</div>
          <pre style={{ whiteSpace: 'pre-wrap', fontSize: 12 }}>{safeJson(result)}</pre>
        </div>
      ) : null}
    </div>
  )
}
