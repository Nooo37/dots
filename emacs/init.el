;;; load early-init.el
(unless (boundp 'early-init-file) ...)

;;; load folders
(add-to-list 'load-path "~/.emacs.d/visuals")
(add-to-list 'load-path "~/.emacs.d/packages")

;;; load files
;; (require 'other)
(require 'visuals-loader)
(require 'packages-loader)

;; whoami
(setq user-full-name "namba")

;; don't litter init.el with that
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

(electric-pair-mode t) ;; autocomplete parens
(show-paren-mode t) ;; highlight matching parens

;; raise undo-limit, autosave
(setq undo-limit 80000000
      auto-save-default t)

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from al other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width

(setq-default frame-title-format '("%f [%m]")) ;; a better window title format

(setq make-backup-files nil) ;; stop doing ~ files

(setq-default indent-tabs-mode nil) ;; don't do tabs

(setq inhibit-splash-screen t
      initial-scratch-message ""
      initial-major-mode 'org-mode)

(server-mode t)

