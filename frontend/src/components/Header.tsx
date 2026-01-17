import { useState } from 'react';
import { useWeb3 } from '@/hooks/useWeb3';
import { shortenAddress } from '@/lib/utils';
import { Wallet, LogOut, BarChart3, TrendingUp } from 'lucide-react';

interface HeaderProps {
  currentPage: 'trading' | 'analytics';
  onPageChange: (page: 'trading' | 'analytics') => void;
}

export function Header({ currentPage, onPageChange }: HeaderProps) {
  const { wallet, connectWallet, disconnectWallet } = useWeb3();

  return (
    <header className="bg-card border-b border-gray-700 sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-6 py-4">
        <div className="flex items-center justify-between">
          {/* Logo and Navigation */}
          <div className="flex items-center space-x-8">
            <div className="flex items-center space-x-2">
              <div className="w-8 h-8 bg-primary rounded-lg flex items-center justify-center">
                <span className="text-black font-bold text-lg">M</span>
              </div>
              <h1 className="text-xl font-bold">MonadCLOB</h1>
            </div>

            <nav className="flex space-x-4">
              <button
                onClick={() => onPageChange('trading')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
                  currentPage === 'trading'
                    ? 'bg-primary text-black font-semibold'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800'
                }`}
              >
                <TrendingUp className="w-4 h-4" />
                <span>Trading</span>
              </button>
              <button
                onClick={() => onPageChange('analytics')}
                className={`flex items-center space-x-2 px-4 py-2 rounded-lg transition-colors ${
                  currentPage === 'analytics'
                    ? 'bg-primary text-black font-semibold'
                    : 'text-gray-400 hover:text-white hover:bg-gray-800'
                }`}
              >
                <BarChart3 className="w-4 h-4" />
                <span>Analytics</span>
              </button>
            </nav>
          </div>

          {/* Wallet Button */}
          <div>
            {wallet.isConnected ? (
              <div className="flex items-center space-x-4">
                <div className="hidden md:flex items-center space-x-2 bg-gray-800 px-4 py-2 rounded-lg">
                  <div className="w-2 h-2 bg-buy rounded-full animate-pulse" />
                  <span className="text-sm font-medium">
                    {shortenAddress(wallet.address || '')}
                  </span>
                </div>
                <button
                  onClick={disconnectWallet}
                  className="flex items-center space-x-2 px-4 py-2 bg-gray-800 hover:bg-gray-700 rounded-lg transition-colors"
                  title="Disconnect Wallet"
                >
                  <LogOut className="w-4 h-4" />
                  <span className="hidden md:inline">Disconnect</span>
                </button>
              </div>
            ) : (
              <button
                onClick={connectWallet}
                className="btn-primary flex items-center space-x-2"
              >
                <Wallet className="w-4 h-4" />
                <span>Connect Wallet</span>
              </button>
            )}
          </div>
        </div>
      </div>
    </header>
  );
}
