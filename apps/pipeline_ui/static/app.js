async function apiGet(path) {
  const res = await fetch(path, {headers: {"Accept": "application/json"}});
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }
  return await res.json();
}

async function apiSend(path, method, body) {
  const res = await fetch(path, {
    method,
    headers: {"Accept": "application/json", "Content-Type": "application/json"},
    body: body ? JSON.stringify(body) : undefined,
  });
  if (!res.ok) {
    const text = await res.text();
    throw new Error(`${res.status} ${res.statusText}: ${text}`);
  }
  return await res.json();
}

const STEP_CONFIG = [
  {key: "split", n: 1, title: "Split Pages", files: ["slides/slide-N.png", "slides/slide-N-audio.mp3", "slides/slide-N-audio.txt"]},
  {key: "convert", n: 2, title: "Convert HTML", files: ["slides/slide-N.html"]},
  {key: "storyboard", n: 3, title: "Storyboard", files: ["slides/slide-N-storyboard-idea.txt", "slides/slide-N-storyboard.yml"]},
  {key: "render", n: 4, title: "Render MP4", files: ["slides/slide-N.mp4"]},
  {key: "combine", n: 5, title: "Combine", files: ["outputs/presentation-master.mp4"]},
  {key: "validate", n: 6, title: "Validate", files: ["slides/* canonical artifacts"]},
  {key: "deliver", n: 7, title: "Deliverables", files: ["slides/slide-N.mp4", "slides/slide-N.srt"]},
];

const runParams = {
  mode: "final",
  renderer: "hyperframes",
  source_mode: "tsx",
};
let activeStepKey = "split";
let timelineRows = [];
const SHOW_TIMELINE_UI = false;
let currentSlides = [];
let deliverRangeText = "";

function el(tag, attrs = {}, children = []) {
  const node = document.createElement(tag);
  for (const [k, v] of Object.entries(attrs)) {
    if (k === "class") node.className = v;
    else if (k.startsWith("on") && typeof v === "function") node.addEventListener(k.slice(2), v);
    else node.setAttribute(k, v);
  }
  for (const c of children) node.appendChild(typeof c === "string" ? document.createTextNode(c) : c);
  return node;
}

function selectedContext() {
  const project = document.getElementById("projectSelect").value || "";
  const slide = document.getElementById("slideSelect").value || null;
  return {project, slide};
}

function renderStepTabs() {
  const host = document.getElementById("stepTabs");
  host.innerHTML = "";
  for (const s of STEP_CONFIG) {
    host.appendChild(
      el("button", {
        type: "button",
        class: activeStepKey === s.key ? "active" : "",
        onclick: () => setActiveStep(s.key),
      }, [`${s.n}. ${s.title}`]),
    );
  }
}

function fileExample(pathTemplate, slide) {
  return slide ? pathTemplate.replaceAll("slide-N", slide) : pathTemplate;
}

