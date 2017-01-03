;; hippie expand is dabbrev expand on steroids
(setq hippie-expand-try-functions-list '(try-expand-dabbrev
                                         try-expand-dabbrev-all-buffers
                                         try-expand-dabbrev-from-kill
                                         try-complete-file-name-partially
                                         try-complete-file-name
                                         try-expand-all-abbrevs
                                         try-expand-list
                                         try-expand-line
                                         try-complete-lisp-symbol-partially
                                         try-complete-lisp-symbol))


(setq ring-bell-function 'ignore)
					; init file changed, it will show in the editor
(global-auto-revert-mode t)

(require 'recentf)
(recentf-mode t)
(setq recentf-max-menu-items 25)
(add-hook 'emacs-lisp-mode-hook 'show-paren-mode)
(delete-selection-mode t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(when (memq window-system '(mac ns))
  (setq mac-option-key-is-meta t)
  (setq mac-right-option-modifier nil))

(setq dired-recursive-copies 'always)
(setq dired-recursive-deletes 'always)
(put 'dired-find-alternate-file 'disabled nil)
(require 'dired-x)
(setq dired-dwim-target t)

;; activate browse kill ring for unnormal behavior
(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))

(provide 'init-better-defaults)
