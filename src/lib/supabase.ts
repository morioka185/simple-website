import { createClient } from '@supabase/supabase-js'
import type { Database } from '@/types/database'

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://jnwnciqrqfijkqxixlcy.supabase.co'
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Impud25jaXFxcmZpamtxeGl4bGN5Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExMjYyNzIsImV4cCI6MjA2NjcwMjI3Mn0.vYB1PwiJ7vdx38VdZFhmIxr9Ie50Baj1_JeCNRAT814'

console.log('Supabase URL:', supabaseUrl)
console.log('Environment:', import.meta.env.MODE)

export const supabase = createClient<Database>(supabaseUrl, supabaseAnonKey)