function renderStepPanel() {
  const host = document.getElementById("stepPanel");
  const step = STEP_CONFIG.find((s) => s.key === activeStepKey) || STEP_CONFIG[0];
  const {project, slide} = selectedContext();
  host.innerHTML = "";

  host.appendChild(el("div", {class: "title"}, [`STEP ${step.n}: ${step.title}`]));
  host.appendChild(el("div", {class: "meta"}, [
    `Project: ${project || "(none)"} · Slide: ${slide || "(all)"} · Running this step activates this tab.`,
  ]));

  const files = el("div", {class: "kv"}, []);
  files.appendChild(el("div", {}, ["Related files"]));
  files.appendChild(el("div", {}, step.files.map((f, i) => el("code", {}, [fileExample(f, slide || "slide-N"), i < step.files.length - 1 ? " " : ""]))));
  host.appendChild(files);

  const params = el("div", {class: "kv"}, []);
  params.appendChild(el("div", {}, ["Parameters"]));
  const pWrap = el("div", {}, []);
  const modeSel = el("select", {id: "paramMode"}, [
    el("option", {value: "final"}, ["final"]),
    el("option", {value: "preview"}, ["preview"]),
  ]);
  modeSel.value = runParams.mode;
  modeSel.addEventListener("change", () => { runParams.mode = modeSel.value; });
  const rendererSel = el("select", {id: "paramRenderer"}, [
    el("option", {value: "hyperframes"}, ["hyperframes"]),
    el("option", {value: "ffmpeg"}, ["ffmpeg"]),
  ]);
  rendererSel.value = runParams.renderer;
  rendererSel.addEventListener("change", () => { runParams.renderer = rendererSel.value; });
  const sourceSel = el("select", {id: "paramSource"}, [
    el("option", {value: "tsx"}, ["tsx"]),
    el("option", {value: "pdf"}, ["pdf"]),
    el("option", {value: "video"}, ["video"]),
  ]);
  sourceSel.value = runParams.source_mode;
  sourceSel.addEventListener("change", () => { runParams.source_mode = sourceSel.value; });

  pWrap.appendChild(el("span", {class: "meta"}, ["mode "]));
  pWrap.appendChild(modeSel);
  pWrap.appendChild(el("span", {class: "meta"}, [" renderer "]));
  pWrap.appendChild(rendererSel);
  pWrap.appendChild(el("span", {class: "meta"}, [" source_mode "]));
  pWrap.appendChild(sourceSel);
  params.appendChild(pWrap);
  host.appendChild(params);

  host.appendChild(el("div", {class: "meta"}, [
    `Command route: /api/pipeline/step/${step.key}`,
  ]));

  if (step.key === "deliver") {
    const box = el("div", {class: "kv"}, []);
    box.appendChild(el("div", {}, ["Downloads"]));
    const d = el("div", {}, []);
    const hasProject = Boolean(project);
    const firstN = currentSlides.length ? Number((currentSlides[0] || "slide-1").replace("slide-", "")) : 1;
    const lastN = currentSlides.length ? Number((currentSlides[currentSlides.length - 1] || "slide-1").replace("slide-", "")) : 1;
    if (!deliverRangeText) deliverRangeText = `${firstN}-${lastN}`;
    const rangeInput = el("input", {type: "text", value: deliverRangeText, placeholder: `${firstN}-${lastN}`});
    rangeInput.style.width = "120px";
    rangeInput.addEventListener("change", () => { deliverRangeText = (rangeInput.value || "").trim(); });
    d.appendChild(el("span", {class: "meta"}, ["Pages"]));
    d.appendChild(document.createTextNode(" "));
    d.appendChild(rangeInput);
    d.appendChild(document.createTextNode("  "));

    const parseRange = () => {
      const raw = (rangeInput.value || "").trim();
      const m = raw.match(/^(\d+)\s*-\s*(\d+)$/);
      if (m) {
        const s = Math.max(1, Number(m[1]));
        const e = Math.max(s, Number(m[2]));
        return `start=${s}&end=${e}`;
      }
      const single = raw.match(/^(\d+)$/);
      if (single) {
        const v = Math.max(1, Number(single[1]));
        return `start=${v}&end=${v}`;
      }
      return "";
    };

    const mp4Url = hasProject ? `/api/deliverables/${encodeURIComponent(project)}/bundle?kind=mp4&${parseRange()}` : "";
    const srtUrl = hasProject ? `/api/deliverables/${encodeURIComponent(project)}/bundle?kind=srt&${parseRange()}` : "";
    const pdfUrl = project ? `/api/source-pdf/${encodeURIComponent(project)}?${parseRange()}` : "";
    d.appendChild(el("button", {
      type: "button",
      disabled: hasProject ? null : "true",
      onclick: () => { if (hasProject) window.open(mp4Url, "_blank"); },
    }, ["Final Video (All)"]));
    d.appendChild(document.createTextNode(" "));
    d.appendChild(el("button", {
      type: "button",
      disabled: hasProject ? null : "true",
      onclick: () => { if (hasProject) window.open(srtUrl, "_blank"); },
    }, ["SRT (All)"]));
    d.appendChild(document.createTextNode(" "));
    d.appendChild(el("button", {
      type: "button",
      disabled: project ? null : "true",
      onclick: () => { if (project) window.open(pdfUrl, "_blank"); },
    }, ["Source PDF"]));
    box.appendChild(d);
    const from = `slide-${firstN}`;
    const to = `slide-${lastN}`;
    box.appendChild(el("div", {class: "marquee"}, [
      el("span", {}, [`Deliverables scope follows Pages selector. Example: ${firstN}-${lastN} (all slides), or a single page like ${firstN}.`]),
    ]));
    host.appendChild(box);
  }
}

