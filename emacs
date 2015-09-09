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

; Ido mode
(ido-mode 1)

; Inhibit the default messages
(setq inhibit-startup-message t
      inhibit-startup-echo-area-message t)

(setq default-tab-width 4)