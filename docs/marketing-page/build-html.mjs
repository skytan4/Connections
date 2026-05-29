import { mkdirSync, readFileSync, writeFileSync } from "node:fs";
import { basename, join } from "node:path";

const sourceDir = new URL("./", import.meta.url).pathname;
const outputDir = join(sourceDir, "../marketing");
const appStoreUrl = "https://apps.apple.com/app/id6763803257";
const redeemUrl = "https://apps.apple.com/redeem?ctx=offercodes&id=6763803257&code=GETSTARTED";
const ogBaseUrl = "https://skytan4.github.io/Connections/marketing/";
const ogImageUrl = `${ogBaseUrl}preview.png`;
const researchLinks = [
  "https://journals.sagepub.com/doi/10.1177/0146167297234003",
  "https://www.affective-science.org/pubs/1998/LaurenFBPl1998.pdf",
];

const redeemLabels = {
  "en-US": "Redeem Full Access Free",
  "es-ES": "Canjea Acceso Completo gratis",
  "fr": "Débloquez l'Accès complet gratuitement",
  "de": "Vollzugriff gratis freischalten",
  "pt-BR": "Resgate o Acesso Completo grátis",
  "nl": "Verzilver gratis Volledige toegang",
  "it": "Riscatta l'Accesso completo gratis",
  "sv": "Lös in Full åtkomst gratis",
  "da": "Indløs Fuld adgang gratis",
  "nb": "Løs inn Full tilgang gratis",
  "fi": "Lunasta Täysi käyttöoikeus ilmaiseksi",
  "pl": "Odbierz Pełny dostęp za darmo",
  "ja": "フルアクセスを無料で利用",
  "zh-Hans": "免费解锁完整版",
  "ru": "Получите полный доступ бесплатно",
};

const offerEyebrows = {
  "en-US": "Limited-time offer",
  "es-ES": "Oferta por tiempo limitado",
  "fr": "Offre à durée limitée",
  "de": "Zeitlich begrenztes Angebot",
  "pt-BR": "Oferta por tempo limitado",
  "nl": "Tijdelijke aanbieding",
  "it": "Offerta a tempo limitato",
  "sv": "Tidsbegränsat erbjudande",
  "da": "Tidsbegrænset tilbud",
  "nb": "Tidsbegrenset tilbud",
  "fi": "Rajoitetun ajan tarjous",
  "pl": "Oferta ograniczona czasowo",
  "ja": "期間限定オファー",
  "zh-Hans": "限时优惠",
  "ru": "Предложение ограничено по времени",
};

const offerTitles = {
  "en-US": "Full Access is free through July 30, 2026",
  "es-ES": "Acceso completo gratis hasta el 30 de julio de 2026",
  "fr": "Accès complet gratuit jusqu'au 30 juillet 2026",
  "de": "Vollzugriff gratis bis zum 30. Juli 2026",
  "pt-BR": "Acesso Completo grátis até 30 de julho de 2026",
  "nl": "Volledige toegang gratis tot 30 juli 2026",
  "it": "Accesso completo gratis fino al 30 luglio 2026",
  "sv": "Full åtkomst är gratis till 30 juli 2026",
  "da": "Fuld adgang er gratis til 30. juli 2026",
  "nb": "Full tilgang er gratis til 30. juli 2026",
  "fi": "Täysi käyttöoikeus ilmaiseksi 30. heinäkuuta 2026 asti",
  "pl": "Pełny dostęp za darmo do 30 lipca 2026",
  "ja": "2026年7月30日までフルアクセス無料",
  "zh-Hans": "完整版免费开放至 2026 年 7 月 30 日",
  "ru": "Полный доступ бесплатен до 30 июля 2026 года",
};

