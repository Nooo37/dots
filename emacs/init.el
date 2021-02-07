;; This config generates itself from the config.org file
;; don't edit that file; edit config.org instead

(setq make-backup-files nil)
(setq auto-save-default nil)

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

(setq inhibit-splash-screen t
      initial-scratch-message ""
      initial-major-mode 'org-mode)

(setq-default frame-title-format '("%f [%m]"))

(electric-pair-mode 1)

;; NOTE: init.el is now generated from Emacs.org.  Please edit that file
;;       in Emacs and init.el will be generated automatically!

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

  ;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; (global-hl-line-mode +1)
 ;; (set-face-background 'hl-line "#333333")

 (setq inhibit-startup-message t)

 (scroll-bar-mode -1)        ; Disable visible scrollbar
 (tool-bar-mode -1)          ; Disable the toolbar
 (tooltip-mode -1)           ; Disable tooltips
 (set-fringe-mode 10)        ; Give some breathing room

 (menu-bar-mode -1)            ; Disable the menu bar

 (column-number-mode)
 (global-display-line-numbers-mode 1)
;; (global-linum-mode t)

 ;; Disable line numbers for some modes
 (dolist (mode '(org-mode-hook
                 deer-mode-hook
                 ranger-mode-hook
                 term-mode-hook
                 shell-mode-hook
                 meme-mode-hook
                 treemacs-mode-hook
                 neotree-mode-hook
                 lsp-ui-imenu-mode-hook
                 eshell-mode-hook))
   (add-hook mode (lambda () (display-line-numbers-mode 0))))

(setq frame-resize-pixelwise t)

;; callback on all open frames
(defun ns/apply-frames (action)
  (interactive)
  (mapc (lambda (frame)
          (funcall action frame)
          (redraw-frame frame))
    (frame-list)))

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from al other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq undo-limit 80000000                         ; Raise undo-limit to 80Mb
;; evil-want-fine-undo t                       ; By default while in insert all changes are one big blob. Be more granular
 auto-save-default t                         ; Nobody likes to loose work, I certainly don't
 truncate-string-ellipsis "…")               ; Unicode ellispis are nicer than "...", and also save /precious/ space


(defun ns/frame-set-parameter (key value)
  "set a value on all current and future frames"
  (interactive)
  ;; current:
  (ns/apply-frames (lambda (k) (set-frame-parameter k key value)))

  ;; future:
  (setq default-frame-alist
        (assq-delete-all key default-frame-alist))

  (add-to-list 'default-frame-alist `(,key . ,value)))


(ns/frame-set-parameter 'internal-border-width 40)

;; You will most likely need to adjust this font size for your system!
(defvar efs/default-font-size 100)
(defvar efs/default-variable-font-size 100)

(set-face-attribute 'default nil :font "JetBrains Mono Nerd Font" :height efs/default-font-size)

;; Set the fixed pitch face
(set-face-attribute 'fixed-pitch nil :font "JetBrains Mono Nerd Font" :height efs/default-font-size)

;; Set the variable pitch face
(set-face-attribute 'variable-pitch nil :font "JetBrains Mono Nerd Font" :height efs/default-variable-font-size :weight 'regular)

(use-package doom-themes
  :init (load-theme 'doom-mine t))

(custom-set-variables
  '(scroll-conservatively 1000)
  '(scroll-margin 9)
)

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15)))

;; show some other usefull stuff
(setq doom-modeline-major-mode-icon t)
(setq doom-modeline-lsp t)

(use-package ivy
  :diminish
  :after evil
  :bind (("C-f" . swiper)
	 :map ivy-minibuffer-map
	 ("TAB" . ivy-alt-done)
	 ("C-l" . ivy-alt-done)
	 ("C-j" . ivy-next-line)
	 ("C-k" . ivy-previous-line)
	 :map ivy-switch-buffer-map
	 ("C-k" . ivy-previous-line)
	 ("C-l" . ivy-done)
	 ("C-d" . ivy-switch-buffer-kill)
	 :map ivy-reverse-i-search-map
	 ("C-k" . ivy-previous-line)
	 ("C-d" . ivy-reverse-i-search-kill))
  :config
  (ivy-mode 1))

(use-package ivy-rich
  :init
  (ivy-rich-mode 1))

(use-package counsel
  :bind (("C-M-j" . 'counsel-switch-buffer)
	 :map minibuffer-local-map
	 ("C-r" . 'counsel-minibuffer-history))
  ;; :custom
  ;; (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (counsel-mode 1))

(use-package helpful
  :custom
  (counsel-describe-function-function #'helpful-callable)
  (counsel-describe-variable-function #'helpful-variable)
  :bind
  ([remap describe-function] . counsel-describe-function)
  ([remap describe-command] . helpful-command)
  ([remap describe-variable] . counsel-describe-variable)
  ([remap describe-key] . helpful-key))

(use-package hydra)

(defhydra hydra-text-scale (:timeout 4)
  "scale text"
  ("j" text-scale-increase "in")
  ("k" text-scale-decrease "out")
  ("f" nil "finished" :exit t))

(use-package ranger)
(ranger-override-dired-mode t)
(setq ranger-parent-depth 1)
(setq ranger-width-parents 0.12)
(setq ranger-max-parent-width 0.12)
(setq ranger-preview-file t)
(setq ranger-width-preview 0.55)
(dolist (mode '(deer-mode-hook))
    (add-hook mode () (ranger-minimal-toggle)))

(use-package elcord)

(use-package fzf)

(use-package neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(use-package emojify)
  ;; :hook (after-init . global-emojify-mode))

(add-to-list 'load-path "~/.config/emacs/meme")
(require 'meme)
(autoload 'meme "meme.el" "Create a meme from a collection" t)
(autoload 'meme-file "meme.el" "Create a meme from a file" t)

(setq inhibit-splash-screen t
      initial-scratch-message ""
      initial-major-mode 'org-mode)

(use-package undo-tree
  :config
  (global-undo-tree-mode t)
  (setq undo-tree-auto-save-history t)
  (push '("." . "~/.config/emacs/undo-tree-history") undo-tree-history-directory-alist))

(use-package rainbow-mode
  :hook (after-init . rainbow-mode))

(setq evil-want-keybindings nil)
  (use-package evil
    :init
    (setq evil-want-integration t)
    (setq evil-want-keybinding nil)
    (setq evil-want-C-u-scroll t)
    (setq evil-want-C-i-jump nil)
	(setq evil-want-fine-undo 'fine)
	(setq evil-undo-system 'undo-tree)
    :config
    (evil-mode 1)
    (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
    (define-key evil-insert-state-map (kbd "C-h") 'evil-delete-backward-char-and-join)

    ;; Use visual line motions even outside of visual-line-mode buffers
    (evil-global-set-key 'motion "j" 'evil-next-visual-line)
    (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

    (evil-set-initial-state 'messages-buffer-mode 'normal)
    (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-org
  :after org
  :config
  (add-hook 'org-mode-hook 'evil-org-mode)
  (add-hook 'evil-org-mode-hook 'evil-org-set-key-theme)
  (require 'evil-org-agenda)
  (evil-org-agenda-set-keys))

  (use-package evil-collection
    :after evil
    :config
    (evil-collection-init))

(use-package evil-surround
	:after evil
	:config
	(global-evil-surround-mode t))

;; Make ESC quit prompts
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)

  ;; just to quickly get to the emacs config
  (global-set-key (kbd "<f5>") (lambda() (interactive)(find-file "~/.config/emacs/config.org")))
  (global-set-key (kbd "<f4>") (lambda() (interactive)(find-file "~/.config/awesome/rc.lua")))
  (global-unset-key (kbd "C-s"))
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-s") 'save-buffer)
  (global-set-key (kbd "C-z") 'evil-undo)


(defun xresources-theme-color (name)
  "Read the color NAME (e.g. color5) from the X resources."
    (interactive)
    (format "%s" (shell-command-to-string (format
                "xrdb -q | grep \"%s\" | awk '{print $2}' | tr -d \"\\n\""
                   (concat name ":"))))
  )

  (global-set-key (kbd "<f3>") (lambda() (interactive)(message (xresources-theme-color "color1"))))


  (use-package general
    :config
    (general-create-definer namba/leader-keys
      :keymaps '(normal insert visual emacs)
      :prefix "SPC"
      :global-prefix "C-SPC")

    (namba/leader-keys
      "t"  '(:ignore t :which-key "toggles")
      "tr" '(rainbow-delimiters-mode :which-key "toggle rainbow delimiters mode")
      "td" '(elcord-mode :which-key "toggle discord thingy")
      "tl" '(:ignore t :which-key "line number toggling")
      "tlr" '(menu-bar--display-line-numbers-mode-relative :which-key "enable relative line numbers")
      "tla" '(menu-bar--display-line-numbers-mode-absolute :which-key "enable relative line numbers")
      "tld" '(display-line-numbers-mode :which-key "enable relative line numbers")
      "c" '(:ignore t :which-key "programming stuff")
      "cf" '(yafolding-toggle-element :which-key "toggle folding element")
      "ca" '(yafolding-toggle-all :which-key "toggle folding all")
      "ci" '(lsp-ui-imenu :which-key "show lsp imenu")
      "tt" '(counsel-load-theme :which-key "choose theme")
      "tn" '(neotree-toggle :which-key "toggles neotree")
      "ts" '(hydra-text-scale/body :which-key "scale text"))
    (namba/leader-keys
      "o"  '(:ignore t :which-key "open")
      "ob" '(switch-to-buffer :which-key "switch buffer")
      "od" '(dired :which-key "open dired")
      "oo" '(org-agenda :which-key "open dired")
      "om" '(meme :which-key "open meme generator")
      "os" '(shell :which-key "open shell"))
    (namba/leader-keys
      "gp" '(org-publish :which-key "org publish"))
    (namba/leader-keys
      "i"  '(:ignore t :which-key "insert")
      "it" '(org-insert-structure-template :which-key "insert structure template")
      "ie" '(emojify-insert-emoji :which-key "insert emojis"))
    (namba/leader-keys
      "l"  '(:ignore t :which-key "latex")
      "ll" '(org-latex-preview :which-key "toggle latex preview")
      "lp" '(latex-preview-update :which-key "show rendered PDF")
      "la" '(TeX-command-run-all :which-key "render as PDF"))
    (namba/leader-keys
      "m"  '(comment-line :which-key "(un-)comment lines")) )

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package auctex-latexmk
  :ensure t
  :config
  (auctex-latexmk-setup)
  (setq auctex-latexmk-inherit-TeX-PDF-mode t))

(use-package tex
  :ensure auctex
  :mode ("\\.tex\\'" . latex-mode)
  :config (progn
	    (setq TeX-source-correlate-mode t)
	    (setq TeX-source-correlate-method 'synctex)
	    (setq TeX-auto-save t)
	    (setq TeX-parse-self t)
	    ;;    (setq-default TeX-master "paper.tex")
	    (setq reftex-plug-into-AUCTeX t)
	    ;;(setq TeX-view-program-selection '((output-pdf "zathura"))
	    ;;    TeX-source-correlate-start-server t)
	    ;; Update PDF buffers after successful LaTeX runs
	    (add-hook 'TeX-after-compilation-finished-functions
		      #'TeX-revert-document-buffer)
	    (add-hook 'LaTeX-mode-hook
		      (lambda ()
			(reftex-mode t)
			(flyspell-mode t)))
	    ))

(use-package auctex
  :defer t
  :ensure t
  :config
  (setq TeX-auto-save t))

(require 'ox-publish)
  (defvar my-preamble  "<p>PREAMBLE</p>")
  (defvar my-postamble "<p>PREAMBLE</p>")


  (defun my-html-preamble (options)
;;   "<div class='topnav'>
;;     <ul>
;;       <li><a href='/blog/index.html'>Home</a></li>
;;       <li><a href='/blog/remember.html'>Blog</a></li>
;;       <li class='right feed'><a href='/blog/rss.xml'>RSS</a></li>
;;     </ul>
;;   </div>

;;   <div class='foreword'>
;;     [%d (last updated: %C) Press <kbd>?</kbd> for navigation help]
;;   </div>"
"<header>
        <center>
        <a class='title' href='https://Nooo37.github.io/webs'>N°37</a>
        <p class='subtitle'>my blorg</p>
        </center>
 </header>")


  (setq org-publish-project-alist
    `(
      ("org-notes"
       :base-directory "~/code/git/blog/"
       :base-extension "org"
       :publishing-directory "~/code/git/webs/"
       :recursive t
       :publishing-function org-html-publish-to-html
       :headline-levels 4             ; Just the default for this project.
       ;; :html-head ,my-preamble ; muss noch
       ;; :auto-preamble nil
       ;; :auto-postamble nil
       :html-preamble my-html-preamble
       ;; :html-postamble ,my-postamble
     )
      ("org-static"
       :base-directory "~/code/git/blog/"
       :base-extension "css\\|js\\|png\\|jpg\\|gif\\|pdf\\|mp3\\|ogg\\|swf"
       :publishing-directory "~/code/git/webs/"
       :recursive t
       :publishing-function org-publish-attachment
     )
     ("org" :components ("org-notes" "org-static"))
    )
  )
;; no validate button on the bottom
(setq org-export-html-validation-link nil)
(setq org-html-validation-link nil)

(setq org-export-in-background t)

(defun efs/org-font-setup ()
  ;; Replace list hyphen with dot
  (font-lock-add-keywords 'org-mode
                          '(("^ *\\([-]\\) "
                             (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))

  ;; Set faces for heading levels
  (dolist (face '((org-level-1 . 1.2)
                  (org-level-2 . 1.1)
                  (org-level-3 . 1.05)
                  (org-level-4 . 1.0)
                  (org-level-5 . 1.1)
                  (org-level-6 . 1.1)
                  (org-level-7 . 1.1)
                  (org-level-8 . 1.1)))
    (set-face-attribute (car face) nil :font "Cantarell" :weight 'regular :height (cdr face)))

  ;; Ensure that anything that should be fixed-pitch in Org files appears that way
  (set-face-attribute 'org-block nil :foreground nil :inherit 'fixed-pitch)
  (set-face-attribute 'org-code nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-table nil   :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-verbatim nil :inherit '(shadow fixed-pitch))
  (set-face-attribute 'org-special-keyword nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-meta-line nil :inherit '(font-lock-comment-face fixed-pitch))
  (set-face-attribute 'org-checkbox nil :inherit 'fixed-pitch))

(defun efs/org-mode-setup ()
  (org-indent-mode)
  (variable-pitch-mode 1)
  (visual-line-mode 1))

(use-package org
  :pin org
  :hook (org-mode . efs/org-mode-setup)
  :config
  (setq org-ellipsis " ▾")

  (setq org-agenda-start-with-log-mode t)
  (setq org-log-done 'time)
  (setq org-log-into-drawer t)

  (setq org-agenda-files '("~/docs/org/"))

  (require 'org-habit)
  (add-to-list 'org-modules 'org-habit)
  (setq org-habit-graph-column 60)

  (setq org-todo-keywords
    '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!)")
      (sequence "BACKLOG(b)" "PLAN(p)" "READY(r)" "ACTIVE(a)" "REVIEW(v)" "WAIT(w@/!)" "HOLD(h)" "|" "COMPLETED(c)" "CANC(k@)")))

  ;;(setq org-refile-targets
  ;;  '(("Archive.org" :maxlevel . 1)
  ;;    ("Tasks.org" :maxlevel . 1)))

  ;; Save Org buffers after refiling!
  (advice-add 'org-refile :after 'org-save-all-org-buffers)

  (setq org-tag-alist
    '((:startgroup)
       ; Put mutually exclusive tags here
       (:endgroup)
       ("@errand" . ?E)
       ("@home" . ?H)
       ("@work" . ?W)
       ("agenda" . ?a)
       ("planning" . ?p)
       ("publish" . ?P)
       ("batch" . ?b)
       ("note" . ?n)
       ("idea" . ?i)))

  ;; Configure custom agenda views
  (setq org-agenda-custom-commands
   '(("d" "Dashboard"
     ((agenda "" ((org-deadline-warning-days 7)))
      (todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))
      (tags-todo "agenda/ACTIVE" ((org-agenda-overriding-header "Active Projects")))))

    ("n" "Next Tasks"
     ((todo "NEXT"
        ((org-agenda-overriding-header "Next Tasks")))))

    ("W" "Work Tasks" tags-todo "+work-email")

    ;; Low-effort next actions
    ("e" tags-todo "+TODO=\"NEXT\"+Effort<15&+Effort>0"
     ((org-agenda-overriding-header "Low Effort Tasks")
      (org-agenda-max-todos 20)
      (org-agenda-files org-agenda-files)))

    ("w" "Workflow Status"
     ((todo "WAIT"
            ((org-agenda-overriding-header "Waiting on External")
             (org-agenda-files org-agenda-files)))
      (todo "REVIEW"
            ((org-agenda-overriding-header "In Review")
             (org-agenda-files org-agenda-files)))
      (todo "PLAN"
            ((org-agenda-overriding-header "In Planning")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "BACKLOG"
            ((org-agenda-overriding-header "Project Backlog")
             (org-agenda-todo-list-sublevels nil)
             (org-agenda-files org-agenda-files)))
      (todo "READY"
            ((org-agenda-overriding-header "Ready for Work")
             (org-agenda-files org-agenda-files)))
      (todo "ACTIVE"
            ((org-agenda-overriding-header "Active Projects")
             (org-agenda-files org-agenda-files)))
      (todo "COMPLETED"
            ((org-agenda-overriding-header "Completed Projects")
             (org-agenda-files org-agenda-files)))
      (todo "CANC"
            ((org-agenda-overriding-header "Cancelled Projects")
             (org-agenda-files org-agenda-files)))))))

  (define-key global-map (kbd "C-c j")
    (lambda () (interactive) (org-capture nil "jj")))

  (efs/org-font-setup))

(use-package org-bullets
  :after org
  :hook (org-mode . org-bullets-mode)
  :custom
  (org-bullets-bullet-list '("◉" "○" "●" "○" "●" "○" "●")))

(defun efs/org-mode-visual-fill ()
  (setq visual-fill-column-width 100
        visual-fill-column-center-text t)
  (visual-fill-column-mode 1))

(use-package visual-fill-column
  :hook (org-mode . efs/org-mode-visual-fill))

(org-babel-do-load-languages
  'org-babel-load-languages
  '((emacs-lisp . t)
    (python . t)))

(push '("conf-unix" . conf-unix) org-src-lang-modes)

;; This is needed as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src shell"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))

;; Automatically tangle config.org config file when saved
(defun efs/org-babel-tangle-config ()
  (when (string-equal (file-name-directory (buffer-file-name))
                      (expand-file-name "~/.config/emacs/"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(setq-default indent-tabs-mode nil)

(use-package yafolding)

(use-package highlight-indent-guides)
(add-hook 'prog-mode-hook 'highlight-indent-guides-mode)
(setq highlight-indent-guides-method 'character)
(setq highlight-indent-guides-character #\:)
(qset 'highlight-indent-guides-odd-face "red")
(qset 'highlight-indent-guides-even-face "red")
(qset 'highlight-indent-guides-character-face "red")
(highlight-indent-guides-auto-set-faces)

(use-package git-gutter)
(add-hook 'prog-mode-hook 'git-gutter+-mode)

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (prog-mode, lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

(add-hook 'after-init-hook #'lsp-ui-mode)

(use-package lsp-ui-imenu
  :hook (lsp-mode . lsp-ui-mode))

(use-package lsp-ui-doc
  :hook (lsp-mode . lsp-ui-mode))

(use-package lsp-treemacs
  :after lsp)

(use-package lsp-ivy)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)

  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup) ;; Automatically installs Node debug adapter if needed

  ;; Bind `C-c l d` to `dap-hydra` for easy access
  (general-define-key
    :keymaps 'lsp-mode-map
    :prefix lsp-keymap-prefix
    "d" '(dap-hydra t :wk "debugger")))

(use-package lua-mode
  :mode "\\.lua\\'"
  :hook (lua-mode . lsp-deferred)
  :config
  (setq lua-indent-level 4))

(add-hook 'lua-mode-hook #'lsp)

(use-package lsp-java 
  :config 
    (add-hook 'java-mode-hook 'lsp))

(add-to-list 'load-path "~/.config/emacs/lsp")

(require 'lsp-latex)
;; "texlab" must be located at a directory contained in `exec-path'.
;; If you want to put "texlab" somewhere else,
;; you can specify the path to "texlab" as follows:
;; (setq lsp-latex-texlab-executable "/path/to/texlab")

(with-eval-after-load "tex-mode"
 (add-hook 'tex-mode-hook 'lsp)
 (add-hook 'latex-mode-hook 'lsp))

;; For YaTeX
(with-eval-after-load "yatex"
 (add-hook 'yatex-mode-hook 'lsp))

;; For bibtex
(with-eval-after-load "bibtex"
 (add-hook 'bibtex-mode-hook 'lsp))

(use-package lsp-bash
  :config 
    (add-hook 'bash-mode-hook 'lsp))

(use-package kbd-mode
  :load-path "~/.config/emacs/")

(use-package company
  :after lsp-mode
  :hook (lsp-mode . company-mode)
  :bind (:map company-active-map
         ("<tab>" . company-complete-selection))
        (:map lsp-mode-map
         ("<tab>" . company-indent-or-complete-common))
  :custom
  (company-minimum-prefix-length 1)
  (company-idle-delay 0.0))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package projectile
  :diminish projectile-mode
  :config (projectile-mode)
  :custom ((projectile-completion-system 'ivy))
  :bind-keymap
  ("C-c p" . projectile-command-map)
  :init
  ;; NOTE: Set this to the folder where you keep your Git repos!
  (setq projectile-switch-project-action #'projectile-dired))

;; (use-package counsel-projectile
  ;; :config (counsel-projectile-mode))

(use-package magit
  :custom
  (magit-display-buffer-function #'magit-display-buffer-same-window-except-diff-v1))

(use-package evil-magit
  :after magit)

;; NOTE: Make sure to configure a GitHub token before using this package!
;; - https://magit.vc/manual/forge/Token-Creation.html#Token-Creation
;; - https://magit.vc/manual/ghub/Getting-Started.html#Getting-Started
(use-package forge)

(use-package rainbow-delimiters
  :hook (prog-mode . rainbow-delimiters-mode))
