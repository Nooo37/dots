;;; load early-init.el
(unless (boundp 'early-init-file) ...)

;;; load folders
(add-to-list 'load-path "~/.emacs.d/visuals")
(add-to-list 'load-path "~/.emacs.d/packages")

;;; load files
(require 'other)
(require 'visuals-loader)
(require 'packages-loader)
