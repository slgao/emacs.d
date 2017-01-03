(require 'cl)
(when (>= emacs-major-version 24)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  )

;;add whatever packages you want here
(defvar shulin/packages '(
                          company
                          monokai-theme
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
;(add-hook 'emacs-lisp-mode-hook 'smartparens-mode)
(smartparens-global-mode t)

;; config python evn
;; use function M-x pyvenv-activate to select python environment manually
(setenv "WORKON_HOME" "C:/Anaconda3/envs")
(pyvenv-mode 1)

;; config elpy
(elpy-enable)

;; config jedi
(require 'jedi)
(add-to-list 'ac-sources 'ac-source-jedi-direct)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

;; config flycheck -- maybe slow
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode)
  (setq flycheck-highlighting-mode 'lines))

;; config pep8
(require 'py-autopep8)
;(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
(elpy-use-ipython)

; config popwin
(require 'popwin)
(popwin-mode t)


;;;;;;;;;;;;;;
;emmet-mode
;;;;;;;;;;;;;
(require 'emmet-mode)
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'html-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook  'emmet-mode)


;;;;;;;;;;;;;;
;web-mode
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
  (setq web-mode-markup-indent-offset 2)
)
(add-hook 'web-mode-hook  'my-web-mode-hook)

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

(provide 'init-packages)
