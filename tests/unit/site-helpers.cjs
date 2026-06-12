// CJS shim: evaluate site.js in a fresh CJS context and re-export its helpers.
// Needed because Node 22 with "type":"module" in the root package.json causes
// require('./site.js') to go through the ESM-CJS bridge, where module.exports
// assignments are ignored. The vm approach bypasses that.
"use strict";
const fs = require("node:fs");
const path = require("node:path");
const vm = require("node:vm");

const src = fs.readFileSync(path.join(__dirname, "../../site/site.js"), "utf8");
const mod = { exports: {} };

// Wrap in CJS format and run in a fresh context
const fn = new vm.Script(
  "(function(module, exports, require, __filename, __dirname) {\n" + src + "\n})"
).runInThisContext({ filename: "site.js" });

fn(
  mod,
  mod.exports,
  require,
  path.join(__dirname, "../../site/site.js"),
  path.join(__dirname, "../../site")
);

module.exports = mod.exports;
