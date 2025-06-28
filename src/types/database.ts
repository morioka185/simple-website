export interface Database {
  public: {
    Tables: {
      users: {
        Row: {
          id: string
          email: string
          name: string
          line_name: string | null
          role: '営業マン' | '営業管理' | '管理者'
          phone: string | null
          is_active: boolean
          last_login_at: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          email: string
          name: string
          line_name?: string | null
          role: '営業マン' | '営業管理' | '管理者'
          phone?: string | null
          is_active?: boolean
          last_login_at?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          email?: string
          name?: string
          line_name?: string | null
          role?: '営業マン' | '営業管理' | '管理者'
          phone?: string | null
          is_active?: boolean
          last_login_at?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      customers: {
        Row: {
          id: string
          name: string
          name_kana: string | null
          line_name: string
          email: string | null
          phone: string | null
          gender: '男性' | '女性' | 'その他' | null
          age: number | null
          prefecture: string | null
          city: string | null
          occupation: string | null
          main_business: string | null
          annual_income: number | null
          inflow_source_id: string | null
          current_status: string
          notes: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          name_kana?: string | null
          line_name: string
          email?: string | null
          phone?: string | null
          gender?: '男性' | '女性' | 'その他' | null
          age?: number | null
          prefecture?: string | null
          city?: string | null
          occupation?: string | null
          main_business?: string | null
          annual_income?: number | null
          inflow_source_id?: string | null
          current_status?: string
          notes?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          name_kana?: string | null
          line_name?: string
          email?: string | null
          phone?: string | null
          gender?: '男性' | '女性' | 'その他' | null
          age?: number | null
          prefecture?: string | null
          city?: string | null
          occupation?: string | null
          main_business?: string | null
          annual_income?: number | null
          inflow_source_id?: string | null
          current_status?: string
          notes?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      inflow_sources: {
        Row: {
          id: string
          name: string
          description: string | null
          is_active: boolean
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          name: string
          description?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          name?: string
          description?: string | null
          is_active?: boolean
          created_at?: string
          updated_at?: string
        }
      }
      meetings: {
        Row: {
          id: string
          customer_id: string
          assigned_user_id: string
          meeting_type: string
          scheduled_at: string
          started_at: string | null
          ended_at: string | null
          meeting_result_id: string | null
          recording_url: string | null
          mindmap_url: string | null
          can_hire: boolean | null
          interest_level: number | null
          referral_possibility: number | null
          financial_status: string | null
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          customer_id: string
          assigned_user_id: string
          meeting_type: string
          scheduled_at: string
          started_at?: string | null
          ended_at?: string | null
          meeting_result_id?: string | null
          recording_url?: string | null
          mindmap_url?: string | null
          can_hire?: boolean | null
          interest_level?: number | null
          referral_possibility?: number | null
          financial_status?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          customer_id?: string
          assigned_user_id?: string
          meeting_type?: string
          scheduled_at?: string
          started_at?: string | null
          ended_at?: string | null
          meeting_result_id?: string | null
          recording_url?: string | null
          mindmap_url?: string | null
          can_hire?: boolean | null
          interest_level?: number | null
          referral_possibility?: number | null
          financial_status?: string | null
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
      contracts: {
        Row: {
          id: string
          contract_number: string
          customer_id: string
          assigned_user_id: string
          plan_type: 'スタンダード' | 'プライム' | 'デザジュク'
          contract_amount: number
          contract_date: string
          start_date: string | null
          end_date: string | null
          status: '契約締結' | '書類作成中' | '書類チェック中' | '郵送中' | '入金待ち' | '契約完了' | 'キャンセル'
          notes: string | null
          created_at: string
          updated_at: string
        }
        Insert: {
          id?: string
          contract_number: string
          customer_id: string
          assigned_user_id: string
          plan_type: 'スタンダード' | 'プライム' | 'デザジュク'
          contract_amount: number
          contract_date: string
          start_date?: string | null
          end_date?: string | null
          status?: '契約締結' | '書類作成中' | '書類チェック中' | '郵送中' | '入金待ち' | '契約完了' | 'キャンセル'
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
        Update: {
          id?: string
          contract_number?: string
          customer_id?: string
          assigned_user_id?: string
          plan_type?: 'スタンダード' | 'プライム' | 'デザジュク'
          contract_amount?: number
          contract_date?: string
          start_date?: string | null
          end_date?: string | null
          status?: '契約締結' | '書類作成中' | '書類チェック中' | '郵送中' | '入金待ち' | '契約完了' | 'キャンセル'
          notes?: string | null
          created_at?: string
          updated_at?: string
        }
      }
    }
  }
}