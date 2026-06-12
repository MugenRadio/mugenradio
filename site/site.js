/* mugen 無限 — shared client script: survival widget, live player, logbook. */
(function () {
  "use strict";

  var HLS_SRC = "/hls/live.m3u8";

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
    var v;
    try { v = parseFloat(sessionStorage.getItem("mugen-vol")); } catch (e) {}
    return isFinite(v) ? v : 0.8;
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
  var GARDEN_CYCLE = 765; // 3 x (210 hold + 45 fade)
  var GARDEN_EDGES = [210, 465, 720]; // seconds where the next scene starts

  function gardenSceneAt(t) {
    t = ((t % GARDEN_CYCLE) + GARDEN_CYCLE) % GARDEN_CYCLE;
    if (t < GARDEN_EDGES[0]) return "a";
    if (t < GARDEN_EDGES[1]) return "b";
    if (t < GARDEN_EDGES[2]) return "c";
    return "a"; // 720-765: crossfading back to a
  }

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
    var hintDefault = hint.textContent;
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
      hint.textContent = "the stream hiccuped, tap to retry";
    }

    function attach() {
      if (attached) return true;
      if (video.canPlayType("application/vnd.apple.mpegurl")) {
        video.src = HLS_SRC;
        attached = true;
        return true;
      }
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
      return false;
    }

    overlay.addEventListener("click", function () {
      overlay.classList.remove("is-error");
      hint.textContent = hintDefault;
      if (!attach()) { showError(); return; }
      video.muted = false;
      video.volume = parseFloat(vol.value);
      video.play().then(function () {
        overlay.hidden = true;
        if (garden) garden.hidden = true;
        bar.hidden = false;
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", "Pause");
        rememberPlaying(true);
      }).catch(showError);
    });

    pauseBtn.addEventListener("click", function () {
      if (video.paused) {
        video.play().catch(showError);
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", "Pause");
        rememberPlaying(true);
      } else {
        video.pause();
        bar.classList.add("is-paused");
        pauseBtn.textContent = "▶";
        pauseBtn.setAttribute("aria-label", "Resume");
        rememberPlaying(false);
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

  /* ---------- logbook ---------- */
  function initJournal() {
    var wrap = document.getElementById("entries");
    if (!wrap) return;

    function dateLabel(filename) {
      var m = filename.match(/^(\d{4})-(\d{2})-(\d{2})/);
      if (m) {
        return new Date(+m[1], +m[2] - 1, +m[3]).toLocaleDateString("en-GB", {
          day: "numeric", month: "long", year: "numeric"
        });
      }
      if (filename.indexOf("comptes") !== -1) return "the books";
      return filename.replace(/\.md$/, "").replace(/[-_]/g, " ");
    }

    fetch("/journal/index.json")
      .then(function (r) { if (!r.ok) throw new Error("index " + r.status); return r.json(); })
      .then(function (files) {
        return Promise.all(files.map(function (f) {
          return fetch("/journal/" + encodeURIComponent(f))
            .then(function (r) { if (!r.ok) throw new Error(f); return r.text(); })
            .then(function (md) { return { file: f, md: md }; })
            .catch(function () { return null; });
        }));
      })
      .then(function (entries) {
        wrap.innerHTML = "";
        entries.forEach(function (entry) {
          if (!entry) return;
          var card = document.createElement("article");
          card.className = "entry";
          var date = document.createElement("p");
          date.className = "entry-date";
          date.textContent = dateLabel(entry.file);
          var body = document.createElement("div");
          body.className = "entry-body";
          body.innerHTML = marked.parse(entry.md);
          card.appendChild(date);
          card.appendChild(body);
          wrap.appendChild(card);
        });
        if (!wrap.children.length) {
          wrap.innerHTML = '<p class="entries-empty">No entries yet. The station is young.</p>';
        }
      })
      .catch(function () {
        wrap.innerHTML = '<p class="entries-empty">Could not load the logbook. Try again in a minute.</p>';
      });
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
      '<span class="mini-live"><span class="mini-dot"></span>live</span>' +
      '<label class="mini-vol"><span class="visually-hidden">Volume</span>' +
      '<input type="range" min="0" max="1" step="0.01"></label>' +
      '<span class="mini-mark" aria-hidden="true">無限</span>';
    document.body.appendChild(mini);

    var media = mini.querySelector(".mini-media");
    var toggle = mini.querySelector(".mini-toggle");
    var volIn = mini.querySelector(".mini-vol input");
    var hls = null;
    volIn.value = savedVolume();

    function attach() {
      if (media.canPlayType("application/vnd.apple.mpegurl")) {
        media.src = HLS_SRC;
        return true;
      }
      if (window.Hls && Hls.isSupported()) {
        hls = new Hls({ maxBufferLength: 20 });
        hls.on(Hls.Events.ERROR, function (_e, info) {
          if (info && info.fatal) setPaused();
        });
        hls.loadSource(HLS_SRC);
        hls.attachMedia(media);
        return true;
      }
      return false;
    }

    function setPlaying() {
      toggle.textContent = "⏸";
      toggle.setAttribute("aria-label", "Pause");
      mini.classList.add("is-on");
      rememberPlaying(true);
    }
    function setPaused() {
      toggle.textContent = "▶";
      toggle.setAttribute("aria-label", "Play");
      mini.classList.remove("is-on");
      rememberPlaying(false);
    }

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

  initSurvival();
  initGarden();
  initPlayer();
  initJournal();
  initMiniPlayer();
})();
