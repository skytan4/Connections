import { mkdirSync, readdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";

const sourceDir = new URL("./", import.meta.url).pathname;
const docsDir = join(sourceDir, "..");
const outputDir = join(docsDir, "support");
const supportEmail = "oldmandevs@gmail.com";

const locales = [
  ["en", "English", "en"],
  ["es", "Español", "es"],
  ["fr", "Français", "fr"],
  ["de", "Deutsch", "de"],
  ["pt-BR", "Português (BR)", "pt-BR"],
  ["nl", "Nederlands", "nl"],
  ["it", "Italiano", "it"],
  ["sv", "Svenska", "sv"],
  ["da", "Dansk", "da"],
  ["nb", "Norsk bokmål", "nb"],
  ["fi", "Suomi", "fi"],
  ["pl", "Polski", "pl"],
  ["ja", "日本語", "ja"],
  ["zh-Hans", "简体中文", "zh-Hans"],
  ["ru", "Русский", "ru"],
];

const localeMeta = new Map(locales.map(([code, label, lang]) => [code, { label, lang }]));

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function parseSupportFile(fileName) {
  const raw = readFileSync(join(sourceDir, fileName), "utf8").trim();
  const blocks = raw.split(/\n{2,}/);
  const meta = {};
  for (const line of blocks[0].split("\n")) {
    const index = line.indexOf(":");
    if (index !== -1) {
      meta[line.slice(0, index).trim()] = line.slice(index + 1).trim();
    }
  }

  const faqs = blocks.slice(1).map((block) => {
    const lines = block.split("\n");
    const question = lines[0].replace(/^Q:\s*/, "");
    const answer = lines.slice(1).join("\n").replace(/^A:\s*/, "");
    return { question, answer };
  });

  return { meta, faqs };
}

function linkifyAnswer(answer, privacyLabel) {
  let html = escapeHtml(answer);
  html = html.replace(
    escapeHtml(supportEmail),
    `<a href="mailto:${supportEmail}">${supportEmail}</a>`
  );
  html = html.replace(
    escapeHtml(privacyLabel),
    `<a href="PRIVACY_URL">${escapeHtml(privacyLabel)}</a>`
  );
  return html;
}

function languageNav(currentCode, inSupportDir) {
  const englishHref = inSupportDir ? "./" : ".";
  return `<nav class="language-nav" aria-label="Language">
    ${locales.map(([code, label]) => {
      const href = code === "en"
        ? englishHref
        : inSupportDir
          ? `${code}.html`
          : `support/${code}.html`;
      const current = code === currentCode ? ` aria-current="page"` : "";
      return `<a href="${href}"${current}>${escapeHtml(label)}</a>`;
    }).join("\n")}
  </nav>`;
}

function supportPage(code, data, { rootPage }) {
  const meta = localeMeta.get(code);
  const privacyHref = rootPage ? "privacy" : "../privacy";
  const marketingHref = rootPage ? "marketing/" : "../marketing/";
  const supportHref = rootPage ? "." : "./";
  const contactHtml = `${escapeHtml(data.meta.contact_label)} <a href="mailto:${supportEmail}">${supportEmail}</a>.`;

  return `<!DOCTYPE html>
<html lang="${meta.lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Deeper Conversations — ${escapeHtml(data.meta.contact_heading)}</title>
  <meta name="description" content="${escapeHtml(data.meta.tagline)}">
  <link rel="stylesheet" href="${rootPage ? "support/styles.css" : "styles.css"}">
</head>
<body>
  <main class="page">
    <header class="header">
      <div class="app-icon" aria-hidden="true"><span></span><span></span></div>
      <h1>Deeper Conversations</h1>
      <p>${escapeHtml(data.meta.tagline)}</p>
      ${languageNav(code, !rootPage)}
    </header>

    <section class="card">
      <h2>${escapeHtml(data.meta.faq_heading)}</h2>
      ${data.faqs.map(({ question, answer }) => `<details class="faq-item">
        <summary>${escapeHtml(question)}</summary>
        <p>${linkifyAnswer(answer, data.meta.privacy_label).replaceAll("PRIVACY_URL", privacyHref)}</p>
      </details>`).join("\n")}
    </section>

    <section class="card contact-card">
      <h2>${escapeHtml(data.meta.contact_heading)}</h2>
      <p>${contactHtml}</p>
    </section>

    <footer class="footer">
      <a href="${privacyHref}">${escapeHtml(data.meta.privacy_label)}</a>
      <a href="${marketingHref}">Deeper Conversations</a>
      <a href="${supportHref}">${escapeHtml(data.meta.contact_heading)}</a>
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
  --bg-soft: #13241d;
  --surface: rgba(255, 246, 222, 0.08);
  --surface-strong: rgba(255, 246, 222, 0.13);
  --border: rgba(255, 246, 222, 0.16);
  --text: #fff3d8;
  --muted: rgba(255, 243, 216, 0.68);
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
    radial-gradient(circle at top left, rgba(242, 195, 95, 0.15), transparent 32rem),
    radial-gradient(circle at 78% 0%, rgba(41, 94, 73, 0.68), transparent 30rem),
    linear-gradient(145deg, #0b1512 0%, #102119 58%, #0c1412 100%);
  line-height: 1.6;
  min-height: 100vh;
}
a { color: var(--gold); text-decoration: none; }
a:hover { text-decoration: underline; text-underline-offset: 0.18em; }
.page { width: min(760px, calc(100% - 32px)); margin: 0 auto; padding: 54px 0 64px; }
.header { text-align: center; margin-bottom: 34px; }
.app-icon { position: relative; width: 82px; height: 82px; margin: 0 auto 18px; border-radius: 24px; overflow: hidden; background: #0f251f; border: 1px solid var(--border); box-shadow: var(--shadow); }
.app-icon span:first-child { position: absolute; width: 72px; height: 72px; left: -24px; top: 5px; border-radius: 24px; background: linear-gradient(145deg, #ffe4a7, #c99039); }
.app-icon span:last-child { position: absolute; width: 68px; height: 68px; right: -27px; top: 7px; border-radius: 50%; background: linear-gradient(145deg, #1d4b3e, #07110f); box-shadow: 0 0 28px rgba(242, 195, 95, 0.66); }
.header h1 { margin: 0; font-size: clamp(2.1rem, 8vw, 4.4rem); line-height: 0.95; letter-spacing: -0.07em; }
.header p { margin: 12px auto 22px; color: var(--muted); font-size: 1.1rem; }
.language-nav { display: flex; gap: 8px; flex-wrap: wrap; justify-content: center; }
.language-nav a { color: var(--muted); border: 1px solid var(--border); border-radius: 999px; padding: 5px 9px; font-size: 0.78rem; background: rgba(255, 255, 255, 0.03); }
.language-nav a[aria-current="page"] { color: #17100b; background: var(--gold); border-color: transparent; }
.card { margin: 18px 0; padding: clamp(22px, 5vw, 34px); border: 1px solid var(--border); border-radius: 28px; background: var(--surface); box-shadow: 0 18px 70px rgba(0,0,0,.15); }
.card h2 { margin: 0 0 16px; color: var(--gold); text-transform: uppercase; letter-spacing: 0.12em; font-size: 0.82rem; }
.faq-item { border-bottom: 1px solid var(--border); padding: 16px 0; }
.faq-item:last-child { border-bottom: 0; padding-bottom: 0; }
.faq-item:first-of-type { padding-top: 0; }
.faq-item summary { cursor: pointer; color: var(--text); font-weight: 760; list-style-position: outside; }
.faq-item p { margin: 8px 0 0; color: var(--muted); }
.contact-card p { margin: 0; color: var(--muted); font-size: 1.02rem; }
.footer { display: flex; justify-content: center; gap: 16px; flex-wrap: wrap; color: var(--soft); padding: 28px 0 0; font-size: 0.92rem; }
.footer a { color: var(--soft); text-decoration: underline; text-underline-offset: 0.18em; }
@media (max-width: 520px) {
  .page { padding-top: 34px; }
  .card { border-radius: 22px; }
}
`.trim();

mkdirSync(outputDir, { recursive: true });
writeFileSync(join(outputDir, "styles.css"), `${css}\n`);

const sourceFiles = readdirSync(sourceDir).filter((file) => file.endsWith(".txt"));
for (const file of sourceFiles) {
  const code = basename(file, ".txt");
  if (!localeMeta.has(code)) {
    throw new Error(`No locale metadata for ${code}`);
  }
  const data = parseSupportFile(file);
  const html = supportPage(code, data, { rootPage: false });
  const outputName = code === "en" ? "index.html" : `${code}.html`;
  writeFileSync(join(outputDir, outputName), html);
  if (code === "en") {
    writeFileSync(join(outputDir, "en.html"), html);
    writeFileSync(join(docsDir, "index.html"), supportPage(code, data, { rootPage: true }));
  }
}

console.log(`Generated ${sourceFiles.length + 1} support pages in ${outputDir}`);
