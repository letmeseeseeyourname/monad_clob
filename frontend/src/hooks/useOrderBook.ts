import { useEffect, useCallback } from 'react';
import { useStore } from '@/lib/store';
import { useWeb3 } from './useWeb3';

export function useOrderBook() {
  const { orderBook, setOrderBook } = useStore();
  const { getOrderBookDepth } = useWeb3();

  const fetchOrderBook = useCallback(async () => {
    const data = await getOrderBookDepth();
    if (data) {
      setOrderBook(data);
    }
  }, [getOrderBookDepth, setOrderBook]);

  // Poll order book every 2 seconds
  useEffect(() => {
    fetchOrderBook(); // Initial fetch

    const interval = setInterval(() => {
      fetchOrderBook();
    }, 2000);

    return () => clearInterval(interval);
  }, [fetchOrderBook]);

  return {
    orderBook,
    refresh: fetchOrderBook,
  };
}