const offerBodies = {
  "en-US": "Unlock the premium library with 2,800+ prompts and follow-up questions.",
  "es-ES": "Desbloquea la biblioteca premium con más de 2,800 preguntas y seguimientos.",
  "fr": "Débloquez la bibliothèque premium avec plus de 2 800 questions et relances.",
  "de": "Schalte die Premium-Bibliothek mit über 2.800 Prompts und Folgefragen frei.",
  "pt-BR": "Desbloqueie a biblioteca premium com mais de 2.800 prompts e perguntas de acompanhamento.",
  "nl": "Ontgrendel de premiumbibliotheek met 2.800+ prompts en vervolgvragen.",
  "it": "Sblocca la libreria premium con oltre 2.800 prompt e domande di approfondimento.",
  "sv": "Lås upp premiumbiblioteket med 2 800+ prompter och uppföljningsfrågor.",
  "da": "Lås op for premiumbiblioteket med 2.800+ prompts og opfølgende spørgsmål.",
  "nb": "Lås opp premiumbiblioteket med 2 800+ prompter og oppfølgingsspørsmål.",
  "fi": "Avaa premiumkirjasto, jossa on yli 2 800 kehotetta ja jatkokysymystä.",
  "pl": "Odblokuj bibliotekę premium z ponad 2 800 promptami i pytaniami pogłębiającymi.",
  "ja": "2,800以上の質問とフォローアップ質問を含むプレミアムライブラリを利用できます。",
  "zh-Hans": "解锁高级内容库，包含 2,800 多个问题和跟进问题。",
  "ru": "Откройте премиум-библиотеку с 2 800+ вопросами и уточняющими подсказками.",
};

const locales = [
  ["en-US", "English", "en", "./"],
  ["es-ES", "Español", "es-ES", "es-ES.html"],
  ["fr", "Français", "fr", "fr.html"],
  ["de", "Deutsch", "de", "de.html"],
  ["pt-BR", "Português (BR)", "pt-BR", "pt-BR.html"],
  ["nl", "Nederlands", "nl", "nl.html"],
  ["it", "Italiano", "it", "it.html"],
  ["sv", "Svenska", "sv", "sv.html"],
  ["da", "Dansk", "da", "da.html"],
  ["nb", "Norsk bokmål", "nb", "nb.html"],
  ["fi", "Suomi", "fi", "fi.html"],
  ["pl", "Polski", "pl", "pl.html"],
  ["ja", "日本語", "ja", "ja.html"],
  ["zh-Hans", "简体中文", "zh-Hans", "zh-Hans.html"],
  ["ru", "Русский", "ru", "ru.html"],
];

const localeMeta = new Map(locales.map(([code, label, lang, href]) => [code, { label, lang, href }]));

function escapeHtml(value) {
  return value
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;");
}

function splitTitleBody(block) {
  const lines = block.split("\n");
  return {
    title: lines[0],
    body: lines.slice(1).join("\n"),
  };
}

function paragraph(text) {
  return `<p>${escapeHtml(text)}</p>`;
}

function multilineParagraphs(text) {
  return text.split("\n").filter(Boolean).map(paragraph).join("\n");
}

function cta(block, className = "button") {
  const label = block.replace(/^\[/, "").replace(/\]$/, "");
  return `<a class="${className}" href="${appStoreUrl}">${escapeHtml(label)}</a>`;
}

function localized(map, code) {
  return map[code] ?? map["en-US"];
}

function redeemCta(code, className = "button button-secondary") {
  const label = redeemLabels[code] ?? redeemLabels["en-US"];
  return `<a class="${className}" href="${redeemUrl}">${escapeHtml(label)}</a>`;
}

function offerBlock(code) {
  return `<aside class="offer-card">
            <p class="offer-eyebrow">${escapeHtml(localized(offerEyebrows, code))}</p>
            <h2>${escapeHtml(localized(offerTitles, code))}</h2>
            <p>${escapeHtml(localized(offerBodies, code))}</p>
            ${redeemCta(code, "button button-offer")}
          </aside>`;
}

function offerStrip(code) {
  return `<aside class="offer-strip">
      <p><strong>${escapeHtml(localized(offerEyebrows, code))}:</strong> ${escapeHtml(localized(offerTitles, code))}. ${escapeHtml(localized(offerBodies, code))}</p>
      ${redeemCta(code, "button button-strip")}
    </aside>`;
}

function card(block) {
  const { title, body } = splitTitleBody(block);
  return `<article class="mini-card">
    <h3>${escapeHtml(title)}</h3>
    ${multilineParagraphs(body)}
  </article>`;
}

