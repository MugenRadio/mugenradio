/* mugen 無限 — shared client script: survival widget, live player, logbook. */
(function () {
  "use strict";

  var HLS_SRC = "/hls/live.m3u8";

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

  /* ---------- live player ---------- */
  function initPlayer() {
    var video = document.getElementById("player");
    var overlay = document.getElementById("tune");
    if (!video || !overlay) return;

    var bar = document.getElementById("player-bar");
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
        bar.hidden = false;
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", "Pause");
      }).catch(showError);
    });

    pauseBtn.addEventListener("click", function () {
      if (video.paused) {
        video.play().catch(showError);
        bar.classList.remove("is-paused");
        pauseBtn.textContent = "⏸";
        pauseBtn.setAttribute("aria-label", "Pause");
      } else {
        video.pause();
        bar.classList.add("is-paused");
        pauseBtn.textContent = "▶";
        pauseBtn.setAttribute("aria-label", "Resume");
      }
    });

    vol.addEventListener("input", function () {
      video.volume = parseFloat(vol.value);
      video.muted = false;
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

  initSurvival();
  initPlayer();
  initJournal();
})();
