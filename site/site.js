/* mugen 無限 — shared client script: survival widget, live player, logbook. */

/* ---------- pure helpers (no DOM, no browser APIs) ----------
   Exposed here so Node.js tests can require() this file directly.
   The IIFE below uses them without modification; browser behaviour unchanged. */

var MUGEN_LANGS = ["en", "fr", "es", "pt", "de", "it", "ja", "ko", "zh"];
var MUGEN_GARDEN_CYCLE = 765;
var MUGEN_GARDEN_EDGES = [210, 465, 720];

/* gardenSceneAt(t) — maps a cycle position (seconds, any sign) to a scene id */
function mugenGardenSceneAt(t) {
  t = ((t % MUGEN_GARDEN_CYCLE) + MUGEN_GARDEN_CYCLE) % MUGEN_GARDEN_CYCLE;
  if (t < MUGEN_GARDEN_EDGES[0]) return "a";
  if (t < MUGEN_GARDEN_EDGES[1]) return "b";
  if (t < MUGEN_GARDEN_EDGES[2]) return "c";
  return "a"; // 720-765: crossfading back to a
}

/* mugenDetectLang(prefs, savedLang) — pure lang detection from explicit inputs */
function mugenDetectLang(prefs, savedLang) {
  if (savedLang && MUGEN_LANGS.indexOf(savedLang) !== -1) return savedLang;
  var list = prefs || ["en"];
  for (var i = 0; i < list.length; i++) {
    var primary = String(list[i]).toLowerCase().split("-")[0];
    if (MUGEN_LANGS.indexOf(primary) !== -1) return primary;
  }
  return "en";
}

/* mugenSavedVolume(raw) — parses a raw sessionStorage string, falls back 0.8 */
function mugenSavedVolume(raw) {
  var v = parseFloat(raw);
  return isFinite(v) ? v : 0.8;
}

/* mugenDateLabel(filename, lang, strings) — pure date formatting */
function mugenDateLabel(filename, l, strings) {
  strings = strings || {};
  function t(key, fallback) {
    return Object.prototype.hasOwnProperty.call(strings, key) ? strings[key] : fallback;
  }
  var m = filename.match(/^(\d{4})-(\d{2})-(\d{2})/);
  if (m) {
    var d = new Date(+m[1], +m[2] - 1, +m[3]);
    var opts = { day: "numeric", month: "long", year: "numeric" };
    try {
      return d.toLocaleDateString(l === "en" ? "en-GB" : l, opts);
    } catch (e) {
      return d.toLocaleDateString("en-GB", opts);
    }
  }
  if (filename.indexOf("comptes") !== -1) return t("journal.books", "the books");
  return filename.replace(/\.md$/, "").replace(/[-_]/g, " ");
}

if (typeof module !== "undefined") {
  module.exports = {
    gardenSceneAt: mugenGardenSceneAt,
    detectLang: mugenDetectLang,
    savedVolume: mugenSavedVolume,
    dateLabel: mugenDateLabel,
    LANGS: MUGEN_LANGS,
    GARDEN_CYCLE: MUGEN_GARDEN_CYCLE,
    GARDEN_EDGES: MUGEN_GARDEN_EDGES,
  };
}