function setActiveStep(stepKey) {
  activeStepKey = stepKey;
  renderStepTabs();
  renderStepPanel();
}

async function refreshProjects() {
  const sel = document.getElementById("projectSelect");
  sel.innerHTML = "";
  const hint = document.getElementById("projectHint");
  hint.textContent = "Loading projects…";

  const data = await apiGet("/api/projects");
  const projects = data.projects || [];
  if (!projects.length) {
    hint.textContent = "No projects found under ./user/project-*";
    return;
  }
  for (const p of projects) {
    sel.appendChild(el("option", {value: p}, [p]));
  }
  hint.textContent = `Found ${projects.length} project(s).`;
  await refreshSlides();
}

async function loadIdea(project, slideId) {
  const data = await apiGet(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}/idea`);
  return data.idea || "";
}

async function saveIdea(project, slideId, idea) {
  await apiSend(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}/idea`, "PUT", {idea});
}

async function loadStoryboard(project, slideId) {
  const data = await apiGet(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}`);
  return data.storyboard || "";
}

async function loadStoryboardObjects(project, slideId) {
  const data = await apiGet(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}/objects`);
  return data.objects || [];
}

async function saveStoryboardObjects(project, slideId, objects) {
  await apiSend(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}/objects`, "PUT", {objects});
}

async function loadObjectCatalog(project, slideId) {
  const data = await apiGet(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}/object-catalog`);
  return data.objects || [];
}

