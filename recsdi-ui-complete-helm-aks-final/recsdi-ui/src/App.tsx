import React from 'react'

export default function App() {
  return (
    <main style={{ textAlign: 'center', marginTop: 48 }}>
      <h1>🚀 RECSDI-UI (React + TypeScript + Vite)</h1>
      <p>Environment: {import.meta.env.VITE_ENV}</p>
      <p>API URL: {import.meta.env.VITE_API_URL}</p>
    </main>
  )
}
