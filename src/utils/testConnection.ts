import { supabase } from '@/lib/supabase'

export async function testSupabaseConnection() {
  try {
    console.log('Supabase接続をテストしています...')
    
    // 基本的な接続テスト
    const { data, error } = await supabase
      .from('inflow_sources')
      .select('*')
      .limit(1)
    
    if (error) {
      console.error('接続エラー:', error.message)
      return false
    }
    
    console.log('接続成功!', data)
    return true
  } catch (error) {
    console.error('接続テスト失敗:', error)
    return false
  }
}

export async function createTestUser() {
  try {
    console.log('テストユーザーを作成しています...')
    
    // テスト用ユーザーデータ
    const { data, error } = await supabase
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
    
    if (error) {
      console.error('ユーザー作成エラー:', error.message)
      return null
    }
    
    console.log('テストユーザー作成成功:', data)
    return data[0]
  } catch (error) {
    console.error('テストユーザー作成失敗:', error)
    return null
  }
}