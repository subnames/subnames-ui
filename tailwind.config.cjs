module.exports = {
  content: [
    "./src/**/*.res",
    "./index.html",
  ],
  darkMode: 'class',
  theme: {
    extend: {
      borderRadius: {
        'custom': '1.8rem',
      },
      boxShadow: {
        'blue-lg': '0 10px 25px -5px rgba(59, 130, 246, 0.2), 0 8px 10px -6px rgba(59, 130, 246, 0.1)',
      },
      colors: {
        dark: {
          primary: '#1f2937',
          secondary: '#111827',
          accent: '#4b5563',
          text: '#f9fafb',
          muted: '#9ca3af'
        }
      }
    },
  },
  plugins: [],
}
