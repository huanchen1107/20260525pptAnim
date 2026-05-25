import React, { useState, useEffect, useRef } from 'react';
import { 
  Terminal, Play, ArrowLeft, ArrowRight, RefreshCw, CheckCircle2, AlertTriangle, 
  Settings, HelpCircle, Sparkles, Layers, ListTodo, Trophy, Check, X, Volume2, VolumeX, Eye, BookOpen
} from 'lucide-react';

// ==========================================
// WEB AUDIO SYNTH ENGINE (No external audio files needed!)
// ==========================================
const playSound = (type) => {
  if (typeof window === 'undefined') return;
  try {
    const ctx = new (window.AudioContext || window.webkitAudioContext)();
    const now = ctx.currentTime;

    if (type === 'click') {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'triangle';
      osc.frequency.setValueAtTime(150, now);
      osc.frequency.exponentialRampToValueAtTime(800, now + 0.05);
      gain.gain.setValueAtTime(0.05, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.05);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.06);
    } else if (type === 'scribble') {
      const bufferSize = ctx.sampleRate * 0.12;
      const buffer = ctx.createBuffer(1, bufferSize, ctx.sampleRate);
      const data = buffer.getChannelData(0);
      for (let i = 0; i < bufferSize; i++) {
        data[i] = Math.random() * 2 - 1;
      }
      const noise = ctx.createBufferSource();
      noise.buffer = buffer;
      const filter = ctx.createBiquadFilter();
      filter.type = 'bandpass';
      filter.frequency.value = 1200;
      filter.Q.value = 3;
      const gain = ctx.createGain();
      gain.gain.setValueAtTime(0.03, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.12);
      noise.connect(filter);
      filter.connect(gain);
      gain.connect(ctx.destination);
      noise.start(now);
    } else if (type === 'buzz') {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(110, now);
      osc.frequency.linearRampToValueAtTime(60, now + 0.25);
      gain.gain.setValueAtTime(0.06, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.25);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.26);
    } else if (type === 'chime') {
      const freqs = [523.25, 659.25, 783.99, 1046.50]; // C5, E5, G5, C6
      freqs.forEach((f, i) => {
        const osc = ctx.createOscillator();
        const gain = ctx.createGain();
        osc.type = 'sine';
        osc.frequency.setValueAtTime(f, now + i * 0.08);
        gain.gain.setValueAtTime(0.04, now + i * 0.08);
        gain.gain.exponentialRampToValueAtTime(0.001, now + i * 0.08 + 0.35);
        osc.connect(gain);
        gain.connect(ctx.destination);
        osc.start(now + i * 0.08);
        osc.stop(now + i * 0.08 + 0.4);
      });
    } else if (type === 'laser') {
      const osc = ctx.createOscillator();
      const gain = ctx.createGain();
      osc.type = 'sawtooth';
      osc.frequency.setValueAtTime(800, now);
      osc.frequency.exponentialRampToValueAtTime(150, now + 0.4);
      gain.gain.setValueAtTime(0.04, now);
      gain.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
      osc.connect(gain);
      gain.connect(ctx.destination);
      osc.start(now);
      osc.stop(now + 0.45);
    }
  } catch (e) {
    console.warn("Audio Context init blocked or unsupported:", e);
  }
};

