(setq package-archives '(("melpa" . "http://melpa.milkbox.net/packages/")
                         ("org" . "http://orgmode.org/elpa/")
                         ("gnu" . "http://elpa.gnu.org/packages/")))

(require 'package)
(package-initialize)

; Make keybindings not terrible
(require 'evil)
(evil-mode 1)
(define-key evil-normal-state-map (kbd "<SPC>") 'evil-ex)
(define-key evil-motion-state-map (kbd "<SPC>") 'evil-ex)

; Line numbers please
(global-linum-mode)

; Make sentences end with a single period.
(setq sentence-end-double-space nil)

; No blinking cursor
(blink-cursor-mode 0)
