import { create } from 'zustand';
import type { WalletState, OrderBook, AnalyticsData } from '@/types';

interface AppState {
  // Wallet state
  wallet: WalletState;
  setWallet: (wallet: Partial<WalletState>) => void;

  // Order book state
  orderBook: OrderBook | null;
  setOrderBook: (orderBook: OrderBook) => void;

  // Analytics state
  analytics: AnalyticsData | null;
  setAnalytics: (analytics: AnalyticsData) => void;

  // Loading states
  isLoading: boolean;
  setIsLoading: (isLoading: boolean) => void;
}

export const useStore = create<AppState>((set) => ({
  // Initial wallet state
  wallet: {
    address: null,
    isConnected: false,
    chainId: null,
  },
  setWallet: (wallet) =>
    set((state) => ({
      wallet: { ...state.wallet, ...wallet },
    })),

  // Initial order book state
  orderBook: null,
  setOrderBook: (orderBook) => set({ orderBook }),

  // Initial analytics state
  analytics: null,
  setAnalytics: (analytics) => set({ analytics }),

  // Loading state
  isLoading: false,
  setIsLoading: (isLoading) => set({ isLoading }),
}));
