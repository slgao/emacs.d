(require 'cl)
(when (>= emacs-major-version 24)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  )

;;add whatever packages you want here
(defvar shulin/packages '(
                          company
                          monokai-theme
			  zenburn-theme
			  tangotango-theme
			  flatland-theme
			  hungry-delete
			  exec-path-from-shell
			  swiper
			  counsel
			  smartparens
			  elpy
			  jedi
			  virtualenv
			  epc
			  magit
			  popwin
			  flycheck
			  py-autopep8
			  emmet-mode
			  web-mode
			  ace-window
			  ace-jump-mode
			  undo-tree
			  neotree
			  all-the-icons
			  js2-refactor
			  expand-region
			  iedit
			  multiple-cursors
			  ein
			  org-gcal
			  sphinx-doc
			  clang-format
			  helm
			  helm-gtags
			  company-jedi
			  irony
			  cmake-mode
			  cython-mode
			  flycheck-cython
			  flycheck-irony
			  company-irony
			  company-irony-c-headers
			  use-package
			  yaml-mode
			  yasnippet
			  yasnippet-snippets
			  gruvbox-theme
			  htmlize
			  eldoc
			  rjsx-mode
			  xref-js2
			  js2-refactor
			  slime
			  slime-company
			  )  "Default packages")

(defun shulin/packages-installed-p ()
  (loop for pkg in shulin/packages
        when (not (package-installed-p pkg)) do (return nil)
        finally (return t)))

(unless (shulin/packages-installed-p)
  (message "%s" "Refreshing package database...")
  (package-refresh-contents)
  (dolist (pkg shulin/packages)
    (when (not (package-installed-p pkg))
      (package-install pkg))))
(setq package-selected-packages shulin/packages)

;; config company-mode, reset company-active-map
;; in python mode, company mode and jedi mode completion may
;; be shown at the same time. Confliction may occur when it comes to
;; chosing the right completion. #TODO: disable company mode only in
;; python mode, more specifically in source code region. and set local
;; key select next and previous jedi mode completion as "C-n" and "C-p"

