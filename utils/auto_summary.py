import os
import re
import subprocess
from datetime import datetime

def run_cmd(args):
    try:
        res = subprocess.run(args, capture_output=True, text=True, check=True)
        return res.stdout.strip()
    except Exception:
        return ""

def get_latest_conversation_dir():
    base_dir = os.path.expanduser("~/.gemini/antigravity/brain")
    if not os.path.exists(base_dir):
        return None
    subdirs = [os.path.join(base_dir, d) for d in os.listdir(base_dir) if os.path.isdir(os.path.join(base_dir, d))]
    if not subdirs:
        return None
    # Get latest modified directory
    return max(subdirs, key=os.path.getmtime)

def get_session_actions(conv_dir):
    if not conv_dir:
        return []
    overview_path = os.path.join(conv_dir, ".system_generated", "logs", "overview.txt")
    if not os.path.exists(overview_path):
        return []
    
    import json
    actions = []
    try:
        with open(overview_path, 'r', encoding='utf-8') as f:
            for line in f:
                line_str = line.strip()
                if not line_str:
                    continue
                try:
                    entry = json.loads(line_str)
                    act = entry.get("toolAction") or entry.get("tool_action")
                    if act:
                        actions.append(act)
                except Exception:
                    # Fallback to regex if line is not valid JSON
                    if "toolAction" in line_str or "toolSummary" in line_str:
                        m = re.search(r'"toolAction":\s*"([^"]+)"', line_str)
                        if m:
                            actions.append(m.group(1))
    except Exception:
        pass
    
    # Return unique action descriptions, capped to last 8
    seen = set()
    unique_actions = []
    for a in reversed(actions):
        if a not in seen and len(unique_actions) < 8:
            seen.add(a)
            unique_actions.append(a)
    return unique_actions

def main():
    print("📝 正在自動生成開發日誌摘要 (log.md)...")
    
    # 1. Gather git info
    git_status = run_cmd(["git", "status", "-s"])
    git_recent_commits = run_cmd(["git", "log", "-n", "3", "--oneline"])
    
    # 2. Gather conversation actions
    latest_conv = get_latest_conversation_dir()
    actions = get_session_actions(latest_conv)
    
    # 3. Compile summary
    today_str = datetime.now().strftime("%Y.%m.%d")
    
    summary_lines = []
    summary_lines.append(f"\n## {today_str} (工作階段自動摘要)")
    summary_lines.append("> **本工作階段由 ./ending.sh 自動觸發生成備份**\n")
    
    if actions:
        summary_lines.append("### 🛠️ 執行動作項目")
        for act in actions:
            summary_lines.append(f"- {act}")
        summary_lines.append("")
        
    if git_status:
        summary_lines.append("### 📂 變更檔案清單")
        for line in git_status.split("\n"):
            summary_lines.append(f"- `{line}`")
        summary_lines.append("")
        
    if git_recent_commits:
        summary_lines.append("### 📦 近期 Git 提交紀錄")
        for line in git_recent_commits.split("\n"):
            summary_lines.append(f"- `{line}`")
        summary_lines.append("")

    summary_text = "\n".join(summary_lines)
    
    log_path = "log.md"
    if not os.path.exists(log_path):
        with open(log_path, "w", encoding="utf-8") as f:
            f.write("# Development Log\n")
            
    # Check if we already appended today's auto-summary
    try:
        with open(log_path, "r", encoding="utf-8") as f:
            content = f.read()
    except Exception:
        content = ""
        
    if f"## {today_str} (工作階段自動摘要)" in content:
        print("ℹ️ 今日的自動摘要已存在於 log.md 中，跳過附加以免重複。")
        # Update README.md anyway
        update_readme(today_str, actions, git_recent_commits)
        return
        
    try:
        with open(log_path, "a", encoding="utf-8") as f:
            f.write(summary_text)
        print("✅ 成功將自動摘要附加至 log.md！")
    except Exception as e:
        print(f"⚠️ 寫入 log.md 失敗: {e}")

    # 4. Also update README.md with latest status
    update_readme(today_str, actions, git_recent_commits)

def update_readme(today_str, actions, git_recent_commits):
    print("📝 正在自動更新 README.md...")
    readme_path = "README.md"
    if not os.path.exists(readme_path):
        return
        
    try:
        with open(readme_path, "r", encoding="utf-8") as f:
            content = f.read()
            
        status_header = "## 📍 Latest Status"
        
        status_lines = [
            status_header,
            f"\nLast updated on **{today_str}** via `./ending.sh`.\n",
        ]
        
        if actions:
            status_lines.append("### Recent Actions:")
            for act in actions:
                status_lines.append(f"- {act}")
            status_lines.append("")
            
        if git_recent_commits:
            status_lines.append("### Recent Commits:")
            for line in git_recent_commits.split("\n")[:2]:
                status_lines.append(f"- `{line}`")
            status_lines.append("")
            
        status_block = "\n".join(status_lines)
        
        # If the header exists, replace everything from it
        if status_header in content:
            parts = content.split(status_header)
            new_content = parts[0] + status_block
        else:
            new_content = content.rstrip() + "\n\n" + status_block
            
        with open(readme_path, "w", encoding="utf-8") as f:
            f.write(new_content)
        print("✅ 成功更新 README.md！")
    except Exception as e:
        print(f"⚠️ 更新 README.md 失敗: {e}")

if __name__ == "__main__":
    main()
