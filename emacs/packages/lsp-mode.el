;;; Comment:
;;; This file have the configuration for LSP mode
;;; and a hook that uses writeroom-mode to hide the headerline
;;; to do not do weird stuff with the normal headerline and use the LSP headerline.


;;; Also LSP support for C/Cpp and Clojure
;;; Check LSP docs for more languages here: https://emacs-lsp.github.io/lsp-mode/page/languages/

;;; Code:

;; LSP and friends

(defun efs/lsp-mode-setup ()
  (setq lsp-headerline-breadcrumb-segments '(path-up-to-project file symbols)))

(use-package lsp-mode
  :ensure
  :commands (lsp lsp-deferred)
  :hook ((lua-mode . lsp)
         (bash-mode . lsp)
         (rustic-mode . lsp)
       (lsp-mode . lsp-enable-which-key-integration))
  :init
  (setq lsp-keymap-prefix "C-c l")  ;; Or 'C-l', 's-l'
  :config
  (lsp-enable-which-key-integration t)
  :custom
  ;; what to use when checking on-save. "check" is default, I prefer clippy
  (lsp-rust-analyzer-cargo-watch-command "clippy")
  (lsp-eldoc-render-all t)
  (lsp-idle-delay 0.6)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  )





(use-package lsp-ivy)

(use-package lsp-ui
  :ensure
  :commands lsp-ui-mode
  :hook (lsp-mode . lsp-ui-mode)
  :custom
  (lsp-ui-doc-position 'bottom)
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable t))

(setq lsp-headerline-breadcrumb-enable nil
    lsp-ui-sideline-enable t
    lsp-ui-sideline-show-code-actions t
    lsp-ui-sideline-show-hover nil
    lsp-modeline-code-actions-enable t
    lsp-diagnostics-provider t
    lsp-ui-sideline-enable t
    lsp-signature-auto-activate t
    lsp-rust-cfg-test nil)


(add-hook 'after-init-hook #'lsp-ui-mode)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)

  :config
  ;; Set up Node debugging
  (require 'dap-node)
  (dap-node-setup)) ;; Automatically installs Node debug adapter if needed

  ;; Bind `C-c l d` to `dap-hydra` for easy access
(add-hook 'after-init-hook #'lsp-ui-mode)

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

(add-hook 'after-init-hook 'global-company-mode)

;;; -- Language support (LSP)

;; LSP for c/cpp
(use-package ccls
  :hook ((c-mode c++-mode objc-mode cuda-mode) .
         (lambda () (require 'ccls) (lsp))))     ;; requires ccls, cmake, clang (install it w/ your package manager)


;; add this to your Clojure config
;; LSP for Clojure
(add-hook 'clojure-mode-hook 'lsp)
(add-hook 'clojurescript-mode-hook 'lsp)
(add-hook 'clojurec-mode-hook 'lsp)
(add-hook 'rust-mode 'lsp)

;; Note to install the lsp-server for Clojure you will need to do:
;;; M-x lsp-install-server RET clojure-lsp

(provide 'lsp-mode)
