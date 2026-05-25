#!/bin/bash

# =========================================================
# Step 1: 環境檢查 (Environment Check)
# =========================================================
echo "=============================="
echo "Step 1: 環境檢查 (Environment Check)"
echo "=============================="
PASS=true
CLIENT="${AI_CLIENT:-codex}"

check_cmd() {
    if command -v "$1" &>/dev/null; then
        echo "  ✅ $1 → $(command -v $1)"
    else
        echo "  ❌ $1 → 未安裝！請執行: $2"
        PASS=false
    fi
}

clean_workspace() {
    local PROJECT_NAME="$1"
    local TODAY=$(date +"%Y.%m.%d")
    local DEV_LOG="log.md"
    
    echo "🧹 Starting project cleanup for: $PROJECT_NAME"
    
    # 1. Handle Development Logs
    echo "📝 Initializing development log: $DEV_LOG"
    find . -maxdepth 1 -name "*開發日誌.md" -delete
    
    cat <<EOF > "$DEV_LOG"
# Development Log

## $TODAY
> **備忘錄**
> 本專案以 **Codex** 為預設代理，搭配 \`.env\` 中設定的 \`OPENAI_API_KEY\` 運作。
> 直接執行 \`./startup.sh\` 即可。

### 今日重點紀錄
1. **專案初始化**：完成環境重置與自動建庫。
2. **新專案啟動**：準備開始 $PROJECT_NAME 的開發工作。

### 技術結論
- (待填寫)
EOF

    # 2. Reset Core Markdown Files
    echo "📄 Resetting core markdown files..."
    
    cat <<EOF > README.md
# $PROJECT_NAME

> **MEMO ($TODAY)**: This project runs via the default **Codex** client with API keys configured in \`.env\`.
> Simply run \`./startup.sh\` to start.

## 🚀 Quick Start

\`\`\`bash
./startup.sh   # Initialize project + launch the configured AI client
./ending.sh    # Commit, push, and finalize session
\`\`\`

## 🤖 How it Works

\`startup.sh\` → reads \`project_initial.md\` and \`pipeline.md\` → launches the configured AI client.

## 📁 Project Structure

\`\`\`
.
├── startup.sh         # Session start: reads project goals + launches the configured AI client
├── ending.sh          # Session end: update logs + commit + push
├── .env               # API keys (gitignored)
├── pipeline.md        # Slide pipeline and artifact contract
├── $DEV_LOG          # Development log
└── user/dialog.md     # Auto-reconstructed conversation history
\`\`\`

## 🛠 Prerequisites

- \`npx\` / Node.js — for Codex or Claude CLI
- \`OPENAI_API_KEY\` set in \`.env\` for Codex
- \`ANTHROPIC_API_KEY\` set in \`.env\` when \`AI_CLIENT=claude\`
EOF

    cat <<EOF > pipeline.md
# Agent Skill Pack Pipeline

This repository now treats slide generation as a seven-stage agent pipeline:

1. Visual analysis
2. Semantic block extraction
3. Excalidraw-style HTML rebuild
4. GSAP storyboard animation
5. HyperFrames rendering
6. Visual QA
7. Revision loop

## Source Of Truth

The pipeline should be described and exchanged through structured artifacts:

- \`analysis/visual_analysis.yaml\`
- \`analysis/semantic_blocks.yaml\`
- \`analysis/storyboard.yaml\`
- \`scene/index.html\`
- \`scene/style.css\`
- \`scene/animation.js\`
- \`qa/qa_report.md\`

## Local Skill Pack

The repo keeps the pipeline skills in \`.agents/skills/\`:

- \`screenshot-visual-analyzer\`
- \`semantic-block-extractor\`
- \`excalidraw-style-html-builder\`
- \`gsap-storyboard-animator\`
- \`hyperframes-video-renderer\`
- \`visual-qa-checker\`
- \`project-orchestrator\`
EOF

    echo "# Project Initial" > project_initial.md
    echo "Rebuild this repository as a Codex-driven PPT/image to Excalidraw-style HTML -> GSAP -> HyperFrames pipeline." >> project_initial.md
    echo "" >> project_initial.md
    echo "Use pipeline.md as the source of truth for the artifact contract and local skill pack." >> project_initial.md
    
    echo "# Skill List" > skill_list.md
    echo "" >> skill_list.md
    echo "## External / installed" >> skill_list.md
    echo "- **gstack** (\`garrytan/gstack\`)" >> skill_list.md
    echo "- **improve-codebase-architecture** (\`mattpocock/skills\`)" >> skill_list.md
    echo "- **skill-creator** (\`anthropics/skills\`)" >> skill_list.md
    echo "- **using-superpowers** (\`obra/superpowers\`)" >> skill_list.md
    echo "- **hyperframes-best-practices** (\`heygen-com/hyperframes\`)" >> skill_list.md
    echo "- **excalidraw-control** (\`excalidraw/skills\`)" >> skill_list.md
    echo "" >> skill_list.md
    echo "## Local pipeline skills" >> skill_list.md
    echo "- **screenshot-visual-analyzer** (\`.agents/skills/screenshot-visual-analyzer\`)" >> skill_list.md
    echo "- **semantic-block-extractor** (\`.agents/skills/semantic-block-extractor\`)" >> skill_list.md
    echo "- **excalidraw-style-html-builder** (\`.agents/skills/excalidraw-style-html-builder\`)" >> skill_list.md
    echo "- **gsap-storyboard-animator** (\`.agents/skills/gsap-storyboard-animator\`)" >> skill_list.md
    echo "- **hyperframes-video-renderer** (\`.agents/skills/hyperframes-video-renderer\`)" >> skill_list.md
    echo "- **visual-qa-checker** (\`.agents/skills/visual-qa-checker\`)" >> skill_list.md
    echo "- **project-orchestrator** (\`.agents/skills/project-orchestrator\`)" >> skill_list.md
    
    # 3. Clean subdirectories
    echo "📁 Cleaning user and Tutorial directories..."
    mkdir -p user Tutorial
    echo "# User Conversation Dialog History" > user/dialog.md
    echo "# Tutorial 1: Getting Started" > Tutorial/Tutorial_1.md
    
    # 4. Finalizing
    rm -f initial.sh cleanAll.sh
    chmod +x startup.sh ending.sh
    
    echo "✅ Cleanup complete. $PROJECT_NAME is ready for a fresh start!"
}


echo ""
echo "📦 依賴工具："
check_cmd "node" "brew install node"
check_cmd "npx"  "brew install node"
check_cmd "curl" "brew install curl"
check_cmd "git"  "brew install git"

echo ""
echo "🧭 AI Agent Rules："
[ -f "CLAUDE.md" ] && echo "  ✅ CLAUDE.md root instructions found" || echo "  ⚠️  CLAUDE.md not found"
[ -f ".cursor/rules/karpathy-guidelines.mdc" ] && echo "  ✅ Cursor Karpathy rule found" || echo "  ⚠️  .cursor/rules/karpathy-guidelines.mdc not found"
[ -f ".agents/skills/karpathy-guidelines/SKILL.md" ] && echo "  ✅ Codex Karpathy skill found" || echo "  ⚠️  .agents/skills/karpathy-guidelines/SKILL.md not found"

echo ""
echo "🤖 AI Client："
echo "  ℹ️  AI_CLIENT=${CLIENT} (set AI_CLIENT=claude to use Claude Code)"

echo ""
echo "🔑 API Keys (.env)："
if [ -f ".env" ]; then
    source .env 2>/dev/null
    if [ "$CLIENT" = "claude" ]; then
        [ -n "$ANTHROPIC_API_KEY" ] && echo "  ✅ ANTHROPIC_API_KEY 已設定 (${ANTHROPIC_API_KEY:0:8}...)" || { echo "  ❌ ANTHROPIC_API_KEY 未設定"; PASS=false; }
    else
        [ -n "$OPENAI_API_KEY" ] && echo "  ✅ OPENAI_API_KEY 已設定 (${OPENAI_API_KEY:0:8}...)" || { echo "  ❌ OPENAI_API_KEY 未設定"; PASS=false; }
    fi
else
    if [ "$CLIENT" = "claude" ]; then
        echo "  ❌ .env 檔案不存在！請建立並填入 ANTHROPIC_API_KEY"
    else
        echo "  ❌ .env 檔案不存在！請建立並填入 OPENAI_API_KEY"
    fi
    PASS=false
fi

echo ""
echo "🌐 網路連線："
if [ "$CLIENT" = "claude" ]; then
    API_URL="https://api.anthropic.com"
    API_NAME="Anthropic API"
else
    API_URL="https://api.openai.com/v1/models"
    API_NAME="OpenAI API"
fi
HTTP=$(curl -s --max-time 5 -o /dev/null -w "%{http_code}" "$API_URL")
if [[ "$HTTP" =~ ^[234] ]]; then
    echo "  ✅ ${API_NAME} 可連線 (HTTP $HTTP)"
else
    echo "  ❌ ${API_NAME} 連線失敗 (HTTP $HTTP)"
    PASS=false
fi

echo ""
if [ "$PASS" = true ]; then
    echo "✅ 環境檢查通過！繼續下一步..."
else
    echo "❌ 環境有問題，請修正後再執行 ./startup.sh"
    exit 1
fi

# =========================================================
# Step 1.5: 專案初始化 (Project Initialization)
# =========================================================
if [ ! -f ".project_setup" ]; then
    echo ""
    echo "=============================="
    echo "⚙️  首次執行專案初始化 (First-time Initialization)"
    echo "=============================="
    
    # 1. 偵測是否已預先指派 Repository (Check if repository is pre-assigned)
    ASSIGNED_REPO=""
    
    # 從 .env 中檢查
    if [ -f ".env" ]; then
        # 暫時載入 .env 變數
        eval "$(grep -E "^(REPO_NAME|GITHUB_REPO)=" .env 2>/dev/null)"
        if [ -n "$REPO_NAME" ]; then
            ASSIGNED_REPO="$REPO_NAME"
        elif [ -n "$GITHUB_REPO" ]; then
            ASSIGNED_REPO="$GITHUB_REPO"
        fi
    fi
    
    # 從 project_initial.md 中檢查
    if [ -z "$ASSIGNED_REPO" ] && [ -f "project_initial.md" ]; then
        # 搜尋包含 github.com 或 repo 關鍵字的行，提取可能的 URL 或使用者/專案名稱
        ASSIGNED_REPO=$(grep -E -o '(https://github.com/[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+|git@github.com:[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+|[a-zA-Z0-9_.-]+/[a-zA-Z0-9_.-]+)' project_initial.md | grep -v 'github.com/huanchen1107/_ProjectTempate' | head -n 1)
    fi
    
    # 2. 確定 Repository
    REPO_TARGET=""
    if [ -n "$ASSIGNED_REPO" ]; then
        echo "🔍 偵測到預先設定的 Repository: $ASSIGNED_REPO"
        REPO_TARGET="$ASSIGNED_REPO"
    else
        echo "❓ 未偵測到預先指派的 Repository。"
        DEFAULT_NAME=$(basename "$PWD")
        read -p "👉 請輸入要連接的 GitHub 專案名稱或 URL (預設使用目前資料夾名稱 '$DEFAULT_NAME'): " USER_INPUT
        if [ -z "$USER_INPUT" ]; then
            REPO_TARGET="$DEFAULT_NAME"
        else
            REPO_TARGET="$USER_INPUT"
        fi
    fi
    
    # 3. 解析專案名稱與使用者名稱 (Resolve repo name and username)
    # 預設使用者
    DEFAULT_USER="huanchen1107"
    if [[ "$REPO_TARGET" =~ github\.com ]]; then
        REPO_NAME=$(echo "$REPO_TARGET" | sed -E 's/.*github\.com[\/:][^\/]+\/([^\/.]+)(\.git)?/\1/')
        REPO_USER=$(echo "$REPO_TARGET" | sed -E 's/.*github\.com[\/:][^\/:]*\/([^\/]+)\/.*/\1/')
        REPO_URL="$REPO_TARGET"
    elif [[ "$REPO_TARGET" =~ .*/.* ]]; then
        REPO_USER=$(echo "$REPO_TARGET" | cut -d'/' -f1)
        REPO_NAME=$(echo "$REPO_TARGET" | cut -d'/' -f2)
        REPO_URL="https://github.com/${REPO_USER}/${REPO_NAME}.git"
    else
        REPO_NAME="$REPO_TARGET"
        REPO_USER=$(git remote get-url origin 2>/dev/null | sed -E 's/.*github\.com[\/:]//; s/\/.*//')
        if [ -z "$REPO_USER" ] || [[ "$REPO_USER" =~ "fatal" ]]; then
            REPO_USER="$DEFAULT_USER"
        fi
        REPO_URL="https://github.com/${REPO_USER}/${REPO_NAME}.git"
    fi
    
    echo "📦 目標專案：$REPO_NAME"
    echo "👤 GitHub 使用者：$REPO_USER"
    echo "🔗 遠端網址：$REPO_URL"
    
    # 4. 斷開範本關聯並重置 Git (Disconnect template and initialize)
    echo "🔗 正在斷開範本與重置 Git 倉庫..."
    rm -rf .git
    git init -b main
    
    # 5. 執行 workspace 重置 (Run cleanup)
    clean_workspace "$REPO_NAME"
    
    # 6. 檢查 GitHub 倉庫是否存在 (Check if GitHub repo exists)
    echo "🌐 檢查 GitHub 上是否存在該倉庫..."
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "$REPO_URL")
    
    if [ "$HTTP_STATUS" -eq 404 ]; then
        echo "❌ 該倉庫在 GitHub 上尚不存在。"
        # 嘗試使用 gh CLI 建立
        if command -v gh &>/dev/null && gh auth status &>/dev/null; then
            echo "🛠 正在使用 GitHub CLI 自動在線上建立倉庫..."
            gh repo create "$REPO_NAME" --public --source=. --remote=origin --push
        else
            echo "⚠️  GitHub CLI 未登入或未安裝，無法自動建立倉庫。"
            echo "👉 請手動在 GitHub 上建立一個名為 '$REPO_NAME' 的空倉庫。"
            read -p "建立完成後，請按 Enter 鍵繼續..."
            git remote add origin "$REPO_URL"
            git add .
            git commit -m "Initial commit from template"
            git push -u origin main --force
        fi
    else
        echo "✅ 該倉庫已存在於 GitHub。"
        git remote add origin "$REPO_URL"
        git add .
        git commit -m "Initial commit from template"
        git push -u origin main --force
    fi
    
    # 7. 寫入初始化標記 (Write initialization marker)
    if [ $? -eq 0 ]; then
        echo "true" > ".project_setup"
        echo "🎉 專案初始化完成！"
    else
        echo "❌ 初始化推送失敗，請檢查權限或網路設定。"
        exit 1
    fi
fi

# =========================================================
# Step 1.6: OpenSpec 初始化 (OpenSpec Initialization)
# =========================================================
if [ ! -f "OpenSpec/config.yaml" ]; then
    echo ""
    echo "=============================="
    echo "⚙️  首次執行 OpenSpec 初始化 (First-time OpenSpec Init)"
    echo "=============================="
    openspec init
fi

# =========================================================
# Step 2: 拉取最新進度 (Git Pull)
# =========================================================
echo ""
echo "=============================="
echo "Step 2: 拉取最新進度 (Git Pull)"
echo "=============================="
git pull origin main || echo "⚠️ 同步失敗，跳過此步驟。"

# =========================================================
# Step 3: 閱讀開發日誌 (Read Dev Log)
# =========================================================
echo ""
echo "=============================="
echo "Step 3: 閱讀開發日誌 (Read Dev Log)"
echo "=============================="
if [ -f "log.md" ]; then
    cat "log.md"
else
    echo "⚠️ 找不到開發日誌檔案 (log.md)！"
fi
echo ""
echo "🤖 嗨，AI 助手！請閱讀上方的開發日誌，並總結目前的進度，然後告訴我接下來可以開始哪些任務 (Tasks to start)。"

# =========================================================
# Step 4: 啟動 AI CLI (Launch)
# =========================================================
echo ""
echo "=============================="
echo "Step 4: 啟動 AI CLI (Launch)"
echo "=============================="
echo ""
echo "✨=======================================================✨"
echo " 🎬 [Pipeline Active] Global & Local Agent Skills Enabled!"
echo " 💡 AI assistants (Claude, Gemini, Codex) will build"
echo "    semantic slide artifacts before rendering deterministic video."
echo "✨=======================================================✨"
echo ""
stty icrnl 2>/dev/null || true
if [ "$CLIENT" = "claude" ]; then
    npx -y @anthropic-ai/claude-code
else
    codex
fi
