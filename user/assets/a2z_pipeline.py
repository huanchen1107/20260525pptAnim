#!/usr/bin/env python3
import re
from pathlib import Path


SOURCE = Path("user/assets/A2Z.tsx")
OUTPUT = Path("user/assets/A2Z.pipeline.yaml")


PAGE_TITLES = {
    1: "System Boot",
    2: "Diagnosis & Failure Case",
    3: "System Architecture Overview",
    4: "Hook Engine: Abstract",
    5: "Background Process: Introduction",
    6: "Battleground Matrix: Related Work",
    7: "Diagnostic View: O-Organize Dashboard",
    8: "Core Architecture: Proposed Scheme",
    9: "Debugger Mode: Structural Consistency",
    10: "Stress Test: Q-V Experiments",
    11: "Output Log: Conclusion & Future Work",
    12: "Full System Synthesis: A-Z Checklist",
    13: "Final Compilation",
}


PAGE_SKILLS = {
    1: ["screenshot-visual-analyzer", "ppt-template-matcher", "slide-scene-rebuild-html-skill"],
    2: ["screenshot-visual-analyzer", "ppt-template-matcher", "slide-scene-rebuild-html-skill"],
    3: ["ppt-template-matcher", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    4: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    5: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    6: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    7: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    8: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    9: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    10: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    11: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    12: ["screenshot-visual-analyzer", "semantic-block-extractor", "slide-scene-rebuild-html-skill"],
    13: ["screenshot-visual-analyzer", "semantic-block-extractor", "gsap-storyboard-animator", "hyperframes-video-renderer"],
}


PAGE_NOTES = {
    1: "Cover slide; strongest candidate for template reuse.",
    2: "High-contrast diagnosis layout; use the same deck theme and preserve the warning-card hierarchy.",
    3: "Navigation hub; use as the template map for the remaining pages.",
    4: "Checklist-based abstract page; requires semantic blocks and click targets.",
    5: "Introductory slide with guidance blocks and comparison rails.",
    6: "Related-work comparison matrix; likely best for repeated card geometry.",
    7: "Dashboard / diagnostic page; mostly structural repetition.",
    8: "Proposed-scheme page; needs stronger body-panel hierarchy.",
    9: "Debugger/consistency view; use animated status blocks and scan feedback.",
    10: "Experiment/stress-test slide; likely dense two-column content.",
    11: "Conclusion and future work; can reuse the same core frame with new copy.",
    12: "Alphabet checklist; candidate for dense grid + progress visual.",
    13: "Final compilation; keep the terminal and progress log animations.",
}

PAGE_STORYBOARD = {
    1: ["boot", "title_reveal", "cta_prompt", "system_status"],
    2: ["diagnose", "failure_cards", "terminal_scan", "fix_prompt"],
    3: ["hub_intro", "module_grid", "flow_connector", "navigation_hint"],
    4: ["abstract_intro", "hook_cards", "node_inspector", "status_alert"],
    5: ["context_intro", "pain_v_warning", "solution_panel", "transition_bar"],
    6: ["compare_grid", "battlefield_focus", "evidence_cards", "bridge_note"],
    7: ["dashboard_scan", "status_cluster", "organize_prompt", "terminal_footer"],
    8: ["scheme_intro", "architecture_blocks", "system_diagram", "key_takeaway"],
    9: ["debug_scan", "consistency_checks", "signal_overlay", "resolve_prompt"],
    10: ["experiment_setup", "metric_cards", "convergence_bar", "result_summary"],
    11: ["conclusion_intro", "output_log", "future_work", "wrap_up"],
    12: ["checklist_grid", "alphabet_progress", "full_system_score", "completion_hint"],
    13: ["compiler_ready", "log_stream", "integrity_confirm", "final_release"],
}


def extract_page_label(source_text: str, page: int) -> str:
    patterns = [
        rf"currentPage === {page} && \(\s*<div className=\"space-y-6\">\s*<div className=\"text-center\">\s*<h2 className=\"text-2xl font-bold\">([^<]+)</h2>",
        rf"currentPage === {page} && \(\s*<div className=\"space-y-6 text-center max-w-3xl mx-auto py-4\">[\s\S]*?<h1 className=\"text-4xl md:text-5xl font-black tracking-tight leading-tight mt-2\">\s*([^<]+)\s*</h1>",
    ]
    for pattern in patterns:
        match = re.search(pattern, source_text, re.M)
        if match:
            return match.group(1).strip()
    return PAGE_TITLES.get(page, f"Page {page}")


def main():
    text = SOURCE.read_text(encoding="utf-8")
    lines = []
    lines.append("a2z_pipeline:")
    lines.append("  source: \"user/assets/A2Z.tsx\"")
    lines.append("  deck: \"A2Z\"")
    lines.append("  pages:")

    for page in range(1, 14):
        label = extract_page_label(text, page)
        skills = PAGE_SKILLS.get(page, ["screenshot-visual-analyzer", "slide-scene-rebuild-html-skill"])
        notes = PAGE_NOTES.get(page, "")
        lines.append(f"    - page: {page}")
        lines.append(f"      title: \"{PAGE_TITLES.get(page, label)}\"")
        lines.append(f"      source_label: \"{label}\"")
        lines.append(f"      skills:")
        for skill in skills:
            lines.append(f"        - \"{skill}\"")
        lines.append(f"      storyboard_beats:")
        for beat in PAGE_STORYBOARD.get(page, []):
            lines.append(f"        - \"{beat}\"")
        if notes:
            lines.append(f"      notes: \"{notes}\"")

    lines.append("  pipeline:")
    lines.append("    - extract page geometry")
    lines.append("    - generate analysis YAML")
    lines.append("    - derive semantic blocks")
    lines.append("    - write storyboard YAML")
    lines.append("    - generate GSAP timeline")
    lines.append("    - render via HyperFrames")
    lines.append("    - validate and revise")

    OUTPUT.write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
