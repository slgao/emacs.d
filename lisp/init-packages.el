(require 'cl)
(when (>= emacs-major-version 24)
  (add-to-list 'package-archives '("melpa" . "http://melpa.org/packages/") t)
  )

;;add whatever packages you want here
(defvar shulin/packages '(
                          company
                          monokai-theme
			  hungry-delete
			  swiper
			  counsel
			  smartparens
			  elpy
			  magit
			  popwin
			  flycheck
			  py-autopep8
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


(global-company-mode t)


(require 'hungry-delete)
(global-hungry-delete-mode)


;; config swiper
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)


;; config smartparens
;(add-hook 'emacs-lisp-mode-hook 'smartparens-mode)
(smartparens-global-mode t)

;; config elpy
(elpy-enable)

;; config flycheck
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; config pep8
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)
(elpy-use-ipython)

; config popwin
(require 'popwin)
(popwin-mode t)

(provide 'init-packages)
