import { useState } from 'react';
import { Toaster } from 'react-hot-toast';
import { Header } from './components/Header';
import { TradingPage } from './pages/TradingPage';
import { AnalyticsPage } from './pages/AnalyticsPage';

function App() {
  const [currentPage, setCurrentPage] = useState<'trading' | 'analytics'>('trading');

  return (
    <div className="min-h-screen bg-background text-white">
      <Header currentPage={currentPage} onPageChange={setCurrentPage} />

      <main>
        {currentPage === 'trading' ? <TradingPage /> : <AnalyticsPage />}
      </main>

      <Toaster
        position="bottom-right"
        toastOptions={{
          className: 'bg-card text-white border border-gray-700',
          duration: 4000,
          success: {
            iconTheme: {
              primary: '#10B981',
              secondary: 'white',
            },
          },
          error: {
            iconTheme: {
              primary: '#EF4444',
              secondary: 'white',
            },
          },
        }}
      />
    </div>
  );
}

export default App;
