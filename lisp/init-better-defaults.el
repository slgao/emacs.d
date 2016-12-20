(setq ring-bell-function 'ignore)
; if init file changed, it will show in the editor
(global-auto-revert-mode t)

(require 'recentf)
(recentf-mode t)
(setq recentf-max-menu-items 25)

(add-hook 'emacs-lisp-mode-hook 'show-paren-mode)
(delete-selection-mode t)

(setq make-backup-files nil)
(setq auto-save-default nil)

(provide 'init-better-defaults)
