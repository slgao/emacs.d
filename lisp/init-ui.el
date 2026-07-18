(setq custom-safe-themes t)

;; Per-OS default font. Kept out of custom.el so the same file works across
;; machines (custom.el used to hard-code the font and caused merge conflicts).
;; Runs on after-init-hook so it applies after custom.el is loaded.
(defun my/set-default-font ()
  (cond
   ((eq system-type 'darwin)
    (set-face-attribute 'default nil :family "Monaco" :height 155))
   ((eq system-type 'windows-nt)
    (set-face-attribute 'default nil :family "Consolas" :height 110))
   (t
    (set-face-attribute 'default nil :family "Ubuntu Mono" :height 105)))
  ;; TUI spinner glyphs (✳ ✶ ✻ ✽ used by Claude Code etc.) normally fall back
  ;; to DejaVu Sans, whose descent (0.236em) exceeds Ubuntu Mono's (0.189em) —
  ;; each animation frame changes the line height and the buffer bounces.
  ;; Render symbols with DejaVu Sans Mono scaled to fit inside the default
  ;; line box (0.189/0.236 ≈ 0.8) so lines keep a constant height.
  (when (and (display-graphic-p)
             (member "DejaVu Sans Mono" (font-family-list)))
    ;; Explicit size (0.8 x default) rather than face-font-rescale-alist: the
    ;; rescale rule is name-based and also shrank every other use of the font
    ;; (fixed-pitch resolves "Monospace" to DejaVu Sans Mono → tiny lsp-ui doc
    ;; popups). A sized font-spec only affects these fallback glyphs.
    (let ((pt (/ (face-attribute 'default :height) 10.0)))
      (set-fontset-font t 'symbol
                        (font-spec :family "DejaVu Sans Mono" :size (* 0.8 pt))
                        nil 'prepend))))
(add-hook 'after-init-hook #'my/set-default-font)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
;; show line numbers in code buffers (native, fast replacement for linum)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(setq initial-frame-alist (quote ((fullscreen . maximized))))
(global-hl-line-mode t)
(setq-default cursor-type 'bar)
;; (load-theme 'monokai t)
(load-theme 'gruvbox t)
;; config split window, split window horizontally by default
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;; configure mode-line to show date, time and column number
(setq column-number-mode t)
(setq display-time-day-and-date t)
(setq display-time-24hr-format t)
(display-time)

;; change selected region color
;; probably need to configure monokai color first
;; (set-face-attribute 'region nil :background "#7FB3D5")

(provide 'init-ui)
