import { create } from 'zustand'
import { supabase } from '@/lib/supabase'
import type { Database } from '@/types/database'

type User = Database['public']['Tables']['users']['Row']

interface AuthState {
  user: User | null
  loading: boolean
  signIn: (email: string, password: string) => Promise<{ error?: string }>
  signOut: () => Promise<void>
  checkUser: () => Promise<void>
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  loading: true,

  signIn: async (email: string, password: string) => {
    try {
      // まず、Supabase Authでサインイン
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      })

      if (error) {
        return { error: error.message }
      }

      if (data.user) {
        // usersテーブルから追加情報を取得
        const { data: userData, error: userError } = await supabase
          .from('users')
          .select('*')
          .eq('email', data.user.email)
          .single()

        if (userError) {
          console.error('ユーザー情報取得エラー:', userError)
          return { error: 'ユーザー情報の取得に失敗しました' }
        }

        if (userData) {
          set({ user: userData })
        }
      }

      return {}
    } catch (error) {
      console.error('サインインエラー:', error)
      return { error: '認証に失敗しました' }
    }
  },

  signOut: async () => {
    await supabase.auth.signOut()
    set({ user: null })
  },

  checkUser: async () => {
    try {
      const { data: { user: authUser } } = await supabase.auth.getUser()
      
      if (authUser) {
        const { data: userData } = await supabase
          .from('users')
          .select('*')
          .eq('email', authUser.email)
          .single()

        if (userData) {
          set({ user: userData })
        }
      }
    } catch (error) {
      console.error('ユーザーチェックエラー:', error)
    } finally {
      set({ loading: false })
    }
  },
}))