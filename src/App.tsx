import { useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom'
import { useAuthStore } from '@/stores/authStore'
import { testSupabaseConnection } from '@/utils/testConnection'
import LoginPage from '@/pages/LoginPage'
import DashboardPage from '@/pages/DashboardPage'
import CustomersPage from '@/pages/CustomersPage'
import MeetingsPage from '@/pages/MeetingsPage'
import ContractsPage from '@/pages/ContractsPage'
import TestPage from '@/pages/TestPage'
import Layout from '@/components/Layout'

function App() {
  const { user, loading, checkUser } = useAuthStore()

  useEffect(() => {
    checkUser()
    testSupabaseConnection()
  }, [checkUser])

  if (loading) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <div className="animate-spin rounded-full h-32 w-32 border-b-2 border-primary-500"></div>
      </div>
    )
  }

  return (
    <Router>
      <Routes>
        <Route path="/test" element={<TestPage />} />
        {!user ? (
          <Route path="*" element={<LoginPage />} />
        ) : (
          <Route path="*" element={
            <Layout>
              <Routes>
                <Route path="/" element={<Navigate to="/dashboard" replace />} />
                <Route path="/dashboard" element={<DashboardPage />} />
                <Route path="/customers" element={<CustomersPage />} />
                <Route path="/meetings" element={<MeetingsPage />} />
                <Route path="/contracts" element={<ContractsPage />} />
              </Routes>
            </Layout>
          } />
        )}
      </Routes>
    </Router>
  )
}

export default App