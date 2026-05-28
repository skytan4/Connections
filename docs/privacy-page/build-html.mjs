import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { join } from "node:path";

const docsDir = new URL("../", import.meta.url).pathname;
const outputDir = join(docsDir, "privacy");

const locales = [
  ["privacy.md", "en", "English", "en", "privacy.html"],
  ["privacy-es.md", "es", "Español", "es", "privacy-es.html"],
  ["privacy-fr.md", "fr", "Français", "fr", "privacy-fr.html"],
  ["privacy-de.md", "de", "Deutsch", "de", "privacy-de.html"],
  ["privacy-pt-BR.md", "pt-BR", "Português (BR)", "pt-BR", "privacy-pt-BR.html"],
  ["privacy-nl.md", "nl", "Nederlands", "nl", "privacy-nl.html"],
  ["privacy-it.md", "it", "Italiano", "it", "privacy-it.html"],
  ["privacy-sv.md", "sv", "Svenska", "sv", "privacy-sv.html"],
  ["privacy-da.md", "da", "Dansk", "da", "privacy-da.html"],
  ["privacy-nb.md", "nb", "Norsk bokmål", "nb", "privacy-nb.html"],
  ["privacy-fi.md", "fi", "Suomi", "fi", "privacy-fi.html"],
  ["privacy-pl.md", "pl", "Polski", "pl", "privacy-pl.html"],
  ["privacy-ja.md", "ja", "日本語", "ja", "privacy-ja.html"],
  ["privacy-zh-Hans.md", "zh-Hans", "简体中文", "zh-Hans", "privacy-zh-Hans.html"],
  ["privacy-ru.md", "ru", "Русский", "ru", "privacy-ru.html"],
];

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function parseMarkdown(fileName) {
  const raw = readFileSync(join(docsDir, fileName), "utf8")
    .replace(/^---[\s\S]*?---\s*/, "")
    .trim();
  const lines = raw.split("\n");
  const title = lines.find((line) => line.startsWith("# "))?.replace(/^#\s+/, "") || "Privacy Policy";
  const sections = [];
  let current = null;

  for (const line of lines) {
    if (line.startsWith("# ")) {
      continue;
    }
    if (line.startsWith("## ")) {
      if (current) sections.push(current);
      current = { title: line.replace(/^##\s+/, ""), body: [] };
      continue;
    }
    if (!current) {
      if (line.trim()) {
        sections.push({ title: null, body: [line] });
      }
      continue;
    }
    current.body.push(line);
  }
  if (current) sections.push(current);

  return { title, sections };
}

function renderInline(line) {
  return escapeHtml(line)
    .replace(/\*\*([^*]+)\*\*/g, "<strong>$1</strong>")
    .replace(/oldmandevs@gmail\.com/g, '<a href="mailto:oldmandevs@gmail.com">oldmandevs@gmail.com</a>');
}

function renderBody(lines) {
  const html = [];
  let list = [];

  const flushList = () => {
    if (list.length) {
      html.push(`<ul>${list.map((item) => `<li>${renderInline(item.replace(/^-\s*/, ""))}</li>`).join("")}</ul>`);
      list = [];
    }
  };

  for (const line of lines) {
    if (!line.trim()) {
      flushList();
      continue;
    }
    if (line.startsWith("- ")) {
      list.push(line);
      continue;
    }
    flushList();
    html.push(`<p>${renderInline(line)}</p>`);
  }
  flushList();

  return html.join("\n");
}

function languageNav(currentCode, directoryPage = false) {
  return `<nav class="language-nav" aria-label="Language">
    ${locales.map(([, code, label, , htmlFile]) => {
      const href = directoryPage
        ? code === "en" ? "./" : `${code}.html`
        : htmlFile;
      const current = code === currentCode ? ` aria-current="page"` : "";
      return `<a href="${href}"${current}>${escapeHtml(label)}</a>`;
    }).join("\n")}
  </nav>`;
}

function page(fileName, code, label, lang, { directoryPage = false } = {}) {
  const data = parseMarkdown(fileName);
  const supportHref = directoryPage ? "../support/" : "support/";
  const marketingHref = directoryPage ? "../marketing/" : "marketing/";
  const cssHref = directoryPage ? "styles.css" : "privacy/styles.css";

  return `<!DOCTYPE html>
<html lang="${lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Deeper Conversations — ${escapeHtml(data.title)}</title>
  <meta name="description" content="${escapeHtml(data.title)} — Deeper Conversations">
  <link rel="stylesheet" href="${cssHref}">
</head>
<body>
  <main class="page">
    <header class="header">
      <div class="app-icon" aria-hidden="true"><span></span><span></span></div>
      <p class="eyebrow">Deeper Conversations</p>
      <h1>${escapeHtml(data.title)}</h1>
      ${languageNav(code, directoryPage)}
    </header>

    <article class="policy-card">
      ${data.sections.map((section) => section.title
        ? `<section class="policy-section"><h2>${escapeHtml(section.title)}</h2>${renderBody(section.body)}</section>`
        : `<section class="policy-intro">${renderBody(section.body)}</section>`
      ).join("\n")}
    </article>

    <footer class="footer">
      <a href="${supportHref}">Support</a>
      <a href="${marketingHref}">Deeper Conversations</a>
      <span>${escapeHtml(label)}</span>
      <span>© 2026 John Tanner</span>
    </footer>
  </main>
</body>
</html>
`;
}

const css = `
*, *::before, *::after { box-sizing: border-box; }
:root {
  --bg: #0d1713;
  --surface: rgba(255, 246, 222, 0.08);
  --surface-strong: rgba(255, 246, 222, 0.13);
  --border: rgba(255, 246, 222, 0.16);
  --text: #fff3d8;
  --muted: rgba(255, 243, 216, 0.72);
  --soft: rgba(255, 243, 216, 0.52);
  --gold: #f2c35f;
  --cream: #ffe0a1;
  --green: #15382f;
  --shadow: 0 24px 80px rgba(0, 0, 0, 0.28);
}
html { background: var(--bg); color: var(--text); }
body {
  margin: 0;
  font-family: ui-rounded, "SF Pro Rounded", "SF Pro Text", -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
  background:
    radial-gradient(circle at top left, rgba(242, 195, 95, 0.14), transparent 34rem),
    radial-gradient(circle at 78% 0%, rgba(41, 94, 73, 0.68), transparent 30rem),
    linear-gradient(145deg, #0b1512 0%, #102119 58%, #0c1412 100%);
  line-height: 1.65;
  min-height: 100vh;
}
a { color: var(--gold); text-decoration: none; }
a:hover { text-decoration: underline; text-underline-offset: 0.18em; }
.page { width: min(860px, calc(100% - 32px)); margin: 0 auto; padding: 54px 0 64px; }
.header { text-align: center; margin-bottom: 34px; }
.app-icon { position: relative; width: 82px; height: 82px; margin: 0 auto 18px; border-radius: 24px; overflow: hidden; background: #0f251f; border: 1px solid var(--border); box-shadow: var(--shadow); }
.app-icon span:first-child { position: absolute; width: 72px; height: 72px; left: -24px; top: 5px; border-radius: 24px; background: linear-gradient(145deg, #ffe4a7, #c99039); }
.app-icon span:last-child { position: absolute; width: 68px; height: 68px; right: -27px; top: 7px; border-radius: 50%; background: linear-gradient(145deg, #1d4b3e, #07110f); box-shadow: 0 0 28px rgba(242, 195, 95, 0.66); }
.eyebrow { margin: 0 0 8px; color: var(--gold); text-transform: uppercase; letter-spacing: 0.16em; font-size: 0.78rem; font-weight: 800; }
.header h1 { margin: 0 0 22px; font-size: clamp(2.25rem, 7vw, 4.5rem); line-height: 0.98; letter-spacing: -0.07em; }
.language-nav { display: flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
.language-nav a { color: var(--muted); border: 1px solid var(--border); border-radius: 999px; padding: 5px 9px; font-size: 0.78rem; background: rgba(255, 255, 255, 0.03); }
.language-nav a[aria-current="page"] { color: #17100b; background: var(--gold); border-color: transparent; }
.policy-card { padding: clamp(24px, 5vw, 44px); border: 1px solid var(--border); border-radius: 30px; background: var(--surface); box-shadow: 0 18px 70px rgba(0,0,0,.15); }
.policy-intro { margin-bottom: 26px; padding-bottom: 22px; border-bottom: 1px solid var(--border); }
.policy-intro p { color: var(--text); font-size: 1.05rem; }
.policy-section { padding: 18px 0; border-bottom: 1px solid var(--border); }
.policy-section:last-child { border-bottom: 0; padding-bottom: 0; }
.policy-section h2 { margin: 0 0 8px; color: var(--gold); font-size: 1.15rem; letter-spacing: -0.02em; }
.policy-section p, .policy-section li { color: var(--muted); }
.policy-section p { margin: 8px 0; }
.policy-section ul { margin: 10px 0; padding-left: 1.25rem; }
.footer { display: flex; justify-content: center; gap: 16px; flex-wrap: wrap; color: var(--soft); padding: 28px 0 0; font-size: 0.92rem; }
.footer a { color: var(--soft); text-decoration: underline; text-underline-offset: 0.18em; }
@media (max-width: 520px) {
  .page { padding-top: 34px; }
  .policy-card { border-radius: 22px; }
}
`.trim();

mkdirSync(outputDir, { recursive: true });
writeFileSync(join(outputDir, "styles.css"), `${css}\n`);

for (const [fileName, code, label, lang, htmlFile] of locales) {
  const html = page(fileName, code, label, lang);
  writeFileSync(join(docsDir, htmlFile), html);

  if (code === "en") {
    const prettyHtml = page(fileName, code, label, lang, { directoryPage: true });
    writeFileSync(join(outputDir, "index.html"), prettyHtml);
    writeFileSync(join(outputDir, "en.html"), prettyHtml);
  } else {
    const prettyHtml = page(fileName, code, label, lang, { directoryPage: true });
    writeFileSync(join(outputDir, `${code}.html`), prettyHtml);
  }
}

console.log(`Generated ${locales.length} root privacy pages and ${locales.length} pretty privacy pages`);
