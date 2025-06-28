import { createClient } from '@supabase/supabase-js'
import * as fs from 'fs'
import * as path from 'path'

const supabaseUrl = 'https://jnwnciqrqfijkqxixlcy.supabase.co'
const supabaseServiceKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impud25jaXFxcmZpamtxeGl4bGN5Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc1MTEyNjI3MiwiZXhwIjoyMDY2NzAyMjcyfQ.qlPJWJqAj-1Fujf_WR0_WAFPZ_w4hBOTyGZj_CbornI'

const supabase = createClient(supabaseUrl, supabaseServiceKey)

async function setupDatabase() {
  try {
    console.log('🔧 Supabaseデータベースの設定を開始します...')
    
    // テーブル作成SQLを読み込み
    const sqlPath = path.join(process.cwd(), 'supabase_tables.sql')
    const sql = fs.readFileSync(sqlPath, 'utf8')
    
    // SQLを個別のステートメントに分割
    const statements = sql
      .split(';')
      .map(stmt => stmt.trim())
      .filter(stmt => stmt.length > 0 && !stmt.startsWith('--'))
    
    console.log(`📄 ${statements.length}個のSQLステートメントを実行します...`)
    
    let successCount = 0
    let errorCount = 0
    
    for (const statement of statements) {
      try {
        const { error } = await supabase.rpc('exec_sql', { sql_query: statement })
        if (error) {
          console.error(`❌ エラー: ${error.message}`)
          errorCount++
        } else {
          successCount++
        }
      } catch (err) {
        console.error(`❌ 実行エラー: ${err.message}`)
        errorCount++
      }
    }
    
    console.log(`✅ 完了: ${successCount}個成功, ${errorCount}個エラー`)
    
    // 接続テスト
    console.log('\n🔍 データベース接続をテストします...')
    const { data, error } = await supabase.from('inflow_sources').select('*').limit(1)
    
    if (error) {
      console.error('❌ 接続テスト失敗:', error.message)
    } else {
      console.log('✅ データベース接続成功!')
      console.log('サンプルデータ:', data)
    }
    
  } catch (error) {
    console.error('❌ セットアップエラー:', error.message)
  }
}

setupDatabase()