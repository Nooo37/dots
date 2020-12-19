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
  :bind (("C-s" . swiper)
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
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
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

(use-package neotree)
(setq neo-theme (if (display-graphic-p) 'icons 'arrow))

(use-package emojify)
  ;; :hook (after-init . global-emojify-mode))

(add-to-list 'load-path "~/.emacs.d/meme")
(require 'meme)
(autoload 'meme "meme.el" "Create a meme from a collection" t)
(autoload 'meme-file "meme.el" "Create a meme from a file" t)

(setq inhibit-splash-screen t
      initial-scratch-message ""
      initial-major-mode 'org-mode)

;;(use-package undo-tree
;;  :config
;;  (global-undo-tree-mode t)
;;  (setq undo-tree-auto-save-history t)
;;  (push '("." . "~/.emacs.d/undo-tree-history") undo-tree-history-directory-alist))

(use-package rainbow-mode
  :hook (after-init . rainbow-mode))

;; Make ESC quit prompts
(global-set-key (kbd "<escape>") 'keyboard-escape-quit)

;; just to quickly get to the emacs config
(global-set-key (kbd "<f5>") (lambda() (interactive)(find-file "~/.emacs.d/config.org")))

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
    "i"  '(:ignore t :which-key "insert")
    "it" '(org-insert-structure-template :which-key "insert structure template")
    "ie" '(emojify-insert-emoji :which-key "insert emojis")))

  (namba/leader-keys
    "l"  '(:ignore t :which-key "latex")
    "ll" '(org-latex-preview :which-key "toggle latex preview")
    "lp" '(latex-preview-update :which-key "show rendered PDF")
    "la" '(TeX-command-run-all :which-key "render as PDF"))

  (namba/leader-keys
    "m"  '(evilnc-comment-or-uncomment-lines :which-key "(un-)comment lines"))

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

;;
;;  (defun org-blog-prepare (project-plist)
;;    "With help from `https://github.com/howardabrams/dot-files'.
;;    Touch `index.org' to rebuilt it.
;;    Argument `PROJECT-PLIST' contains information about the current project."
;;    (let* ((base-directory (plist-get project-plist :base-directory))
;;           (buffer (find-file-noselect (expand-file-name "index.org" base-directory) t)))
;;      (with-current-buffer buffer
;;        (set-buffer-modified-p t)
;;        (save-buffer 0))
;;      (kill-buffer buffer)))
;;
;;  (defvar org-blog-head
;;    "<link rel=\"stylesheet\" type=\"text/css\" href=\"/assets/css/bootstrap.css\"/>
;;    <link rel=\"stylesheet\" type=\"text/css\" href=\"https://fonts.googleapis.com/css?family=Amaranth|Handlee|Libre+Baskerville|Bree+Serif|Ubuntu+Mono|Pacifico&subset=latin,greek\"/>
;;    <link rel=\"shortcut icon\" type=\"image/x-icon\" href=\"favicon.ico\">")
;;
;;  (defun org-blog-preamble (_plist)
;;    "Pre-amble for whole blog."
;;    "<div class=\"banner\">
;;      <a href=\"/\"> Ramblings from a Corner </a>
;;    </div>
;;    <ul class=\"banner-links\">
;;      <li><a href=\"/\"> About Me </a> </li>
;;      <li><a href=\"/archive.html\"> Posts </a> </li>
;;    </ul>
;;    <hr>")
;;
;;  (defun org-blog-postamble (plist)
;;    "Post-amble for whole blog."
;;    (concat
;;    "<footer class=\"footer\">
;;        <!-- Footer Definition -->
;;     </footer>
;;
;;    <!-- Google Analytics Js -->"
;;
;;     ;; Add Disqus if it's a post
;;     (when (s-contains-p "/posts/" (plist-get plist :input-file))
;;     "<!-- Disqua JS --> ")))
;;
;;  (defun org-blog-sitemap-format-entry (entry _style project)
;;    "Return string for each ENTRY in PROJECT."
;;    (when (s-starts-with-p "posts/" entry)
;;      (format "@@html:<span class=\"archive-item\"><span class=\"archive-date\">@@ %s @@html:</span>@@ [[file:%s][%s]] @@html:</span>@@"
;;              (format-time-string "%h %d, %Y"
;;                                  (org-publish-find-date entry project))
;;              entry
;;              (org-publish-find-title entry project))))
;;
;;  (defun org-blog-sitemap-function (title list)
;;    "Return sitemap using TITLE and LIST returned by `org-blog-sitemap-format-entry'."
;;    (concat "#+TITLE: " title "\n\n"
;;            "\n#+begin_archive\n"
;;            (mapconcat (lambda (li)
;;                         (format "@@html:<li>@@ %s @@html:</li>@@" (car li)))
;;                       (seq-filter #'car (cdr list))
;;                       "\n")
;;            "\n#+end_archive\n"))
;;
;;  (defun org-blog-publish-to-html (plist filename pub-dir)
;;    "Same as `org-html-publish-to-html' but modifies html before finishing."
;;    (let ((file-path (org-html-publish-to-html plist filename pub-dir)))
;;      (with-current-buffer (find-file-noselect file-path)
;;        (goto-char (point-min))
;;        (search-forward "<body>")
;;        (insert (concat "\n<div class=\"content-wrapper container\">\n "
;;                        "  <div class=\"row\"> <div class=\"col\"> </div> "
;;                        "  <div class=\"col-sm-6 col-md-8\"> "))
;;        (goto-char (point-max))
;;        (search-backward "</body>")
;;        (insert "\n</div>\n<div class=\"col\"></div></div>\n</div>\n")
;;        (save-buffer)
;;        (kill-buffer))
;;      file-path))
;;
;;  (setq org-publish-project-alist
;;        `(("orgfiles"
;;           :base-directory "~/test/"
;;           :exclude ".*drafts/.*"
;;           :base-extension "org"
;;
;;           :publishing-directory "~/test/"
;;
;;           :recursive t
;;           :preparation-function org-blog-prepare
;;           :publishing-function org-blog-publish-to-html
;;
;;           :with-toc nil
;;           :with-title t
;;           :with-date t
;;           :section-numbers nil
;;           :html-doctype "html5"
;;           :html-html5-fancy t
;;           :html-head-include-default-style nil
;;           :html-head-include-scripts nil
;;           :htmlized-source t
;;           :html-head-extra ,org-blog-head
;;           :html-preamble org-blog-preamble
;;           :html-postamble org-blog-postamble
;;
;;           :auto-sitemap t
;;           :sitemap-filename "archive.org"
;;           :sitemap-title "Blog Posts"
;;           :sitemap-style list
;;           :sitemap-sort-files anti-chronologically
;;           :sitemap-format-entry org-blog-sitemap-format-entry
;;           :sitemap-function org-blog-sitemap-function)
;;
;;          ("assets"
;;           :base-directory "~/test/src/assets/"
;;           :base-extension ".*"
;;           :publishing-directory "~/test/assets/"
;;           :publishing-function org-publish-attachment
;;           :recursive t)
;;
;;          ;; ("rss"
;;          ;;  :base-directory "~/test/src/"
;;          ;;  :base-extension "org"
;;          ;;  :html-link-home "https://vicarie.in/"
;;          ;;  :html-link-use-abs-url t
;;          ;;  :rss-extension "xml"
;;          ;;  :publishing-directory "~/test/"
;;          ;;  :publishing-function (org-rss-publish-to-rss)
;;          ;;  :exclude ".*"
;;          ;;  :include ("archive.org")
;;          ;;  :section-numbers nil
;;          ;;  :table-of-contents nil)
;;
;;          ("blog" :components ("orgfiles" "assets" "rss"))))

(use-package htmlize)

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
                      (expand-file-name "~/.emacs.d/"))
    ;; Dynamic scoping to the rescue
    (let ((org-confirm-babel-evaluate nil))
      (org-babel-tangle))))

(add-hook 'org-mode-hook (lambda () (add-hook 'after-save-hook #'efs/org-babel-tangle-config)))

(use-package yafolding)

(use-package git-gutter)

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols))
  (lsp-headerline-breadcrumb-mode))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook (lsp-mode . efs/lsp-mode-setup)
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t))

(use-package lsp-ui
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom))

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

(add-to-list 'load-path "~/.emacs.d/lsp")

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

(use-package counsel-projectile
  :config (counsel-projectile-mode))

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
