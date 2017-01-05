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
;; make mac os font bigger
(if (eq system-type 'darwin)
    (add-to-list 'default-frame-alist
		 '(font . "Consolas-13"))
  (add-to-list 'default-frame-alist
	       '(font . "Consolas-9"))
  )

(set-face-bold-p 'bold 1)

;; configure mode-line to show date, time and column number
(setq column-number-mode t)
(setq display-time-day-and-date t)
(setq display-time-24hr-format t)
(display-time)

;; change selected region color
;; probably need to configure monokai color first
;; (set-face-attribute 'region nil :background "#7FB3D5")

(provide 'init-ui)