(global-company-mode t)
(eval-after-load 'company
  '(progn
     (define-key company-active-map (kbd "C-n") 'company-select-next)
     (define-key company-active-map [tab] 'company-select-next)
     (define-key company-active-map (kbd "C-p") 'company-select-previous)
     (define-key company-active-map (kbd "<S-tab>") 'company-select-previous)
     (define-key company-active-map (kbd "<escape>") 'company-abort)
     ))
(setq company-selection-wrap-around t)

(require 'hungry-delete)
(global-hungry-delete-mode)

;; config exec-path-from-shell
(when (memq window-system '(mac ns))
  (exec-path-from-shell-initialize))

;; config swiper
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)

;; config smartparens
;; (add-hook 'emacs-lisp-mode-hook 'smartparens-mode)
(smartparens-global-mode t)

;; config python evn
;; use function M-x pyvenv-activate to select python environment manually
(if (eq system-type 'windows-nt)
    (setenv "WORKON_HOME" "c:/Users/SGao0001/Anaconda3/envs")
    (setenv "WORKON_HOME" "~/anaconda3/envs")
)
(pyvenv-mode 1)

;; config elpy
(elpy-enable)
(setq python-shell-interpreter "ipython"
      python-shell-interpreter-args "-i --simple-prompt")
;; disable eldoc and company mode on windows system.
(if (eq system-type 'windows-nt)
    (progn
	  (setq elpy-modules (delq 'elpy-module-eldoc elpy-modules))
	  (setq elpy-modules (delq 'elpy-module-company elpy-modules))
	  )
)

;; config jedi
(require 'jedi)
(add-to-list 'ac-sources 'ac-source-jedi-direct)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)
;; set jedi as company backends.
;; if elpy-rpc-backend is set to jedi, company-backends may be also
;; be set accordingly.
(defun company-backends/python-mode-hook ()
  (add-to-list 'company-backends 'company-jedi))
(add-hook 'python-mode-hook 'company-backends/python-mode-hook)
;; set elpy backend to jedi, comment it out since the newer version of elpy works good.
(setq elpy-rpc-backend "jedi")

;; config irony mode
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)

;; set company backend to company irony
(defun company-backends/c++-mode-hook()
  (add-to-list 'company-backends '(company-irony-c-headers company-irony)))
(add-hook 'irony-mode-hook 'company-backends/c++-mode-hook)

;; start flycheck-irony when irony mode is activated
(add-hook 'irony-mode-hook 'flycheck-mode)
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; config flycheck -- comment to disable flycheck, slow in python mode
;; (when (require 'flycheck nil t)
;;   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;;   (add-hook 'elpy-mode-hook 'flycheck-mode))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++11")))

;; global flycheck mode.
;; (use-package flycheck
;;   :ensure t
;;   :init (global-flycheck-mode))

;; set checker variable
;; (custom-set-variables
;;  '(flycheck-python-flake8-executable "python")
;;  ;; '(flycheck-python-pycompile-executable "python")
;;  ;; '(flycheck-python-pylint-executable "python")
;; )


;; config pep8
(require 'py-autopep8)
					;(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;; config popwin
(require 'popwin)
(popwin-mode t)

;;;;;;;;;;;;;;
;;emmet-mode
;;;;;;;;;;;;;
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'html-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook  'emmet-mode)

;;;;;;;;;;;;;;
;;web-mode
;;;;;;;;;;;;;;;
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.phtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.tpl\\.php\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.[agj]sp\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.as[cp]x\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.erb\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.mustache\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.djhtml\\'" . web-mode))
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(defun my-web-mode-hook ()
  "Hooks for Web mode."
  (setq web-mode-markup-indent-offset 2) ; web-mode, html tag in html file
  (setq web-mode-css-indent-offset 2)    ; web-mode, css in html file
  (setq web-mode-code-indent-offset 2)   ; web-mode, js code in html file
  )
(add-hook 'web-mode-hook  'my-web-mode-hook)

;; switch between 2 and 4 space indents
(defun my-toggle-web-indent ()
  (interactive)
  ;; web development
  (if (or (eq major-mode 'js-mode) (eq major-mode 'js2-mode))
      (progn
	(setq js-indent-level (if (= js-indent-level 2) 4 2))
	(setq js2-basic-offset (if (= js2-basic-offset 2) 4 2))))

  (if (eq major-mode 'web-mode)
      (progn (setq web-mode-markup-indent-offset (if (= web-mode-markup-indent-offset 2) 4 2))
	     (setq web-mode-css-indent-offset (if (= web-mode-css-indent-offset 2) 4 2))
	     (setq web-mode-code-indent-offset (if (= web-mode-code-indent-offset 2) 4 2))))
  (if (eq major-mode 'css-mode)
      (setq css-indent-offset (if (= css-indent-offset 2) 4 2)))

  (setq indent-tabs-mode nil))

(global-set-key (kbd "C-c t i") 'my-toggle-web-indent)


;; config ace-window
(setq aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
(setq aw-background nil)

;; config move-lines
(require 'move-lines)

;; add undo-tree mode 
(require 'undo-tree)
(global-undo-tree-mode)

;; add neotree mode 
(require 'neotree)
(setq neo-smart-open t)

;; add all-the-icons
(require 'all-the-icons)
;; the fonts in all-the-icons packages should be installed if icons neo-theme is used
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(setq inhibit-compacting-font-caches t)

;; config js2-refactor
(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-m")

;; config iedit
(require 'iedit)

;; config multiple-cursors
(require 'multiple-cursors)

(require 'ein)
;; (require 'ein-loaddefs)
(require 'ein-notebook)
;; enable auto-complete for ein
(setq ein:use-auto-complete t)
;; Or, to enable "superpack" (a little bit hacky improvements):
;; (setq ein:use-auto-complete-superpack t)
;; enable smartrep
(setq ein:use-smartrep t)

;; try company-anaconda
;; I commented this out because I also use jedi mode to complete the code
;; (add-hook 'python-mode-hook 'anaconda-mode)
;; (add-hook 'python-mode-hook
;; 	  (lambda ()
;; 	  (set(make-local-variable 'company-backends) '(company-anaconda company-dabbrev))))

;; ;; commented maybe because of the ssl aut problem
;; (require 'org-gcal)
;; (setq org-gcal-client-id "224061746080-mvhsjeafepmuul58osdmf6i5dk9ul29p.apps.googleusercontent.com"
;;       org-gcal-client-secret "JSJ-ehfmbdR_OrIFfizYAGav"
;;       org-gcal-file-alist '(("sleangao@gmail.com" .  "~/.emacs.d/org-gcal/gcal.org")))

;; ;; sync org file and gcal
;; (add-hook 'org-agenda-mode-hook (lambda () (org-gcal-sync) ))
;; (add-hook 'org-capture-after-finalize-hook (lambda () (org-gcal-sync) ))

(require 'org-bullets)
(setq org-bullets-face-name (quote org-bullet-face))
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
;; (setq org-bullets-bullet-list '("✙" "♱" "♰" "☥" "✞" "✟" "✝" "†" "✠" "✚" "✜" "✛" "✢" "✣" "✤" "✥"))

;; add this to quick insertion of org templates.
(require 'org-tempo)

;; add cygwin path
(if (eq system-type 'windows-nt)
    (add-to-list 'exec-path "c:/cygwin64/bin/"))

;; py-autopep8 config
(require 'py-autopep8)
;; enable formatting when python file is saved
;; (add-hook 'python-mode-hook 'py-autopep8-enable-on-save) ; commented out for efficiency
(setq py-autopep8-options '("--max-line-length=100"))

;; yasnippet minor mode config
(require 'yasnippet)
(yas-reload-all)
(add-hook 'prog-mode-hook #'yas-minor-mode)

;; sphinx-doc mode config
(add-hook 'python-mode-hook (lambda ()
			      (require 'sphinx-doc)
			      (sphinx-doc-mode t)))

;; clang-format config
(require 'clang-format)
(global-set-key (kbd "C-c i") 'clang-format-region)
(global-set-key (kbd "C-c u") 'clang-format-buffer)
(setq clang-format-style-option "llvm")

;; helm config
(require 'helm-config)

;; config cmake-mode
(require 'cmake-mode)

;; use flycheck for cython-mode
(require 'flycheck-cython)
(add-hook 'cython-mode-hook 'flycheck-mode)

;; flycheck-irony config
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))

;; config yaml-mode
(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

(require 'yapfify)

; enaml config
(require 'enaml)
(setq auto-mode-alist (cons '("\\.enaml$" . enaml-mode) auto-mode-alist))

;; js2-refactor and xref-js2 config
(require 'js2-refactor)
(require 'xref-js2)

(add-hook 'js2-mode-hook #'js2-refactor-mode)
(js2r-add-keybindings-with-prefix "C-c C-r")
(define-key js2-mode-map (kbd "C-k") #'js2r-kill)

;; js-mode (which js2 is based on) binds "M-." which conflicts with xref, so
;; unbind it.
(define-key js-mode-map (kbd "M-.") nil)

(add-hook 'js2-mode-hook (lambda ()
  (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))

;; slime settings
(setq inferior-lisp-program "sbcl")
(require 'slime-autoloads)
(slime-setup '(slime-fancy))
(slime-setup '(slime-company))

(provide 'init-packages)
;;; init-package.el ends here

