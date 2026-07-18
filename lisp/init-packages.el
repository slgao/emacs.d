(require 'cl-lib)
(when (>= emacs-major-version 24)
  (add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/") t)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  )

;;add whatever packages you want here
(defvar shulin/packages '(company
                          monokai-theme
                          gruvbox-theme
                          hungry-delete
                          exec-path-from-shell
                          swiper
                          counsel
                          projectile
                          counsel-projectile
                          which-key
                          diff-hl
                          smartparens
                          pyvenv
                          magit
                          popwin
                          flycheck
                          py-autopep8
                          blacken
                          emmet-mode
                          web-mode
                          ace-window
                          undo-tree
                          neotree
                          all-the-icons
                          js2-refactor
                          xref-js2
                          expand-region
                          iedit
                          multiple-cursors
                          sphinx-doc
                          clang-format
                          cmake-mode
                          cython-mode
                          flycheck-cython
                          use-package
                          yaml-mode
                          yasnippet
                          yasnippet-snippets
                          htmlize
                          citre
                          copilot
                          slime
                          slime-company
                          lsp-mode
                          lsp-ivy
                          lsp-ui
                          dap-mode
                          dockerfile-mode
                          jenkinsfile-mode
                          dotenv-mode
                          php-mode
                          git-modes
                          go-mode
                          typescript-mode)
  "Default packages")

;; vterm needs a Unix terminal layer and a compiled native module — not
;; available on native Windows Emacs.
(unless (eq system-type 'windows-nt)
  (add-to-list 'shulin/packages 'vterm t))

(defun shulin/packages-installed-p ()
  (cl-every #'package-installed-p shulin/packages))

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

(global-hungry-delete-mode)

;; config exec-path-from-shell — include Linux GUI (x) so pylsp and other
;; ~/.local/bin tools are visible to Emacs. Use a non-interactive login shell:
;; starting an interactive shell just to read $PATH slows down startup.
(setq exec-path-from-shell-arguments '("-l"))
(when (memq window-system '(mac ns x))
  (exec-path-from-shell-initialize))

;; config swiper
(ivy-mode 1)
(setq ivy-use-virtual-buffers t)

;; config smartparens
;; (add-hook 'emacs-lisp-mode-hook 'smartparens-mode)
(smartparens-global-mode t)

;; config python evn
;; use function M-x pyvenv-activate to select python environment manually
;; (if (eq system-type 'windows-nt)
;;     (setenv "WORKON_HOME" "C:/Users/SGao0001/AppData/Local/Continuum/anaconda3/envs")
;;     (setenv "WORKON_HOME" "/anaconda3/envs")
;; )

;; pyvenv loads lazily with the first python buffer (see the
;; hack-local-variables-hook below) — loading it at startup drags in eshell
;; (~0.5s). The default env makes pylsp visible on exec-path for python files
;; that don't sit inside a project-level venv/.venv.
(defvar my/pyvenv-default-env (expand-file-name "~/my-python-envs/emacs-elpy-env"))

(setq python-shell-interpreter
      (if (eq system-type 'windows-nt) "python" "python3")
      python-shell-interpreter-args "-i")

;; jedi disabled in favour of lsp-mode for goto-definition
;; (require 'jedi)
;; (add-to-list 'ac-sources 'ac-source-jedi-direct)
;; (add-hook 'python-mode-hook 'jedi:setup)
;; (setq jedi:complete-on-dot t)
;; (defun company-backends/python-mode-hook ()
;;   (add-to-list 'company-backends 'company-jedi))
;; (add-hook 'python-mode-hook 'company-backends/python-mode-hook)
;; (setq elpy-rpc-backend "jedi")

;; C/C++ via lsp-mode + clangd (replaces the old irony/helm-gtags stack).
;; lsp-mode offers to download clangd on first use if none is installed.
;; For project-wide awareness provide compile_commands.json at the project
;; root (cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON, or bear for make).
;; Completion, diagnostics (flycheck via lsp), M-., M-? all work like the
;; python/go/ts setups.
(add-hook 'c-mode-hook #'lsp)
(add-hook 'c++-mode-hook #'lsp)
(add-hook 'objc-mode-hook #'lsp)

;; One-command compile_commands.json pipeline for CMake projects: configure
;; into <root>/build with the compilation database enabled and link the db
;; to the project root, where clangd looks for it.
(defun my/cmake-project-root ()
  "Topmost directory above the current file that has a CMakeLists.txt."
  (let ((dir (locate-dominating-file default-directory "CMakeLists.txt"))
        top)
    (while dir
      (setq top dir
            dir (locate-dominating-file
                 (file-name-directory (directory-file-name dir))
                 "CMakeLists.txt")))
    top))

(defun my/cmake-generate-compile-db ()
  "Generate compile_commands.json for the current CMake project.
Cross-platform: uses Ninja only when available (the Visual Studio generator
ignores CMAKE_EXPORT_COMPILE_COMMANDS, so ninja is recommended on Windows),
and publishes the database to the project root with a symlink on Unix or a
copy on Windows. When the configure finishes, run M-x lsp-workspace-restart
so clangd picks the database up."
  (interactive)
  (unless (executable-find "cmake")
    (user-error "cmake not found — install it first (Linux: apt install cmake | macOS: brew install cmake | Windows: winget install Kitware.CMake)"))
  ;; without ninja, Windows' default Visual Studio generator silently ignores
  ;; CMAKE_EXPORT_COMPILE_COMMANDS — fail fast instead of after a configure
  (when (and (eq system-type 'windows-nt) (not (executable-find "ninja")))
    (user-error "ninja not found — required on Windows to export compile_commands.json (winget install Ninja-build.Ninja)"))
  (let* ((root (or (my/cmake-project-root)
                   (user-error "No CMakeLists.txt found above %s"
                               default-directory)))
         (default-directory root)
         (buf (compilation-start
               (concat "cmake -S . -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON"
                       (if (executable-find "ninja") " -G Ninja" "")))))
    (with-current-buffer buf
      (add-hook 'compilation-finish-functions
                (lambda (_buf status)
                  (let ((db  (expand-file-name "build/compile_commands.json" root))
                        (dst (expand-file-name "compile_commands.json" root)))
                    (cond
                     ((not (string-match-p "finished" status))
                      (message "cmake configure failed — see the compilation buffer"))
                     ((not (file-exists-p db))
                      (message "configure ok, but the generator produced no compile_commands.json — install ninja and retry"))
                     (t
                      (when (file-exists-p dst) (delete-file dst))
                      (if (eq system-type 'windows-nt)
                          (copy-file db dst t)   ; symlinks need privileges on Windows
                        (make-symbolic-link "build/compile_commands.json" dst t))
                      (message "compile_commands.json ready — M-x lsp-workspace-restart to reload clangd")))))
                nil t))))

;; Hint (once per project) when a CMake C/C++ tree has no compilation database
(defvar my/compile-db-hinted nil)
(defun my/cpp-compile-db-hint ()
  (when-let* ((root (my/cmake-project-root)))
    (unless (or (file-exists-p (expand-file-name "compile_commands.json" root))
                (member root my/compile-db-hinted))
      (push root my/compile-db-hinted)
      (message "No compile_commands.json in %s — M-x my/cmake-generate-compile-db gives clangd full project awareness"
               (abbreviate-file-name root)))))
(add-hook 'c-mode-hook #'my/cpp-compile-db-hint)
(add-hook 'c++-mode-hook #'my/cpp-compile-db-hint)

;; citre: indexed navigation on ctags / GNU Global databases — the modern
;; replacement for the old helm-gtags workflow (same gtags engine, no helm).
;; It backs up M-. in two situations:
;; 1. buffers without LSP: citre is the xref backend, so no tags-table prompt
;; 2. LSP buffers where the server has no answer (e.g. clangd in a tree
;;    without compile_commands.json): M-. transparently retries on the index
;; Build the index once per tree: `gtags' at the project root (or
;; M-x citre-global-create-database); update it with `global -u'.
(autoload 'citre-xref-backend "citre")
(setq citre-find-definition-backends '(tags global)
      citre-find-reference-backends '(global))
(add-hook 'xref-backend-functions #'citre-xref-backend)
(define-advice xref-find-definitions (:around (fn &rest args) citre-fallback)
  "Retry the lookup on the citre index when the active backend finds nothing.
If citre itself fails too (no index, index being rebuilt, ...), re-signal
the original \"no definitions\" error instead of citre's internals."
  (condition-case err
      (apply fn args)
    (user-error
     (require 'citre)
     (condition-case nil
         (let ((xref-backend-functions '(citre-xref-backend)))
           (prog1 (apply fn args)
             ;; make the fallback visible so it's clear which backend answered
             (message "LSP had no answer — jumped via the citre index")))
       (error (signal (car err) (cdr err)))))))

;; config flycheck -- comment to disable flycheck, slow in python mode
;; (when (require 'flycheck nil t)
;;   (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
;;   (add-hook 'elpy-mode-hook 'flycheck-mode))
;; (add-hook 'c++-mode-hook (lambda () (setq flycheck-clang-language-standard "c++11")))

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


;; config popwin
(popwin-mode t)

;;;;;;;;;;;;;;
;;emmet-mode
;;;;;;;;;;;;;
(add-hook 'sgml-mode-hook 'emmet-mode) ;; Auto-start on any markup modes
(add-hook 'html-mode-hook 'emmet-mode)
(add-hook 'web-mode-hook 'emmet-mode)
(add-hook 'css-mode-hook  'emmet-mode)

;;;;;;;;;;;;;;
;;web-mode
;;;;;;;;;;;;;;;
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
;; LSP in web-mode, but only for file types with an installed server: html
;; (vscode-html-language-server, npm i -g vscode-langservers-extracted) and
;; tsx (typescript-language-server). Unguarded, lsp would prompt to install
;; a server for every template flavor web-mode handles (.erb, .mustache, ...).
(add-hook 'web-mode-hook
          (lambda ()
            (when (and buffer-file-name
                       (string-match-p "\\.\\(html?\\|tsx\\)\\'" buffer-file-name))
              (lsp))))

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
(global-undo-tree-mode)

;; add neotree mode
(setq neo-smart-open t)
;; the fonts in all-the-icons packages should be installed if icons neo-theme is used
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))
(setq inhibit-compacting-font-caches t)

;; iedit and multiple-cursors: commands are autoloaded, bound in init-keybindings

;; (require 'ein)
;; (require 'ein-core)
;; (require 'ein-cell)
;; ;; (require 'ein-loaddefs)
;; (require 'ein-notebook)
;; ;; enable auto-complete for ein
;; (setq ein:use-auto-complete t)
;; ;; Or, to enable "superpack" (a little bit hacky improvements):
;; ;; (setq ein:use-auto-complete-superpack t)
;; ;; enable smartrep
;; (setq ein:use-smartrep t)

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

;; org-bullets lives in site-lisp (no autoloads) — load it with the first
;; org buffer instead of at startup
(add-hook 'org-mode-hook (lambda ()
                           (require 'org-bullets)
                           (setq org-bullets-face-name 'org-bullet-face)
                           (org-bullets-mode 1)))
;; (setq org-bullets-bullet-list '("✙" "♱" "♰" "☥" "✞" "✟" "✝" "†" "✠" "✚" "✜" "✛" "✢" "✣" "✤" "✥"))

;; add cygwin path
(if (eq system-type 'windows-nt)
    (add-to-list 'exec-path "c:/cygwin64/bin/"))

;; py-autopep8 config
;; enable formatting when python file is saved
;; (add-hook 'python-mode-hook 'py-autopep8-enable-on-save) ; commented out for efficiency
(setq py-autopep8-options '("--max-line-length=100"))

;; yasnippet minor mode config: yas-minor-mode is autoloaded, so the package
;; and its snippet tables (~0.7s) load with the first code buffer, not at startup
(add-hook 'prog-mode-hook #'yas-minor-mode)
(with-eval-after-load 'yasnippet (yas-reload-all))

;; sphinx-doc mode config
(add-hook 'python-mode-hook (lambda ()
			      (require 'sphinx-doc)
			      (sphinx-doc-mode t)))

;; clang-format config (commands are autoloaded)
(global-set-key (kbd "C-c i") 'clang-format-region)
(global-set-key (kbd "C-c u") 'clang-format-buffer)
(setq clang-format-style-option "llvm")

;; use flycheck for cython-mode (checker registers when flycheck first loads)
(with-eval-after-load 'flycheck (require 'flycheck-cython))
(add-hook 'cython-mode-hook 'flycheck-mode)

;; config yaml-mode
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))

(require 'yapfify)

; enaml config
(require 'enaml)
(setq auto-mode-alist (cons '("\\.enaml$" . enaml-mode) auto-mode-alist))

;; js2-refactor and xref-js2 config — loaded with js2-mode itself (first
;; .js/.mjs file); eagerly they pull js2-mode+js+cc-mode (~0.7s) at startup
(with-eval-after-load 'js2-mode
  (require 'js2-refactor)
  (require 'xref-js2)
  (js2r-add-keybindings-with-prefix "C-c C-r")
  (define-key js2-mode-map (kbd "C-k") #'js2r-kill)
  ;; js-mode (which js2 is based on) binds "M-." which conflicts with xref,
  ;; so unbind it.
  (define-key js-mode-map (kbd "M-.") nil))

(add-hook 'js2-mode-hook #'js2-refactor-mode)
(add-to-list 'auto-mode-alist '("\\.mjs\\'" . js2-mode))

(add-hook 'js2-mode-hook (lambda ()
  (add-hook 'xref-backend-functions #'xref-js2-xref-backend nil t)))

;; slime settings
(setq inferior-lisp-program "sbcl")
(require 'slime-autoloads)
;; one call — each slime-setup call overwrites the previous contrib list.
;; Deferred: running it eagerly loads slime+comint+etags at startup; the
;; contribs are registered when slime itself first loads (M-x slime).
(with-eval-after-load 'slime
  (slime-setup '(slime-fancy slime-company)))

;; ;; lsp-mode config
;; ;; if you want to change prefix for lsp-mode keybindings.
;; (setq lsp-keymap-prefix "s-l")

;; (add-hook 'java-mode-hook #'lsp)
;; (add-hook 'c++-mode-hook #'lsp)

;; Start LSP after dir-locals are applied. Auto-detect a venv named venv/ or
;; .venv/ by searching upward from the file itself, so it also works in plain
;; folders that are not git repos. Without this, pyvenv keeps whatever env was
;; activated last and pylsp resolves imports against the wrong site-packages.
(add-hook 'hack-local-variables-hook
          (lambda ()
            (when (derived-mode-p 'python-mode)
              (pyvenv-mode 1)          ; autoloaded; loads pyvenv on first use
              (let (venv)
                (locate-dominating-file
                 default-directory
                 (lambda (dir)
                   (setq venv (seq-find #'file-directory-p
                                        (mapcar (lambda (name)
                                                  (expand-file-name name dir))
                                                '("venv" ".venv"))))))
                ;; no project venv and nothing active yet: fall back to the
                ;; default env (if it exists on this machine) so pylsp is found
                (unless (or venv pyvenv-virtual-env)
                  (when (file-directory-p my/pyvenv-default-env)
                    (setq venv my/pyvenv-default-env)))
                (when venv (pyvenv-activate venv)))
              (lsp))))

;; (require 'dired+)

;; Install Copilot via MELPA
(use-package copilot
  :ensure t
  :hook ((python-mode
          sh-mode
          c-mode
          c++-mode
          yaml-mode
          terraform-mode
          go-mode
          typescript-mode) . copilot-mode)
  :config
  ;; Copilot won't complete in buffers over copilot-max-char (100KB); that's
  ;; expected, so don't warn about it on every large file visit.
  (setq copilot-max-char-warning-disable t)
  (define-key copilot-mode-map (kbd "C-M-<return>") #'copilot-accept-completion)
  (define-key copilot-mode-map (kbd "C-M-<prior>") #'copilot-previous-completion)
  (define-key copilot-mode-map (kbd "C-M-<next>") #'copilot-next-completion)
  (define-key copilot-mode-map (kbd "C-M-<right>") #'copilot-accept-completion-by-word)
  (define-key copilot-mode-map (kbd "C-M-<down>") #'copilot-accept-completion-by-line)
  (define-key copilot-mode-map (kbd "C-c C-c") #'copilot-clear-overlay))

;; Install Terraform
(use-package terraform-mode
  :ensure t
  :custom (terraform-indent-level 4)
  :config
  (defun my-terraform-mode-init ()
    ;; if you want to use outline-minor-mode
    ;; (outline-minor-mode 1)
    )

  (add-hook 'terraform-mode-hook 'my-terraform-mode-init))

;; lsp-mode keybinding prefix. C-c l instead of s-l: the Super key is usually
;; grabbed by the desktop environment (Super+L locks the screen on GNOME).
(setq lsp-keymap-prefix "C-c l")

;; lsp-mode and lsp-ivy load lazily via autoloads on first `lsp' call.

;; tsgo (@typescript/native-preview) is incompatible with lsp-mode's
;; inlineCompletion:null capability — use typescript-language-server instead.
(setq lsp-disabled-clients '(tsgo))

;; Disable LSP symbol highlighting globally (expensive on every cursor move).
(setq lsp-enable-symbol-highlighting nil
      lsp-idle-delay 0.5)

;; Don't poll for code actions on every idle just for the modeline lightbulb —
;; the lsp-ui sideline already shows code actions (9% CPU in profiling).
(setq lsp-modeline-code-actions-enable nil)

;; Don't render hover docs in the echo area via eldoc — the lsp-ui doc popup
;; already shows them; keeping both doubles the hover requests on every idle.
(setq lsp-eldoc-enable-hover nil)

;; Don't register filesystem watchers over the whole workspace — a known
;; slowdown in large repos, and the servers we use barely rely on them.
(setq lsp-enable-file-watchers nil)

;; counsel-imenu hardcodes python.el's slow regex-based index for python
;; buffers, discarding the LSP-provided one. Route it back to the buffer's
;; imenu function (LSP's) when lsp manages the buffer.
(define-advice python-imenu-create-flat-index (:around (fn &rest args) prefer-lsp)
  (if (and (bound-and-true-p lsp-managed-mode)
           (not (eq imenu-create-index-function #'python-imenu-create-flat-index)))
      (funcall imenu-create-index-function)
    (apply fn args)))

;; Disable slow minor modes for large files (>100KB). append=t ensures this
;; runs after smartparens-global-mode's find-file-hook, which would otherwise
;; re-enable smartparens-mode after we disable it. LSP stays enabled — the
;; navigation slowness was show-paren's backward-up-list, not LSP.
(defun my/large-file-performance-mode ()
  (when (> (buffer-size) 100000)
    (when (bound-and-true-p flycheck-mode)    (flycheck-mode -1))
    (when (bound-and-true-p smartparens-mode) (smartparens-mode -1))
    (when (bound-and-true-p hs-minor-mode)    (hs-minor-mode -1))
    (setq-local jit-lock-stealth-time nil)))
(add-hook 'find-file-hook #'my/large-file-performance-mode t)
(add-hook 'terraform-mode-hook #'lsp)

;; M-s i (counsel-imenu) uses lsp-mode's imenu symbols in lsp buffers.
;; M-s I searches symbols project-wide across all workspace files.
(with-eval-after-load 'lsp-mode
  (define-key lsp-mode-map (kbd "M-s I") #'lsp-ivy-workspace-symbol))

;; lsp-ui: hover docs, peek references, sideline. Configured conservatively so
;; it doesn't tax cursor movement (see the typing.py history): docs and
;; sideline render only after the cursor rests, and hover info is off in the
;; sideline (diagnostics and code actions still show).
(with-eval-after-load 'lsp-mode
  (require 'lsp-ui)
  (setq lsp-ui-doc-show-with-cursor t
        lsp-ui-doc-delay 0.8
        lsp-ui-doc-position 'at-point
        lsp-ui-sideline-delay 0.5
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-code-actions t)
  ;; doc popup appearance: symbol header + type signature, gruvbox colors,
  ;; subtle border, capped size so it never covers the whole window
  (setq lsp-ui-doc-header t
        lsp-ui-doc-include-signature t
        lsp-ui-doc-max-width 82
        lsp-ui-doc-max-height 18
        lsp-ui-doc-border "#928374")
  (set-face-attribute 'lsp-ui-doc-background nil :background "#32302f")
  (set-face-attribute 'lsp-ui-doc-header nil
                      :background "#3c3836" :foreground "#83a598" :weight 'bold)
  ;; peek views instead of plain xref buffers
  (define-key lsp-ui-mode-map [remap xref-find-references] #'lsp-ui-peek-find-references))

;; dap-mode: interactive debugging via VS Code debug adapters. Loads lazily on
;; first M-x dap-debug. Python needs `pip install debugpy', Go uses delve.
(with-eval-after-load 'dap-mode
  (require 'dap-python)
  (require 'dap-dlv-go)
  ;; dap-python defaults to the deprecated ptvsd adapter, which crashes on
  ;; modern Python (stack requests fail); debugpy is its maintained successor
  (setq dap-python-debugger 'debugpy)
  (dap-auto-configure-mode 1)
  ;; mouse support: hover a variable during a session to see its value
  (dap-tooltip-mode 1)
  (tooltip-mode 1))

;; VS Code-style: click the left fringe to toggle a breakpoint on that line
(defun my/dap-mouse-toggle-breakpoint (event)
  "Toggle a dap breakpoint on the line whose fringe was clicked."
  (interactive "e")
  (save-excursion
    (mouse-set-point event)
    (dap-breakpoint-toggle)))
(global-set-key [left-fringe mouse-1] #'my/dap-mouse-toggle-breakpoint)

;; vterm: real terminal emulator (compiles a native module on first launch;
;; needs cmake and libtool/libvterm installed). Unsupported on native Windows
;; Emacs, where C-c v falls back to the built-in eshell.
(global-set-key (kbd "C-c v")
                (if (eq system-type 'windows-nt) 'eshell 'vterm))

;; Open the current buffer's directory in the OS file manager.
(defun open-in-file-manager ()
  "Open the directory of the current buffer in the system file manager."
  (interactive)
  (let ((dir (if (buffer-file-name)
                 (file-name-directory (buffer-file-name))
               default-directory)))
    (cond
     ((eq system-type 'gnu/linux)  (start-process "" nil "xdg-open" dir))
     ((eq system-type 'darwin)     (start-process "" nil "open" dir))
     ((eq system-type 'windows-nt) (w32-shell-execute "open" dir)))))

;; Go mode config
(use-package go-mode
  :ensure t
  :mode "\\.go\\'"
  :hook ((go-mode . lsp)
         (go-mode . (lambda ()
                      (setq tab-width 4)
                      (setq indent-tabs-mode t)))
         (before-save . (lambda ()
                          (when (eq major-mode 'go-mode)
                            (lsp-format-buffer)
                            (lsp-organize-imports))))))

;; TypeScript mode config
(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'"
  :hook ((typescript-mode . lsp)
         (typescript-mode . (lambda ()
                               (setq typescript-indent-level 2))))
  :config
  (add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
  (define-key typescript-mode-map (kbd "M-.") nil))

;; ---- modern IDE starter set ----

;; which-key: after pressing a prefix (C-c p, C-c l, ...), pop up a panel
;; showing every binding that continues from it.
(which-key-mode 1)

;; projectile: project-aware commands under C-c p — fuzzy find file (C-c p f),
;; switch project (C-c p p), search (C-c p s g), etc. counsel-projectile makes
;; them use ivy completion.
(projectile-mode 1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(counsel-projectile-mode 1)

;; diff-hl: VS Code-style git change markers (added/modified/deleted) in the
;; window fringe, updated live while editing.
(global-diff-hl-mode 1)
(diff-hl-flydiff-mode 1)
(with-eval-after-load 'magit
  (add-hook 'magit-pre-refresh-hook 'diff-hl-magit-pre-refresh)
  (add-hook 'magit-post-refresh-hook 'diff-hl-magit-post-refresh))

(provide 'init-packages)
;;; init-package.el ends here
