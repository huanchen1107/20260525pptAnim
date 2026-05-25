#!/bin/bash
echo "🛑 準備結束目前的工作階段..."
echo ""

# =========================================================
# 1. 驗證與同步專案核心文件
# =========================================================
echo "================================================="
echo "📋 步驟 1：驗證核心文件"
echo "================================================="
echo ""

# Check dev log exists and show last update
if [ -f "log.md" ]; then
    echo "✅ 開發日誌 (log.md)：存在"
    echo "   最後修改：$(date -r log.md '+%Y-%m-%d %H:%M:%S')"
else
    echo "❌ 找不到開發日誌 (log.md)！請建立再繼續。"
fi

# Check README exists
if [ -f "README.md" ]; then
    echo "✅ README.md：存在"
    echo "   最後修改：$(date -r README.md '+%Y-%m-%d %H:%M:%S')"
else
    echo "❌ 找不到 README.md！"
fi
echo ""

# =========================================================
# 2. 自動生成開發日誌與摘要更新
# =========================================================
echo "================================================="
echo "🤖 步驟 2：自動生成開發日誌、對話紀錄與摘要更新"
echo "================================================="
echo ""
echo "正在自動分析本次工作階段的變更..."
python3 utils/auto_summary.py || echo "⚠️ auto_summary.py 執行失敗"
echo ""
echo "正在自動重建 user/dialog.md 對話紀錄..."
python3 utils/reconstruct_dialog.py 2>/dev/null || echo "⚠️ reconstruct_dialog.py 執行失敗"
echo ""
read -r -p "✅ 自動摘要與文件已確認更新完畢？按 Enter 繼續推送至 GitHub..."
echo ""

# =========================================================
# 3. Git 備份
# =========================================================
echo "================================================="
echo "📦 步驟 3：Git 備份推送至 GitHub"
echo "================================================="

CURRENT_BRANCH=$(git branch --show-current)
if [ -z "$CURRENT_BRANCH" ]; then
  CURRENT_BRANCH="master"
fi

echo "目前分支：$CURRENT_BRANCH"
git add .
git commit -m "Auto-commit: 結束工作階段 $(date +%Y-%m-%d)" || echo "（無新變更）"
git push origin "$CURRENT_BRANCH" || echo "⚠️ 推送失敗：請確認 git remote 設定。"
echo ""
echo "🎬 [Pipeline Compositions] Semantic blocks, GSAP timelines, and HyperFrames outputs synced."
echo "✅ 完成備份與同步！下次請執行 ./startup.sh 開始新工作階段。"