function bullets(block) {
  const lines = block.split("\n");
  const intro = lines[0];
  const items = lines.slice(1).map((line) => line.replace(/^- /, ""));
  return `${paragraph(intro)}
  <ul>
    ${items.map((item) => `<li>${escapeHtml(item)}</li>`).join("\n")}
  </ul>`;
}

function researchList(block) {
  const lines = block.split("\n");
  const intro = lines[0];
  const items = lines.slice(1).map((line) => line.replace(/^- /, ""));
  return `${paragraph(intro)}
  <ul>
    ${items.map((item, index) => `<li><a href="${researchLinks[index]}">${escapeHtml(item)}</a></li>`).join("\n")}
  </ul>`;
}

function faq(block) {
  const { title, body } = splitTitleBody(block);
  return `<details>
    <summary>${escapeHtml(title)}</summary>
    ${multilineParagraphs(body)}
  </details>`;
}

function invitePageHref(code) {
  return code === "en-US" ? "invite.html" : `invite-${code}.html`;
}

function languageNav(currentCode, options = {}) {
  return `<nav class="language-nav" aria-label="Language">
    ${locales.map(([code, label, , href]) => {
      const target = options.invite ? invitePageHref(code) : code === "en-US" ? "./" : href;
      const current = code === currentCode ? ` aria-current="page"` : "";
      return `<a href="${target}"${current}>${escapeHtml(label)}</a>`;
    }).join("\n")}
  </nav>`;
}