export default function App() {
  const [currentPage, setCurrentPage] = useState(1);
  const [theme, setTheme] = useState('grid'); // 'grid', 'blueprint', 'chalkboard'
  const [soundEnabled, setSoundEnabled] = useState(true);
  
  // Custom states for interactive modules
  const [rejectedFixed, setRejectedFixed] = useState(false);
  const [activeHookLetter, setActiveHookLetter] = useState('A');
  const [activeIntroLetter, setActiveIntroLetter] = useState('G');
  const [battlegroundProgress, setBattlegroundProgress] = useState(30);
  const [swotSelections, setSwotSelections] = useState({
    oldA: true, oldB: false, oldC: true,
    complexA: false, complexB: true, complexC: false,
    recentA: true, recentB: false, recentC: true,
    proposedA: true, proposedB: true, proposedC: true
  });
  const [activeCoreQuadrant, setActiveCoreQuadrant] = useState('Intent');
  const [congruencyScanning, setCongruencyScanning] = useState(false);
  const [congruencyStatus, setCongruencyStatus] = useState('idle'); // idle, scanning, success, failed
  const [convergenceSpeed, setConvergenceSpeed] = useState(50);
  const [checklist, setChecklist] = useState({
    A: true, B: true, C: true, D: false, E: true, F: true,
    G: true, H: true, I: false, J: true, K: true, L: false,
    M: true, N: true, O: false,
    PA: true, PB: true, PC: true, PD: false, PE: true, PF: true, PG: false, PH: true, PI: true, PJ: false, PK: true, PL: true, PM: false,
    Q: true, R: true, S: true, T: false, U: true, V: true,
    W: true, X: true, Y: true, Z: true
  });
  const [buildLogs, setBuildLogs] = useState([]);
  const [compilingState, setCompilingState] = useState('idle'); // idle, compiling, success
  const [compilingProgress, setCompilingProgress] = useState(0);

  // Helper trigger for sounds
  const playSfx = (type) => {
    if (soundEnabled) playSound(type);
  };

  // Nav actions
  const nextPage = () => {
    if (currentPage < 13) {
      setCurrentPage(prev => prev + 1);
      playSfx('click');
    }
  };
  const prevPage = () => {
    if (currentPage > 1) {
      setCurrentPage(prev => prev - 1);
      playSfx('click');
    }
  };
  const selectPage = (num) => {
    setCurrentPage(num);
    playSfx('click');
  };

  // Toggle checklist item
  const toggleChecklistItem = (letter) => {
    setChecklist(prev => {
      const updated = { ...prev, [letter]: !prev[letter] };
      playSfx('scribble');
      return updated;
    });
  };

  // Auto check all checklist
  const autoCheckAll = () => {
    setChecklist(prev => {
      const updated = {};
      Object.keys(prev).forEach(k => { updated[k] = true; });
      playSfx('chime');
      return updated;
    });
  };

  // Calculate total checked score
  const totalLetters = Object.keys(checklist).length;
  const checkedCount = Object.values(checklist).filter(Boolean).length;
  const systemIntegrity = Math.round((checkedCount / totalLetters) * 100);

  // Page 9 scan congruency
  const triggerCongruencyScan = () => {
    setCongruencyScanning(true);
    setCongruencyStatus('scanning');
    playSfx('laser');
    
    setTimeout(() => {
      // Check if both PG and PM are checked in our checklist
      if (checklist.PG && checklist.PM) {
        setCongruencyStatus('success');
        playSfx('chime');
      } else {
        setCongruencyStatus('failed');
        playSfx('buzz');
      }
      setCongruencyScanning(false);
    }, 1500);
  };

  // Trigger compiler sequence on page 13
  const runBuildCompiler = () => {
    setCompilingState('compiling');
    setBuildLogs([]);
    setCompilingProgress(0);
    playSfx('click');

    const logs = [
      "Initializing Academic OS Engine v1.2...",
      "Analyzing Module 1 [A-F] - Hook Engine Integrity: " + (checklist.A && checklist.B && checklist.C ? "PASS" : "WARN"),
      "Analyzing Module 2 [G-L] - Expanding Context Map: OK",
      "Checking Related Literature Matrices [M-O]... Resolved",
      "Validating Proposed Scheme Architecture Core [PA-PM]...",
      "Comparing PG (Graph) with PM (Math Proof) consistency...",
      checklist.PG && checklist.PM ? ">> Congruency OK: Graph perfectly supports Mathematical logic." : ">> SYNTAX ERROR: PG and PM logic conflict detected!",
      "Evaluating Simulation & Experimental Setup [Q-V]... 100% stress compliance.",
      "Synchronizing Output Logs & Future Works [W-Z]...",
      "Building final PDF and compilation bundle...",
      "Status check: " + systemIntegrity + "% overall node synthesis integrity."
    ];

    let currentLogIndex = 0;
    const interval = setInterval(() => {
      if (currentLogIndex < logs.length) {
        setBuildLogs(prev => [...prev, logs[currentLogIndex]]);
        setCompilingProgress(Math.min(Math.round(((currentLogIndex + 1) / logs.length) * 100), 100));
        playSfx('scribble');
        currentLogIndex++;
      } else {
        clearInterval(interval);
        if (systemIntegrity >= 85) {
          setCompilingState('success');
          playSfx('chime');
        } else {
          setCompilingState('failed');
          playSfx('buzz');
        }
      }
    }, 450);
  };

  // Theme definition
  const themeClasses = {
    grid: {
      bg: "bg-[#fbfbf9] text-slate-800",
      gridPattern: "grid-bg-paper",
      card: "bg-white border-slate-800 shadow-[4px_4px_0px_0px_rgba(30,41,59,1)]",
      stampRed: "border-red-500 text-red-500 bg-red-50/70",
      terminal: "bg-slate-900 text-green-400 border-slate-700",
      highlightYellow: "bg-amber-100 border-amber-300 text-amber-900",
      accentBorder: "border-slate-800",
      accentText: "text-blue-600",
      btnPrimary: "bg-blue-600 hover:bg-blue-700 text-white border-slate-800 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]",
      btnSecondary: "bg-amber-100 hover:bg-amber-200 text-slate-800 border-slate-800 shadow-[2px_2px_0px_0px_rgba(0,0,0,1)]",
    },
    blueprint: {
      bg: "bg-[#0b2447] text-blue-100",
      gridPattern: "grid-bg-blueprint",
      card: "bg-[#19376d]/60 border-blue-300 shadow-[4px_4px_0px_0px_rgba(147,197,253,0.8)]",
      stampRed: "border-rose-400 text-rose-400 bg-rose-950/70",
      terminal: "bg-[#071931] text-cyan-300 border-blue-400",
      highlightYellow: "bg-yellow-950/50 border-yellow-500 text-yellow-200",
      accentBorder: "border-blue-300",
      accentText: "text-cyan-400",
      btnPrimary: "bg-cyan-500 hover:bg-cyan-600 text-slate-950 border-blue-200 shadow-[2px_2px_0px_0px_rgba(255,255,255,0.8)]",
      btnSecondary: "bg-blue-900 hover:bg-blue-850 text-cyan-200 border-blue-300 shadow-[2px_2px_0px_0px_rgba(255,255,255,0.8)]",
    },
    chalkboard: {
      bg: "bg-[#1e2522] text-[#e3eade]",
      gridPattern: "grid-bg-chalkboard",
      card: "bg-[#252f2a]/60 border-[#c4d2bf] shadow-[4px_4px_0px_0px_rgba(196,210,191,0.5)]",
      stampRed: "border-red-400 text-red-400 bg-red-950/40",
      terminal: "bg-[#121614] text-yellow-200 border-[#627263]",
      highlightYellow: "bg-[#433b28]/60 border-amber-200 text-amber-200",
      accentBorder: "border-[#c4d2bf]",
      accentText: "text-amber-300",
      btnPrimary: "bg-[#627263] hover:bg-[#728273] text-white border-[#c4d2bf] shadow-[2px_2px_0px_0px_rgba(255,255,255,0.4)]",
      btnSecondary: "bg-[#344038] hover:bg-[#3d4c42] text-amber-200 border-[#c4d2bf] shadow-[2px_2px_0px_0px_rgba(255,255,255,0.4)]",
    }
  }[theme];

  return (
    <div className={`min-h-screen ${themeClasses.bg} ${themeClasses.gridPattern} font-sketch transition-colors duration-500 flex flex-col`}>
      
      {/* ==========================================
          HEADER UTILITIES
          ========================================== */}
      <header className="border-b-4 border-slate-800 px-4 py-3 flex flex-wrap justify-between items-center bg-white/5 backdrop-blur-sm z-10">
        <div className="flex items-center space-x-3">
          <div className="sketch-border bg-amber-400 text-slate-900 px-3 py-1 text-sm font-bold shadow-sm tracking-wide">
            MODULE: TITLE_BLOCK [V1.2]
          </div>
          <span className="text-xs uppercase tracking-widest opacity-80 border-l border-current pl-3 hidden md:inline">
            The Academic Operating System
          </span>
        </div>

        {/* System Dashboard Indicator */}
        <div className="flex items-center space-x-6">
          <div className="flex items-center space-x-2 bg-slate-900/10 px-3 py-1 rounded-md text-xs">
            <span className="relative flex h-2.5 w-2.5">
              <span className={`animate-ping absolute inline-flex h-full w-full rounded-full opacity-75 ${systemIntegrity > 80 ? 'bg-green-400' : 'bg-yellow-400'}`}></span>
              <span className={`relative inline-flex rounded-full h-2.5 w-2.5 ${systemIntegrity > 80 ? 'bg-green-500' : 'bg-yellow-500'}`}></span>
            </span>
            <span className="font-mono">INTEGRITY: {systemIntegrity}%</span>
          </div>

          {/* Theme Controllers */}
          <div className="flex items-center space-x-1 bg-slate-900/20 p-1 rounded-lg">
            <button 
              onClick={() => { setTheme('grid'); playSfx('click'); }} 
              className={`text-xs px-2 py-1 rounded transition ${theme === 'grid' ? 'bg-white text-slate-900 shadow-sm' : 'opacity-70'}`}
            >
              Grid
            </button>
            <button 
              onClick={() => { setTheme('blueprint'); playSfx('click'); }} 
              className={`text-xs px-2 py-1 rounded transition ${theme === 'blueprint' ? 'bg-[#19376d] text-white shadow-sm' : 'opacity-70'}`}
            >
              Blueprint
            </button>
            <button 
              onClick={() => { setTheme('chalkboard'); playSfx('click'); }} 
              className={`text-xs px-2 py-1 rounded transition ${theme === 'chalkboard' ? 'bg-[#344038] text-white shadow-sm' : 'opacity-70'}`}
            >
              Chalk
            </button>
          </div>

          {/* Sound toggle */}
          <button 
            onClick={() => setSoundEnabled(!soundEnabled)} 
            className="p-1 rounded-full hover:bg-slate-500/20 transition text-current"
            title="Toggle Synthesizer SFX"
          >
            {soundEnabled ? <Volume2 size={18} /> : <VolumeX size={18} />}
          </button>
        </div>
      </header>

      {/* ==========================================
          MAIN SLIDE CONTENT AREA
          ========================================== */}
      <main className="flex-1 flex flex-col items-center justify-center p-4 max-w-7xl w-full mx-auto relative">
        
        {/* Dynamic Canvas Container with sketchy styling */}
        <div className={`w-full sketch-border min-h-[580px] p-6 md:p-8 flex flex-col justify-between ${themeClasses.card} transition-all duration-350`}>
          
          {/* Header of the Active Card */}
          <div className="flex justify-between items-center mb-6 border-b-2 border-dashed border-current pb-3">
            <div className="flex items-center space-x-2">
              <span className="font-mono text-xs opacity-75">PAGE {currentPage}/13</span>
              <span className="font-bold text-sm tracking-widest px-2 py-0.5 bg-current text-white mix-blend-difference rounded">
                {currentPage === 1 && "SYSTEM BOOT"}
                {currentPage >= 2 && currentPage <= 3 && "DIAGNOSIS & SYSTEM MAP"}
                {currentPage >= 4 && currentPage <= 11 && `MODULE 0${currentPage - 3} ENGINE`}
                {currentPage === 12 && "AZ DEBUGGER REPORT"}
                {currentPage === 13 && "COMPILATION READY"}
              </span>
            </div>
            <div className="flex space-x-1">
              {Array.from({ length: 13 }).map((_, idx) => (
                <div 
                  key={idx} 
                  onClick={() => selectPage(idx + 1)}
                  className={`w-2 h-2 rounded-full cursor-pointer transition-all duration-300 ${currentPage === idx + 1 ? 'bg-amber-400 scale-150' : 'bg-slate-400 hover:bg-slate-600'}`}
                />
              ))}
            </div>
          </div>

          {/* Slide Switch Board */}
          <div className="flex-1 flex flex-col justify-center">
            {currentPage === 1 && (
              <div className="space-y-6 text-center max-w-3xl mx-auto py-4">
                <div className="inline-block sketch-border bg-amber-400 text-slate-900 px-4 py-2 font-bold rotate-[-1deg] text-lg">
                  // THE ACADEMIC OPERATING SYSTEM
                </div>
                <h1 className="text-4xl md:text-5xl font-black tracking-tight leading-tight mt-2">
                  學術論文寫作全指南
                </h1>
                <p className="text-xl md:text-2xl font-bold text-amber-500">
                  從 A 到 Z 的完美架構與 Debug 偵錯實務
                </p>
                
                <div className="sketch-border p-4 max-w-xl mx-auto bg-white/5 border-2 border-dashed">
                  <p className="text-sm md:text-base leading-relaxed">
                    "論文寫作不是藝術，而是系統工程。掌握 A 到 Z 架構，將你的寫作流程升級為精準的「偵錯模式（Debug Mode）」！"
                  </p>
                </div>

                <div className="flex flex-wrap justify-center gap-4 pt-4">
                  <button 
                    onClick={nextPage}
                    className={`px-6 py-3 font-bold rounded-lg flex items-center space-x-2 text-lg transform hover:scale-105 transition active:scale-95 ${themeClasses.btnPrimary}`}
                  >
                    <span>啟動系統架構偵錯</span>
                    <Play size={18} fill="currentColor" />
                  </button>
                  <button 
                    onClick={autoCheckAll}
                    className={`px-4 py-3 font-bold rounded-lg flex items-center space-x-2 text-sm transform hover:scale-105 transition active:scale-95 ${themeClasses.btnSecondary}`}
                  >
                    <Sparkles size={16} />
                    <span>自動修復預設節點 (綠燈)</span>
                  </button>
                </div>

                <div className="text-xs font-mono opacity-60">
                  SYSTEM STATUS: READY | TYPE: ACADEMIC_ENGINEERING | 2026.05.25
                </div>
              </div>
            )}

            {currentPage === 2 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold text-red-500">為什麼你的論文會被拒絕？</h2>
                  <p className="text-sm opacity-90 mt-1">審稿委員的視角：這不是觀點差異，而是「編譯失敗」。</p>
                </div>

                <div className="grid md:grid-cols-2 gap-6 items-stretch">
                  
                  {/* Left Column: Traditional Pain */}
                  <div className="sketch-border p-5 bg-red-50/5 border-red-400 relative overflow-hidden flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-center mb-2">
                        <span className="font-bold text-red-500 uppercase">THE PAIN [Traditional]</span>
                        <span className="px-2 py-0.5 text-xs bg-red-100 text-red-800 rounded">DEPRECATED</span>
                      </div>
                      <ul className="space-y-2 text-sm leading-relaxed">
                        <li className="flex items-start space-x-2">
                          <span className="text-red-500 mt-0.5">✗</span>
                          <span><strong>盲目落筆：</strong>沒有釐清各章節關鍵銜接點。</span>
                        </li>
                        <li className="flex items-start space-x-2">
                          <span className="text-red-500 mt-0.5">✗</span>
                          <span><strong>邏輯發散：</strong>前言與結論頭尾無法呼應。</span>
                        </li>
                        <li className="flex items-start space-x-2">
                          <span className="text-red-500 mt-0.5">✗</span>
                          <span><strong>自說自話：</strong>圖表系統、程式碼、公式缺乏互驗。</span>
                        </li>
                      </ul>
                    </div>

                    <div className="mt-6 flex flex-col items-center">
                      <div className={`transform -rotate-12 sketch-border border-4 px-6 py-2 text-3xl font-black uppercase tracking-wider transition duration-300 ${rejectedFixed ? 'line-through opacity-30 border-gray-400 text-gray-400' : 'border-red-500 text-red-500'}`}>
                        REJECTED
                      </div>
                      {!rejectedFixed ? (
                        <button 
                          onClick={() => { setRejectedFixed(true); playSfx('chime'); }}
                          className="mt-4 text-xs px-3 py-1 bg-amber-400 text-slate-900 rounded font-bold hover:bg-amber-300 transition"
                        >
                          ✔ 按此導入 Debug Mode 覆蓋審查機制
                        </button>
                      ) : (
                        <span className="text-xs text-green-500 mt-3 font-mono">DEBUG MODE COMPILATION DEPLOYED!</span>
                      )}
                    </div>
                  </div>

                  {/* Right Column: Terminal Diagnosis */}
                  <div className="sketch-border p-5 flex flex-col justify-between bg-slate-900 text-green-400 border-slate-700 font-mono">
                    <div>
                      <div className="flex justify-between items-center border-b border-green-800 pb-2 mb-3 text-xs">
                        <div className="flex items-center space-x-2">
                          <span className="w-3 h-3 rounded-full bg-red-500 inline-block animate-pulse"></span>
                          <span>DIAGNOSTIC TERMINAL v2.0 - CRITICAL</span>
                        </div>
                        <span>[SYS_ERR: 3]</span>
                      </div>
                      <div className="space-y-4 text-xs md:text-sm">
                        <div className="p-2 bg-red-950/40 border border-red-800 rounded">
                          <p className="text-red-400 font-bold flex items-center space-x-1">
                            <AlertTriangle size={14} /> <span>Error 404: Motivation Not Found [Module A]</span>
                          </p>
                          <p className="opacity-70 mt-0.5">摘要前三句不夠引人注意，挑戰不明確。</p>
                        </div>
                        <div className="p-2 bg-yellow-950/40 border border-yellow-800 rounded">
                          <p className="text-yellow-400 font-bold flex items-center space-x-1">
                            <AlertTriangle size={14} /> <span>Syntax Error: Graph (PG) does not match Math (PM)</span>
                          </p>
                          <p className="opacity-70 mt-0.5">系統架構圖畫的模組與公式參數命名不一致。</p>
                        </div>
                        <div className="p-2 bg-red-950/40 border border-red-800 rounded">
                          <p className="text-red-400 font-bold flex items-center space-x-1">
                            <AlertTriangle size={14} /> <span>Warning: Weak SOTA Comparison [Module R]</span>
                          </p>
                          <p className="opacity-70 mt-0.5">沒有將自己提出方案的強大數據在比較矩陣中突顯。</p>
                        </div>
                      </div>
                    </div>

                    <div className="mt-4 border-t border-green-800 pt-3 text-[10px] opacity-75">
                      SYSTEM_LOG: COMPILATION FAILED. PLEASE REVIEW MODULES A, PH, AND R FOR DEBUGGING.
                    </div>
                  </div>

                </div>
              </div>
            )}

            {currentPage === 3 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">System Architecture: 六大核心編譯模組</h2>
                  <p className="text-sm opacity-90">每一份完美的論文，都能無縫對應這 26 個邏輯字母。點擊任何模組探索詳情！</p>
                </div>

                {/* 6 Modules Row Grid */}
                <div className="grid grid-cols-2 lg:grid-cols-6 gap-4">
                  {[
                    { title: "[A-F] 摘要與動機", sub: "The Hook Engine", desc: "確立故事起點與核心創見。", pg: 4 },
                    { title: "[G-L] 簡介", sub: "Expanding Context", desc: "引導讀者走入完整的背景體系。", pg: 5 },
                    { title: "[M-O] 相關研究", sub: "Battleground Matrix", desc: "建立結構化比較表狠擊痛點。", pg: 6 },
                    { title: "[PA-PM] 提出方法", sub: "The Core Engine", desc: "系統架構、演算法與數學證明。", pg: 8 },
                    { title: "[Q-V] 模擬與實驗", sub: "The Stress Test", desc: "利用定性定量數據碾壓對手。", pg: 10 },
                    { title: "[W-Z] 結論與未來", sub: "The Output Log", desc: "完美呼應開頭，展望終極禪境。", pg: 11 },
                  ].map((mod, i) => (
                    <div 
                      key={i}
                      onClick={() => selectPage(mod.pg)}
                      className="sketch-border p-4 bg-white/5 border-2 hover:border-amber-400 hover:scale-[1.03] transition-all cursor-pointer flex flex-col justify-between text-center relative group"
                    >
                      <div className="absolute top-1 right-1 text-[10px] font-mono opacity-40">M0{i+1}</div>
                      <div>
                        <h3 className="font-bold text-sm md:text-base text-current group-hover:text-amber-500 transition">{mod.title}</h3>
                        <p className="text-xs italic opacity-85 mt-1 font-mono">{mod.sub}</p>
                      </div>
                      <p className="text-xs mt-3 opacity-70 leading-relaxed">{mod.desc}</p>
                      <div className="mt-4 text-[10px] bg-slate-900/10 px-1 py-0.5 rounded font-bold uppercase">Explore →</div>
                    </div>
                  ))}
                </div>

                {/* Interactive Connector Line Drawing (SVG) */}
                <div className="hidden lg:block relative h-10 w-full">
                  <svg className="absolute inset-0 w-full h-full stroke-current opacity-65" fill="none">
                    <path d="M 50 20 Q 300 35, 1100 20" strokeWidth="2.5" strokeDasharray="6,6" />
                    <path d="M 1100 20 L 1090 15 M 1100 20 L 1090 25" strokeWidth="2.5" />
                  </svg>
                  <div className="absolute left-1/2 -translate-x-1/2 bg-amber-400 text-slate-900 px-3 py-0.5 text-xs font-bold rounded shadow-sm">
                    編譯數據流 (Data Compilation Flow)
                  </div>
                </div>

                <div className="text-center text-xs opacity-70">
                  <span className="font-mono bg-slate-500/10 px-2 py-1 rounded">
                    code_comment: 完美的論文不是寫出來的，而是當所有核心編譯模組皆為 Pass 狀態時「編譯」而成的系統工程。
                  </span>
                </div>
              </div>
            )}

            {currentPage === 4 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 1] The Hook Engine: 摘要與動機 (Abstract)</h2>
                  <p className="text-sm opacity-90">摘要是你的學術門面。以下 6 大節點必須缺一不可，環環相扣：</p>
                </div>

                {/* Interactive Abstract Blocks */}
                <div className="grid grid-cols-2 md:grid-cols-6 gap-3">
                  {[
                    { char: 'A', name: 'Attention Getter', sub: '引人注意', desc: '有趣的開場，帶出你研究領域的大方向與重要性。', status: checklist.A },
                    { char: 'B', name: 'But (However)', sub: '界定挑戰', desc: '轉折！目前學術界面臨的特定瓶頸。', status: checklist.B },
                    { char: 'C', name: 'Cure', sub: '提出解法', desc: '你的解決方案。一針見血，你提出了什麼？', status: checklist.C },
                    { char: 'D', name: 'Development', sub: '方法設計', desc: '你的方法架構與核心開發邏輯是什麼？', status: checklist.D },
                    { char: 'E', name: 'Experiments', sub: '實驗評估', desc: '你做了什麼實驗，模擬了哪些場景？', status: checklist.E },
                    { char: 'F', name: 'Findings', sub: '關鍵發現', desc: '最猛的改進數據！比如提昇了 40% 的效能。', status: checklist.F }
                  ].map((node) => (
                    <div 
                      key={node.char}
                      onClick={() => { setActiveHookLetter(node.char); playSfx('click'); }}
                      className={`sketch-border p-3 text-center cursor-pointer transition ${activeHookLetter === node.char ? 'border-amber-400 bg-amber-400/10 scale-105' : 'bg-white/5 border-current'}`}
                    >
                      <div className="flex justify-between items-center mb-1">
                        <span className={`w-5 h-5 rounded-full flex items-center justify-center text-xs font-bold ${node.status ? 'bg-green-500 text-white' : 'bg-slate-400 text-slate-900'}`}>
                          {node.status ? '✔' : '?'}
                        </span>
                        <span className="font-mono font-bold text-xs">M1.{node.char}</span>
                      </div>
                      <div className="text-2xl font-black">{node.char}</div>
                      <div className="text-xs font-bold truncate">{node.name}</div>
                    </div>
                  ))}
                </div>

                {/* Detailed display area */}
                <div className="sketch-border p-5 bg-white/5 border-current relative">
                  <div className="absolute top-2 right-2 text-xs font-mono opacity-50">Node Inspector</div>
                  <h3 className="text-lg font-bold flex items-center space-x-2">
                    <span className="text-2xl font-black text-amber-500">[{activeHookLetter}]</span>
                    <span>
                      {activeHookLetter === 'A' && 'Attention Getter (引人注意)'}
                      {activeHookLetter === 'B' && 'But / However (界定挑戰)'}
                      {activeHookLetter === 'C' && 'Cure (提出解法)'}
                      {activeHookLetter === 'D' && 'Development (方法設計)'}
                      {activeHookLetter === 'E' && 'Experiments (實驗評估)'}
                      {activeHookLetter === 'F' && 'Findings (關鍵發現)'}
                    </span>
                  </h3>
                  <p className="mt-3 text-sm leading-relaxed">
                    {activeHookLetter === 'A' && '在摘要的前三句話中，必須清楚定義主題。必須同時具備「有趣、重要、創新」三大核心。不可直接講枯燥公式，要拉高視野講趨勢。'}
                    {activeHookLetter === 'B' && '這是最關鍵的一步。如果沒有清晰的「But」，代表這篇論文沒有研究動機。你需要精確提煉出前人工作的缺陷：如複雜度太高、缺乏彈性、或是不適用於高密度場景。'}
                    {activeHookLetter === 'C' && '直接丟出你的專案名稱。描述你的方法基本工作原理。一句話解釋：「我們在此提出了一個基於 xxx 的新型機制，能完美克服前述問題。」'}
                    {activeHookLetter === 'D' && '講述你用了什麼技術路線來具體開發。不需要講到具體程式，而是設計理念、核心策略以及具備的獨特定理。'}
                    {activeHookLetter === 'E' && '講述你的驗證框架。例：「我們透過大規模模擬與真實場景數據集，測試了多種流量分佈模型，以此評估系統抗壓性。」'}
                    {activeHookLetter === 'F' && '用最具震撼力的數據做為總結。別含糊其詞！「實驗表明，所提方案在傳輸延遲上比傳統 SOTA 降低了 35%，吞吐量提昇 1.5 倍。」'}
                  </p>
                  
                  <div className="mt-4 flex items-center justify-between">
                    <button 
                      onClick={() => toggleChecklistItem(activeHookLetter)}
                      className={`px-3 py-1 text-xs font-bold rounded transition flex items-center space-x-1 border ${checklist[activeHookLetter] ? 'bg-green-100 text-green-800 border-green-300' : 'bg-red-100 text-red-800 border-red-300'}`}
                    >
                      <span>狀態: {checklist[activeHookLetter] ? '亮綠燈 (PASS)' : '待修復 (WARN)'}</span>
                    </button>
                    <span className="text-xs italic opacity-75">提示：點擊按鈕手動修復本節點</span>
                  </div>
                </div>

                {/* Highlight/Alert Area */}
                <div className={`p-4 rounded-lg sketch-border flex items-start space-x-3 ${themeClasses.highlightYellow}`}>
                  <AlertTriangle className="flex-shrink-0 mt-0.5" />
                  <div>
                    <strong className="block text-sm">Debug Mode Alert:</strong>
                    <p className="text-xs leading-relaxed mt-1">
                      [Debug Focus] 摘要的 <strong>But</strong> 是審稿委員開箱時最愛看的地方。如果你的 Cure 不能 100% 精準對應你的 But 提出的痛點，論文編譯就會在這裡死機，審稿委員會立即給予 rejected。
                    </p>
                  </div>
                </div>
              </div>
            )}

            {currentPage === 5 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 2] Background Process: 簡介 (Introduction)</h2>
                  <p className="text-sm opacity-90">簡介是摘要 [A-F] 重點的詳細延伸與長篇幅解釋，為讀者構建背景知識地圖：</p>
                </div>

                <div className="grid md:grid-cols-3 gap-6 items-stretch">
                  
                  {/* Left Column: Interactive Diagram Block */}
                  <div className="sketch-border p-4 bg-white/5 md:col-span-1 flex flex-col justify-between">
                    <div>
                      <h4 className="font-bold text-xs uppercase mb-3 text-current">數據擴展流程</h4>
                      <p className="text-xs leading-relaxed mb-4">簡介是由摘要中 <strong>[B]</strong> 的痛點，發散拓展開來：</p>
                    </div>

                    <div className="space-y-2 font-mono">
                      <div className="flex items-center space-x-2">
                        <div className="w-8 h-8 rounded-full border-2 border-dashed border-current flex items-center justify-center font-bold text-sm">B</div>
                        <div className="text-xs">BUT (摘要痛點)</div>
                      </div>
                      <div className="text-center text-sm py-1">⬇ 延伸為 ⬇</div>
                      <div className="space-y-1 text-xs">
                        {['G', 'H', 'I', 'J', 'K', 'L'].map(l => (
                          <div 
                            key={l}
                            onClick={() => { setActiveIntroLetter(l); playSfx('click'); }}
                            className={`p-1 border rounded flex justify-between cursor-pointer ${activeIntroLetter === l ? 'border-amber-400 bg-amber-400/20' : 'border-current'}`}
                          >
                            <span>[{l}] {l === 'G' && 'General'} {l === 'H' && 'However'} {l === 'I' && 'In Literature'} {l === 'J' && 'Judgement'} {l === 'K' && 'Keypoint'} {l === 'L' && 'List'}</span>
                            <span className={checklist[l] ? 'text-green-500' : 'text-slate-400'}>{checklist[l] ? '✔' : '?'}</span>
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                  {/* Right Column: Node Details Inspector */}
                  <div className="sketch-border p-5 md:col-span-2 bg-white/5 border-current flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-center mb-3">
                        <span className="font-bold text-xs uppercase tracking-wider text-amber-500">Node Detailed Specification</span>
                        <span className="text-xs font-mono">M2.{activeIntroLetter}</span>
                      </div>
                      
                      <h3 className="text-xl font-bold mb-3">
                        {activeIntroLetter === 'G' && '[G] General: 現況與背景'}
                        {activeIntroLetter === 'H' && '[H] However: 面臨的挑戰'}
                        {activeIntroLetter === 'I' && '[I] In Literature: 文獻分類'}
                        {activeIntroLetter === 'J' && '[J] Judgement: 優缺點評論'}
                        {activeIntroLetter === 'K' && '[K] Keypoint: 重申亮點'}
                        {activeIntroLetter === 'L' && '[L] List: 結構安排'}
                      </h3>

                      <p className="text-sm leading-relaxed">
                        {activeIntroLetter === 'G' && '深入分析整個學術領域的大趨勢與背景。必須交代目前關鍵的爆發性成長技術是什麼，好比機器學習或邊緣運算，以此作為整篇論文開頭。'}
                        {activeIntroLetter === 'H' && '這部分是摘要 [B] 的詳細加強版。你要花上兩至三段的篇幅，非常仔細地界定目前遇到什麼難題，為什麼舊有技術無法在極端或特定物理情況下生存？'}
                        {activeIntroLetter === 'I' && '對文獻進行分類：從舊到新、簡單到複雜、一維到多維。引導讀者了解前人是如何演進解法的，展示你博大精深的學術研究底蘊。'}
                        {activeIntroLetter === 'J' && '不要只是列舉文獻！你要對這些前人工作做出極度客觀但深刻的 SWOT 評論：批判他們的盲點（例如：雖然算力低但精度很差）。為你的方法埋下爆發伏筆。'}
                        {activeIntroLetter === 'K' && '重申你的設計精神、核心亮點與 Novelty！用最自信的詞彙：我們首創了、我們突破了...。亮出主要的貢獻清單。'}
                        {activeIntroLetter === 'L' && '簡潔交代接下來的文章結構。例：「本篇其餘部分的結構安排如下：第二章為相關工作；第三章為系統設計...」這為讀者建立了清晰的導航地圖。'}
                      </p>
                    </div>

                    <div className="mt-6 pt-4 border-t border-dashed border-current flex items-center justify-between">
                      <button 
                        onClick={() => toggleChecklistItem(activeIntroLetter)}
                        className={`px-4 py-1.5 rounded text-xs font-bold transition flex items-center space-x-1 ${checklist[activeIntroLetter] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}
                      >
                        <span>修復本節點: {checklist[activeIntroLetter] ? '綠燈 (PASS)' : '紅燈 (WARN)'}</span>
                      </button>
                      <span className="text-xs italic opacity-75">
                        [Debug Focus] (G)與(H)有清晰的分野嗎？(L)導航地圖是否完整？
                      </span>
                    </div>
                  </div>

                </div>
              </div>
            )}

            {currentPage === 6 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 3] The Battleground: 相關研究 (Related Work)</h2>
                  <p className="text-sm opacity-90">不要把這裡寫成流水帳。這裡是你的「學術戰場」，要在這裡把前人痛扁，來凸顯自身強大優勢！</p>
                </div>

                <div className="grid md:grid-cols-3 gap-6 items-stretch">
                  
                  {/* Cards describing M, N, O */}
                  {[
                    { 
                      letter: 'M', 
                      title: 'Methods (技術演進與分類)', 
                      desc: '將過去方法做大分類，描述一條清晰的技術演進軌跡。展示舊屬性到新屬性的過渡，比如最經典的 $CNN \to LSTM \to Autoencoder$ 技術軌跡演化。',
                      tip: '將混亂的文獻歸併在 2-3 個大類中。',
                      status: checklist.M
                    },
                    { 
                      letter: 'N', 
                      title: 'New Proposed (新方法的優勢)', 
                      desc: '點出最新趨勢與你的新創見。明確指出你的方法是如何在前輩們的骨灰盒上，成功戰勝並彌補舊有方法的遺憾。',
                      tip: '「審判（Judgement）」前人，絕非只是「列舉」前人！',
                      status: checklist.N
                    },
                    { 
                      letter: 'O', 
                      title: 'Organize (圖表統整比較)', 
                      desc: '基於之前的優缺點評論，將其歸納為結構化的比較矩陣。這張比較表格將會是整篇相關研究的靈魂，也是審稿人最看重的地方！',
                      tip: '也就是我們下一頁即將呈現的 O-Organize 儀表板。',
                      status: checklist.O
                    }
                  ].map((item) => (
                    <div 
                      key={item.letter}
                      className="sketch-border p-5 bg-white/5 border-current flex flex-col justify-between"
                    >
                      <div>
                        <div className="flex justify-between items-center mb-2">
                          <span className="text-2xl font-black text-amber-500">[{item.letter}]</span>
                          <button 
                            onClick={() => toggleChecklistItem(item.letter)}
                            className={`w-5 h-5 rounded-full flex items-center justify-center text-xs font-bold ${item.status ? 'bg-green-500 text-white' : 'bg-red-500 text-white'}`}
                          >
                            {item.status ? '✔' : '!'}
                          </button>
                        </div>
                        <h3 className="font-bold text-base leading-tight mb-2">{item.title}</h3>
                        <p className="text-xs leading-relaxed opacity-90">{item.desc}</p>
                      </div>

                      <div className="mt-4 p-2 bg-slate-900/10 border border-dashed rounded text-xs">
                        <strong className="block text-[10px] uppercase">Battle Plan:</strong>
                        <p className="opacity-80 mt-0.5">{item.tip}</p>
                      </div>
                    </div>
                  ))}
                </div>

                {/* Simulated interactive sliders for battlefield strength */}
                <div className="sketch-border p-4 bg-white/5">
                  <div className="flex justify-between items-center mb-2">
                    <span className="text-sm font-bold">互動戰鬥力評估：你的新方案 N 戰勝舊方法 M 的比例</span>
                    <span className="text-sm font-mono font-black text-amber-500">{battlegroundProgress}% Superiority</span>
                  </div>
                  <input 
                    type="range" 
                    min="10" 
                    max="100" 
                    value={battlegroundProgress} 
                    onChange={(e) => { setBattlegroundProgress(e.target.value); playSfx('scribble'); }}
                    className="w-full accent-amber-500"
                  />
                  <div className="flex justify-between text-[10px] mt-1 opacity-70">
                    <span>微弱改進 (容易退稿)</span>
                    <span>結構性改進 (推薦發表)</span>
                    <span>降維打擊、全面碾壓 (SOTA!)</span>
                  </div>
                </div>
              </div>
            )}

            {currentPage === 7 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Diagnostic View] The O-Organize Dashboard</h2>
                  <p className="text-sm opacity-90">用 SWOT 表格將先前文章中的評論進行「視覺化」，一秒證明你完勝所有舊方法！</p>
                </div>

                {/* Interactive Grid Table mimicking Excalidraw sketch sheet */}
                <div className="sketch-border overflow-hidden bg-white/5 border-current">
                  <table className="w-full text-left text-xs md:text-sm border-collapse">
                    <thead>
                      <tr className="border-b-2 border-current bg-slate-900/10 font-bold">
                        <th className="p-3 border-r border-current">技術方法 / 特徵指標</th>
                        <th className="p-3 border-r border-current text-center">特徵提取與感知</th>
                        <th className="p-3 border-r border-current text-center">高效算力/低延迟</th>
                        <th className="p-3 border-r border-current text-center">極低資料需求</th>
                        <th className="p-3 text-center">收斂與抗壓穩定性</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-current">
                      <tr>
                        <td className="p-3 font-bold border-r border-current bg-slate-900/5">Method A - Old (經典老方案)</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 border-r border-current text-center text-green-500 font-bold">✔</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 text-center text-red-500 font-bold">✗</td>
                      </tr>
                      <tr>
                        <td className="p-3 font-bold border-r border-current bg-slate-900/5">Method B - Complex (複雜高算力)</td>
                        <td className="p-3 border-r border-current text-center text-green-500 font-bold">✔</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 text-center text-red-500 font-bold">✗</td>
                      </tr>
                      <tr>
                        <td className="p-3 font-bold border-r border-current bg-slate-900/5">Method C - Recent (近期改進版)</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 border-r border-current text-center text-red-500 font-bold">✗</td>
                        <td className="p-3 border-r border-current text-center text-green-500 font-bold">✔</td>
                        <td className="p-3 text-center text-green-500 font-bold">✔</td>
                      </tr>
                      {/* Highlighted Proposed Row */}
                      <tr className="bg-amber-400/20 font-bold border-t-2 border-dashed">
                        <td className="p-3 border-r border-current text-amber-500">Proposed Scheme - N (你的新方案)</td>
                        <td className="p-3 border-r border-current text-center text-green-500 text-lg">✔</td>
                        <td className="p-3 border-r border-current text-center text-green-500 text-lg">✔</td>
                        <td className="p-3 border-r border-current text-center text-green-500 text-lg">✔</td>
                        <td className="p-3 text-center text-green-500 text-lg">✔</td>
                      </tr>
                    </tbody>
                  </table>
                </div>

                <div className="sketch-border p-4 bg-white/5 text-xs flex flex-col md:flex-row justify-between items-center gap-3">
                  <div>
                    <strong>偵錯實務：</strong> 審稿人最愛看這張表！必須在第二章結尾丟出這張表，讓審稿人快速理解你的 Novelty 點在哪裡，避免他帶著盲目的質疑繼續讀下去。
                  </div>
                  <button 
                    onClick={() => { toggleChecklistItem('O'); }}
                    className={`px-4 py-2 font-bold rounded flex-shrink-0 transition flex items-center space-x-1 ${checklist.O ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}
                  >
                    <span>比較表 [O] 狀態: {checklist.O ? '綠燈 PASS' : '點此修復'}</span>
                  </button>
                </div>
              </div>
            )}

            {currentPage === 8 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 4] The Core Architecture: 提出方法與系統 (Proposed Scheme)</h2>
                  <p className="text-sm opacity-90">論文的心臟。從設計思想到數學證明，利用四大維度拆解：</p>
                </div>

                {/* Quad-Split Interactivity Panel */}
                <div className="grid md:grid-cols-4 gap-4">
                  {[
                    { 
                      id: 'Intent', 
                      title: '1. Intent (目標與背景)', 
                      letters: 'PA, PB, PC', 
                      desc: 'Aim (確立目標)、Background (背景基礎)、Cure (解法原理)。建立此方案研發的出發點。' 
                    },
                    { 
                      id: 'Design', 
                      title: '2. Design (架構拆解)', 
                      letters: 'PD, PE, PF', 
                      desc: 'Design (架構設計)、Paper Element (系統重要元素)、Foundation (元素功能)。全面拆解系統拼圖。' 
                    },
                    { 
                      id: 'Mechanics', 
                      title: '3. Mechanics (互動實作)', 
                      letters: 'PG, PH, PI', 
                      desc: 'Graph (架構圖)、How (如何達成目標)、Implementation (元素互動與流程實作)。' 
                    },
                    { 
                      id: 'Proof', 
                      title: '4. Proof (驗證與貢獻)', 
                      letters: 'PJ, PK, PL, PM', 
                      desc: 'Jump to Example (範例)、Key Points (重申貢獻)、Later (模擬預告)、Math Proof (數學證明)。' 
                    }
                  ].map((quad) => (
                    <div 
                      key={quad.id}
                      onClick={() => { setActiveCoreQuadrant(quad.id); playSfx('click'); }}
                      className={`sketch-border p-4 cursor-pointer transition flex flex-col justify-between ${activeCoreQuadrant === quad.id ? 'border-amber-400 bg-amber-400/10 scale-102' : 'bg-white/5 border-current'}`}
                    >
                      <div>
                        <div className="flex justify-between items-center mb-1">
                          <span className="text-xs font-mono font-bold opacity-75">{quad.letters}</span>
                          {activeCoreQuadrant === quad.id && <span className="w-2 h-2 rounded-full bg-amber-500 inline-block animate-ping"></span>}
                        </div>
                        <h4 className="font-bold text-sm text-current">{quad.title}</h4>
                        <p className="text-xs opacity-85 mt-2 leading-relaxed">{quad.desc}</p>
                      </div>
                      <div className="mt-3 text-[10px] text-right font-mono italic">Expand Module Panel </div>
                    </div>
                  ))}
                </div>

                {/* Display Specific Selected Quadrant */}
                <div className="sketch-border p-5 bg-white/5">
                  <h3 className="font-bold text-base border-b border-dashed pb-2 mb-3">
                    Quadrant Inspector: {activeCoreQuadrant === 'Intent' && '目標與背景深度解析 [PA - PC]'}
                    {activeCoreQuadrant === 'Design' && '架構拆解與模組設計 [PD - PF]'}
                    {activeCoreQuadrant === 'Mechanics' && '交互運作與虛擬碼實作 [PG - PI]'}
                    {activeCoreQuadrant === 'Proof' && '嚴謹證明與實用貢獻 [PJ - PM]'}
                  </h3>

                  <div className="text-sm space-y-3">
                    {activeCoreQuadrant === 'Intent' && (
                      <div>
                        <p className="leading-relaxed"><strong>PA (Aim):</strong> 首段必須宣告終極設計目標；<strong>PB (Background):</strong> 交代你採用的物理基礎理論與公式背景；<strong>PC (Cure):</strong> 一句話核心，如何利用這些基礎完美推導出你宣告的解法。</p>
                        <div className="mt-3 flex gap-2 flex-wrap">
                          {['PA', 'PB', 'PC'].map(l => (
                            <button key={l} onClick={() => toggleChecklistItem(l)} className={`px-2 py-0.5 rounded text-xs border ${checklist[l] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{l}: {checklist[l] ? 'OK' : 'FIX'}</button>
                          ))}
                        </div>
                      </div>
                    )}
                    {activeCoreQuadrant === 'Design' && (
                      <div>
                        <p className="leading-relaxed"><strong>PD (Design):</strong> 全局系統部署框線設計，切勿混亂；<strong>PE (Paper Element):</strong> 系統中至關重要的 3-4 個關鍵元件（組件）；<strong>PF (Foundation):</strong> 每個元件分別起到什麼核心功能，不可存在冗餘零件。</p>
                        <div className="mt-3 flex gap-2 flex-wrap">
                          {['PD', 'PE', 'PF'].map(l => (
                            <button key={l} onClick={() => toggleChecklistItem(l)} className={`px-2 py-0.5 rounded text-xs border ${checklist[l] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{l}: {checklist[l] ? 'OK' : 'FIX'}</button>
                          ))}
                        </div>
                      </div>
                    )}
                    {activeCoreQuadrant === 'Mechanics' && (
                      <div>
                        <p className="leading-relaxed"><strong>PG (Graph):</strong> 全文之魂。一張精美的二維系統拓撲互動圖，是整篇文章審稿人停留最久的地方；<strong>PH (How):</strong> 逐步講述資料包如何在這張拓撲圖中流動；<strong>PI (Implementation):</strong> 用結構精緻的虛擬碼（Algorithm 偽代碼）實作其內部流控。</p>
                        <div className="mt-3 flex gap-2 flex-wrap">
                          {['PG', 'PH', 'PI'].map(l => (
                            <button key={l} onClick={() => toggleChecklistItem(l)} className={`px-2 py-0.5 rounded text-xs border ${checklist[l] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{l}: {checklist[l] ? 'OK' : 'FIX'}</button>
                          ))}
                        </div>
                      </div>
                    )}
                    {activeCoreQuadrant === 'Proof' && (
                      <div>
                        <p className="leading-relaxed"><strong>PJ (Example):</strong> 對複雜模組舉一個玩具實例，讓讀者迅速代入；<strong>PK (Key Points):</strong> 總結此部分技術改進的理論貢獻；<strong>PL (Later):</strong> 埋下伏筆，交代「在第五章中，我們將會對上述模組進行強力的模擬驗證」；<strong>PM (Math Proof):</strong> 用極其強大的理論及多個核心公式為系統提供無懈可擊的嚴格數學定理證明。</p>
                        <div className="mt-3 flex gap-2 flex-wrap">
                          {['PJ', 'PK', 'PL', 'PM'].map(l => (
                            <button key={l} onClick={() => toggleChecklistItem(l)} className={`px-2 py-0.5 rounded text-xs border ${checklist[l] ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'}`}>{l}: {checklist[l] ? 'OK' : 'FIX'}</button>
                          ))}
                        </div>
                      </div>
                    )}
                  </div>
                </div>
              </div>
            )}

            {currentPage === 9 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Debugger Mode] 系統架構的連貫性偵錯</h2>
                  <p className="text-sm opacity-90">論文中的重大致命傷：架構圖畫了一套、虛擬碼寫了另一套、而數學證明則完全無關！</p>
                </div>

                <div className="grid md:grid-cols-2 gap-6 items-stretch">
                  
                  {/* Left Column: Triangle congruence diagram */}
                  <div className="sketch-border p-6 bg-white/5 border-current flex flex-col justify-between text-center relative overflow-hidden">
                    <span className="absolute top-2 left-2 text-[10px] font-mono opacity-60">SystemCongruenceScanner.sys</span>
                    
                    {/* The Triangle Graphic */}
                    <div className="relative w-64 h-64 mx-auto my-4">
                      {/* Triangle background lines */}
                      <svg className="absolute inset-0 w-full h-full stroke-current opacity-70" viewBox="0 0 256 256" fill="none">
                        <polygon points="128,30 30,190 226,190" strokeWidth="3" />
                        
                        {/* Laser scan effect overlay */}
                        {congruencyScanning && (
                          <line x1="20" y1={Math.sin(Date.now()/200)*80 + 110} x2="236" y2={Math.sin(Date.now()/200)*80 + 110} stroke="#f59e0b" strokeWidth="4" className="animate-pulse" />
                        )}
                      </svg>

                      {/* Vertex 1: PG */}
                      <div 
                        onClick={() => toggleChecklistItem('PG')} 
                        className={`absolute -top-4 left-1/2 -translate-x-1/2 px-3 py-1 bg-slate-900 border-2 rounded text-xs cursor-pointer ${checklist.PG ? 'border-green-500 text-green-400' : 'border-red-500 text-red-400'}`}
                      >
                        PG (Graph 架構圖) <br/> {checklist.PG ? '🟢 PASS' : '🔴 WARN'}
                      </div>

                      {/* Vertex 2: PI */}
                      <div 
                        onClick={() => toggleChecklistItem('PI')} 
                        className={`absolute -bottom-2 -left-8 px-3 py-1 bg-slate-900 border-2 rounded text-xs cursor-pointer ${checklist.PI ? 'border-green-500 text-green-400' : 'border-red-500 text-red-400'}`}
                      >
                        PI (Implementation 實作) <br/> {checklist.PI ? '🟢 PASS' : '🔴 WARN'}
                      </div>

                      {/* Vertex 3: PM */}
                      <div 
                        onClick={() => toggleChecklistItem('PM')} 
                        className={`absolute -bottom-2 -right-8 px-3 py-1 bg-slate-900 border-2 rounded text-xs cursor-pointer ${checklist.PM ? 'border-green-500 text-green-400' : 'border-red-500 text-red-400'}`}
                      >
                        PM (Math 數學證明) <br/> {checklist.PM ? '🟢 PASS' : '🔴 WARN'}
                      </div>
                    </div>

                    <div className="space-y-2">
                      <button 
                        onClick={triggerCongruencyScan}
                        disabled={congruencyScanning}
                        className={`w-full py-2 font-bold rounded flex items-center justify-center space-x-2 ${themeClasses.btnPrimary}`}
                      >
                        <RefreshCw size={16} className={congruencyScanning ? 'animate-spin' : ''} />
                        <span>{congruencyScanning ? '正在編譯比對邏輯...' : '執行一致性安全掃描'}</span>
                      </button>
                    </div>
                  </div>

                  {/* Right Column: Scan Report */}
                  <div className="sketch-border p-5 flex flex-col justify-between bg-slate-900 text-green-400 border-slate-700 font-mono text-xs leading-relaxed">
                    <div>
                      <div className="border-b border-green-800 pb-2 mb-3 flex justify-between items-center">
                        <span className="font-bold flex items-center space-x-1">
                          <Terminal size={14} /> <span>CONGRUENCY SCANNER LOG</span>
                        </span>
                        <span className="text-[10px] opacity-70">A-Z FRAMEWORK INC.</span>
                      </div>
                      
                      <div className="space-y-2">
                        <p>[Scan 1] 你的架構圖（PG）中繪製的每一個元件組件，是否都在演算法虛擬碼實作（PI）中有明確對應的處理迴圈與判斷式？</p>
                        <p className={checklist.PG && checklist.PI ? 'text-green-400' : 'text-yellow-400'}>
                          &gt;&gt; PG ↔ PI Link Check: {checklist.PG && checklist.PI ? '[SUCCESS] 所有組件已完全映射到偽代碼。' : '[WARNING] 部分圖中組件未在程式虛擬碼中定義！'}
                        </p>

                        <p className="mt-4">[Scan 2] 你的數學公式推導（PM）與定理證明，是否完美支撐了你在第三章中宣稱的演算法核心運作邏輯？</p>
                        <p className={checklist.PM && checklist.PG ? 'text-green-400' : 'text-red-400 font-bold'}>
                          &gt;&gt; PM ↔ PG Link Check: {checklist.PM && checklist.PG ? '[SUCCESS] 數學證明與架構邏輯完美共振、自圓其說。' : '[FATAL ERROR] 圖表畫了一套，程式寫了另一套，公式完全無關！編譯徹底中斷。'}
                        </p>
                      </div>
                    </div>

                    <div className="mt-6 pt-3 border-t border-green-800 flex justify-between items-center">
                      <span>SCAN STATUS:</span>
                      {congruencyStatus === 'idle' && <span className="text-slate-400">[WAITING FOR COMMAND]</span>}
                      {congruencyStatus === 'scanning' && <span className="text-yellow-400 animate-pulse">[SCANNING ALL BLOCKS...]</span>}
                      {congruencyStatus === 'success' && <span className="text-green-400 font-bold bg-green-950/50 px-2 py-0.5 rounded">✔ COMPILATION PASS</span>}
                      {congruencyStatus === 'failed' && <span className="text-red-400 font-bold bg-red-950/50 px-2 py-0.5 rounded">✗ COMPILATION ERROR</span>}
                    </div>
                  </div>

                </div>
              </div>
            )}

            {currentPage === 10 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 5] The Stress Test: 模擬與實驗 (Q-V)</h2>
                  <p className="text-sm opacity-90">空口無憑！利用這 4 個維度全方位對你的系統進行最嚴格的壓力測試：</p>
                </div>

                <div className="grid md:grid-cols-2 gap-6 items-stretch">
                  
                  {/* Interactive Widgets: Speedometers & Charts */}
                  <div className="sketch-border p-5 bg-white/5 border-current flex flex-col justify-between">
                    <div>
                      <h3 className="font-bold text-sm mb-3 text-center">模擬壓力測試控制面板</h3>
                      <div className="space-y-4">
                        <div>
                          <div className="flex justify-between text-xs mb-1 font-mono">
                            <span>定性指標: 收斂速度 (Quality)</span>
                            <span>{convergenceSpeed}% Faster</span>
                          </div>
                          <input 
                            type="range" 
                            min="20" 
                            max="100" 
                            value={convergenceSpeed} 
                            onChange={(e) => { setConvergenceSpeed(e.target.value); playSfx('scribble'); }}
                            className="w-full accent-green-500"
                          />
                        </div>

                        {/* Interactive bar chart comparing proposed with legacy */}
                        <div className="mt-4">
                          <span className="text-xs font-bold block mb-2">定量指標: 運行吞吐量 (Quantity)</span>
                          <div className="space-y-2 text-xs">
                            <div className="flex items-center space-x-2">
                              <span className="w-24 truncate font-mono">Legacy SOTA:</span>
                              <div className="flex-1 bg-slate-300 h-4 rounded overflow-hidden">
                                <div className="bg-red-400 h-full transition-all duration-300" style={{ width: '45%' }}></div>
                              </div>
                              <span className="font-mono">45k/s</span>
                            </div>
                            <div className="flex items-center space-x-2">
                              <span className="w-24 truncate font-mono">Our Proposed:</span>
                              <div className="flex-1 bg-slate-300 h-4 rounded overflow-hidden">
                                <div className="bg-green-500 h-full transition-all duration-500 animate-pulse" style={{ width: `${Math.max(60, convergenceSpeed)}%` }}></div>
                              </div>
                              <span className="font-mono">{Math.round(45 * (1 + convergenceSpeed/100))}k/s</span>
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>

                    <div className="mt-6 flex justify-around">
                      <div className="text-center">
                        <div className="text-2xl font-black text-green-500">{convergenceSpeed}%</div>
                        <div className="text-[10px] uppercase opacity-75">收斂提速</div>
                      </div>
                      <div className="text-center border-l border-current pl-4">
                        <div className="text-2xl font-black text-amber-500">{(1 + convergenceSpeed/100).toFixed(1)}x</div>
                        <div className="text-[10px] uppercase opacity-75">吞吐量倍率</div>
                      </div>
                    </div>
                  </div>

                  {/* Technical Explanations Card */}
                  <div className="sketch-border p-5 bg-white/5 border-current flex flex-col justify-between">
                    <div className="space-y-4 text-sm">
                      <div>
                        <h4 className="font-bold flex items-center space-x-1">
                          <CheckCircle2 size={16} className="text-green-500" />
                          <span>Q / R: 定性/定量與 SOTA 比較</span>
                        </h4>
                        <p className="text-xs leading-relaxed mt-1 opacity-90">
                          <strong>定性指標 (Quality):</strong> 方法性質優勢（收斂神速、免除大樣本標註）；<strong>R (Related):</strong> 與前沿技術 (SOTA) 展開慘烈白刃戰，用硬核數據粉碎質疑。
                        </p>
                      </div>

                      <div>
                        <h4 className="font-bold flex items-center space-x-1">
                          <CheckCircle2 size={16} className="text-green-500" />
                          <span>S / T: 實驗設定與參數調優</span>
                        </h4>
                        <p className="text-xs leading-relaxed mt-1 opacity-90">
                          <strong>S (Setup):</strong> 詳細交代實驗硬體環境、超參數、取樣分佈；<strong>T (Tuning):</strong> 展示超參數調優過程與敏感度分析，自證系統已調校到黃金平衡。
                        </p>
                      </div>

                      <div>
                        <h4 className="font-bold flex items-center space-x-1">
                          <CheckCircle2 size={16} className="text-green-500" />
                          <span>U / V: 實用成效與架構驗證</span>
                        </h4>
                        <p className="text-xs leading-relaxed mt-1 opacity-90">
                          <strong>U (Useful):</strong> 在多個實用邊界極端場景中皆表現卓越；<strong>V (Verify):</strong> 對各個微小提出的技術元件進行消融實驗 (Ablation Study)，證實每個模組都有重大貢獻，絕無注水！
                        </p>
                      </div>
                    </div>

                    <div className="mt-4 pt-3 border-t border-dashed border-current flex justify-between items-center">
                      <span className="text-xs italic opacity-75">快速通道：確保 Q、R、S、T、U、V 節點亮燈：</span>
                      <div className="flex space-x-1">
                        {['Q', 'R', 'S', 'T', 'U', 'V'].map(l => (
                          <div 
                            key={l}
                            onClick={() => toggleChecklistItem(l)}
                            className={`w-5 h-5 rounded-full flex items-center justify-center text-[9px] font-bold cursor-pointer border ${checklist[l] ? 'bg-green-500 text-white border-green-600' : 'bg-red-500 text-white border-red-600'}`}
                          >
                            {l}
                          </div>
                        ))}
                      </div>
                    </div>
                  </div>

                </div>
              </div>
            )}

            {currentPage === 11 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Module 6] The Output Log: 結論與未來工作 (W-Z)</h2>
                  <p className="text-sm opacity-90">結論不是前言的簡單複製，而是一個首尾相接、完美閉環的系統自洽電路！</p>
                </div>

                <div className="grid md:grid-cols-2 gap-6 items-stretch">
                  
                  {/* Detailed explanation column */}
                  <div className="sketch-border p-5 bg-white/5 border-current flex flex-col justify-between">
                    <div className="space-y-3">
                      <h3 className="font-bold text-base text-amber-500">W-Z 閉環收尾四大法寶</h3>
                      
                      <div className="space-y-2 text-xs md:text-sm">
                        <p><strong>W (What Proposed):</strong> 整體大回顧。重新盤點研究的情境脈絡、想解決的痛點，重新站在學術制高點宣布所提方案。</p>
                        <p><strong>X (eXcel):</strong> 專精優勢。說明你的演算法在哪些具體細分環境下能展現降維打擊的優勢，坦白極限邊界在哪。</p>
                        <p><strong>Y (Yields):</strong> 具體產出。用精煉的一到兩句話，再次歸納模擬結果中最令人驚嘆的核心數據點與效能特性。</p>
                        <p><strong>Z (Zen):</strong> 終極展望。總結研究精神，並為後來者指明未來的 2-3 個前沿研究方向（Future Work）。</p>
                      </div>
                    </div>

                    <div className="p-3 bg-amber-100/10 border border-dashed rounded text-xs mt-4">
                      <strong>Debug Warning Alert:</strong> <br/>
                      你的結論 <strong>Zen (Z)</strong> 必須完美響應摘要的 <strong>Attention Getter (A)</strong> 所勾勒的願景！如果頭尾分叉、不合拍，論文編譯器依舊會當場 Crash。
                    </div>
                  </div>

                  {/* Circle animation visualization */}
                  <div className="sketch-border p-5 bg-white/5 border-current flex flex-col justify-between items-center text-center">
                    <div>
                      <h4 className="font-bold text-xs uppercase tracking-widest mb-2">A-Z 環形閉環自適應電路</h4>
                      <p className="text-xs opacity-75">點擊各個節點，觀察它是如何回歸到 Attention Getter (A) 的：</p>
                    </div>

                    {/* SVG Loop Diagram */}
                    <div className="relative w-48 h-48 my-4">
                      <svg className="absolute inset-0 w-full h-full stroke-current opacity-70 animate-spin-slow" viewBox="0 0 200 200" fill="none">
                        <circle cx="100" cy="100" r="70" strokeWidth="2.5" strokeDasharray="8,6" />
                        <path d="M 170 100 Q 170 140, 140 160" strokeWidth="3" />
                      </svg>

                      {/* Vertex 1: Attention (Top) */}
                      <div className="absolute top-1 left-1/2 -translate-x-1/2 bg-amber-400 text-slate-900 w-12 h-12 rounded-full border-2 border-slate-800 flex items-center justify-center font-bold text-sm cursor-pointer hover:scale-110 transition shadow-sm">
                        A
                      </div>

                      {/* Vertex 2: Zen (Bottom) */}
                      <div className="absolute bottom-1 left-1/2 -translate-x-1/2 bg-[#000]/10 border-2 border-dashed border-current w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm cursor-pointer hover:scale-110 transition shadow-sm">
                        Z
                      </div>

                      {/* Vertex 3: What (Left) */}
                      <div className="absolute top-1/2 -translate-y-1/2 left-1 bg-[#000]/10 border-2 border-dashed border-current w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm cursor-pointer hover:scale-110 transition shadow-sm">
                        W
                      </div>

                      {/* Vertex 4: Yields (Right) */}
                      <div className="absolute top-1/2 -translate-y-1/2 right-1 bg-[#000]/10 border-2 border-dashed border-current w-12 h-12 rounded-full flex items-center justify-center font-bold text-sm cursor-pointer hover:scale-110 transition shadow-sm">
                        Y
                      </div>
                    </div>

                    <div className="flex gap-2 text-xs">
                      {['W', 'X', 'Y', 'Z'].map(l => (
                        <button 
                          key={l}
                          onClick={() => { toggleChecklistItem(l); playSfx('scribble'); }}
                          className={`w-8 py-1 rounded border font-mono font-bold ${checklist[l] ? 'bg-green-100 text-green-800 border-green-400' : 'bg-red-100 text-red-800 border-red-400'}`}
                        >
                          {l}
                        </button>
                      ))}
                    </div>
                  </div>

                </div>
              </div>
            )}

            {currentPage === 12 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">[Full System Synthesis] A-Z 偵錯清單</h2>
                  <p className="text-sm opacity-90">送出論文 (Submit) 前的最後掃描：這 26 個邏輯節點是否已全部亮起綠燈？點擊方格可手動修補或切換狀態。</p>
                </div>

                {/* 26 Checklist Matrix Grid */}
                <div className="grid grid-cols-4 md:grid-cols-8 lg:grid-cols-13 gap-2">
                  {Object.keys(checklist).map((letter) => (
                    <div 
                      key={letter}
                      onClick={() => toggleChecklistItem(letter)}
                      className={`sketch-border p-2 cursor-pointer transition text-center select-none ${checklist[letter] ? 'bg-green-500/10 hover:bg-green-500/20 border-green-500 text-green-600' : 'bg-red-50/5 hover:bg-red-50/10 border-red-400 text-red-400'}`}
                    >
                      <div className="font-mono text-[9px] opacity-75">
                        {['A','B','C','D','E','F'].includes(letter) && 'M1'}
                        {['G','H','I','J','K','L'].includes(letter) && 'M2'}
                        {['M','N','O'].includes(letter) && 'M3'}
                        {['PA','PB','PC','PD','PE','PF','PG','PH','PI','PJ','PK','PL','PM'].includes(letter) && 'M4'}
                        {['Q','R','S','T','U','V'].includes(letter) && 'M5'}
                        {['W','X','Y','Z'].includes(letter) && 'M6'}
                      </div>
                      <div className="text-lg font-black">{letter}</div>
                      <div className="text-[10px] mt-1 font-bold">
                        {checklist[letter] ? '☑ PASS' : '☐ FIX'}
                      </div>
                    </div>
                  ))}
                </div>

                {/* Integration Health Bar */}
                <div className="sketch-border p-4 bg-white/5 space-y-2">
                  <div className="flex justify-between items-center text-sm font-bold">
                    <span>論文綜合指標編譯編譯度 (System Compilation Integrity)</span>
                    <span className={`font-mono text-lg ${systemIntegrity >= 85 ? 'text-green-500' : 'text-yellow-500'}`}>{systemIntegrity}% INTEGRITY</span>
                  </div>
                  
                  {/* Progress bar container */}
                  <div className="w-full bg-slate-200 h-6 rounded-full overflow-hidden border border-slate-700 relative">
                    <div 
                      className={`h-full transition-all duration-500 flex items-center justify-end pr-3 ${systemIntegrity >= 85 ? 'bg-green-500' : 'bg-amber-500'}`} 
                      style={{ width: `${systemIntegrity}%` }}
                    >
                      <span className="text-[10px] font-mono font-black text-white">{systemIntegrity}%</span>
                    </div>
                  </div>

                  <div className="flex justify-between items-center pt-2">
                    <span className="text-xs italic opacity-75">
                      {systemIntegrity >= 85 ? '✔ 指標已大於 85%，您可以安全地執行下一頁的最終學術編譯！' : '⚠ 部分核心節點尚處於 WARN 狀態，建議手動點擊格子將其亮起綠燈以防退稿。'}
                    </span>
                    <button 
                      onClick={autoCheckAll}
                      className="text-xs px-3 py-1 bg-amber-400 text-slate-900 rounded font-bold hover:bg-amber-300 transition"
                    >
                      ⚡ 懶人模式: 一鍵亮綠燈
                    </button>
                  </div>
                </div>
              </div>
            )}

            {currentPage === 13 && (
              <div className="space-y-6">
                <div className="text-center">
                  <h2 className="text-2xl font-bold">Final Compilation: 全系統最終綜合編譯</h2>
                  <p className="text-sm opacity-90">萬事俱備。現在，讓學術編譯器執行最後的 A-Z 靜態檢查與打包部署吧！</p>
                </div>

                <div className="grid md:grid-cols-3 gap-6 items-center">
                  
                  {/* Left panel: Trigger compiler Button */}
                  <div className="sketch-border p-6 bg-white/5 border-current flex flex-col justify-between h-full space-y-4">
                    <div className="text-center">
                      <div className="text-5xl font-black text-amber-500 mb-2">100%</div>
                      <div className="text-xs font-mono opacity-80 uppercase tracking-widest">Compiler Engine Ready</div>
                    </div>

                    <p className="text-xs leading-relaxed text-center">
                      按下下方按鈕模擬將論文投入 A-Z 頂級學術診斷終端。系統將逐個掃描 26 個邏輯卡槽，並輸出最終的 Compilation Report。
                    </p>

                    <button 
                      onClick={runBuildCompiler}
                      disabled={compilingState === 'compiling'}
                      className={`w-full py-3 font-bold text-base rounded-lg flex items-center justify-center space-x-2 ${themeClasses.btnPrimary}`}
                    >
                      <RefreshCw size={18} className={compilingState === 'compiling' ? 'animate-spin' : ''} />
                      <span>{compilingState === 'compiling' ? '正在編譯論文核心...' : '執行 A-Z 核心終端編譯'}</span>
                    </button>
                  </div>

                  {/* Center & Right panel: Compiler Output Stream */}
                  <div className="sketch-border p-5 md:col-span-2 bg-slate-900 text-green-400 border-slate-700 font-mono text-xs h-[300px] overflow-y-auto flex flex-col justify-between">
                    <div>
                      <div className="flex justify-between items-center border-b border-green-800 pb-2 mb-3">
                        <span className="font-bold flex items-center space-x-1">
                          <Terminal size={14} /> <span>ACADEMIC_COMPILER_LOG.log</span>
                        </span>
                        <span className="text-[10px] animate-pulse">● ONLINE</span>
                      </div>

                      {buildLogs.length === 0 ? (
                        <div className="text-slate-500 italic h-48 flex items-center justify-center">
                          等待啟動最終編譯指令。
                        </div>
                      ) : (
                        <div className="space-y-1 font-mono text-[11px] h-48 overflow-y-auto">
                          {buildLogs.map((log, index) => (
                            <div key={index} className="transition-all duration-300">
                              <span className="text-green-600">[$]</span> {log}
                            </div>
                          ))}
                        </div>
                      )}
                    </div>

                    {/* Compile Progress Bar */}
                    {compilingState === 'compiling' && (
                      <div className="space-y-1">
                        <div className="flex justify-between text-[10px]">
                          <span>Compiling Bundle Progress:</span>
                          <span>{compilingProgress}%</span>
                        </div>
                        <div className="w-full bg-slate-800 h-2 rounded overflow-hidden">
                          <div className="bg-green-400 h-full transition-all duration-300" style={{ width: `${compilingProgress}%` }}></div>
                        </div>
                      </div>
                    )}

                    {compilingState === 'success' && (
                      <div className="bg-green-950/40 border border-green-500 p-3 rounded text-center animate-bounce mt-2">
                        <h4 className="font-bold text-green-400 text-sm">✔ COMPILATION SUCCESSFUL!</h4>
                        <p className="text-[10px] text-green-300 mt-1">
                          恭喜！0 Syntax Errors Found. 0 Logic Gaps Detected. 你的論文已準備好迎接審稿委員挑戰。
                        </p>
                      </div>
                    )}

                    {compilingState === 'failed' && (
                      <div className="bg-red-950/40 border border-red-500 p-3 rounded text-center mt-2">
                        <h4 className="font-bold text-red-400 text-sm">✗ COMPILATION FAILED!</h4>
                        <p className="text-[10px] text-red-300 mt-1">
                          未通過靜態檢查。完整度不足 {systemIntegrity}%/85%。請手動前往前一頁修補至綠燈。
                        </p>
                      </div>
                    )}
                  </div>

                </div>
              </div>
            )}
          </div>

          {/* Footer Controls */}
          <div className="mt-8 border-t-2 border-dashed border-current pt-4 flex flex-wrap justify-between items-center gap-4">
            
            {/* Quick module selection */}
            <div className="flex items-center space-x-1 bg-slate-500/10 px-2 py-1 rounded text-xs">
              <span className="font-mono uppercase opacity-75">快速導航:</span>
              <select 
                value={currentPage} 
                onChange={(e) => selectPage(Number(e.target.value))} 
                className="bg-transparent font-bold border-none text-current outline-none focus:ring-0 cursor-pointer"
              >
                <option value={1} className="text-slate-900">01. 論文封面 & Boot</option>
                <option value={2} className="text-slate-900">02. 被退稿的痛點 vs 診斷</option>
                <option value={3} className="text-slate-900">03. 全系統架構圖</option>
                <option value={4} className="text-slate-900">04. 摘要與動機 [A-F]</option>
                <option value={5} className="text-slate-900">05. 導言發散擴展 [G-L]</option>
                <option value={6} className="text-slate-900">06. 相關工作與戰略 [M-O]</option>
                <option value={7} className="text-slate-900">07. 比較矩陣 O-Organize</option>
                <option value={8} className="text-slate-900">08. 核心方法拆解 [PA-PM]</option>
                <option value={9} className="text-slate-900">09. 架構圖與公式一致性檢驗</option>
                <option value={10} className="text-slate-900">10. 模擬與壓力測試 [Q-V]</option>
                <option value={11} className="text-slate-900">11. 結論 W-Z 完美閉環</option>
                <option value={12} className="text-slate-900">12. A-Z 偵錯清單儀表板</option>
                <option value={13} className="text-slate-900">13. 最終編譯打包</option>
              </select>
            </div>

            {/* Pagination Controls */}
            <div className="flex items-center space-x-3">
              <button 
                onClick={prevPage}
                disabled={currentPage === 1}
                className={`p-2 rounded-lg border-2 border-slate-800 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:pointer-events-none ${themeClasses.btnSecondary}`}
              >
                <ArrowLeft size={16} />
              </button>
              
              <span className="text-sm font-bold font-mono">
                {currentPage} / 13
              </span>

              <button 
                onClick={nextPage}
                disabled={currentPage === 13}
                className={`p-2 rounded-lg border-2 border-slate-800 hover:scale-105 active:scale-95 transition-all disabled:opacity-50 disabled:pointer-events-none ${themeClasses.btnPrimary}`}
              >
                <ArrowRight size={16} />
              </button>
            </div>

          </div>

        </div>

      </main>

      {/* ==========================================
          FOOTER/COPYRIGHT INFO
          ========================================== */}
      <footer className="text-center py-4 text-xs opacity-60 border-t border-slate-500/20 max-w-7xl w-full mx-auto px-4">
        <div>
          THE ACADEMIC OPERATING SYSTEM • AUTHORIZED BY NOTEBOOKLM ENG NOTE • BUILD: 2026.05.25_v1.2
        </div>
        <div className="mt-1 font-mono">
          Interactive Sketch Layout & Sound Synthesizer constructed on-the-fly.
        </div>
      </footer>

      {/* Embedded CSS rules for the pristine Excalidraw / Grid Patterns */}
      <style>{`
        /* 1. Paper Grid Pattern */
        .grid-bg-paper {
          background-size: 24px 24px;
          background-image: 
            linear-gradient(to right, rgba(148, 163, 184, 0.08) 1.5px, transparent 1.5px),
            linear-gradient(to bottom, rgba(148, 163, 184, 0.08) 1.5px, transparent 1.5px);
        }

        /* 2. Blueprint Grid Pattern */
        .grid-bg-blueprint {
          background-size: 30px 30px;
          background-image: 
            linear-gradient(to right, rgba(147, 197, 253, 0.12) 1px, transparent 1px),
            linear-gradient(to bottom, rgba(147, 197, 253, 0.12) 1px, transparent 1px);
        }

        /* 3. Chalkboard Grid Pattern */
        .grid-bg-chalkboard {
          background-size: 28px 28px;
          background-image: 
            linear-gradient(to right, rgba(196, 210, 191, 0.05) 1.5px, transparent 1.5px),
            linear-gradient(to bottom, rgba(196, 210, 191, 0.05) 1.5px, transparent 1.5px);
        }

        /* 4. Excalidraw Wobbly Border Trick using custom radius ratios */
        .sketch-border {
          border-width: 2px;
          border-style: solid;
          border-radius: 255px 15px 225px 15px / 15px 225px 15px 255px;
        }

        /* Custom subtle spin speed for the circle loop slide */
        .animate-spin-slow {
          animation: spin 16s linear infinite;
        }
        @keyframes spin {
          from { transform: rotate(0deg); }
          to { transform: rotate(360deg); }
        }
      `}</style>
    </div>
  );
}