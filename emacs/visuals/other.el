;; font + padding + arbitrary resizing etc

;; take up all space (looks off in tiling otherwise)
(setq frame-resize-pixelwise t)

;; font
(set-frame-font "JetBrainsMono NF 9" nil t)

;; callback on all open frames for padding
(defun ns/apply-frames (action)
  (interactive)
  (mapc (lambda (frame)
          (funcall action frame)
          (redraw-frame frame))
    (frame-list)))

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


;; scroll
(setq scroll-up-aggressively 0.01
      scroll-down-aggressively 0.01
      scroll-margin 10
      scroll-step 1
      scroll-conservatively 10000)

;; "insertmode" should be a bar
(setq-default cursor-type 'bar)

(provide 'other)
