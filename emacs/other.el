;;; all sort of tweaks

;; whoami
(setq user-full-name "namba")

;; don't litter init.el with that
(setq custom-file "~/.emacs.d/custom.el")
(load custom-file)

;; autocomplete parentesis
(electric-pair-mode t)
;; show matching parenthesis
(show-paren-mode t)

;; raise undo-limit, autosave
(setq undo-limit 80000000
      auto-save-default t)

(setq-default
 delete-by-moving-to-trash t                      ; Delete files to trash
 window-combination-resize t                      ; take new window space from al other windows (not just current)
 x-stretch-cursor t)                              ; Stretch cursor to the glyph width


;; title format
(setq-default frame-title-format '("%f [%m]"))

;; stop creating ~ files
(setq make-backup-files nil)

(provide 'other)