function pageHtml(code, content, options = {}) {
  const blocks = content.trim().split(/\n{2,}/);
  const meta = localeMeta.get(code);
  const headlineLines = blocks[4].split("\n");
  const ogHref = options.ogHref ?? meta.href;
  const ogUrl = ogHref === "./" ? ogBaseUrl : `${ogBaseUrl}${ogHref}`;
  const ogTitle = `${blocks[0]} — ${blocks[1]}`;
  const brandHref = options.brandHref ?? "./";
  const heroAction = options.redeem
    ? `${offerBlock(code)}\n          ${cta(blocks[3])}`
    : cta(blocks[3]);

  return `<!DOCTYPE html>
<html lang="${meta.lang}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>${escapeHtml(blocks[0])} — ${escapeHtml(blocks[1])}</title>
  <meta name="description" content="${escapeHtml(blocks[2])}">
  <meta property="og:type" content="website">
  <meta property="og:site_name" content="${escapeHtml(blocks[0])}">
  <meta property="og:locale" content="${escapeHtml(meta.lang)}">
  <meta property="og:url" content="${escapeHtml(ogUrl)}">
  <meta property="og:title" content="${escapeHtml(ogTitle)}">
  <meta property="og:description" content="${escapeHtml(blocks[2])}">
  <meta property="og:image" content="${escapeHtml(ogImageUrl)}">
  <meta property="og:image:width" content="1200">
  <meta property="og:image:height" content="630">
  <meta name="twitter:card" content="summary_large_image">
  <meta name="twitter:title" content="${escapeHtml(blocks[0])}">
  <meta name="twitter:description" content="${escapeHtml(blocks[2])}">
  <meta name="twitter:image" content="${escapeHtml(ogImageUrl)}">
  <link rel="stylesheet" href="styles.css">
</head>
<body>
  <main class="page">
${options.redeem ? `    ${offerStrip(code)}\n` : ""}    <header class="hero">
      <div class="topbar">
        <a class="brand" href="${escapeHtml(brandHref)}" aria-label="${escapeHtml(blocks[0])}">
          <span class="mark" aria-hidden="true"><span></span><span></span></span>
          <span>${escapeHtml(blocks[0])}</span>
        </a>
        ${languageNav(code, { invite: options.inviteNav })}
      </div>

      <section class="hero-grid">
        <div class="hero-copy">
          <p class="eyebrow">${escapeHtml(blocks[0])}</p>
          <h1>${escapeHtml(blocks[1])}</h1>
          ${paragraph(blocks[2])}
          ${heroAction}
        </div>
        <div class="visual-card" aria-hidden="true">
          <div class="shape-square"></div>
          <div class="shape-circle"></div>
          <div class="shape-glow"></div>
        </div>
      </section>
    </header>

    <section class="section opener">
      <h2>${escapeHtml(headlineLines[0])}<br>${escapeHtml(headlineLines[1] || "")}</h2>
      ${paragraph(blocks[5])}
      ${paragraph(blocks[6])}
    </section>

    <section class="section research">
      <h2>${escapeHtml(blocks[7])}</h2>
      ${[8, 9, 10, 11].map((index) => paragraph(blocks[index])).join("\n")}
      ${researchList(blocks[12])}
    </section>

    <section class="section">
      <h2>${escapeHtml(blocks[13])}</h2>
      <div class="card-grid">
        ${[14, 15, 16, 17].map((index) => card(blocks[index])).join("\n")}
      </div>
    </section>

    <section class="section tone">
      <h2>${escapeHtml(blocks[18])}</h2>
      <div class="tone-list">
        ${blocks[19].split("\n").map((line) => `<p>${escapeHtml(line)}</p>`).join("\n")}
      </div>
      ${paragraph(blocks[20])}
    </section>

    <section class="section">
      <h2>${escapeHtml(blocks[21])}</h2>
      <div class="card-grid">
        ${[22, 23, 24, 25].map((index) => card(blocks[index])).join("\n")}
      </div>
    </section>

    <section class="section purchase">
      <h2>${escapeHtml(blocks[26])}</h2>
      ${paragraph(blocks[27])}
      ${paragraph(blocks[28])}
      ${bullets(blocks[29])}
      <p class="purchase-note">${escapeHtml(blocks[30])}</p>
    </section>

    <section class="section privacy">
      <h2>${escapeHtml(blocks[31])}</h2>
      <div class="privacy-list">
        ${blocks[32].split("\n").map((line) => `<span>${escapeHtml(line)}</span>`).join("\n")}
      </div>
      ${paragraph(blocks[33])}
    </section>

    <section class="section final-cta">
      <h2>${escapeHtml(blocks[34])}</h2>
      ${paragraph(blocks[35])}
      ${cta(blocks[36])}${options.redeem ? `\n      ${redeemCta(code)}` : ""}
    </section>

    <section class="section faq">
      <h2>${escapeHtml(blocks[37])}</h2>
      ${[38, 39, 40, 41, 42].map((index) => faq(blocks[index])).join("\n")}
    </section>

    <footer class="footer">
      <a href="../privacy">${escapeHtml(blocks[44].split("\n")[0])}</a>
      <a href="../">${escapeHtml(blocks[44].split("\n")[1])}</a>
      <span>${escapeHtml(blocks[44].split("\n")[2])}</span>
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
  --border: rgba(255, 246, 222, 0.18);
  --text: #fff3d8;
  --muted: rgba(255, 243, 216, 0.72);
  --soft: rgba(255, 243, 216, 0.54);
  --gold: #f2c35f;
  --amber: #d9851f;
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
    radial-gradient(circle at 78% 8%, rgba(41, 94, 73, 0.7), transparent 28rem),
    linear-gradient(145deg, #0b1512 0%, #102119 58%, #0c1412 100%);
  line-height: 1.6;
}
a { color: var(--gold); text-decoration: none; }
a:hover { text-decoration: underline; text-underline-offset: 0.18em; }
.page { width: min(1120px, calc(100% - 36px)); margin: 0 auto; padding: 28px 0 64px; }
.offer-strip { display: flex; align-items: center; justify-content: space-between; gap: 16px; margin: 0 0 26px; padding: 14px 16px; border: 1px solid rgba(242, 195, 95, 0.54); border-radius: 20px; background: linear-gradient(145deg, rgba(242, 195, 95, 0.2), rgba(255, 246, 222, 0.08)); box-shadow: 0 18px 58px rgba(0,0,0,.2); }
.offer-strip p { margin: 0; color: var(--muted); font-size: 0.98rem; line-height: 1.35; }
.offer-strip strong { color: var(--gold); text-transform: uppercase; letter-spacing: 0.08em; font-size: 0.82rem; }
.button-strip { flex: 0 0 auto; min-height: 42px; margin-top: 0; background: var(--cream); color: #17100b; border: 1px solid rgba(255, 224, 161, 0.78); box-shadow: 0 14px 40px rgba(242, 195, 95, 0.24); }
.topbar { display: flex; align-items: center; justify-content: space-between; gap: 18px; margin-bottom: 54px; }
.brand { display: inline-flex; align-items: center; gap: 12px; color: var(--text); font-weight: 760; letter-spacing: -0.02em; }
.mark { position: relative; width: 36px; height: 36px; border-radius: 12px; overflow: hidden; background: #0f251f; box-shadow: inset 0 0 0 1px var(--border); }
.mark span:first-child { position: absolute; width: 30px; height: 30px; left: -9px; top: 3px; border-radius: 10px; background: var(--cream); }
.mark span:last-child { position: absolute; width: 29px; height: 29px; right: -10px; top: 3px; border-radius: 50%; background: var(--green); box-shadow: 0 0 24px rgba(242, 195, 95, 0.55); }
.language-nav { display: flex; gap: 8px; flex-wrap: wrap; justify-content: flex-end; max-width: 760px; }
.language-nav a { color: var(--muted); border: 1px solid var(--border); border-radius: 999px; padding: 5px 9px; font-size: 0.78rem; background: rgba(255, 255, 255, 0.03); }
.language-nav a[aria-current="page"] { color: #17100b; background: var(--gold); border-color: transparent; }
.hero { padding: 18px 0 36px; }
.hero-grid { display: grid; grid-template-columns: minmax(0, 1.02fr) minmax(300px, 0.78fr); gap: 48px; align-items: center; }
.hero-copy h1 { margin: 0; max-width: 780px; font-size: clamp(3.1rem, 8vw, 6.8rem); line-height: 0.9; letter-spacing: -0.075em; }
.hero-copy p { max-width: 680px; color: var(--muted); font-size: clamp(1.08rem, 2vw, 1.34rem); }
.eyebrow { color: var(--gold) !important; font-size: 0.78rem !important; text-transform: uppercase; letter-spacing: 0.18em; font-weight: 780; margin-bottom: 12px; }
.button { display: inline-flex; align-items: center; justify-content: center; min-height: 48px; margin-top: 18px; padding: 0 20px; border-radius: 999px; background: var(--gold); color: #17100b; font-weight: 780; box-shadow: 0 12px 40px rgba(217, 133, 31, 0.26); }
.button-secondary { background: var(--cream); color: #17100b; border: 1px solid rgba(255, 224, 161, 0.72); box-shadow: 0 14px 42px rgba(242, 195, 95, 0.22); margin-left: 10px; }
.offer-card { max-width: 640px; margin-top: 22px; padding: 22px; border: 1px solid rgba(242, 195, 95, 0.48); border-radius: 26px; background: linear-gradient(145deg, rgba(242, 195, 95, 0.18), rgba(255, 246, 222, 0.07)); box-shadow: 0 20px 70px rgba(0,0,0,.22); }
.offer-card .offer-eyebrow { margin: 0 0 8px; color: var(--gold); font-size: 0.76rem; font-weight: 820; letter-spacing: 0.16em; text-transform: uppercase; }
.offer-card h2 { margin: 0; color: var(--cream); font-size: clamp(1.42rem, 2.4vw, 2rem); line-height: 1.08; letter-spacing: -0.035em; }
.offer-card p { margin: 10px 0 0; color: var(--muted); font-size: 1.02rem; }
.button-offer { width: 100%; min-height: 54px; margin-top: 18px; background: var(--cream); color: #17100b; border: 1px solid rgba(255, 224, 161, 0.78); box-shadow: 0 18px 50px rgba(242, 195, 95, 0.26); }
.visual-card { position: relative; min-height: 420px; border: 1px solid var(--border); border-radius: 36px; overflow: hidden; background: linear-gradient(145deg, #11251e, #08110f); box-shadow: var(--shadow); }
.shape-square { position: absolute; width: 78%; height: 78%; left: -23%; top: 11%; border-radius: 30%; background: linear-gradient(145deg, #ffe4a7, #c99039); box-shadow: inset 0 0 18px rgba(255,255,255,.24); }
.shape-circle { position: absolute; width: 76%; height: 76%; right: -25%; top: 12%; border-radius: 50%; background: linear-gradient(145deg, #1d4b3e, #07110f); box-shadow: inset 0 0 14px rgba(255,224,161,.16); }
.shape-glow { position: absolute; inset: 0; background: radial-gradient(circle at 50% 49%, rgba(242,195,95,.9), rgba(217,133,31,.38) 19%, transparent 36%); mix-blend-mode: screen; }
.section { margin: 22px 0; padding: clamp(28px, 5vw, 54px); border: 1px solid var(--border); border-radius: 34px; background: var(--surface); box-shadow: 0 18px 70px rgba(0,0,0,.15); }
.section h2 { margin: 0 0 18px; font-size: clamp(1.9rem, 4vw, 3.5rem); line-height: 1.02; letter-spacing: -0.055em; }
.section p { max-width: 840px; color: var(--muted); font-size: 1.04rem; }
.opener h2 { color: var(--cream); }
.research { background: linear-gradient(145deg, rgba(255, 246, 222, 0.11), rgba(255, 246, 222, 0.055)); }
.research ul, .purchase ul { margin: 18px 0 0; padding-left: 1.2rem; color: var(--muted); }
.research li, .purchase li { margin: 8px 0; }
.card-grid { display: grid; grid-template-columns: repeat(2, minmax(0, 1fr)); gap: 14px; }
.mini-card { padding: 22px; border-radius: 22px; background: var(--surface-strong); border: 1px solid var(--border); }
.mini-card h3 { margin: 0 0 8px; color: var(--gold); font-size: 1.04rem; }
.mini-card p { margin: 0; font-size: 0.98rem; }
.tone-list { display: grid; gap: 10px; margin-bottom: 18px; }
.tone-list p, .privacy-list span, .purchase-note { border: 1px solid var(--border); background: rgba(255, 246, 222, 0.09); border-radius: 18px; padding: 14px 16px; color: var(--text); font-weight: 650; }
.privacy-list { display: grid; grid-template-columns: repeat(4, minmax(0, 1fr)); gap: 10px; margin-bottom: 20px; }
.final-cta { text-align: center; background: radial-gradient(circle at 50% 0%, rgba(242,195,95,.22), var(--surface) 48%); }
.final-cta p { margin-left: auto; margin-right: auto; }
.faq details { border-bottom: 1px solid var(--border); padding: 18px 0; }
.faq details:last-child { border-bottom: 0; }
.faq summary { cursor: pointer; font-weight: 780; color: var(--text); }
.faq details p { margin-bottom: 0; }
.footer { display: flex; justify-content: center; gap: 18px; flex-wrap: wrap; color: var(--soft); padding: 34px 0 0; font-size: 0.95rem; }
.footer a { color: var(--soft); text-decoration: underline; text-underline-offset: 0.18em; }
@media (max-width: 820px) {
  .offer-strip { align-items: stretch; flex-direction: column; }
  .button-strip { width: 100%; }
  .topbar { align-items: flex-start; flex-direction: column; }
  .language-nav { justify-content: flex-start; }
  .hero-grid { grid-template-columns: 1fr; }
  .visual-card { min-height: 290px; }
  .button-secondary { margin-left: 0; }
  .card-grid, .privacy-list { grid-template-columns: 1fr; }
  .section { border-radius: 24px; }
}
`.trim();

mkdirSync(outputDir, { recursive: true });
writeFileSync(join(outputDir, "styles.css"), `${css}\n`);

for (const [code] of locales) {
  const sourcePath = join(sourceDir, `${code}.txt`);
  const content = readFileSync(sourcePath, "utf8");
  const html = pageHtml(code, content);
  const fileName = code === "en-US" ? "index.html" : `${basename(sourcePath, ".txt")}.html`;
  writeFileSync(join(outputDir, fileName), html);
  if (code === "en-US") {
    writeFileSync(join(outputDir, "en-US.html"), html);
  }
}

const outreachPages = locales.map(([sourceCode]) => ({
  sourceCode,
  outFile: invitePageHref(sourceCode),
}));

for (const { sourceCode, outFile } of outreachPages) {
  const sourcePath = join(sourceDir, `${sourceCode}.txt`);
  const content = readFileSync(sourcePath, "utf8");
  const html = pageHtml(sourceCode, content, { redeem: true, ogHref: outFile, inviteNav: true, brandHref: outFile });
  writeFileSync(join(outputDir, outFile), html);
}

console.log(`Generated ${locales.length + 1 + outreachPages.length} marketing pages in ${outputDir}`);
