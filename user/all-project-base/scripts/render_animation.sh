#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="user/project-1"
RENDER_MODE="final"
SLIDE_FILTER=""
RENDERER="hyperframes"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --project) PROJECT_ROOT="$2"; shift 2 ;;
    --slide) SLIDE_FILTER="$2"; shift 2 ;;
    --renderer) RENDERER="$2"; shift 2 ;;
    --mode) RENDER_MODE="${2:-final}"; shift 2 ;;
    --mode=*) RENDER_MODE="${1#*=}"; shift ;;
    *) PROJECT_ROOT="$1"; shift ;;
  esac
done

INPUT_PATH="$PROJECT_ROOT/slides"

# Ensure HyperFrames binds localhost in restricted environments.
patch_hyperframes_localhost_bind() {
  local hf_cli="node_modules/hyperframes/dist/cli.js"
  [[ -f "$hf_cli" ]] || return 0

  # Patch both known server.listen(...) callsites if still unpatched.
  if rg -q 'server\.listen\(port\);' "$hf_cli"; then
    perl -0777 -i -pe 's/server\.listen\(port\);/server.listen({ port, host: "127.0.0.1" });/g' "$hf_cli"
  fi
}

patch_hyperframes_localhost_bind

for html in "$INPUT_PATH"/slide-[0-9]*.html; do
  [[ -f "$html" ]] || continue
  slide_id="$(basename "$html" .html)"
  [[ "$slide_id" =~ ^slide-[0-9]+$ ]] || continue
  [[ -n "$SLIDE_FILTER" && "$slide_id" != "slide-$SLIDE_FILTER" ]] && continue

  out="$INPUT_PATH/${slide_id}.mp4"
  preview="$INPUT_PATH/${slide_id}.preview.mp4"
  audio="$INPUT_PATH/${slide_id}-audio.mp3"
  image="$INPUT_PATH/${slide_id}.png"
  storyboard="$INPUT_PATH/${slide_id}-storyboard.yml"
  duration="5"
  if [[ -f "$audio" ]] && command -v ffprobe >/dev/null 2>&1; then
    duration="$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$audio" 2>/dev/null || echo 5)"
  fi

  if [[ "$RENDERER" == "ffmpeg" ]]; then
    [[ -f "$image" ]] || { echo "Missing image for $slide_id: $image"; exit 1; }
    if [[ -f "$audio" ]]; then
      ffmpeg -y -loop 1 -t "$duration" -i "$image" -i "$audio" -c:v libx264 -pix_fmt yuv420p -vf "scale=1920:1080" -c:a aac -b:a 128k -shortest "$out" -loglevel error
    else
      ffmpeg -y -loop 1 -t "$duration" -i "$image" -c:v libx264 -pix_fmt yuv420p -vf "scale=1920:1080" "$out" -loglevel error
    fi
  else
    tmpdir="$INPUT_PATH/.render-${slide_id}"
    rm -rf "$tmpdir" && mkdir -p "$tmpdir"
    cp "$html" "$tmpdir/index.html"
    cp "$image" "$tmpdir/${slide_id}.png" 2>/dev/null || true
    cp "$storyboard" "$tmpdir/${slide_id}-storyboard.yml" 2>/dev/null || true

    # HyperFrames requires window.__hf = { duration, seek }.
    # Inject a safe fallback only when missing to keep legacy HTML renderable.
    if ! rg -q "window\.__hf" "$tmpdir/index.html"; then
      perl -0777 -i -pe 's#<body\b([^>]*)>#<body$1 data-composition-id="main" data-width="1920" data-height="1080" data-duration="'"$duration"'" style="margin:0;width:1920px;height:1080px;overflow:hidden;">#' "$tmpdir/index.html"

      # Write shim JS with embedded storyboard (base64) to avoid shell/perl quoting issues.
      sb_b64="$(python3 -c "import base64,sys,os; p=sys.argv[1]; data=open(p,'rb').read() if os.path.exists(p) else b''; print(base64.b64encode(data).decode('ascii'))" "$tmpdir/${slide_id}-storyboard.yml" 2>/dev/null || true)"
      cat > "$tmpdir/hf_shim.js" <<JS
