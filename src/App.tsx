import { useEffect, useState } from 'react'
import { HashRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from '@/stores/authStore'
import { testSupabaseConnection } from '@/utils/testConnection'
import LoginPage from '@/pages/LoginPage'
import DashboardPage from '@/pages/DashboardPage'
import CustomersPage from '@/pages/CustomersPage'
import MeetingsPage from '@/pages/MeetingsPage'
import ContractsPage from '@/pages/ContractsPage'
import TestPage from '@/pages/TestPage'
import SimplePage from '@/pages/SimplePage'
import Layout from '@/components/Layout'

function App() {
  const { user, loading, checkUser } = useAuthStore()
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const init = async () => {
      try {
        await checkUser()
        await testSupabaseConnection()
      } catch (error) {
        console.error('アプリケーション初期化エラー:', error)
        setError(error instanceof Error ? error.message : 'Unknown error')
      }
    }
    init()
  }, [checkUser])

  if (error) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center p-8">
          <h1 className="text-2xl font-bold text-red-600 mb-4">エラーが発生しました</h1>
          <p className="text-gray-600 mb-4">{error}</p>
          <button 
            onClick={() => window.location.reload()} 
            className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600"
          >
            再読み込み
          </button>
        </div>
      </div>
    )
  }

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50">
        <div className="text-center">
          <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-blue-500 mx-auto mb-4"></div>
          <p className="text-gray-600">読み込み中...</p>
        </div>
      </div>
    )
  }

  return (
    <Router>
      <Routes>
        <Route path="/" element={<SimplePage />} />
        <Route path="/test" element={<TestPage />} />
        <Route path="/login" element={<LoginPage />} />
        {user ? (
          <Route path="/app/*" element={
            <Layout>
              <Routes>
                <Route path="/" element={<Navigate to="/app/dashboard" replace />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/customers" element={<CustomersPage />} />
                <Route path="/meetings" element={<MeetingsPage />} />
                <Route path="/contracts" element={<ContractsPage />} />
              </Routes>
            </Layout>
          } />
        ) : null}
      </Routes>
    </Router>
  )
}

export default App