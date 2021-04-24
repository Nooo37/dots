(require 'xresources-theme)

(defun make-new-buffer ()
  "makes a new buffer, uniquely named"
  (interactive)
  (switch-to-buffer "New")
  (rename-uniquely))

(use-package undo-tree
  :config
  (global-undo-tree-mode t)
  (setq undo-tree-auto-save-history t)
  (push '("." . "~/.emacs.d/undo-tree-history") undo-tree-history-directory-alist))

(use-package general
  :config
  (general-create-definer namba/leader-keys
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (namba/leader-keys
    ;; toggle 
    "t"  '(:ignore t :which-key "toggle")
    "tr" '(rainbow-delimiters-mode :which-key "toggle rainbow delimiters mode")
    "tc" '(rainbow-mode :which-key "toggle rainbow mode")
    "td" '(elcord-mode :which-key "toggle discord thingy")
    "tg" '(git-gutter-mode :which-key "git gutter")
    "tl" '(:ignore t :which-key "line number toggling")
    "tlr" '(menu-bar--display-line-numbers-mode-relative :which-key "enable relative line numbers")
    "tla" '(menu-bar--display-line-numbers-mode-absolute :which-key "enable relative line numbers")
    "tld" '(display-line-numbers-mode :which-key "enable relative line numbers")
    ;; open 
    "o"  '(:ignore t :which-key "open")
    "oe" '(elfeed :which-key "open elfeed")
    "ob" '(counsel-switch-buffer :which-key "switch buffer")
    "od" '(dired :which-key "open dired")
    "oo" '(org-agenda :which-key "open dired")
    "om" '(magit-status :which-key "open magit")
    "os" '(shell :which-key "open shell")
    ;; latex
    "l"  '(:ignore t :which-key "latex")
    "ll" '(org-latex-preview :which-key "toggle latex preview")
    "lp" '(latex-preview-update :which-key "show rendered PDF")
    "la" '(TeX-command-run-all :which-key "render as PDF")

    "m"  '(comment-line :which-key "(un-)comment lines")))

;; forgive me for I have sinned

(use-package evil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  (setq evil-want-c-u-scroll t)
  (setq evil-want-c-i-jump nil)
  (setq evil-want-fine-undo 'fine)
  (setq evil-undo-system 'undo-tree)
  :config
  (evil-mode 1)
  (define-key evil-insert-state-map (kbd "C-g") 'evil-normal-state)
  (define-key evil-normal-state-map (kbd "C-f") 'swiper)
  ;; use visual line motions even outside of visual-line-mode buffers
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

(evil-collection-init 'elfeed)

(use-package evil-surround
	:after evil
	:config
	(global-evil-surround-mode t))

(use-package evil-magit
  :after magit)

(use-package which-key
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 0.25)
  (which-key-mode +1))

(use-package evil-colemak-basics
  :config
  (global-evil-colemak-basics-mode))


(undo-tree-mode t)
(evil-mode t)

(global-set-key (kbd "<f5>") (lambda() (interactive)(find-file "~/code/rust/mampf/src/util.rs")))
(global-set-key (kbd "<f4>") (lambda() (interactive)(find-file "~/.emacs.d/packages/keys.el")))
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-f") 'swiper)
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) 

(provide 'keys)
