(require 'straight-setup)

;;; currently mostly kakoune.el + some global binds
(require 'keys)

;;; various things
(require 'utils)

;;; language server 
(require 'lsp-mode)

;;; all kind of languages
(require 'langs)

;;; discord rich presence (off by default)
(require 'elcord)

(require 'my-mode)

(provide 'packages-loader)
