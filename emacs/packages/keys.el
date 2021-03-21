(require 'xresources-theme)

(global-set-key (kbd "<f5>") (lambda() (interactive)(find-file "~/code/rust/mampf/src/util.rs")))
(global-set-key (kbd "<f4>") (lambda() (interactive)(find-file "~/.emacs.d/visuals/xresources-theme.el")))
(global-set-key (kbd "C-s") (lambda() (interactive)(save-buffer)))
(global-set-key (kbd "C-f") (lambda() (interactive)(swiper)))
(global-set-key (kbd "<escape>") 'keyboard-escape-quit) 

(use-package kakoune
  ;; Having a non-chord way to escape is important, since key-chords don't work in macros
  :bind ("<escape>" . ryo-modal-mode)
  :hook (after-init . my/kakoune-setup)
  :config
  (defun ryo-enter () "Enter normal mode" (interactive) (ryo-modal-mode 1))
  (defun my/kakoune-setup ()
      "Call kakoune-setup-keybinds and then add some personal config."
      (kakoune-setup-keybinds)
      (setq ryo-modal-cursor-type 'box)
      (add-hook 'prog-mode-hook #'ryo-enter)
      (define-key ryo-modal-mode-map (kbd "SPC h") 'help-command)
      ;; Access all C-x bindings easily
      (define-key ryo-modal-mode-map (kbd "z") ctl-x-map)
      (ryo-modal-keys
       ("," save-buffer)
       ("P" counsel-yank-pop)
       ("m" mc/mark-next-like-this)
       ("M" mc/skip-to-next-like-this)
       ("n" mc/mark-previous-like-this)
       ("N" mc/skip-to-previous-like-this)
       ("M-m" mc/edit-lines)
       ("*" mc/mark-all-like-this)
       ("v" er/expand-region)
       ("C-v" set-rectangular-region-anchor)
       ("M-s" mc/split-region)
       (";" (("q" delete-window)
             ("v" split-window-horizontally)
             ("s" split-window-vertically)))
       ("C-h" windmove-left)
       ("C-j" windmove-down)
       ("C-k" windmove-up)
       ("C-l" windmove-right)
       ("C-u" scroll-down-command :first '(deactivate-mark))
       ("C-d" scroll-up-command :first '(deactivate-mark)))))

;; This overrides the default mark-in-region with a prettier-looking one,
;; and provides a couple extra commands
(use-package visual-regexp
  :ryo
  ("s" vr/mc-mark)
  ("?" vr/replace)
  ("M-/" vr/query-replace))

;; Probably the first thing you'd miss is undo and redo, which requires an extra package
;; to work like it does in kakoune (and almost every other editor).
(use-package undo-tree
  :config
  (global-undo-tree-mode)
  :ryo
  ("u" undo-tree-undo)
  ("U" undo-tree-redo)
  ("SPC u" undo-tree-visualize)
  :bind (:map undo-tree-visualizer-mode-map
              ("h" . undo-tree-visualize-switch-branch-left)
              ("j" . undo-tree-visualize-redo)
              ("k" . undo-tree-visualize-undo)
              ("l" . undo-tree-visualize-switch-branch-right)))

(setq ryo-modal-cursor-color cyan)

(provide 'keys)
