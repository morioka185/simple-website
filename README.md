# CRM System

営業活動・顧客管理を効率化するためのCRMシステムです。

## 🚀 Features

- **顧客管理** - 顧客情報の一元管理
- **面談管理** - 面談スケジュール・結果の記録
- **契約管理** - 契約状況・進捗の追跡
- **書類管理** - 契約書類のチェック・承認
- **品質管理** - 面談・書類の品質評価
- **ダッシュボード** - KPI・統計情報の可視化

## 🛠️ Tech Stack

- **Frontend**: React 18 + TypeScript + Vite
- **Styling**: Tailwind CSS
- **State Management**: Zustand
- **Data Fetching**: React Query
- **Database**: Supabase (PostgreSQL)
- **Authentication**: Supabase Auth
- **Deployment**: GitHub Pages

## 📦 Installation

```bash
# Clone the repository
git clone <repository-url>
cd test

# Install dependencies
npm install

# Start development server
npm run dev
```

## 🔧 Environment Setup

`.env`ファイルを作成し、以下の環境変数を設定してください：

```env
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
```

## 🗄️ Database Setup

1. Supabaseプロジェクトを作成
2. `supabase_tables.sql`をSQL Editorで実行
3. Authentication > Settingsで Email認証を有効化

## 🚀 Deployment

GitHub Pagesに自動デプロイされます：

```bash
# Build for production
npm run build

# Preview production build
npm run preview
```

## 📱 Usage

### テスト機能
- `/test` - データベース接続テスト
- テストユーザー作成機能

### 認証
- Supabase Authによるセキュアな認証
- ロールベースアクセス制御（営業マン・営業管理・管理者）

### 主要機能
- ダッシュボード: `/dashboard`
- 顧客管理: `/customers`
- 面談管理: `/meetings`
- 契約管理: `/contracts`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🔗 Live Demo

[GitHub Pages](https://your-username.github.io/test/)