function renderObjectsPanel(panel, project, slideId, onSaved) {
  panel.innerHTML = "";
  const title = el("div", {class: "modalTitle"}, [`Objects · ${slideId}`]);
  const list = el("div", {class: "objList"}, []);
  const status = el("div", {class: "meta"}, []);
  const header = el("div", {class: "objectsHeader"}, []);
  const rightActions = el("div", {class: "actions"}, []);
  const tableWrap = el("div", {class: "objectsTableWrap"}, []);
  let visible = true;
  let autoSyncTimer = null;
  const collectObjects = () => {
    const rows = Array.from(list.querySelectorAll(".objRow"));
    return rows.map((node) => node._get()).filter((item) => item.id);
  };
  const persistObjects = async (showMsg = true) => {
    const objects = collectObjects();
    await saveStoryboardObjects(project, slideId, objects);
    if (showMsg) {
      status.textContent = "Objects synced to storyboard.";
      setTimeout(() => (status.textContent = ""), 1200);
    }
    if (onSaved) onSaved();
  };
  const scheduleAutoSync = () => {
    if (autoSyncTimer) clearTimeout(autoSyncTimer);
    autoSyncTimer = setTimeout(() => {
      persistObjects(false).catch((err) => {
        status.textContent = String(err);
      });
    }, 500);
  };
  const row = (obj = {}, catalog = []) => {
    const r = el("div", {class: "objRow"}, []);
    const idInput = el("select", {});
    idInput.appendChild(el("option", {value: ""}, ["Select Object ID"]));
    for (const item of catalog) {
      const label = `${item.id} — ${item.name}`;
      idInput.appendChild(el("option", {value: item.id}, [label]));
    }
    if (obj.id && !catalog.find((x) => x.id === obj.id)) {
      idInput.appendChild(el("option", {value: obj.id}, [`${obj.id} — (custom)`]));
    }
    idInput.value = obj.id || "";
    const actionInput = el("input", {type: "text", placeholder: "action", value: obj.action || "fade_in"});
    const atInput = el("input", {type: "text", placeholder: "at", value: obj.at || "0.00"});
    const durInput = el("input", {type: "text", placeholder: "duration", value: obj.duration || "0.80"});
    const intentInput = el("input", {type: "text", placeholder: "intent", value: obj.intent || "manual"});
    const defaultsForObject = (oid) => {
      if (oid === "title_center" || oid === "title") {
        return {action: "word_by_word", at: "0.30", duration: "2.20", intent: "title_intro"};
      }
      if (oid === "subtitle") {
        return {action: "fade_up", at: "2.20", duration: "0.90", intent: "caption_intro"};
      }
      if (oid === "progress_fill") {
        return {action: "progress_fill", at: "0.20", duration: "33.53", intent: "timeline_progress"};
      }
      if (oid === "pass_text") {
        return {action: "fade_up", at: "10.00", duration: "1.00", intent: "pass_marker"};
      }
      if (oid === "main_image") {
        return {action: "zoom_in", at: "0.35", duration: "2.40", intent: "image_intro"};
      }
      return {action: "fade_in", at: "0.00", duration: "0.80", intent: "manual"};
    };
    idInput.addEventListener("change", () => {
      const oid = (idInput.value || "").trim();
      if (!oid) return;
      const d = defaultsForObject(oid);
      actionInput.value = d.action;
      atInput.value = d.at;
      durInput.value = d.duration;
      intentInput.value = d.intent;
      scheduleAutoSync();
    });
    actionInput.addEventListener("change", scheduleAutoSync);
    atInput.addEventListener("change", scheduleAutoSync);
    durInput.addEventListener("change", scheduleAutoSync);
    intentInput.addEventListener("change", scheduleAutoSync);
    const delBtn = el("button", {type: "button", onclick: () => r.remove()}, ["Delete"]);
    delBtn.addEventListener("click", scheduleAutoSync);
    r.appendChild(idInput);
    r.appendChild(actionInput);
    r.appendChild(atInput);
    r.appendChild(durInput);
    r.appendChild(intentInput);
    r.appendChild(delBtn);
    r._get = () => ({
      id: (idInput.value || "").trim(),
      action: (actionInput.value || "").trim(),
      at: (atInput.value || "").trim(),
      duration: (durInput.value || "").trim(),
      intent: (intentInput.value || "").trim(),
    });
    return r;
  };

  const addBtn = el("button", {type: "button", disabled: "true"}, ["Add Action"]);
  const saveBtn = el("button", {type: "button", onclick: async () => {
    await persistObjects(true);
  }}, ["Save Objects"]);
  const toggleBtn = el("button", {type: "button", onclick: () => {
    visible = !visible;
    tableWrap.style.display = visible ? "" : "none";
    toggleBtn.textContent = visible ? "Hide Table" : "Show Table";
  }}, ["Hide Table"]);

  rightActions.appendChild(toggleBtn);
  rightActions.appendChild(addBtn);
  rightActions.appendChild(saveBtn);
  header.appendChild(title);
  header.appendChild(rightActions);
  tableWrap.appendChild(list);
  panel.appendChild(header);
  panel.appendChild(tableWrap);
  panel.appendChild(status);

  Promise.all([loadStoryboardObjects(project, slideId), loadObjectCatalog(project, slideId)]).then(([objs, catalog]) => {
    list.innerHTML = "";
    if (!objs.length) list.appendChild(row({}, catalog));
    else for (const item of objs) list.appendChild(row(item, catalog));
    addBtn.disabled = false;
    addBtn.onclick = () => {
      const rows = Array.from(list.querySelectorAll(".objRow"));
      if (rows.length === 1) {
        const existing = rows[0]._get ? rows[0]._get() : null;
        if (existing && !existing.id) {
          return;
        }
      }
      list.appendChild(row({}, catalog));
    };
  }).catch((err) => {
    status.textContent = String(err);
  });
}

async function loadCaption(project, slideId) {
  const data = await apiGet(`/api/caption/${encodeURIComponent(project)}/${encodeURIComponent(slideId)}`);
  return data.caption || "";
}

async function loadPipelineStatus(project, slideIdOrNull) {
  const qs = new URLSearchParams({project_id: project});
  if (slideIdOrNull) qs.set("slide", slideIdOrNull);
  const data = await apiGet(`/api/pipeline/status?${qs.toString()}`);
  return data.status || {};
}

async function loadTimeline(project) {
  const data = await apiGet(`/api/timeline/${encodeURIComponent(project)}`);
  return data.timeline || [];
}

