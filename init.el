;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

;; Added by Package.el.  This must come before configurations of
;; installed packages.  Don't delete this line.  If you don't want it,
;; just comment it out by adding a semicolon to the start of the line.
;; You may delete these explanatory comments.

;; (add-to-list 'package-archives '("org" . "https://orgmode.org/elpa/") t)
;;(require 'org-install)
;; Load a literate (.org) config. org-babel-load-file drags in all of org —
;; plus its export backends, ~1s — on every startup just to compare file
;; timestamps. Do the freshness check ourselves: load the tangled .el cache
;; directly and only involve org when the .org actually changed.
(defun my/load-org-config (file)
  (let* ((org-file (expand-file-name file user-emacs-directory))
         (el-file (concat (file-name-sans-extension org-file) ".el")))
    (if (file-newer-than-file-p org-file el-file)
        (progn (require 'ob-tangle)
               (org-babel-load-file org-file))
      (load el-file nil 'nomessage))))
(my/load-org-config "shulins_emacs_config.org")
(put 'narrow-to-region 'disabled nil)
(put 'downcase-region 'disabled nil)
(put 'erase-buffer 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)
