(defun set-selected-frame-opaque ()
  (interactive)
  (set-frame-parameter (selected-frame)
                       'alpha '(100 100)))

(defun set-selected-frame-transparent ()
  (interactive)
  (set-frame-parameter (selected-frame)
                       'alpha (list
                               dotspacemacs-active-transparency
                               dotspacemacs-inactive-transparency)))

(defun set-transparent-if-fullscreen ()
  (if (member (frame-parameter (selected-frame) 'fullscreen)
              '(fullscreen fullboth))
      (set-selected-frame-transparent)
    (set-selected-frame-opaque)))