async function saveTimeline(project, timeline) {
  await apiSend(`/api/timeline/${encodeURIComponent(project)}`, "PUT", {timeline});
}

function toClock(sec) {
  const value = Math.max(0, Number(sec) || 0);
  const mm = Math.floor(value / 60);
  const ss = Math.floor(value % 60);
  return `${String(mm).padStart(2, "0")}:${String(ss).padStart(2, "0")}`;
}

function num(v, fallback = 0) {
  const n = Number(v);
  return Number.isFinite(n) ? n : fallback;
}

function applyTimelineEdit(index, requestedStart, requestedEnd) {
  if (index < 0 || index >= timelineRows.length) return;

  const oldDurations = timelineRows.map((r) => Math.max(0.1, num(r.duration, num(r.end, 0) - num(r.start, 0))));
  const row = timelineRows[index];

  let start = Math.max(0, num(requestedStart, num(row.start, 0)));
  if (index > 0) {
    const prev = timelineRows[index - 1];
    prev.end = start;
    prev.duration = Math.max(0.1, num(prev.end) - num(prev.start));
    start = num(prev.end);
  }

  const end = Math.max(start + 0.1, num(requestedEnd, num(row.end, start + oldDurations[index])));
  row.start = start;
  row.end = end;
  row.duration = end - start;

  let cursor = row.end;
  for (let i = index + 1; i < timelineRows.length; i++) {
    const dur = oldDurations[i];
    timelineRows[i].start = cursor;
    timelineRows[i].end = cursor + dur;
    timelineRows[i].duration = dur;
    cursor = timelineRows[i].end;
  }
}

function bindTimelineInputs(index, startInput, endInput, badge, allControls) {
  const refreshFromModel = () => {
    for (const ctl of allControls) {
      const row = timelineRows[ctl.index];
      if (!row) continue;
      ctl.startInput.value = String(num(row.start, 0).toFixed(2));
      ctl.endInput.value = String(num(row.end, 0).toFixed(2));
      ctl.badge.textContent = `${toClock(row.start)} ~ ${toClock(row.end)}`;
    }
  };

  const applyLocal = () => {
    const row = timelineRows[index];
    if (!row) return;
    const newStart = num(startInput.value, num(row.start, 0));
    const newEnd = num(endInput.value, num(row.end, 5));
    applyTimelineEdit(index, newStart, newEnd);
    refreshFromModel();
  };

  startInput.addEventListener("change", applyLocal);
  endInput.addEventListener("change", applyLocal);
}

function renderStepper(statusMap) {
  const steps = STEP_CONFIG;
  const host = document.getElementById("stepper");
  host.innerHTML = "";
  for (const s of steps) {
    const state = statusMap[s.key] || "pending";
    const stepEl = el("div", {class: `step ${state}`}, []);
    stepEl.appendChild(el("div", {class: "line"}, []));
    stepEl.appendChild(el("div", {class: "dot"}, [String(s.n)]));
    stepEl.appendChild(el("div", {class: "label"}, [`STEP ${s.n}`]));
    stepEl.appendChild(el("div", {class: "title"}, [s.title]));
    stepEl.appendChild(el("div", {class: "state"}, [state.replace("_", " ")]));
    if (s.key !== "deliver") {
      stepEl.appendChild(
        el("button", {class: "run", type: "button", onclick: async () => {
          setActiveStep(s.key);
          await runStep(s.key);
          await refreshStepper();
        }}, ["Run"]),
      );
    } else {
      stepEl.appendChild(
        el("button", {class: "run", type: "button", onclick: async () => {
          setActiveStep("deliver");
        }}, ["Open"]),
      );
    }
    host.appendChild(stepEl);
  }
}

