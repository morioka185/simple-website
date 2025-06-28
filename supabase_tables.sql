-- ===================================================================
-- CRMシステム用 Supabase テーブル作成SQL
-- ===================================================================

-- ===================================================================
-- 1. マスタテーブル（6テーブル）
-- ===================================================================

-- M1. 流入経路マスタ
CREATE TABLE inflow_sources (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- M2. 面談結果マスタ
CREATE TABLE meeting_results (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_success BOOLEAN NOT NULL DEFAULT false, -- 成約か否か
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- M3. 支払方法マスタ（階層構造対応）
CREATE TABLE payment_methods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    parent_id UUID REFERENCES payment_methods(id),
    payment_type VARCHAR(20) NOT NULL CHECK (payment_type IN ('一括', '分割')),
    description TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- M4. 書類種別マスタ
CREATE TABLE document_types (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    is_required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- M5. 書類チェック項目マスタ
CREATE TABLE document_check_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    document_type_id UUID NOT NULL REFERENCES document_types(id),
    item_name VARCHAR(200) NOT NULL,
    description TEXT,
    check_points TEXT[], -- チェックポイントの配列
    is_required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- M6. 収録チェック項目マスタ
CREATE TABLE recording_check_items (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    item_name VARCHAR(200) NOT NULL,
    category VARCHAR(100) NOT NULL, -- 挨拶、ヒアリング、説明等
    description TEXT,
    evaluation_criteria TEXT,
    max_score INTEGER DEFAULT 5,
    is_required BOOLEAN DEFAULT true,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- 2. ユーザー・顧客管理テーブル（3テーブル）
-- ===================================================================

-- 1. ユーザー情報テーブル
CREATE TABLE users (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    line_name VARCHAR(100),
    role VARCHAR(20) NOT NULL CHECK (role IN ('営業マン', '営業管理', '管理者')),
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    last_login_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 2. 顧客基本情報テーブル
CREATE TABLE customers (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    name_kana VARCHAR(100),
    line_name VARCHAR(100) NOT NULL, -- LINE名必須
    email VARCHAR(255),
    phone VARCHAR(20),
    gender VARCHAR(10) CHECK (gender IN ('男性', '女性', 'その他')),
    age INTEGER CHECK (age >= 0 AND age <= 150),
    prefecture VARCHAR(20),
    city VARCHAR(50),
    occupation VARCHAR(100),
    main_business VARCHAR(200),
    annual_income INTEGER,
    inflow_source_id UUID REFERENCES inflow_sources(id),
    current_status VARCHAR(50) DEFAULT '新規',
    notes TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. 顧客担当割当履歴テーブル
CREATE TABLE customer_assignments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id),
    assigned_user_id UUID NOT NULL REFERENCES users(id),
    assigned_by_user_id UUID REFERENCES users(id),
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    unassigned_at TIMESTAMP WITH TIME ZONE,
    is_current BOOLEAN DEFAULT true,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- 3. 営業活動・契約・書類管理テーブル（7テーブル）
-- ===================================================================

-- 4. 面談記録テーブル
CREATE TABLE meetings (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    customer_id UUID NOT NULL REFERENCES customers(id),
    assigned_user_id UUID NOT NULL REFERENCES users(id),
    meeting_type VARCHAR(50) NOT NULL, -- 個別、グループ等
    scheduled_at TIMESTAMP WITH TIME ZONE NOT NULL,
    started_at TIMESTAMP WITH TIME ZONE,
    ended_at TIMESTAMP WITH TIME ZONE,
    meeting_result_id UUID REFERENCES meeting_results(id),
    recording_url TEXT,
    mindmap_url TEXT,
    can_hire BOOLEAN, -- 採用可否
    interest_level INTEGER CHECK (interest_level >= 1 AND interest_level <= 5), -- 温度感1-5
    referral_possibility INTEGER CHECK (referral_possibility >= 1 AND referral_possibility <= 5), -- 紹介可能性1-5
    financial_status VARCHAR(100), -- 財務状況
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. 契約情報テーブル
CREATE TABLE contracts (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_number VARCHAR(50) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id),
    assigned_user_id UUID NOT NULL REFERENCES users(id),
    plan_type VARCHAR(50) NOT NULL CHECK (plan_type IN ('スタンダード', 'プライム', 'デザジュク')),
    contract_amount INTEGER NOT NULL CHECK (contract_amount >= 0),
    contract_date DATE NOT NULL,
    start_date DATE,
    end_date DATE,
    status VARCHAR(50) DEFAULT '契約締結' CHECK (status IN ('契約締結', '書類作成中', '書類チェック中', '郵送中', '入金待ち', '契約完了', 'キャンセル')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. 契約支払方法テーブル（多対多関係）
CREATE TABLE contract_payment_methods (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_id UUID NOT NULL REFERENCES contracts(id),
    payment_method_id UUID NOT NULL REFERENCES payment_methods(id),
    allocation_amount INTEGER CHECK (allocation_amount >= 0),
    allocation_percentage DECIMAL(5,2) CHECK (allocation_percentage >= 0 AND allocation_percentage <= 100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(contract_id, payment_method_id)
);

-- 7. 契約書類テーブル
CREATE TABLE contract_documents (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_id UUID NOT NULL REFERENCES contracts(id),
    document_type_id UUID NOT NULL REFERENCES document_types(id),
    document_name VARCHAR(200) NOT NULL,
    file_url TEXT,
    version INTEGER DEFAULT 1,
    approval_status VARCHAR(20) DEFAULT '未承認' CHECK (approval_status IN ('未承認', '承認済み', '要修正', '却下')),
    approved_by_user_id UUID REFERENCES users(id),
    approved_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 8. 書類郵送管理テーブル
CREATE TABLE document_shipments (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_id UUID NOT NULL REFERENCES contracts(id),
    tracking_number VARCHAR(100),
    shipped_date DATE,
    delivery_completed BOOLEAN DEFAULT false,
    delivery_completed_at TIMESTAMP WITH TIME ZONE,
    created_by_user_id UUID REFERENCES users(id),
    credit_company_submitted BOOLEAN DEFAULT false,
    credit_company_submitted_at TIMESTAMP WITH TIME ZONE,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 9. 書類チェックテーブル
CREATE TABLE document_checks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_document_id UUID NOT NULL REFERENCES contract_documents(id),
    checked_by_user_id UUID NOT NULL REFERENCES users(id),
    check_result VARCHAR(20) NOT NULL CHECK (check_result IN ('合格', '不合格', '要修正')),
    requires_revision BOOLEAN DEFAULT false,
    revision_deadline DATE,
    overall_notes TEXT,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 10. 書類チェック詳細テーブル
CREATE TABLE document_check_details (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    document_check_id UUID NOT NULL REFERENCES document_checks(id),
    check_item_id UUID NOT NULL REFERENCES document_check_items(id),
    result VARCHAR(20) NOT NULL CHECK (result IN ('OK', 'NG', 'N/A')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- 4. 入金・品質・コミュニケーション管理テーブル（7テーブル）
-- ===================================================================

-- 11. 入金予定テーブル
CREATE TABLE payment_schedules (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    contract_id UUID NOT NULL REFERENCES contracts(id),
    payment_method_id UUID NOT NULL REFERENCES payment_methods(id),
    installment_number INTEGER NOT NULL DEFAULT 1,
    scheduled_amount INTEGER NOT NULL CHECK (scheduled_amount >= 0),
    scheduled_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT '予定' CHECK (status IN ('予定', '入金確認', '遅延', 'キャンセル')),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 12. 入金実績テーブル
CREATE TABLE payment_records (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    payment_schedule_id UUID REFERENCES payment_schedules(id),
    contract_id UUID NOT NULL REFERENCES contracts(id),
    payment_method_id UUID NOT NULL REFERENCES payment_methods(id),
    paid_amount INTEGER NOT NULL CHECK (paid_amount >= 0),
    paid_date DATE NOT NULL,
    confirmed_by_user_id UUID REFERENCES users(id),
    confirmed_at TIMESTAMP WITH TIME ZONE,
    bank_reference VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 13. 収録チェックテーブル
CREATE TABLE recording_checks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    meeting_id UUID NOT NULL REFERENCES meetings(id),
    checked_by_user_id UUID NOT NULL REFERENCES users(id),
    overall_result VARCHAR(20) NOT NULL CHECK (overall_result IN ('優秀', '良好', '標準', '要改善', '不合格')),
    total_score INTEGER DEFAULT 0,
    max_possible_score INTEGER DEFAULT 0,
    requires_improvement BOOLEAN DEFAULT false,
    improvement_notes TEXT,
    checked_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 14. 収録チェック詳細テーブル
CREATE TABLE recording_check_details (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    recording_check_id UUID NOT NULL REFERENCES recording_checks(id),
    check_item_id UUID NOT NULL REFERENCES recording_check_items(id),
    result VARCHAR(20) NOT NULL CHECK (result IN ('優秀', '良好', '標準', '要改善', '不合格')),
    score INTEGER DEFAULT 0,
    timestamp_start INTEGER, -- 秒単位
    timestamp_end INTEGER, -- 秒単位
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 15. 修正依頼管理テーブル
CREATE TABLE check_revision_requests (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('書類修正', '面談改善')),
    target_id UUID NOT NULL, -- document_check_id または recording_check_id
    assigned_user_id UUID NOT NULL REFERENCES users(id),
    requested_by_user_id UUID NOT NULL REFERENCES users(id),
    deadline DATE,
    status VARCHAR(20) DEFAULT '未対応' CHECK (status IN ('未対応', '対応中', '完了', '期限切れ')),
    response_content TEXT,
    completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 16. メッセージテーブル
CREATE TABLE messages (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID NOT NULL REFERENCES users(id),
    recipient_id UUID REFERENCES users(id),
    customer_id UUID REFERENCES customers(id),
    subject VARCHAR(200),
    content TEXT NOT NULL,
    message_type VARCHAR(20) DEFAULT '通常' CHECK (message_type IN ('通常', '緊急', '通知', 'システム')),
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP WITH TIME ZONE,
    parent_message_id UUID REFERENCES messages(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 17. タスク管理テーブル
CREATE TABLE tasks (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    assigned_user_id UUID NOT NULL REFERENCES users(id),
    created_by_user_id UUID NOT NULL REFERENCES users(id),
    customer_id UUID REFERENCES customers(id),
    contract_id UUID REFERENCES contracts(id),
    task_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    priority VARCHAR(10) DEFAULT '中' CHECK (priority IN ('高', '中', '低')),
    status VARCHAR(20) DEFAULT '未着手' CHECK (status IN ('未着手', '進行中', '完了', '保留', 'キャンセル')),
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    completion_notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- 5. 監査ログテーブル
-- ===================================================================

-- 18. 監査ログテーブル
CREATE TABLE audit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES users(id),
    table_name VARCHAR(100) NOT NULL,
    record_id UUID NOT NULL,
    operation VARCHAR(20) NOT NULL CHECK (operation IN ('INSERT', 'UPDATE', 'DELETE', 'SELECT')),
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ===================================================================
-- インデックス作成
-- ===================================================================

-- 顧客関連
CREATE INDEX idx_customers_line_name ON customers(line_name);
CREATE INDEX idx_customers_inflow_source ON customers(inflow_source_id);
CREATE INDEX idx_customers_status ON customers(current_status);
CREATE INDEX idx_customer_assignments_customer ON customer_assignments(customer_id);
CREATE INDEX idx_customer_assignments_user ON customer_assignments(assigned_user_id);
CREATE INDEX idx_customer_assignments_current ON customer_assignments(is_current) WHERE is_current = true;

-- 面談関連
CREATE INDEX idx_meetings_customer ON meetings(customer_id);
CREATE INDEX idx_meetings_user ON meetings(assigned_user_id);
CREATE INDEX idx_meetings_scheduled ON meetings(scheduled_at);
CREATE INDEX idx_meetings_result ON meetings(meeting_result_id);

-- 契約関連
CREATE INDEX idx_contracts_customer ON contracts(customer_id);
CREATE INDEX idx_contracts_user ON contracts(assigned_user_id);
CREATE INDEX idx_contracts_status ON contracts(status);
CREATE INDEX idx_contracts_number ON contracts(contract_number);

-- 支払い関連
CREATE INDEX idx_payment_schedules_contract ON payment_schedules(contract_id);
CREATE INDEX idx_payment_schedules_date ON payment_schedules(scheduled_date);
CREATE INDEX idx_payment_records_contract ON payment_records(contract_id);
CREATE INDEX idx_payment_records_date ON payment_records(paid_date);

-- タスク関連
CREATE INDEX idx_tasks_assigned_user ON tasks(assigned_user_id);
CREATE INDEX idx_tasks_status ON tasks(status);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);

-- メッセージ関連
CREATE INDEX idx_messages_recipient ON messages(recipient_id);
CREATE INDEX idx_messages_sender ON messages(sender_id);
CREATE INDEX idx_messages_read ON messages(is_read);

-- 監査ログ関連
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_table ON audit_logs(table_name);
CREATE INDEX idx_audit_logs_created ON audit_logs(created_at);

-- ===================================================================
-- RLS (Row Level Security) ポリシー設定例
-- ===================================================================

-- ユーザーテーブルのRLS有効化
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- 顧客テーブルのRLS有効化（営業マンは自分の担当顧客のみ閲覧可能）
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;

-- 基本的なポリシー例（詳細は実装時に調整）
CREATE POLICY users_policy ON users
    FOR ALL
    USING (auth.uid()::text = id::text OR 
           EXISTS (SELECT 1 FROM users WHERE id::text = auth.uid()::text AND role IN ('営業管理', '管理者')));

-- ===================================================================
-- マスタデータ初期投入
-- ===================================================================

-- 流入経路マスタ
INSERT INTO inflow_sources (name, description) VALUES
    ('個別', '個別相談からの流入'),
    ('AI', 'AI関連サービスからの流入'),
    ('予約専用', '予約専用サイトからの流入'),
    ('コンドウハルキ個別', 'コンドウハルキ個別相談'),
    ('コンドウハルキ公式', 'コンドウハルキ公式サイト'),
    ('SP', 'スペシャルプログラム'),
    ('アドプロ', 'アドプロからの流入'),
    ('オーガニック', '自然検索流入'),
    ('送客', '他社からの送客');

-- 面談結果マスタ
INSERT INTO meeting_results (name, description, is_success) VALUES
    ('成約', '面談で成約に至った', true),
    ('非成約', '面談したが成約に至らなかった', false),
    ('事前キャンセル', '面談前にキャンセルされた', false),
    ('無断キャンセル', '連絡なしでキャンセルされた', false),
    ('保留', '検討中で保留状態', false),
    ('契約済み（入金待ち）', '契約は済んでいるが入金待ち', true),
    ('スクール生', '既存のスクール生', false),
    ('面談なし（採用）', '面談なしで採用決定', true),
    ('入金前解除', '入金前に契約解除', false),
    ('入金前解除（信販否決）', '信販会社の審査否決による解除', false),
    ('クーリングオフ', 'クーリングオフによる解除', false),
    ('担当変更', '担当者変更のため', false);

-- 支払方法マスタ（階層構造）
INSERT INTO payment_methods (name, payment_type, parent_id) VALUES
    ('一括払い', '一括', NULL),
    ('分割払い', '分割', NULL);

-- 一括払いの詳細
INSERT INTO payment_methods (name, payment_type, parent_id) 
SELECT 
    sub.name, 
    '一括', 
    pm.id 
FROM payment_methods pm,
     (VALUES 
        ('銀行振込'),
        ('MOSH'),
        ('ユニヴァ'),
        ('アスマイル'),
        ('インフォカート'),
        ('invoy')
     ) AS sub(name)
WHERE pm.name = '一括払い';

-- 分割払いの詳細
INSERT INTO payment_methods (name, payment_type, parent_id) 
SELECT 
    sub.name, 
    '分割', 
    pm.id 
FROM payment_methods pm,
     (VALUES 
        ('CBS'),
        ('京都信販'),
        ('日本プラム')
     ) AS sub(name)
WHERE pm.name = '分割払い';

-- 書類種別マスタ
INSERT INTO document_types (name, description, display_order) VALUES
    ('契約書', '正式な契約書類', 1),
    ('電子交付承諾書', '電子交付に関する承諾書', 2),
    ('概要書面', 'サービス概要を説明する書面', 3);

-- 書類チェック項目マスタ（契約書用）
INSERT INTO document_check_items (document_type_id, item_name, description, check_points, display_order)
SELECT 
    dt.id,
    '氏名一致',
    '契約書記載の氏名が顧客情報と一致しているか',
    ARRAY['氏名の正確性', '漢字の正確性', 'フリガナの一致'],
    1
FROM document_types dt WHERE dt.name = '契約書';

INSERT INTO document_check_items (document_type_id, item_name, description, check_points, display_order)
SELECT 
    dt.id,
    '金額正確性',
    '契約金額が正確に記載されているか',
    ARRAY['契約金額の正確性', '消費税の計算', '分割回数の確認'],
    2
FROM document_types dt WHERE dt.name = '契約書';

-- 収録チェック項目マスタ
INSERT INTO recording_check_items (item_name, category, description, max_score, display_order) VALUES
    ('挨拶・導入', '開始時', '適切な挨拶と導入ができているか', 5, 1),
    ('ニーズヒアリング', 'ヒアリング', '顧客のニーズを適切にヒアリングできているか', 5, 2),
    ('サービス説明', '説明', 'サービス内容を分かりやすく説明できているか', 5, 3),
    ('質問対応', '対応', '顧客の質問に適切に対応できているか', 5, 4),
    ('クロージング', '終了時', '適切なクロージングができているか', 5, 5);