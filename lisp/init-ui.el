(setq custom-safe-themes t)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(setq inhibit-splash-screen t)
(global-linum-mode t)
(setq initial-frame-alist (quote ((fullscreen . maximized))))
(global-hl-line-mode t)
(setq-default cursor-type 'bar)
(load-theme 'monokai t)
;; config split window, split window horizontally by default
(setq split-height-threshold nil)
(setq split-width-threshold 0)

;; config font
(add-to-list 'default-frame-alist
             '(font . "Consolas-11"))
(set-face-bold-p 'bold 1)

;; configure mode-line to show date, time and column number 
(setq display-time-24hr-format t)
(setq display-time-day-and-date t)
(setq column-number-mode t)

(provide 'init-ui)