async function refreshSlides() {
  const sel = document.getElementById("projectSelect");
  const project = sel.value;
  const container = document.getElementById("slides");
  const slideSelect = document.getElementById("slideSelect");
  container.innerHTML = "";
  if (!project) return;
  const data = await apiGet(`/api/projects/${encodeURIComponent(project)}/slides`);
  const slides = data.slides || [];
  currentSlides = slides.slice();
  timelineRows = await loadTimeline(project);
  const timelineBySlide = new Map(timelineRows.map((r) => [r.slide_id, r]));
  let cursorEnd = 0;
  timelineRows = slides.map((slideId) => {
    const row = timelineBySlide.get(slideId);
    if (row) {
      cursorEnd = num(row.end, cursorEnd);
      return row;
    }
    const fallback = {slide_id: slideId, start: cursorEnd, end: cursorEnd + 5, duration: 5};
    cursorEnd += 5;
    return fallback;
  });

  slideSelect.innerHTML = "";
  slideSelect.appendChild(el("option", {value: ""}, ["(All slides)"]));
  for (const s of slides) {
    slideSelect.appendChild(el("option", {value: s}, [s]));
  }

  for (let idx = 0; idx < slides.length; idx++) {
    const s = slides[idx];
    const card = el("div", {class: "slide"}, []);

    const row2 = el("div", {class: "row2"}, []);
    const left = el("div", {class: "left"}, []);
    const right = el("div", {class: "right"}, []);
    row2.appendChild(left);
    row2.appendChild(right);

    const thumbSrc = `/api/thumb/${encodeURIComponent(project)}/${encodeURIComponent(s)}`;
    const thumbImg = el("img", {class: "thumb", src: thumbSrc, alt: `${s} thumbnail`});
    const resultVideo = el("video", {class: "thumb", controls: "true", playsinline: "true"});
    resultVideo.style.display = "none";
    left.appendChild(thumbImg);
    left.appendChild(resultVideo);

    // Caption panel removed (redundant with storyboard/idea context).

    const tr = timelineRows[idx] || {slide_id: s, start: 0, end: 5, duration: 5};
    let startInput = null;
    let endInput = null;
    if (SHOW_TIMELINE_UI) {
      const timelineBox = el("div", {class: "captionBox"}, []);
      timelineBox.appendChild(el("div", {class: "label"}, ["Timeline (ripple to neighbors)"]));
      const tRow = el("div", {class: "row"}, []);
      startInput = el("input", {type: "number", step: "0.1", min: "0", value: String(num(tr.start, 0))});
      endInput = el("input", {type: "number", step: "0.1", min: "0.1", value: String(num(tr.end, 5))});
      const badge = el("span", {class: "meta timeline-badge"}, [`${toClock(tr.start)} ~ ${toClock(tr.end)}`]);
      tRow.appendChild(el("span", {class: "meta"}, ["start"]));
      tRow.appendChild(startInput);
      tRow.appendChild(el("span", {class: "meta"}, ["end"]));
      tRow.appendChild(endInput);
      tRow.appendChild(badge);
      timelineBox.appendChild(tRow);
      right.appendChild(timelineBox);
    }

    const headRight = el("div", {class: "row slideHead"}, []);
    const nameEl = el("div", {class: "name"}, [s]);
    const primaryActions = el("div", {class: "actions primaryActions"}, []);
    headRight.appendChild(nameEl);
    headRight.appendChild(primaryActions);
    right.appendChild(headRight);

    const ideaBox = el("div", {class: "ideaBox"}, []);
    ideaBox.appendChild(el("div", {class: "label"}, ["Animation design (idea)"]));
    const textarea = el("textarea", {"data-slide": s});
    textarea.value = await loadIdea(project, s);
    textarea.dataset.manualSized = "0";
    const syncIdeaHeight = () => {
      if (textarea.dataset.manualSized === "1") return;
      const h = Math.max(220, Math.round(thumbImg.getBoundingClientRect().height || 0));
      if (h > 0) textarea.style.height = `${h}px`;
    };
    syncIdeaHeight();
    if (typeof ResizeObserver !== "undefined") {
      const ro = new ResizeObserver(() => syncIdeaHeight());
      ro.observe(thumbImg);
    }
    textarea.addEventListener("mouseup", () => {
      textarea.dataset.manualSized = "1";
    });
    ideaBox.appendChild(textarea);
    let ideaSyncTimer = null;

    const actions = el("div", {class: "actions"}, []);
    let resultToggleBtn = null;
    if (SHOW_TIMELINE_UI) {
      actions.appendChild(
        el("button", {type: "button", onclick: async () => {
          const model = timelineRows[idx] || tr;
          const newStart = num(startInput.value, num(model.start, 0));
          const newEnd = num(endInput.value, num(model.end, 5));
          applyTimelineEdit(idx, newStart, newEnd);
          await saveTimeline(project, timelineRows);
          actions.querySelector(".status").textContent = "Timeline saved.";
          await refreshSlides();
        }}, ["Save Timeline"]),
      );
    }
    const syncIdeaToStoryboard = async () => {
      await saveIdea(project, s, textarea.value || "");
      const regen = await apiSend(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(s)}/regenerate`, "POST", {});
      await pollRun(regen.run.run_id);
      await refreshStepper();
      actions.querySelector(".status").textContent = "Idea synced to storyboard.";
      setTimeout(() => (actions.querySelector(".status").textContent = ""), 1500);
    };
    textarea.addEventListener("change", async () => {
      if (ideaSyncTimer) clearTimeout(ideaSyncTimer);
      ideaSyncTimer = setTimeout(() => {
        syncIdeaToStoryboard().catch((err) => {
          actions.querySelector(".status").textContent = String(err);
        });
      }, 300);
    });

    const saveIdeaBtn = el("button", {type: "button", onclick: async () => {
        await saveIdea(project, s, textarea.value || "");
        actions.querySelector(".status").textContent = "Saved.";
        setTimeout(() => (actions.querySelector(".status").textContent = ""), 1200);
      }}, ["Save Idea"]);
    primaryActions.appendChild(saveIdeaBtn);

    const regenBtn = el("button", {type: "button", onclick: async () => {
        await saveIdea(project, s, textarea.value || "");
        if (resultToggleBtn) {
          resultToggleBtn.disabled = true;
          resultToggleBtn.classList.add("is-generating");
          resultToggleBtn.textContent = "Generating…";
        }
        document.getElementById("runHint").textContent = "Regenerating storyboard + running pipeline…";
        const runRes = await apiSend(`/api/storyboard/${encodeURIComponent(project)}/${encodeURIComponent(s)}/regenerate-and-run`, "POST", {
          mode: runParams.mode,
          renderer: runParams.renderer,
        });
        await pollRun(runRes.run.run_id);
        await refreshStepper();
        actions.querySelector(".status").textContent = "Storyboard + pipeline complete.";
        setTimeout(() => (actions.querySelector(".status").textContent = ""), 1800);
        if (resultToggleBtn) {
          resultToggleBtn.disabled = false;
          resultToggleBtn.classList.remove("is-generating");
          resultToggleBtn.textContent = "Show Result";
        }
      }}, ["Regen Storyboard"]);
    primaryActions.appendChild(regenBtn);

    primaryActions.appendChild(
      (resultToggleBtn = el("button", {type: "button", onclick: async (ev) => {
        const btn = ev.currentTarget;
        if (btn.disabled) return;
        const isShowingVideo = resultVideo.style.display !== "none";
        if (!isShowingVideo) {
          const url = `/api/result/${encodeURIComponent(project)}/${encodeURIComponent(s)}?t=${Date.now()}`;
          resultVideo.src = url;
          resultVideo.poster = thumbSrc; // use slide image as the first-frame cue
          resultVideo.preload = "metadata";
          resultVideo.muted = true;
          resultVideo.style.display = "block";
          thumbImg.style.display = "none";
          const onError = () => {
            // Fallback immediately to thumbnail if video cannot be decoded/loaded.
            resultVideo.style.display = "none";
            thumbImg.style.display = "block";
            actions.querySelector(".status").textContent = "Result video load failed.";
            setTimeout(() => (actions.querySelector(".status").textContent = ""), 1800);
          };
          resultVideo.addEventListener("error", onError, {once: true});
          // Jump past intentional black intro so user sees a meaningful frame.
          resultVideo.addEventListener("loadedmetadata", () => {
            const t = Math.min(1.2, Math.max(0, (resultVideo.duration || 2) * 0.08));
            try { resultVideo.currentTime = t; } catch (_) {}
            // Keep it paused on a visible frame; user can press play.
            try { resultVideo.pause(); } catch (_) {}
          }, {once: true});
          btn.textContent = "Show Thumbnail";
        } else {
          resultVideo.pause();
          resultVideo.removeAttribute("src");
          resultVideo.load();
          resultVideo.style.display = "none";
          thumbImg.style.display = "block";
          btn.textContent = "Show Result";
        }
      }}, ["Show Result"])),
    );
    actions.appendChild(el("span", {class: "meta status"}, [""]));

    ideaBox.appendChild(actions);
    right.appendChild(ideaBox);

    card.appendChild(row2);
    const objectsWide = el("div", {class: "objectsWide"}, []);
    renderObjectsPanel(objectsWide, project, s, () => {
      actions.querySelector(".status").textContent = "Objects updated.";
      setTimeout(() => (actions.querySelector(".status").textContent = ""), 1500);
    });
    card.appendChild(objectsWide);
    container.appendChild(card);
  }

  // Wire timeline controls after cards are created to keep adjacent slides in sync on-screen.
  if (SHOW_TIMELINE_UI) {
    const allControls = [];
    const cards = container.querySelectorAll(".slide");
    cards.forEach((card, index) => {
      const inputs = card.querySelectorAll('.captionBox input[type="number"]');
      const badge = card.querySelector(".timeline-badge");
      if (inputs.length >= 2 && badge) {
        const startInput = inputs[0];
        const endInput = inputs[1];
        allControls.push({index, startInput, endInput, badge});
      }
    });
    for (const ctl of allControls) {
      bindTimelineInputs(ctl.index, ctl.startInput, ctl.endInput, ctl.badge, allControls);
    }
  }

  // Always refresh stepper after slide/project data updates.
  await refreshStepper();
}

async function pollRun(runId) {
  const hint = document.getElementById("runHint");
  const log = document.getElementById("runLog");
  for (;;) {
    const data = await apiGet(`/api/runs/${encodeURIComponent(runId)}`);
    hint.textContent = `${data.run.status} (exit=${data.run.exit_code ?? "?"})`;
    log.textContent = data.log || "";
    if (data.run.status === "succeeded" || data.run.status === "failed") return;
    await new Promise((r) => setTimeout(r, 1000));
  }
}

async function runStep(stepName) {
  setActiveStep(stepName);
  const project = document.getElementById("projectSelect").value;
  const slide = document.getElementById("slideSelect").value || null;
  document.getElementById("runHint").textContent = `Running ${stepName}…`;
  const res = await apiSend(`/api/pipeline/step/${encodeURIComponent(stepName)}`, "POST", {
    project_id: project,
    slide,
    mode: runParams.mode,
    renderer: runParams.renderer,
    source_mode: runParams.source_mode,
  });
  await pollRun(res.run.run_id);
}

async function refreshStepper() {
  const project = document.getElementById("projectSelect").value;
  const slide = document.getElementById("slideSelect").value || null;
  const status = await loadPipelineStatus(project, slide);
  renderStepper(status);
}

document.getElementById("runFinalBtn").addEventListener("click", async () => {
  const project = document.getElementById("projectSelect").value;
  const hint = document.getElementById("runHint");
  hint.textContent = "Running…";
  const res = await apiSend("/api/pipeline/run", "POST", {project_id: project, mode: "final", renderer: "hyperframes"});
  await pollRun(res.run.run_id);
});

document.getElementById("stepSplitBtn").addEventListener("click", () => runStep("split"));
document.getElementById("stepConvertBtn").addEventListener("click", () => runStep("convert"));
document.getElementById("stepStoryboardBtn").addEventListener("click", () => runStep("storyboard"));
document.getElementById("stepRenderBtn").addEventListener("click", () => runStep("render"));
document.getElementById("stepCombineBtn").addEventListener("click", () => runStep("combine"));
document.getElementById("stepValidateBtn").addEventListener("click", () => runStep("validate"));

document.getElementById("refreshBtn").addEventListener("click", refreshProjects);
document.getElementById("projectSelect").addEventListener("change", refreshSlides);
document.getElementById("slideSelect").addEventListener("change", async () => {
  await refreshStepper();
  renderStepPanel();
});
refreshProjects().catch((err) => {
  document.getElementById("projectHint").textContent = String(err);
});

// After initial load.
setTimeout(() => refreshStepper().catch(() => {}), 0);
setActiveStep("split");
