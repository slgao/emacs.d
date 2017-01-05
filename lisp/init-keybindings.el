(global-set-key (kbd "<f2>") 'open-my-init-file)

(global-set-key "\C-x\ \C-r" 'recentf-open-files)

(global-set-key (kbd "C-h C-f") 'find-function)
(global-set-key (kbd "C-h C-v") 'find-variable)
(global-set-key (kbd "C-h C-k") 'find-function-on-key)

(global-set-key "\C-s" 'swiper)
;; resume the last completion session e.g last M-x command
(global-set-key (kbd "C-c C-r") 'ivy-resume)
(global-set-key (kbd "<f6>") 'ivy-resume)
;; avy fast goto word
(global-set-key (kbd "C-c g") 'avy-goto-word-or-subword-1)

(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key (kbd "C-h f") 'counsel-describe-function)
(global-set-key (kbd "C-h v") 'counsel-describe-variable)

(global-set-key (kbd "C-c a") 'org-agenda)
(global-set-key (kbd "C-M-\\") 'indent-region-or-buffer)
(global-set-key (kbd "M-/") 'hippie-expand)
(with-eval-after-load 'dired
  (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file))
(global-set-key (kbd "C-x C-;") 'toggle-comment-on-line)

(global-set-key (kbd "C-c d") 'duplicate-line-or-region)
(global-set-key (kbd "C-c c") 'xah-copy-line-or-region)

;; kbd ace-window
(global-set-key (kbd "C-x o") 'ace-window)

;; kbd to enhance user friendlity of h and v split windows
(global-set-key (kbd "C-x 2") 'vsplit-last-buffer)
(global-set-key (kbd "C-x 3") 'hsplit-last-buffer)

;; kbd to refresh buffer
(global-set-key (kbd "C-c r") 'revert-buffer)

;; kbd to move line or regions up and down
(move-lines-binding)

;; kbd for magit
(global-set-key (kbd "C-x g") 'magit-status)

;; kbd to toggle neotree
(global-set-key [f8] 'neotree-toggle)

;; config for expand-region
;; the original recommended kbd "C-=" somehow does not take effect
(global-set-key (kbd "C-+") 'er/expand-region)
   
;; kbd for iedit mode 
(global-set-key (kbd "C-;") 'iedit-mode)
(global-set-key (kbd "C-x r <return>") 'iedit-rectangle-mode)

(provide 'init-keybindings)
