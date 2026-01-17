import { formatUnits, parseUnits } from 'ethers';

export function formatPrice(price: bigint | number, decimals: number = 6): string {
  if (typeof price === 'number') return price.toFixed(2);
  return parseFloat(formatUnits(price, decimals)).toFixed(2);
}

export function formatAmount(amount: bigint | number, decimals: number = 18): string {
  if (typeof amount === 'number') return amount.toFixed(4);
  return parseFloat(formatUnits(amount, decimals)).toFixed(4);
}

export function parsePrice(price: string, decimals: number = 6): bigint {
  try {
    return parseUnits(price, decimals);
  } catch {
    return BigInt(0);
  }
}

export function parseAmount(amount: string, decimals: number = 18): bigint {
  try {
    return parseUnits(amount, decimals);
  } catch {
    return BigInt(0);
  }
}

export function shortenAddress(address: string): string {
  if (!address) return '';
  return `${address.slice(0, 6)}...${address.slice(-4)}`;
}

export function cn(...classes: (string | boolean | undefined)[]): string {
  return classes.filter(Boolean).join(' ');
}