/* The IIFE below requires a real browser DOM. Skip when loaded from Node.js. */
if (typeof document !== "undefined") (function () {
  "use strict";

  var HLS_SRC = "/hls/live.m3u8";

  /* ---------- i18n (decision 0004) ----------
     Nine LTR languages, English as source of truth and fallback. Two layers:
     UI strings from /i18n/{lang}.json applied onto [data-i18n] markers (the
     English text stays in the HTML, so no-JS still reads in English), and
     journal chapters served per language from /journal/{lang}/. */
  var LANGS = MUGEN_LANGS;
  var LANG_NAMES = {
    en: "English", fr: "Français", es: "Español", pt: "Português",
    de: "Deutsch", it: "Italiano", ja: "日本語", ko: "한국어", zh: "中文"
  };
  var strings = {}; // active catalogue; empty object = English defaults
  var langListeners = []; // called with the new lang after every switch

  function detectLang() {
    var saved = null;
    try { saved = localStorage.getItem("mugen-lang"); } catch (e) {}
    var prefs = navigator.languages || [navigator.language || "en"];
    return mugenDetectLang(prefs, saved);
  }

  var lang = detectLang();
  document.documentElement.setAttribute("lang", lang);

  function t(key, fallback) {
    return Object.prototype.hasOwnProperty.call(strings, key) ? strings[key] : fallback;
  }

  function applyStrings() {
    document.documentElement.setAttribute("lang", lang);
    Array.prototype.forEach.call(document.querySelectorAll("[data-i18n]"), function (el) {
      // first pass memorises the English default so en restores it exactly
      if (!el.hasAttribute("data-i18n-default")) {
        el.setAttribute("data-i18n-default", el.textContent);
      }
      el.textContent = t(el.getAttribute("data-i18n"), el.getAttribute("data-i18n-default"));
    });
    Array.prototype.forEach.call(document.querySelectorAll("[data-i18n-html]"), function (el) {
      // trusted catalogue (same repo), needed for strings with inline links
      if (!el.hasAttribute("data-i18n-default-html")) {
        el.setAttribute("data-i18n-default-html", el.innerHTML);
      }
      el.innerHTML = t(el.getAttribute("data-i18n-html"), el.getAttribute("data-i18n-default-html"));
    });
    Array.prototype.forEach.call(document.querySelectorAll("[data-i18n-attr]"), function (el) {
      el.getAttribute("data-i18n-attr").split(";").forEach(function (pair) {
        var sep = pair.indexOf(":");
        if (sep === -1) return;
        var attr = pair.slice(0, sep), key = pair.slice(sep + 1);
        if (!el.hasAttribute("data-i18n-default-" + attr)) {
          el.setAttribute("data-i18n-default-" + attr, el.getAttribute(attr) || "");
        }
        el.setAttribute(attr, t(key, el.getAttribute("data-i18n-default-" + attr)));
      });
    });
  }

  function setLang(next, persist) {
    if (LANGS.indexOf(next) === -1) next = "en";
    if (persist) { try { localStorage.setItem("mugen-lang", next); } catch (e) {} }
    function done() {
      lang = next;
      applyStrings();
      langListeners.forEach(function (fn) { fn(lang); });
    }
    if (next === "en") { strings = {}; done(); return; } // defaults are English
    fetch("/i18n/" + next + ".json")
      .then(function (r) { if (!r.ok) throw new Error("i18n " + r.status); return r.json(); })
      .then(function (json) { strings = json || {}; done(); })
      .catch(function () { strings = {}; done(); }); // fall back to English
  }

  /* visible selector, top-right of the hero */
  function initLangSelector() {
    var hero = document.querySelector(".hero");
    if (!hero) return;
    var label = document.createElement("label");
    label.className = "lang-pick";
    var sr = document.createElement("span");
    sr.className = "visually-hidden";
    sr.setAttribute("data-i18n", "lang.label");
    sr.textContent = "Language";
    var sel = document.createElement("select");
    sel.id = "lang-select";
    LANGS.forEach(function (l) {
      var opt = document.createElement("option");
      opt.value = l;
      opt.textContent = LANG_NAMES[l]; // endonyms, never translated
      opt.setAttribute("lang", l);
      sel.appendChild(opt);
    });
    sel.value = lang;
    sel.addEventListener("change", function () { setLang(sel.value, true); });
    label.appendChild(sr);
    label.appendChild(sel);
    hero.appendChild(label);
  }

  /* ---------- cross-page playback memory ----------
     The logbook is a separate page, so audio can't carry over a navigation.
     We remember intent + volume in sessionStorage and let the mini-player on
     the next page rejoin the live edge (same content — it's a live stream). */
  function rememberPlaying(on) {
    try { sessionStorage.setItem("mugen-playing", on ? "1" : "0"); } catch (e) {}
  }
  function rememberVolume(v) {
    try { sessionStorage.setItem("mugen-vol", String(v)); } catch (e) {}
  }
  function wasPlaying() {
    try { return sessionStorage.getItem("mugen-playing") === "1"; } catch (e) { return false; }
  }
  function savedVolume() {
    var raw;
    try { raw = sessionStorage.getItem("mugen-vol"); } catch (e) {}
    return mugenSavedVolume(raw);
  }

  /* ---------- survival widget ---------- */
  function initSurvival() {
    var box = document.getElementById("survival");
    if (!box) return;
    fetch("/status.json")
      .then(function (r) { if (!r.ok) throw new Error("status " + r.status); return r.json(); })
      .then(function (status) {
        var born = Date.parse(status.born);
        var day = Math.floor((Date.now() - born) / 86400000) + 1;
        if (!status.balance || !isFinite(day) || day < 1) return;
        document.getElementById("day-num").textContent = String(day);
        document.getElementById("balance").textContent = status.balance;
        box.hidden = false;
      })
      .catch(function () { /* stay hidden */ });
  }

  /* ---------- zen garden scene rotation (decision 0002) ----------
     Three night scenes a/b/c, 210 s hold + 45 s crossfade each, 765 s cycle
     synced to the wall clock so every visitor sees the same phase. The
     crossfade itself is pure CSS (45 s transitions on .garden variables);
     here we only flip data-scene at the right times. */
  var GARDEN_CYCLE = MUGEN_GARDEN_CYCLE;
  var GARDEN_EDGES = MUGEN_GARDEN_EDGES;

  var gardenSceneAt = mugenGardenSceneAt;

  function gardenCyclePos() {
    return Math.floor(Date.now() / 1000) % GARDEN_CYCLE;
  }

  function initGarden() {
    var garden = document.getElementById("garden");
    if (!garden) return;

    // landing mid-cycle: jump straight to the current scene, no 45 s ramp
    garden.classList.add("zg-no-transition");
    garden.setAttribute("data-scene", gardenSceneAt(gardenCyclePos()));
    void garden.offsetWidth; // flush styles while transitions are disabled
    requestAnimationFrame(function () {
      garden.classList.remove("zg-no-transition");
    });

    function schedule() {
      var t = gardenCyclePos();
      var next = GARDEN_CYCLE;
      for (var i = 0; i < GARDEN_EDGES.length; i++) {
        if (t < GARDEN_EDGES[i]) { next = GARDEN_EDGES[i]; break; }
      }
      setTimeout(function () {
        garden.setAttribute("data-scene", gardenSceneAt(gardenCyclePos()));
        schedule();
      }, (next - t) * 1000 + 250);
    }
    schedule();
  }

  // exposed for tests and curiosity
  window.MUGEN = window.MUGEN || {};
  window.MUGEN.gardenSceneAt = gardenSceneAt;
  window.MUGEN.gardenCyclePos = gardenCyclePos;

  /* ---------- live player ---------- */
  function initPlayer() {
    var video = document.getElementById("player");
    var overlay = document.getElementById("tune");
    if (!video || !overlay) return;

    var bar = document.getElementById("player-bar");
    var garden = document.getElementById("garden");
    var hint = document.getElementById("tune-hint");
    var pauseBtn = document.getElementById("pause");
    var vol = document.getElementById("vol");
    var hls = null;
    var attached = false;

    function detach() {
      if (hls) { hls.destroy(); hls = null; }
      video.removeAttribute("src");
      video.load();
      attached = false;
    }

    function showError() {
      detach();
      bar.hidden = true;
      if (garden) garden.hidden = false;
      overlay.hidden = false;
      overlay.classList.add("is-error");
      hint.textContent = t("player.error", "the stream hiccuped, tap to retry");
    }

    function attach() {
      if (attached) return true;
      // hls.js first (Chrome/Firefox via MSE); native only as Safari fallback.
      if (window.Hls && Hls.isSupported()) {
        hls = new Hls({ maxBufferLength: 20 });
        hls.on(Hls.Events.ERROR, function (_evt, info) {
          if (info && info.fatal) showError();
        });
        hls.loadSource(HLS_SRC);
        hls.attachMedia(video);
        attached = true;
        return true;
      }
      if (video.canPlayType("application/vnd.apple.mpegurl")) {
        video.src = HLS_SRC;
        attached = true;
        return true;
      }
      return false;
    }

    function startMain(onBlocked) {
      if (!attach()) { showError(); return; }
      video.muted = false;
      video.volume = parseFloat(vol.value);
      video.play().then(function () {
        overlay.hidden = true;
        if (garden) garden.hidden = true;
        bar.hidden = false;
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", t("player.pause", "Pause"));
        rememberPlaying(true);
      }).catch(onBlocked || showError);
    }

    overlay.addEventListener("click", function () {
      overlay.classList.remove("is-error");
      hint.textContent = t("player.hint", "sound on · live · very small server");
      startMain();
    });

    // venir du journal en écoutant -> on reprend la lecture sans re-cliquer.
    // Si le navigateur bloque l'autoplay, on retombe sans bruit sur l'overlay.
    if (wasPlaying()) {
      vol.value = savedVolume();
      startMain(function () { /* autoplay bloqué : overlay reste, pas une erreur */ });
    }

    pauseBtn.addEventListener("click", function () {
      if (video.paused) {
        video.play().catch(showError);
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", t("player.pause", "Pause"));
        rememberPlaying(true);
      } else {
        video.pause();
        bar.classList.add("is-paused");
        pauseBtn.textContent = "▶";
        pauseBtn.setAttribute("aria-label", t("player.resume", "Resume"));
        rememberPlaying(false);
      }
    });

    // keep state-dependent labels current after a language switch
    langListeners.push(function () {
      pauseBtn.setAttribute("aria-label",
        video.paused ? t("player.resume", "Resume") : t("player.pause", "Pause"));
      if (overlay.classList.contains("is-error")) {
        hint.textContent = t("player.error", "the stream hiccuped, tap to retry");
      }
    });

    vol.addEventListener("input", function () {
      video.volume = parseFloat(vol.value);
      video.muted = false;
      rememberVolume(vol.value);
    });

    video.addEventListener("error", function () {
      if (!overlay.hidden) return; // not started yet, overlay handles it
      showError();
    });
  }

  /* ---------- logbook ----------
     English (/journal/) is the master list. For any other language we also
     fetch /journal/{lang}/index.json: chapters translated by MUGEN keep the
     same filename as their English source, the rest falls back to English
     with a small "shown in English" note on the card. */
  function initJournal() {
    var wrap = document.getElementById("entries");
    if (!wrap) return;

    function dateLabel(filename, l) {
      return mugenDateLabel(filename, l, strings);
    }

    function message(cls, text) {
      var p = document.createElement("p");
      p.className = cls;
      p.textContent = text;
      wrap.innerHTML = "";
      wrap.appendChild(p);
    }

    var renderToken = 0;
    function render(l) {
      var token = ++renderToken;
      var translatedIndex = l === "en"
        ? Promise.resolve([])
        : fetch("/journal/" + l + "/index.json")
            .then(function (r) { if (!r.ok) throw new Error("lang index"); return r.json(); })
            .catch(function () { return []; }); // no translations yet: full fallback

      Promise.all([
        fetch("/journal/index.json")
          .then(function (r) { if (!r.ok) throw new Error("index " + r.status); return r.json(); }),
        translatedIndex
      ])
        .then(function (res) {
          var files = res[0], translated = res[1];
          return Promise.all(files.map(function (f) {
            var hasTranslation = translated.indexOf(f) !== -1;
            function english() {
              return fetch("/journal/" + encodeURIComponent(f))
                .then(function (r) { if (!r.ok) throw new Error(f); return r.text(); })
                .then(function (md) { return { file: f, md: md, lang: "en" }; });
            }
            var loaded = hasTranslation
              ? fetch("/journal/" + l + "/" + encodeURIComponent(f))
                  .then(function (r) { if (!r.ok) throw new Error(f); return r.text(); })
                  .then(function (md) { return { file: f, md: md, lang: l }; })
                  .catch(english)
              : english();
            return loaded.catch(function () { return null; });
          }));
        })
        .then(function (entries) {
          if (token !== renderToken) return; // a newer language switch won
          wrap.innerHTML = "";
          entries.forEach(function (entry) {
            if (!entry) return;
            var card = document.createElement("article");
            card.className = "entry";
            card.id = entry.file.replace(/\.md$/, "");
            var date = document.createElement("p");
            date.className = "entry-date";
            date.textContent = dateLabel(entry.file, l);
            if (l !== "en" && entry.lang === "en") {
              var note = document.createElement("span");
              note.className = "entry-fallback";
              note.textContent = t("journal.inEnglish", "shown in English");
              date.appendChild(note);
            }
            var body = document.createElement("div");
            body.className = "entry-body";
            body.setAttribute("lang", entry.lang);
            body.innerHTML = marked.parse(entry.md);
            card.appendChild(date);
            card.appendChild(body);
            wrap.appendChild(card);
          });
          if (!wrap.children.length) {
            message("entries-empty", t("journal.empty", "No entries yet. The station is young."));
          }
          if (location.hash) {
            var target = document.getElementById(location.hash.slice(1));
            if (target) target.scrollIntoView({ behavior: "smooth", block: "start" });
          }
        })
        .catch(function () {
          if (token !== renderToken) return;
          message("entries-empty", t("journal.error", "Could not load the logbook. Try again in a minute."));
        });
    }

    // first render comes from the initial setLang() below, like every switch
    langListeners.push(render);
  }

  /* ---------- floating mini-player (logbook & other inner pages) ----------
     Appears on pages that have no main player. Rejoins the live stream so a
     reader keeps the music while browsing the journal. Autoplay-with-sound
     may be blocked on a fresh document; if so we show a paused state with a
     one-tap resume rather than fake silence. */
  function initMiniPlayer() {
    if (document.getElementById("player")) return; // home page has the real one
    if (!document.querySelector("main")) return;

    var mini = document.createElement("div");
    mini.className = "mini";
    mini.innerHTML =
      '<video class="mini-media" playsinline></video>' +
      '<button class="mini-toggle" type="button" aria-label="Play">▶</button>' +
      '<span class="mini-live"><span class="mini-dot"></span><span data-i18n="player.live">live</span></span>' +
      '<label class="mini-vol"><span class="visually-hidden" data-i18n="player.volume">Volume</span>' +
      '<input type="range" min="0" max="1" step="0.01"></label>' +
      '<span class="mini-mark" aria-hidden="true">無限</span>';
    document.body.appendChild(mini);

    var media = mini.querySelector(".mini-media");
    var toggle = mini.querySelector(".mini-toggle");
    var volIn = mini.querySelector(".mini-vol input");
    var hls = null;
    var attached = false;
    volIn.value = savedVolume();

    function attach() {
      if (attached) return true; // attache une seule fois (sinon double hls sur Firefox)
      // hls.js first (Chrome/Firefox via MSE); native only as Safari fallback.
      if (window.Hls && Hls.isSupported()) {
        hls = new Hls({ maxBufferLength: 20 });
        hls.on(Hls.Events.ERROR, function (_e, info) {
          if (info && info.fatal) {
            if (hls) { hls.destroy(); hls = null; }
            attached = false; // permet une vraie réattache au prochain clic
            setPaused();
          }
        });
        hls.loadSource(HLS_SRC);
        hls.attachMedia(media);
        attached = true;
        return true;
      }
      if (media.canPlayType("application/vnd.apple.mpegurl")) {
        media.src = HLS_SRC;
        attached = true;
        return true;
      }
      return false;
    }

    function setPlaying() {
      toggle.textContent = "⏸";
      toggle.setAttribute("aria-label", t("player.pause", "Pause"));
      mini.classList.add("is-on");
      rememberPlaying(true);
    }
    function setPaused() {
      toggle.textContent = "▶";
      toggle.setAttribute("aria-label", t("player.play", "Play"));
      mini.classList.remove("is-on");
      rememberPlaying(false);
    }
    langListeners.push(function () {
      toggle.setAttribute("aria-label",
        media.paused ? t("player.play", "Play") : t("player.pause", "Pause"));
    });

    function start() {
      if (!media.src && !hls && !attach()) return;
      media.muted = false;
      media.volume = parseFloat(volIn.value);
      media.play().then(setPlaying).catch(setPaused);
    }

    toggle.addEventListener("click", function () {
      if (media.paused) start();
      else { media.pause(); setPaused(); }
    });
    volIn.addEventListener("input", function () {
      media.volume = parseFloat(volIn.value);
      media.muted = false;
      rememberVolume(volIn.value);
    });

    // show the bar always on inner pages; auto-resume only if they were listening
    mini.hidden = false;
    if (wasPlaying()) start();
    else setPaused();
  }

  initLangSelector();
  initSurvival();
  initGarden();
  initPlayer();
  initJournal();
  initMiniPlayer();
  // load the active catalogue and trigger the first render of UI + journal
  setLang(lang, false);

  window.MUGEN.setLang = setLang;
})();