(function () {
  var d = ${duration};
  var sbB64 = "${sb_b64}";
  function clamp(v, a, b) { return Math.max(a, Math.min(b, v)); }
  function decodeB64(s) { try { return atob(s || ""); } catch (e) { return ""; } }
  function parseYamlObjects(y) {
    var out = [];
    var lines = String(y || "").split(/\\r?\\n/);
    var cur = null;
    var inObjects = false;
    for (var i = 0; i < lines.length; i++) {
      var L = lines[i];
      if (/^objects:/.test(L.trim())) { inObjects = true; continue; }
      if (!inObjects) continue;
      var t = L.trim();
      if (t.startsWith("- id:")) {
        if (cur && cur.id) out.push(cur);
        cur = { id: t.replace(/^- id:\\s*/, "").trim() };
        continue;
      }
      if (!cur) continue;
      if (t.startsWith("at:")) cur.at = parseFloat(t.replace(/^at:\\s*/, "")) || 0;
      if (t.startsWith("action:")) cur.action = t.replace(/^action:\\s*/, "").trim();
      if (t.startsWith("duration:")) cur.duration = parseFloat(t.replace(/^duration:\\s*/, "")) || 0.6;
    }
    if (cur && cur.id) out.push(cur);
    return out;
  }

  var events = parseYamlObjects(decodeB64(sbB64));

  function targetFor(id) {
    if (!id || id === "global") return document.querySelector(".wrap") || document.body;
    return document.getElementById(id) || document.querySelector("#" + id) || null;
  }

  function resetEl(el) {
    if (!el) return;
    el.style.opacity = "";
    el.style.transform = "";
    el.style.transformOrigin = "";
    el.style.filter = "";
    el.style.color = "";
    el.style.textShadow = "";
    el.style.clipPath = "";
    if (el.__wordWrapRoot) {
      var spans = el.querySelectorAll("span.__wf");
      for (var i = 0; i < spans.length; i++) spans[i].style.opacity = "0";
      el.style.opacity = "1";
    }
    if (el.__charWrapRoot) {
      var cspans = el.querySelectorAll("span.__cf");
      for (var ci = 0; ci < cspans.length; ci++) {
        cspans[ci].style.opacity = "0";
        cspans[ci].style.transform = "translateY(12px)";
      }
      el.style.opacity = "1";
    }
  }

  function ensureWordSpans(el) {
    if (!el || el.__wordWrapRoot) return;
    var text = (el.textContent || "").trim();
    if (!text) return;
    var words = text.split(/\\s+/);
    if (words.length <= 1) {
      words = Array.from(text);
    }
    el.textContent = "";
    for (var i = 0; i < words.length; i++) {
      var sp = document.createElement("span");
      sp.className = "__wf";
      sp.textContent = words[i] + (i < words.length - 1 ? " " : "");
      sp.style.opacity = "0";
      sp.style.display = "inline-block";
      sp.style.transform = "translateY(10px)";
      el.appendChild(sp);
    }
    el.__wordWrapRoot = true;
  }

  function ensureCharSpans(el) {
    if (!el || el.__charWrapRoot) return;
    var text = (el.textContent || "");
    if (!text) return;
    var chars = Array.from(text);
    el.textContent = "";
    for (var i = 0; i < chars.length; i++) {
      var sp = document.createElement("span");
      sp.className = "__cf";
      sp.textContent = chars[i];
      sp.style.opacity = "0";
      sp.style.display = "inline-block";
      sp.style.transform = "translateY(12px)";
      el.appendChild(sp);
    }
    el.__charWrapRoot = true;
  }

  function apply(el, action, p) {
    if (!el) return;
    p = clamp(p, 0, 1);
    switch (action) {
      case "fade_in": el.style.opacity = String(p); break;
      case "fade_out": el.style.opacity = String(1 - p); break;
      case "fade_up": el.style.opacity = String(p); el.style.transform = "translateY(" + Math.round((1 - p) * 18) + "px)"; break;
      case "slide_in_up": el.style.opacity = String(p); el.style.transform = "translateY(" + Math.round((1 - p) * 36) + "px)"; break;
      case "zoom_in": el.style.transform = "scale(" + (1 + 0.08 * p) + ")"; break;
      case "zoom_out": el.style.transform = "scale(" + (1.08 - 0.08 * p) + ")"; break;
      case "pan_x": el.style.transform = "translateX(" + Math.round(22 * p) + "px)"; break;
      case "draw_in": el.style.clipPath = "inset(0 " + Math.round((1 - p) * 100) + "% 0 0)"; break;
      case "split_reveal": el.style.clipPath = "inset(0 " + Math.round((1 - p) * 50) + "% 0 " + Math.round((1 - p) * 50) + "%)"; break;
      case "swap_focus": el.style.filter = "blur(" + (2 - 2 * p) + "px) brightness(" + (0.85 + 0.15 * p) + ")"; break;
      case "pulse": { var w = Math.sin(Math.PI * p); el.style.transform = "scale(" + (1 + 0.04 * w) + ")"; break; }
      case "highlight": { var w2 = Math.sin(Math.PI * p); el.style.filter = "brightness(" + (1 + 0.24 * w2) + ")"; break; }
      case "micro_emphasis": { var w3 = Math.sin(Math.PI * p); el.style.transform = "scale(" + (1 + 0.03 * w3) + ")"; break; }
      case "progress_fill": el.style.transformOrigin = "left center"; el.style.transform = "scaleX(" + p + ")"; break;
      case "progress_fill_fast": {
        var pf = 1 - Math.pow(1 - p, 2.2);
        el.style.transformOrigin = "left center";
        el.style.transform = "scaleX(" + pf + ")";
        break;
      }
      case "title_glow": {
        var tg = Math.sin(Math.PI * p);
        el.style.filter = "drop-shadow(0 0 " + Math.round(20 * tg) + "px rgba(96,165,250,0.95)) brightness(" + (1 + 0.2 * tg) + ")";
        el.style.textShadow = "0 0 " + Math.round(28 * tg) + "px rgba(96,165,250,0.55)";
        break;
      }
      case "font_red_pass": {
        var rp = Math.sin(Math.PI * p);
        el.style.color = "rgb(" + Math.round(255) + "," + Math.round(255 - 120 * rp) + "," + Math.round(255 - 120 * rp) + ")";
        el.style.filter = "brightness(" + (1 + 0.12 * rp) + ")";
        break;
      }
      case "word_by_word": {
        ensureWordSpans(el);
        var ws = el.querySelectorAll("span.__wf");
        var visible = Math.floor(p * ws.length + 0.0001);
        for (var i = 0; i < ws.length; i++) {
          var on = i < visible;
          ws[i].style.opacity = on ? "1" : "0";
          ws[i].style.transform = on ? "translateY(0px)" : "translateY(10px)";
        }
        break;
      }
      case "char_by_char": {
        ensureCharSpans(el);
        var cs = el.querySelectorAll("span.__cf");
        var visibleC = Math.floor(p * cs.length + 0.0001);
        for (var ci = 0; ci < cs.length; ci++) {
          var onC = ci < visibleC;
          cs[ci].style.opacity = onC ? "1" : "0";
          cs[ci].style.transform = onC ? "translateY(0px)" : "translateY(12px)";
        }
        break;
      }
      default: el.style.opacity = String(p);
    }
  }

  function seek(t) {
    t = Math.max(0, Number(t) || 0);
    (function updateCaptionCue() {
      var sub = document.getElementById("subtitle");
      if (!sub) return;
      var mode = sub.getAttribute("data-cues-mode") || "";
      var cues = [];
      var b64 = sub.getAttribute("data-cues-b64") || "";
      if (b64) {
        try {
          var decoded = atob(b64);
          cues = decoded.split(/\\r?\\n/).map(function (x) { return String(x || "").trim(); }).filter(Boolean);
        } catch (_) {}
      }
      if (mode === "full") {
        if (cues.length) {
          var full = cues.join("\\n");
          if (sub.__fullText !== full) {
            sub.textContent = full;
            sub.__fullText = full;
          }
        }
        return;
      }
      if (cues.length <= 1) {
        var raw = sub.getAttribute("data-cues") || "";
        cues = raw.split("||").map(function (x) { return String(x || "").trim(); }).filter(Boolean);
        if (cues.length <= 1) cues = raw.split("|").map(function (x) { return String(x || "").trim(); }).filter(Boolean);
      }
      if (!cues.length) return;
      var startAt = 2.0;
      var segDuration = Math.max(0.8, (d - startAt) / cues.length);
      var idx = Math.floor((t - startAt) / segDuration);
      idx = Math.max(0, Math.min(cues.length - 1, idx));
      if (sub.__cueIndex !== idx) {
        sub.textContent = cues[idx];
        sub.__cueIndex = idx;
      }
    })();

    var touched = [];
    for (var i = 0; i < events.length; i++) {
      var e = events[i];
      var el = targetFor(e.id);
      if (el) touched.push(el);
    }
    for (var j = 0; j < touched.length; j++) resetEl(touched[j]);
    for (var k = 0; k < events.length; k++) {
      var ev = events[k];
      var start = ev.at || 0;
      var dur = Math.max(0.1, ev.duration || 0.6);
      if (t < start) continue;
      var prog = (t - start) / dur;
      var target = targetFor(ev.id);
      if (!target) continue;
      apply(target, ev.action || "fade_in", prog);
    }
  }

  window.__hf = { duration: d, seek: seek };
  window.__timelines = window.__timelines || {};
  window.__timelines.main = window.__timelines.main || {
    seek: function (t) { seek(t); return this; },
    pause: function () { return this; },
    play: function () { return this; },
    duration: function () { return d; },
  };
  seek(0);
})();
JS

      perl -0777 -i -pe 's#</body>#<script src="./hf_shim.js"></script></body>#s' "$tmpdir/index.html"
    fi

    HOST=127.0.0.1 PORT=4173 npx hyperframes render "$tmpdir" -c index.html -o "$out" --quiet --workers 1 --host 127.0.0.1 || {
      rm -rf "$tmpdir"
      echo "Render failed for $slide_id"
      exit 1
    }
    if [[ -f "$audio" ]]; then
      ffmpeg -y -i "$out" -i "$audio" -map 0:v:0 -map 1:a:0 -c:v copy -c:a aac -b:a 128k -shortest "$out.tmp.mp4" -loglevel error
      mv "$out.tmp.mp4" "$out"
    fi
    rm -rf "$tmpdir"
  fi

  if [[ "$RENDER_MODE" == "preview" ]]; then
    ffmpeg -y -i "$out" -vf scale=960:540 -c:v libx264 -preset veryfast -crf 24 -c:a aac -b:a 96k "$preview" -loglevel error
  fi

  echo "Rendered $out"
done
