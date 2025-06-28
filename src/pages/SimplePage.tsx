export default function SimplePage() {
  return (
    <div className="min-h-screen bg-gray-50 flex items-center justify-center">
      <div className="text-center p-8 bg-white rounded-lg shadow-lg">
        <h1 className="text-3xl font-bold text-gray-900 mb-4">
          CRM System
        </h1>
        <p className="text-gray-600 mb-6">
          システムが正常に動作しています
        </p>
        <div className="space-y-4">
          <a 
            href="#/test" 
            className="inline-block bg-blue-500 text-white px-6 py-3 rounded hover:bg-blue-600"
          >
            データベーステスト
          </a>
          <br />
          <a 
            href="#/login" 
            className="inline-block bg-green-500 text-white px-6 py-3 rounded hover:bg-green-600"
          >
            ログイン
          </a>
        </div>
        <div className="mt-6 text-sm text-gray-500">
          <p>GitHub Pages でホスティング中</p>
          <p>React + TypeScript + Vite</p>
        </div>
      </div>
    </div>
  )
}