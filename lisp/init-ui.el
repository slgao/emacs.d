(setq custom-safe-themes t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(global-linum-mode t)
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
