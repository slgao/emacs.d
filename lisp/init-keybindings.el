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
(global-set-key (kbd "C-:") 'avy-goto-word-or-subword-1)

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
(global-set-key (kbd "C-x c") 'xah-copy-line-or-region)

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

;; kbd for kill word at point
(global-set-key (kbd "C-c k") 'my-kill-word-at-point)

;; kbd for smart open line and smart open line above
(global-set-key (kbd "M-o") 'smart-open-line)
(global-set-key (kbd "M-O") 'smart-open-line-above)

;; kbd for multiple-cursors
(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->") 'mc/mark-next-like-this)
(global-set-key (kbd "C-<") 'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<") 'mc/mark-all-like-this)

;; kbd for toggle window split
(global-set-key (kbd "C-x |") 'toggle-window-split)

;; kbd for select current line
(global-set-key (kbd "C-c s") 'select-current-line)

;; yasnippet keybinding
(define-key yas-minor-mode-map (kbd "<C-tab>")     'yas-ido-expand)

;; key bindings for helm-gtags
(with-eval-after-load 'helm-gtags
  (define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
  (define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
  (define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
  (define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
  (define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
  (define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history))

;; change jedi goto-definition keybindings
;; change elpy backend to jedi does not use jedi:goto-definition
(eval-after-load 'jedi
  '(progn
     (define-key jedi-mode-map (kbd "C-c .") nil)
     (define-key jedi-mode-map (kbd "M-.") 'jedi:goto-definition)     
     (define-key jedi-mode-map (kbd "C-c ,") nil)
     (define-key jedi-mode-map (kbd "M-,") 'jedi:goto-definition-pop-marker)))

;; kbd to kill compilation
(global-set-key (kbd "C-c C-k") 'kill-compilation)

;; set flymake kbd to show the error message when go to the error
;; it does not show the error message when the point is at the error somehow.
;; use bink-key* macro in use-package from melpa to overwrite kbd.
;; for emacs -v=26 use the kbd, -v=25 show error use elpy-flymake-next-error
;; (bind-key* "C-c C-n" 'flymake-goto-next-error)
;; (bind-key* "C-c C-p" 'flymake-goto-prev-error)

(provide 'init-keybindings)
