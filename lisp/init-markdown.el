;;; init-markdown.el --- Markdown preview styling  -*- lexical-binding: t; -*-

;;; Commentary:
;; Configuration for markdown-mode's HTML preview (`C-c C-c p').  The default
;; `markdown' converter predates GFM, so pipe tables render as plain text; we
;; prefer pandoc (or multimarkdown) when installed and dress the generated
;; page up to look like a hand-built document.  Kept in its own file so the
;; large HTML/CSS/JS template does not clutter init-packages.el.

;;; Code:

;; markdown-mode preview (C-c C-c p): the default `markdown' converter
;; predates GFM, so pipe tables render as plain text. Prefer pandoc (or
;; multimarkdown) when installed. The generated page is dressed up to look
;; like a hand-built doc: an editorial "paper/seal-green" palette, Geist /
;; Geist Mono webfonts (the fonts openskills.cc uses), a sticky top bar with
;; a light/dark toggle, and a table-of-contents sidebar auto-built from the
;; headings. markdown-mode wraps pandoc's output between the body preamble
;; (nav + <main>) and epilogue (closing tags + the driver script).
;;
;; ```mermaid fenced blocks pass through pandoc as <pre class="mermaid">; the
;; epilogue script loads mermaid.js from a CDN (so a diagram needs a network
;; connection) and re-renders diagrams in the matching theme when toggled.
(with-eval-after-load 'markdown-mode
  (cond ((executable-find "pandoc")
         (setq markdown-command "pandoc -f gfm -t html5"))
        ((executable-find "multimarkdown")
         (setq markdown-command "multimarkdown")))
  (setq markdown-fontify-code-blocks-natively t)
  (setq markdown-xhtml-header-content
        "<meta name=viewport content='width=device-width, initial-scale=1'>
         <link rel=preconnect href='https://fonts.googleapis.com'>
         <link rel=preconnect href='https://fonts.gstatic.com' crossorigin>
         <link rel=stylesheet href='https://fonts.googleapis.com/css2?family=Fira+Code:wght@400;500;600;700&display=swap'>
         <script>
           (function () {
             try {
               var t = localStorage.getItem('mdtheme') ||
                 (matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
               document.documentElement.setAttribute('data-theme', t);
             } catch (e) {}
           })();
         </script>
         <style>
           :root {
             --paper:#EFF1EB; --paper-2:#E7E9E1; --paper-3:#DDE0D5;
             --rule:#CDD3C6; --ink:#171C18; --ink-soft:#576057; --ink-faint:#7C8479;
             --seal:#1F5D3F; --band:#10140F; --band-ink:#E8ECE0; --band-rule:#2A3126;
             --font-display:'Fira Code',ui-monospace,monospace;
             --font-body:'Fira Code',ui-monospace,monospace;
             --font-mono:'Fira Code',ui-monospace,monospace;
             --maxw:1180px;
           }
           :root[data-theme=dark] {
             --paper:#12160F; --paper-2:#1A1E15; --paper-3:#222719;
             --rule:#2E3529; --ink:#E8ECE0; --ink-soft:#A2AA98; --ink-faint:#79826F;
             --seal:#6DB88A; --band:#0C0F09; --band-ink:#E8ECE0; --band-rule:#23291D;
           }
           * { box-sizing:border-box; }
           html { scroll-behavior:smooth; -webkit-text-size-adjust:100%; }
           body { margin:0; background:var(--paper); color:var(--ink);
                  font-family:var(--font-body); font-size:15px; line-height:1.75;
                  -webkit-font-smoothing:antialiased; }
           ::selection { background:var(--seal); color:var(--paper); }
           a { color:var(--seal); text-underline-offset:2px; }
           h1, h2, h3, h4 { font-family:var(--font-display); font-weight:700;
                            letter-spacing:-0.01em; line-height:1.2; text-wrap:balance; }
           /* top bar */
           .nav { position:sticky; top:0; z-index:50; border-bottom:1px solid var(--rule);
                  background:color-mix(in oklab, var(--paper) 90%, transparent);
                  backdrop-filter:blur(8px); }
           .nav-in { max-width:var(--maxw); margin:0 auto; height:58px; display:flex;
                     align-items:center; justify-content:space-between;
                     padding:0 clamp(1rem,4vw,2rem); }
           .brand { display:flex; align-items:center; gap:.6rem;
                    text-decoration:none; color:var(--ink); }
           .brand svg { width:24px; height:24px; }
           .brand b { font-family:var(--font-display); font-weight:800; font-size:1.02rem; }
           .brand span { font-family:var(--font-mono); font-size:.72rem;
                         color:var(--ink-faint); letter-spacing:.04em; }
           .themebtn { font-family:var(--font-mono); font-size:.7rem; letter-spacing:.08em;
                       text-transform:uppercase; background:none; border:1px solid var(--rule);
                       color:var(--ink-soft); padding:.36rem .6rem; border-radius:2px; cursor:pointer; }
           .themebtn:hover { border-color:var(--ink-soft); color:var(--ink); }
           /* layout */
           .shell { max-width:var(--maxw); margin:0 auto; padding:0 clamp(1rem,4vw,2rem);
                    display:grid; grid-template-columns:1fr; gap:2rem; }
           @media (min-width:960px) { .shell { grid-template-columns:220px 1fr; gap:3rem;
                                               align-items:start; } }
           .toc { display:none; }
           @media (min-width:960px) {
             .toc { display:block; position:sticky; top:78px; font-family:var(--font-mono);
                    font-size:.78rem; line-height:1.5; border-left:1px solid var(--rule);
                    padding-left:1rem; max-height:calc(100vh - 100px); overflow:auto; }
             .toc a { display:flex; gap:.45rem; color:var(--ink-soft);
                      text-decoration:none; padding:.28rem 0; }
             .toc a:hover { color:var(--ink); }
             .toc a .n { flex:0 0 auto; min-width:1.4rem; text-align:right; color:var(--ink-faint); }
             .toc a.toc-sub { padding-left:1.85rem; font-size:.74rem; }
             .toc .t { color:var(--seal); text-transform:uppercase; letter-spacing:.14em;
                       font-size:.66rem; margin-bottom:.4rem; }
           }
           main { min-width:0; padding:2.5rem 0 5rem; }
           main h1 { font-size:clamp(2rem,4.5vw,3rem); margin:0 0 .8rem; }
           main > h2 { font-size:clamp(1.4rem,3vw,1.9rem); margin:2.6rem 0 .8rem;
                       padding-bottom:.3rem; border-bottom:1px solid var(--rule);
                       display:flex; align-items:baseline; gap:.7rem; }
           main > h2[data-num]::before { content:attr(data-num);
                               flex:0 0 auto; min-width:1.5rem; text-align:right;
                               font-family:var(--font-mono); font-size:.95rem; font-weight:500;
                               color:var(--ink-faint); letter-spacing:.02em; }
           h3 { font-size:1.2rem; margin:2rem 0 .5rem; }
           h4 { font-size:1.02rem; margin:1.4rem 0 .4rem; }
           p { margin:.9rem 0; }
           ul, ol { padding-left:1.3rem; }
           li { margin:.4rem 0; }
           li input[type=checkbox] { margin:0 .4em 0 -1.3em; }
           blockquote { border-left:3px solid var(--seal); background:var(--paper-2);
                        margin:1.2rem 0; padding:.7rem 1.1rem; color:var(--ink-soft);
                        border-radius:0 2px 2px 0; }
           blockquote p:last-child { margin-bottom:0; }
           hr { border:0; border-top:1px solid var(--rule); margin:2.5rem 0; }
           img { max-width:100%; }
           pre { background:var(--band); color:var(--band-ink); border:1px solid var(--band-rule);
                 border-radius:2px; padding:1.1rem 1.2rem; overflow-x:auto;
                 font-family:var(--font-mono); font-size:.82rem; line-height:1.7; margin:1.2rem 0; }
           pre code { background:none; padding:0; color:inherit; font-size:1em; }
           :not(pre) > code { font-family:var(--font-mono); font-size:.86em;
                              background:var(--paper-3); padding:.06em .35em; border-radius:2px; }
           table { width:100%; border-collapse:collapse; margin:1.4rem 0; font-size:.95rem;
                   display:block; overflow-x:auto; }
           th, td { border:1px solid var(--rule); padding:.55rem .8rem;
                    text-align:left; vertical-align:top; }
           th { font-family:var(--font-mono); font-size:.72rem; letter-spacing:.06em;
                text-transform:uppercase; color:var(--seal); background:var(--paper-2); font-weight:500; }
           /* mermaid diagram card */
           pre.mermaid { background:#ffffff; color:#171C18; border:1px solid #CDD3C6;
                         border-left:3px solid var(--seal); border-radius:2px; padding:1.4rem 1rem;
                         margin:1.4rem 0; overflow-x:auto; display:flex; justify-content:center;
                         font-family:var(--font-body); font-size:1rem; }
           @media (prefers-reduced-motion: reduce) {
             html { scroll-behavior:auto; }
             * { transition:none !important; animation:none !important; }
           }
         </style>")
  (setq markdown-xhtml-body-preamble
        "<header class=nav><div class=nav-in>
           <a class=brand href='#'>
             <b id=brandname>Preview</b> <span>markdown</span>
           </a>
           <button class=themebtn id=themebtn type=button>Dark</button>
         </div></header>
         <div class=shell>
           <nav class=toc id=toc></nav>
           <main>")
  (setq markdown-xhtml-body-epilogue
        "  </main>
         </div>
         <script type=module>
           const root = document.documentElement;
           const btn = document.getElementById('themebtn');
           const setLabel = () =>
             btn.textContent = root.getAttribute('data-theme') === 'dark' ? 'Light' : 'Dark';
           setLabel();

           const bn = document.getElementById('brandname');
           if (document.title) bn.textContent = document.title;

           // table of contents, numbered, from the headings inside <main>
           const main = document.querySelector('main');
           const toc = document.getElementById('toc');
           const heads = main ? main.querySelectorAll('h2, h3') : [];
           if (heads.length) {
             const t = document.createElement('div');
             t.className = 't'; t.textContent = 'Contents';
             toc.appendChild(t);
             let n = 0;
             heads.forEach(h => {
               if (!h.id)
                 h.id = h.textContent.trim().toLowerCase()
                          .replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
               const a = document.createElement('a');
               a.href = '#' + h.id;
               if (h.tagName === 'H3') {
                 a.className = 'toc-sub';
                 a.textContent = h.textContent;
               } else {
                 n++;
                 h.setAttribute('data-num', n);   // same counter drives the heading marker
                 const num = document.createElement('span');
                 num.className = 'n'; num.textContent = n + ' \\u00b7';
                 const lab = document.createElement('span');
                 lab.textContent = h.textContent;
                 a.append(num, lab);
               }
               toc.appendChild(a);
             });
           } else if (toc) {
             toc.remove();
           }

           // normalise pandoc's <pre class=mermaid><code>...</code></pre> into
           // a bare <pre class=mermaid> holding the diagram source as text
           const nodes = [];
           document.querySelectorAll(
             'pre.mermaid > code, code.language-mermaid, code.mermaid').forEach(code => {
               const host = code.closest('pre') || code;
               const box = document.createElement('pre');
               box.className = 'mermaid';
               box.textContent = code.textContent;
               host.replaceWith(box);
               nodes.push(box);
             });

           btn.addEventListener('click', () => {
             const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
             root.setAttribute('data-theme', next);
             try { localStorage.setItem('mdtheme', next); } catch (e) {}
             setLabel();
           });

           // diagrams always render in mermaid's light theme so they stay
           // readable on the fixed white card, whatever the page theme is
           if (nodes.length) {
             const mermaid = (await import(
               'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs')).default;
             mermaid.initialize({ startOnLoad: false, securityLevel: 'loose', theme: 'default' });
             await mermaid.run({ nodes });
           }
         </script>"))

(provide 'init-markdown)
;;; init-markdown.el ends here
