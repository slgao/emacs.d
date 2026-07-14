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
    (set-face-attribute 'default nil :family "Ubuntu Mono" :height 105))))
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
