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
             '(font . "Consolas-9"))
(set-face-bold-p 'bold 1)
(provide 'init-ui)
