(if (fboundp 'with-eval-after-load)
    (defalias 'after-load 'with-eval-after-load)
  (defmacro after-load (feature &rest body)
    "After FEATURE is loaded, evaluate BODY."
    (declare (indent defun))
    `(eval-after-load ,feature
       '(progn ,@body))))


;;----------------------------------------------------------------------------
;; Handier way to add modes to auto-mode-alist
;;----------------------------------------------------------------------------
(defun add-auto-mode (mode &rest patterns)
  "Add entries to `auto-mode-alist' to use `MODE' for all given file `PATTERNS'."
  (dolist (pattern patterns)
    (add-to-list 'auto-mode-alist (cons pattern mode))))


;;----------------------------------------------------------------------------
;; String utilities missing from core emacs
;;----------------------------------------------------------------------------
(defun sanityinc/string-all-matches (regex str &optional group)
  "Find all matches for `REGEX' within `STR', returning the full match string or group `GROUP'."
  (let ((result nil)
        (pos 0)
        (group (or group 0)))
    (while (string-match regex str pos)
      (push (match-string group str) result)
      (setq pos (match-end group)))
    result))


;;----------------------------------------------------------------------------
;; Delete the current file
;;----------------------------------------------------------------------------
(defun delete-this-file ()
  "Delete the current file, and kill the buffer."
  (interactive)
  (or (buffer-file-name) (error "No file is currently being edited"))
  (when (yes-or-no-p (format "Really delete '%s'?"
                             (file-name-nondirectory buffer-file-name)))
    (delete-file (buffer-file-name))
    (kill-this-buffer)))


;;----------------------------------------------------------------------------
;; Rename the current file
;;----------------------------------------------------------------------------
(defun rename-this-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (unless filename
      (error "Buffer '%s' is not visiting a file!" name))
    (progn
      (when (file-exists-p filename)
        (rename-file filename new-name 1))
      (set-visited-file-name new-name)
      (rename-buffer new-name))))

;;----------------------------------------------------------------------------
;; Browse current HTML file
;;----------------------------------------------------------------------------
(defun browse-current-file ()
  "Open the current file as a URL using `browse-url'."
  (interactive)
  (let ((file-name (buffer-file-name)))
    (if (and (fboundp 'tramp-tramp-file-p)
             (tramp-tramp-file-p file-name))
        (error "Cannot open tramp file")
      (browse-url (concat "file://" file-name)))))

;;----------------------------------------------------------------------------
;; Browse current file in file browser
;;----------------------------------------------------------------------------
(defun browse-file-directory ()
  "Open the current file's directory however the OS would."
  (interactive)
  (if default-directory
      (browse-url (expand-file-name default-directory))
    (error "No `default-directory' to open")))

;;----------------------------------------------------------------------------
;; Duplicate line
;;----------------------------------------------------------------------------
(defun duplicate-line-or-region()
  "Duplicate line or region"
  (interactive)
  (xah-copy-line-or-region)
  (newline)
  (yank)
  )

(defun xah-copy-line-or-region ()
    "Copy current line or selection.
When called repeatedly, append copy subsequent lines.
When `universal-argument' is called first, copy whole buffer (respects `narrow-to-region').

URL `http://xahlee.info/emacs/emacs/emacs_copy_cut_current_line.html'
Version: 2010-05-21 2022-10-03"
  (interactive)
  (let ((inhibit-field-text-motion nil))
    (if current-prefix-arg
        (progn
          (copy-region-as-kill (point-min) (point-max)))
      (if (region-active-p)
          (progn
            (copy-region-as-kill (region-beginning) (region-end)))
        (if (eq last-command this-command)
            (if (eobp)
                (progn )
              (progn
                (kill-append "\n" nil)
                (kill-append
                 (buffer-substring-no-properties (line-beginning-position) (line-end-position))
                 nil)
                (progn
                  (end-of-line)
                  (forward-char))))
          (if (eobp)
              (if (eq (char-before) 10 )
                  (progn )
                (progn
                  (copy-region-as-kill (line-beginning-position) (line-end-position))
                  (end-of-line)))
            (progn
              (copy-region-as-kill (line-beginning-position) (line-end-position))
              (end-of-line)
              (forward-char))))))))

;; self defined functions are here
(defun toggle-comment-on-line ()
  "comment or uncomment current line"
  (interactive)
  (comment-or-uncomment-region (line-beginning-position) (line-end-position)))

(defun indent-buffer ()
  "Indent the currently visited buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun indent-region-or-buffer ()
  "Indent a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (indent-buffer)
        (message "Indented buffer.")))))

;; self defined split-window-vertically
(defun vsplit-last-buffer (prefix)
"split the window vertically and display the previous buffer"
  (interactive "p")
  (split-window-vertically)
  (other-window 1 nil)
  (if (= prefix 1)
      (switch-to-next-buffer)
    ))

;; self defined split-window-horizontally
(defun hsplit-last-buffer (prefix)
"split the window horizontally and display the previous buffer"
  (interactive "p")
  (split-window-horizontally)
  (other-window 1 nil)
  (if (= prefix 1)
      (switch-to-next-buffer)
    ))

(defun smart-open-line-above ()
  "Insert an empty line above the current line.
Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(defun smart-open-line ()
  "Insert an empty line after the current line.
Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun toggle-window-split ()
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
         (next-win-buffer (window-buffer (next-window)))
         (this-win-edges (window-edges (selected-window)))
         (next-win-edges (window-edges (next-window)))
         (this-win-2nd (not (and (<= (car this-win-edges)
                     (car next-win-edges))
                     (<= (cadr this-win-edges)
                     (cadr next-win-edges)))))
         (splitter
          (if (= (car this-win-edges)
             (car (window-edges (next-window))))
          'split-window-horizontally
        'split-window-vertically)))
    (delete-other-windows)
    (let ((first-win (selected-window)))
      (funcall splitter)
      (if this-win-2nd (other-window 1))
      (set-window-buffer (selected-window) this-win-buffer)
      (set-window-buffer (next-window) next-win-buffer)
      (select-window first-win)
      (if this-win-2nd (other-window 1))))))

(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Completing point by some yasnippet key
(defun yas-ido-expand ()
  "Lets you select (and expand) a yasnippet key"
  (interactive)
    (let ((original-point (point)))
      (while (and
	      (not (= (point) (point-min) ))
	      (not
	       (string-match "[[:space:]\n]" (char-to-string (char-before)))))
	(backward-word 1))
    (let* ((init-word (point))
	   (word (buffer-substring init-word original-point))
	   (list (yas-active-keys)))
      (goto-char original-point)
      (let ((key (remove-if-not
		  (lambda (s) (string-match (concat "^" word) s)) list)))
	(if (= (length key) 1)
	    (setq key (pop key))
	  (setq key (ido-completing-read "key: " list nil nil word)))
	(delete-char (- init-word original-point))
	(insert key)
        (yas-expand)))))

(require 'ox-latex)
(add-to-list 'org-latex-classes
             '("beamer"
               "\\documentclass\[presentation\]\{beamer\}"
               ("\\section\{%s\}" . "\\section*\{%s\}")
               ("\\subsection\{%s\}" . "\\subsection*\{%s\}")
               ("\\subsubsection\{%s\}" . "\\subsubsection*\{%s\}")))

(add-to-list 'org-latex-classes
          '("bjmarticle"
            "\\documentclass{article}
	    \\usepackage[utf8]{inputenc}
            \\usepackage[T1]{fontenc}
            \\usepackage{graphicx}
            \\usepackage{longtable}
            \\usepackage{hyperref}
            \\usepackage{natbib}
            \\usepackage{amssymb}
            \\usepackage{amsmath}
            \\usepackage{geometry}
            \\geometry{a4paper,left=2.5cm,top=2cm,right=2.5cm,bottom=2cm,marginparsep=7pt, marginparwidth=.6in}"
            ("\\section{%s}" . "\\section*{%s}")
            ("\\subsection{%s}" . "\\subsection*{%s}")
            ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
            ("\\paragraph{%s}" . "\\paragraph*{%s}")
            ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))

(provide 'init-utils)
