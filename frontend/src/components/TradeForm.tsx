import { useState, useEffect } from 'react';
import { useWeb3 } from '@/hooks/useWeb3';
import { parsePrice, parseAmount, formatPrice, formatAmount } from '@/lib/utils';
import { CONTRACTS } from '@/lib/contracts';
import toast from 'react-hot-toast';

export function TradeForm() {
  const { wallet, placeLimitOrder, getUserBalance } = useWeb3();
  const [isBuy, setIsBuy] = useState(true);
  const [price, setPrice] = useState('');
  const [amount, setAmount] = useState('');
  const [balance, setBalance] = useState<bigint>(BigInt(0));
  const [isSubmitting, setIsSubmitting] = useState(false);

  // Fetch user balance
  useEffect(() => {
    if (wallet.isConnected) {
      const tokenAddress = isBuy ? CONTRACTS.USDC.address : CONTRACTS.MONAD.address;
      getUserBalance(tokenAddress).then(setBalance);
    }
  }, [wallet.isConnected, isBuy, getUserBalance]);

  const total = price && amount ? (parseFloat(price) * parseFloat(amount)).toFixed(2) : '0.00';

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!wallet.isConnected) {
      toast.error('Please connect your wallet');
      return;
    }

    if (!price || !amount) {
      toast.error('Please enter price and amount');
      return;
    }

    try {
      setIsSubmitting(true);
      const priceValue = parsePrice(price, 6); // USDC has 6 decimals
      const amountValue = parseAmount(amount, 18); // MONAD has 18 decimals

      await placeLimitOrder(isBuy, priceValue, amountValue);

      // Reset form
      setPrice('');
      setAmount('');
    } catch (error) {
      // Error is already handled in useWeb3
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <div className="card p-6">
      <h2 className="text-xl font-bold mb-6">Place Order</h2>

      {/* Buy/Sell Toggle */}
      <div className="grid grid-cols-2 gap-2 mb-6">
        <button
          type="button"
          onClick={() => setIsBuy(true)}
          className={`py-3 rounded-lg font-semibold transition-all ${
            isBuy
              ? 'bg-buy text-white'
              : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
          }`}
        >
          Buy
        </button>
        <button
          type="button"
          onClick={() => setIsBuy(false)}
          className={`py-3 rounded-lg font-semibold transition-all ${
            !isBuy
              ? 'bg-sell text-white'
              : 'bg-gray-800 text-gray-400 hover:bg-gray-700'
          }`}
        >
          Sell
        </button>
      </div>

      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Price Input */}
        <div>
          <label className="block text-sm text-gray-400 mb-2">
            Price (USDC)
          </label>
          <input
            type="number"
            step="0.01"
            value={price}
            onChange={(e) => setPrice(e.target.value)}
            placeholder="0.00"
            className="input-field w-full"
            disabled={isSubmitting}
          />
        </div>

        {/* Amount Input */}
        <div>
          <label className="block text-sm text-gray-400 mb-2">
            Amount (MONAD)
          </label>
          <input
            type="number"
            step="0.0001"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.00"
            className="input-field w-full"
            disabled={isSubmitting}
          />
        </div>

        {/* Total Display */}
        <div className="bg-gray-800 rounded-lg p-4">
          <div className="flex justify-between items-center">
            <span className="text-gray-400">Total:</span>
            <span className="text-lg font-semibold">{total} USDC</span>
          </div>
        </div>

        {/* Balance Display */}
        {wallet.isConnected && (
          <div className="flex justify-between text-sm text-gray-400">
            <span>Available:</span>
            <span>
              {formatAmount(balance, isBuy ? 6 : 18)}{' '}
              {isBuy ? 'USDC' : 'MONAD'}
            </span>
          </div>
        )}

        {/* Submit Button */}
        <button
          type="submit"
          disabled={!wallet.isConnected || isSubmitting}
          className={`w-full py-3 rounded-lg font-semibold transition-all ${
            isBuy ? 'btn-buy' : 'btn-sell'
          } disabled:opacity-50 disabled:cursor-not-allowed`}
        >
          {isSubmitting
            ? 'Processing...'
            : wallet.isConnected
            ? `${isBuy ? 'Buy' : 'Sell'} MONAD`
            : 'Connect Wallet to Trade'}
        </button>
      </form>

      {!wallet.isConnected && (
        <p className="text-xs text-gray-400 text-center mt-4">
          Connect your wallet to start trading
        </p>
      )}
    </div>
  );
}
