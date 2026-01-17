import { useState, useEffect, useCallback } from 'react';
import { BrowserProvider, Contract, formatUnits } from 'ethers';
import { useStore } from '@/lib/store';
import { CONTRACTS, CLOB_ABI, PAIRS, NETWORK } from '@/lib/contracts';
import type { OrderBook, OrderBookLevel } from '@/types';
import toast from 'react-hot-toast';

declare global {
  interface Window {
    ethereum?: any;
  }
}

export function useWeb3() {
  const { wallet, setWallet } = useStore();
  const [provider, setProvider] = useState<BrowserProvider | null>(null);
  const [clobContract, setClobContract] = useState<Contract | null>(null);

  // Initialize provider and contract
  useEffect(() => {
    if (typeof window !== 'undefined' && window.ethereum) {
      const browserProvider = new BrowserProvider(window.ethereum);
      setProvider(browserProvider);

      const contract = new Contract(CONTRACTS.CLOB.address, CLOB_ABI, browserProvider);
      setClobContract(contract);
    }
  }, []);

  // Connect wallet
  const connectWallet = useCallback(async () => {
    if (!window.ethereum) {
      toast.error('MetaMask is not installed');
      return;
    }

    try {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts',
      });

      const chainId = await window.ethereum.request({
        method: 'eth_chainId',
      });

      setWallet({
        address: accounts[0],
        isConnected: true,
        chainId: parseInt(chainId, 16),
      });

      toast.success('Wallet connected!');
    } catch (error: any) {
      toast.error(`Failed to connect wallet: ${error.message}`);
    }
  }, [setWallet]);

  // Disconnect wallet
  const disconnectWallet = useCallback(() => {
    setWallet({
      address: null,
      isConnected: false,
      chainId: null,
    });
    toast.success('Wallet disconnected');
  }, [setWallet]);

  // Get order book depth
  const getOrderBookDepth = useCallback(async (): Promise<OrderBook | null> => {
    if (!clobContract) return null;

    try {
      const result = await clobContract.getOrderBookDepth(
        PAIRS['MONAD/USDC'].pairId,
        10
      );

      const bids: OrderBookLevel[] = result[0]
        .filter((level: any) => level.price > 0)
        .map((level: any) => ({
          price: parseFloat(formatUnits(level.price, 6)),
          amount: parseFloat(formatUnits(level.totalAmount, 18)),
          orderCount: Number(level.orderCount),
          total: 0, // Will be calculated
        }));

      const asks: OrderBookLevel[] = result[1]
        .filter((level: any) => level.price > 0)
        .map((level: any) => ({
          price: parseFloat(formatUnits(level.price, 6)),
          amount: parseFloat(formatUnits(level.totalAmount, 18)),
          orderCount: Number(level.orderCount),
          total: 0,
        }));

      // Calculate totals
      bids.forEach((bid) => {
        bid.total = bid.price * bid.amount;
      });
      asks.forEach((ask) => {
        ask.total = ask.price * ask.amount;
      });

      return {
        bids,
        asks,
        lastUpdate: new Date(),
      };
    } catch (error: any) {
      console.error('Failed to fetch order book:', error);
      return null;
    }
  }, [clobContract]);

  // Place limit order
  const placeLimitOrder = useCallback(
    async (isBuy: boolean, price: bigint, amount: bigint) => {
      if (!provider || !wallet.isConnected) {
        toast.error('Please connect your wallet');
        return;
      }

      try {
        const signer = await provider.getSigner();
        const contractWithSigner = new Contract(
          CONTRACTS.CLOB.address,
          CLOB_ABI,
          signer
        );

        const tx = await contractWithSigner.placeLimitOrder(
          PAIRS['MONAD/USDC'].pairId,
          isBuy,
          price,
          amount,
          0 // No expiry
        );

        toast.loading('Transaction pending...', { id: tx.hash });
        await tx.wait();
        toast.success('Order placed successfully!', { id: tx.hash });

        return tx.hash;
      } catch (error: any) {
        console.error('Failed to place order:', error);
        toast.error(`Failed to place order: ${error.message}`);
        throw error;
      }
    },
    [provider, wallet.isConnected]
  );

  // Cancel order
  const cancelOrder = useCallback(
    async (orderId: bigint) => {
      if (!provider || !wallet.isConnected) {
        toast.error('Please connect your wallet');
        return;
      }

      try {
        const signer = await provider.getSigner();
        const contractWithSigner = new Contract(
          CONTRACTS.CLOB.address,
          CLOB_ABI,
          signer
        );

        const tx = await contractWithSigner.cancelOrder(orderId);

        toast.loading('Cancelling order...', { id: tx.hash });
        await tx.wait();
        toast.success('Order cancelled!', { id: tx.hash });

        return tx.hash;
      } catch (error: any) {
        console.error('Failed to cancel order:', error);
        toast.error(`Failed to cancel order: ${error.message}`);
        throw error;
      }
    },
    [provider, wallet.isConnected]
  );

  // Get user balance
  const getUserBalance = useCallback(
    async (tokenAddress: string): Promise<bigint> => {
      if (!clobContract || !wallet.address) return BigInt(0);

      try {
        const balance = await clobContract.getUserBalance(
          wallet.address,
          tokenAddress
        );
        return balance;
      } catch (error) {
        console.error('Failed to fetch user balance:', error);
        return BigInt(0);
      }
    },
    [clobContract, wallet.address]
  );

  return {
    provider,
    wallet,
    connectWallet,
    disconnectWallet,
    getOrderBookDepth,
    placeLimitOrder,
    cancelOrder,
    getUserBalance,
  };
}
