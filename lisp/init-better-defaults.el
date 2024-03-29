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
(fset 'yes-or-no-p 'y-or-n-p)

(require 'recentf)
(recentf-mode t)
(setq recentf-max-menu-items 25)

;; when cursor is at one side of parenthesis, highlight the other one
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

;; smartparens is not used for "'" in emacs lisp major mode
(sp-local-pair 'emacs-lisp-mode "'" nil :actions nil)
(sp-local-pair 'lisp-interaction-mode "'" nil :actions nil)

;; highlight parenthesis as well if the cursor is surrounded by parenthesises
;; src from http://book.emacs-china.org/#orgheadline24
(define-advice show-paren-function (:around (fn) fix-show-paren-function)
  "Highlight enclosing parens."
  (cond ((looking-at-p "\\s(") (funcall fn))
	(t (save-excursion
	     (ignore-errors (backward-up-list))
	     (funcall fn)))))

;; activate browse kill ring for unnormal behavior
(when (require 'browse-kill-ring nil 'noerror)
  (browse-kill-ring-default-keybindings))

;; hidden and remove dos eol for web development
;; src from http://book.emacs-china.org/#orgheadline24
(defun hidden-dos-eol ()
  "Do not show ^M in files containing mixed UNIX and DOS line endings."
  (interactive)
  (unless buffer-display-table
    (setq buffer-display-table (make-display-table)))
  (aset buffer-display-table ?\^M []))

(defun remove-dos-eol ()
  "Replace DOS eolns CR LF with Unix eolns CR"
  (interactive)
  (goto-char (point-min))
  (while (search-forward "\r" nil t) (replace-match "")))

;; enhance occur mode, dwim: do what I mean
;; src from http://book.emacs-china.org/#orgheadline27
(defun occur-dwim ()
  "Call `occur' with a sane default."
  (interactive)
  (push (if (region-active-p)
	    (buffer-substring-no-properties
	     (region-beginning)
	     (region-end))
	  (let ((sym (thing-at-point 'symbol)))
	    (when (stringp sym)
	      (regexp-quote sym))))
	regexp-history)
  (call-interactively 'occur))
(global-set-key (kbd "M-s o") 'occur-dwim)

;; enhance counsel-imenu mode to find functions
;; src from http://book.emacs-china.org/#orgheadline27
;; only javascript was used as an example 
(defun js2-imenu-make-index ()
  (interactive)
  (save-excursion
    ;; (setq imenu-generic-expression '((nil "describe\\(\"\\(.+\\)\"" 1)))
    (imenu--generic-function '(("describe" "\\s-*describe\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
			       ("it" "\\s-*it\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
			       ("test" "\\s-*test\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
			       ("before" "\\s-*before\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
			       ("after" "\\s-*after\\s-*(\\s-*[\"']\\(.+\\)[\"']\\s-*,.*" 1)
			       ("Function" "function[ \t]+\\([a-zA-Z0-9_$.]+\\)[ \t]*(" 1)
			       ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*function[ \t]*(" 1)
			       ("Function" "^var[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*=[ \t]*function[ \t]*(" 1)
			       ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*()[ \t]*{" 1)
			       ("Function" "^[ \t]*\\([a-zA-Z0-9_$.]+\\)[ \t]*:[ \t]*function[ \t]*(" 1)
			       ("Task" "[. \t]task([ \t]*['\"]\\([^'\"]+\\)" 1)))))
(add-hook 'js2-mode-hook
	  (lambda ()
	    (setq imenu-create-index-function 'js2-imenu-make-index)))

(global-set-key (kbd "M-s i") 'counsel-imenu)

;; set msys path on MS Windows system
(if (eq system-type 'windows-nt)
    (setenv "PATH"
	    (concat
	     ;; Change this with your path to MSYS bin directory
	     "C:\\MinGW\\msys\\1.0\\bin;"
	     (getenv "PATH")))
  )

;; set clang path on MS Windows system
(if (eq system-type 'windows-nt)
    (setq company-clang-executable "C:\\Program Files\\LLVM\\bin\\clang.exe"))

;; python-mode-hook hide and show code block
(add-hook 'python-mode-hook
	  (	  lambda()
	    (local-set-key (kbd "C-c <right>") 'hs-show-block)
	    (local-set-key (kbd "C-c <left>")  'hs-hide-block)
	    (local-set-key (kbd "C-c <up>")    'hs-hide-all)
	    (local-set-key (kbd "C-c <down>")  'hs-show-all)
	    (hs-minor-mode t)))

;; insert parentheses
(global-set-key (kbd "M-[") 'insert-pair)
(global-set-key (kbd "M-{") 'insert-pair)
(global-set-key (kbd "M-\"") 'insert-pair)
(global-set-key (kbd "M-)") 'delete-pair)

(setq frame-title-format
      (list (format "%s %%S: %%j " (system-name))
	    '(buffer-file-name "%f" (dired-directory dired-directory "%b"))))

(add-hook 'flycheck-mode-hook #'flycheck-virtualenv-setup)

;; select current line command
(transient-mark-mode 1)

(defun select-current-line ()
  "Select the current line"
  (interactive)
  (end-of-line) ; move to end of line
  (set-mark (line-beginning-position)))

;; show trailing white space
(require 'whitespace)
(setq whitespace-style
      '(face trailing))

;; config helm-gtags
(setq helm-gtags-ignore-case t
      helm-gtags-auto-update t
      helm-gtags-use-input-at-cursor t
      helm-gtags-pulse-at-cursor t
      helm-gtags-prefix-key "\C-cg"
      helm-gtags-suggested-key-mapping t)

;; Enable helm-gtags-mode in Dired so you can jump to any tag
;; when navigate project tree with Dired
(add-hook 'dired-mode-hook 'helm-gtags-mode)

;; Enable helm-gtags-mode in Eshell for the same reason as above
(add-hook 'eshell-mode-hook 'helm-gtags-mode)

;; Enable helm-gtags-mode in languages that GNU Global supports
(add-hook 'c-mode-hook 'helm-gtags-mode)
(add-hook 'c++-mode-hook 'helm-gtags-mode)
(add-hook 'java-mode-hook 'helm-gtags-mode)
(add-hook 'asm-mode-hook 'helm-gtags-mode)

;; Windows performance tweaks for irony
;;
(when (boundp 'w32-pipe-read-delay)
  (setq w32-pipe-read-delay 0))
;; Set the buffer size to 64K on Windows (from the original 4K)
(when (boundp 'w32-pipe-buffer-size)
  (setq irony-server-w32-pipe-buffer-size (* 64 1024)))

;; set default python env as py36, python 3.6 needs to be named as py36
;; (require 'pyvenv)
;; (pyvenv-workon "py36")

;; set the default encoding system
(prefer-coding-system 'utf-8)
(setq default-file-name-coding-system 'utf-8)
(set-default-coding-systems 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
;; backwards compatibility as default-buffer-file-coding-system
;; is deprecated in 23.2.
(if (boundp buffer-file-coding-system)
    (setq buffer-file-coding-system 'utf-8)
  (setq default-buffer-file-coding-system 'utf-8))

;; Treat clipboard input as UTF-8 string first; compound text next, etc.
(setq x-select-request-type '(UTF8_STRING COMPOUND_TEXT TEXT STRING))

;; fix for slow emacs when saving files
;; this may result magit not working properly, but speed up emacs a lot.
(setq vc-handled-backends nil)
;; (setq mgit-git-executable "git")
(provide 'init-better-defaults)

;; Run/highlight code using babel in org-mode
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (shell . t)
   ;; Include other languages here ...
   ))

;; auto insert text for python file.
(auto-insert-mode 1)
(eval-after-load 'autoinsert
  '(define-auto-insert
     '("\\.\\py\\'" . "python skeleton")
     '(""
       "#! /usr/bin/env python"\n
       "# coding=utf-8"\n
       "# ================================================================"\n
       "#   Copyright (C) " (format-time-string "%Y" (current-time)) " * Ltd. All rights reserved."\n
       "#"\n
       "#   Editor      : EMACS"\n
       "#   File name   : " (file-name-nondirectory (buffer-file-name))\n
       "#   Author      : slgao"\n
       "#   Created date: " (format-time-string "%a %b %d %Y %H:%M:%S" (current-time))\n 
       "#   Description :"\n
       "#"\n
       "# ================================================================"\n
       \n
       > _ \n
       )))


;; add this to quick insertion of org templates.
(require 'org-tempo)

;; add ruler at maximum column
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)

;; #####################################
;; WEB DEVELOPMENT
;; #####################################

;; auto-enable web-mode for .js and .jsx files
(add-to-list 'auto-mode-alist '("\\.jsx?$" . web-mode))
;; enable JSX syntax highlighting.
(setq web-mode-content-types-alist '(("jsx" . "\\.js[x]?\\'")))
;; Configure indentation
(defun web-mode-init-hook ()
  "Hooks for Web mode.  Adjust indent."
  (setq web-mode-markup-indent-offset 4))
(add-hook 'web-mode-hook  'web-mode-init-hook)

;; disable default jslint
(setq-default flycheck-disabled-checkers
              (append flycheck-disabled-checkers
                      '(javascript-jshint json-jsonlist)))
;; Enable eslint checker for web-mode
(flycheck-add-mode 'javascript-eslint 'web-mode)
;; Enable flycheck globally if not windows system.
(if (not(eq system-type 'windows-nt))
    (add-hook 'after-init-hook #'global-flycheck-mode))
;; backup in one place. flat, no tree structure
(setq backup-directory-alist '(("" . "~/.emacs.d/backup")))
;; deactivating emacs writing lock files in React.js development to prevent server crashes.
(setq create-lockfiles nil)

;; enable dead keys
(define-key key-translation-map [dead-grave] "`")
(define-key key-translation-map [dead-acute] "'")
(define-key key-translation-map [dead-circumflex] "^")
(define-key key-translation-map [dead-diaeresis] "\"")
(define-key key-translation-map [dead-tilde] "~")
;; enable to insert backtick in some modes
(global-set-key [S-dead-grave] "`")

;; column indicator
(add-hook 'prog-mode-hook #'display-fill-column-indicator-mode)
