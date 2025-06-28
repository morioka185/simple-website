import { useState } from 'react'
import { supabase } from '@/lib/supabase'

export default function TestPage() {
  const [connectionStatus, setConnectionStatus] = useState<string>('未テスト')
  const [tables, setTables] = useState<any[]>([])
  const [testResults, setTestResults] = useState<any[]>([])

  const testConnection = async () => {
    setConnectionStatus('テスト中...')
    
    try {
      // 基本的な接続テスト
      const { data, error } = await supabase
        .from('inflow_sources')
        .select('*')
        .limit(5)
      
      if (error) {
        setConnectionStatus(`エラー: ${error.message}`)
        return
      }
      
      setConnectionStatus('接続成功!')
      setTestResults(data || [])
      
      // テーブル一覧取得（可能な範囲で）
      const tableTests = [
        'users',
        'customers', 
        'inflow_sources',
        'meeting_results',
        'payment_methods'
      ]
      
      const tableResults = []
      
      for (const tableName of tableTests) {
        try {
          const { count, error: countError } = await supabase
            .from(tableName)
            .select('*', { count: 'exact', head: true })
          
          tableResults.push({
            table: tableName,
            status: countError ? 'エラー' : '存在',
            count: countError ? 0 : count,
            error: countError?.message
          })
        } catch (err) {
          tableResults.push({
            table: tableName,
            status: 'エラー',
            count: 0,
            error: err instanceof Error ? err.message : 'Unknown error'
          })
        }
      }
      
      setTables(tableResults)
      
    } catch (error) {
      setConnectionStatus(`接続失敗: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  const createTestUser = async () => {
    try {
      // Auth用のユーザー作成
      const { error: authError } = await supabase.auth.signUp({
        email: 'test@example.com',
        password: 'testpassword123'
      })
      
      if (authError) {
        alert(`Authユーザー作成エラー: ${authError.message}`)
        return
      }
      
      // usersテーブルにレコード作成
      const { error: userError } = await supabase
        .from('users')
        .insert([
          {
            email: 'test@example.com',
            name: 'テストユーザー',
            role: '営業マン',
            line_name: 'test_user',
            phone: '090-1234-5678'
          }
        ])
        .select()
      
      if (userError) {
        alert(`ユーザーテーブル作成エラー: ${userError.message}`)
        return
      }
      
      alert('テストユーザー作成成功!')
      
    } catch (error) {
      alert(`テストユーザー作成失敗: ${error instanceof Error ? error.message : 'Unknown error'}`)
    }
  }

  return (
    <div className="p-6 max-w-4xl mx-auto">
      <h1 className="text-2xl font-bold mb-6">Supabase 接続テスト</h1>
      
      <div className="space-y-6">
        <div className="bg-white p-4 rounded-lg shadow">
          <h2 className="text-lg font-semibold mb-4">接続状態</h2>
          <p className="mb-4">ステータス: <span className="font-mono">{connectionStatus}</span></p>
          <button
            onClick={testConnection}
            className="bg-blue-500 text-white px-4 py-2 rounded hover:bg-blue-600 mr-4"
          >
            接続テスト実行
          </button>
          <button
            onClick={createTestUser}
            className="bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600"
          >
            テストユーザー作成
          </button>
        </div>

        {tables.length > 0 && (
          <div className="bg-white p-4 rounded-lg shadow">
            <h2 className="text-lg font-semibold mb-4">テーブル状態</h2>
            <div className="overflow-x-auto">
              <table className="min-w-full border-collapse border border-gray-300">
                <thead>
                  <tr className="bg-gray-50">
                    <th className="border border-gray-300 px-4 py-2">テーブル名</th>
                    <th className="border border-gray-300 px-4 py-2">状態</th>
                    <th className="border border-gray-300 px-4 py-2">レコード数</th>
                    <th className="border border-gray-300 px-4 py-2">エラー</th>
                  </tr>
                </thead>
                <tbody>
                  {tables.map((table, index) => (
                    <tr key={index}>
                      <td className="border border-gray-300 px-4 py-2 font-mono">{table.table}</td>
                      <td className="border border-gray-300 px-4 py-2">
                        <span className={`px-2 py-1 rounded text-sm ${
                          table.status === '存在' ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                        }`}>
                          {table.status}
                        </span>
                      </td>
                      <td className="border border-gray-300 px-4 py-2">{table.count}</td>
                      <td className="border border-gray-300 px-4 py-2 text-sm text-red-600">{table.error || '-'}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </div>
        )}

        {testResults.length > 0 && (
          <div className="bg-white p-4 rounded-lg shadow">
            <h2 className="text-lg font-semibold mb-4">サンプルデータ (inflow_sources)</h2>
            <pre className="bg-gray-100 p-4 rounded text-sm overflow-x-auto">
              {JSON.stringify(testResults, null, 2)}
            </pre>
          </div>
        )}
      </div>
    </div>
  )
}