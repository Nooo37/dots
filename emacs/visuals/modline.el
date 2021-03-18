;; Don't judge me

(use-package all-the-icons)

(use-package doom-modeline
  :init (doom-modeline-mode 1)
  :custom ((doom-modeline-height 15))
  :config (setq 
        doom-modeline-major-mode-icon t
        doom-modeline-lsp t
        doom-modeline-height 25
        doom-modeline-bar-width 1
        doom-modeline-unicode-fallback t
        doom-modeline-enable-word-count nil
        doom-modeline-continuous-word-count-modes '(markdown-mode gfm-mode org-mode)
        doom-modeline-buffer-encoding nil
        doom-modeline-indent-info nil
        doom-modeline-workspace-name t))

;; show some other usefull stuff

(provide 'modline)
