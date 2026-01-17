/** @type {import('tailwindcss').Config} */
export default {
  content: [
    "./index.html",
    "./src/**/*.{js,ts,jsx,tsx}",
  ],
  theme: {
    extend: {
      colors: {
        background: '#121212',
        card: '#1E1E1E',
        primary: '#FFC107',
        'primary-dark': '#FFA000',
        buy: '#10B981',
        sell: '#EF4444',
      },
    },
  },
  plugins: [],
}
