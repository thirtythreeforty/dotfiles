;;; packages.el --- whitespace Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2014 Sylvain Benner
;; Copyright (c) 2014-2015 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

;; List of all packages to install and/or initialize. Built-in packages
;; which require an initialization must be listed explicitly in the list.
(setq whitespace-packages
      '(
        dtrt-indent
        smart-tabs-mode
        whitespace
        ws-butler
        ))

;; List of packages to exclude.
(setq whitespace-excluded-packages '())

;; dtrt-indent initialization

(defun whitespace/init-dtrt-indent ()
  (use-package dtrt-indent
    :commands (dtrt-indent-mode dtrt-indent-adapt)))

(defun whitespace/post-init-dtrt-indent ()
  (when whitespace-global-detect-indent
    (dtrt-indent-mode)))

;; smart-tabs-mode initialization
(defun whitespace/init-smart-tabs-mode ()
  (use-package smart-tabs-mode
    :commands (smart-tabs-mode
               smart-tabs-mode-enable
               smart-tabs-advice
               smart-tabs-insinuate)))

(defun whitespace/post-init-smart-tabs-mode ()
  (when whitespace-smart-tabs
    (smart-tabs-insinuate 'c 'c++ 'java 'javascript 'cperl 'python 'ruby 'nxml)))

;; whitespace initialization
(defun whitespace/post-init-whitespace ()
  (when whitespace-global-show
    (global-whitespace-mode)))

;; ws-butler initialization

(defun whitespace/init-ws-butler ()
  (use-package ws-butler
    :commands (ws-butler-mode ws-butler-global-mode)))

(defun whitespace/post-init-ws-butler ()
  (when whitespace-global-butler
    (ws-butler-global-mode))
  (spacemacs|add-toggle whitespace-strip
    :status ws-butler-mode
    :on (ws-butler-mode)
    :off (ws-butler-mode -1)
    :documentation ("Strip whitespace on save.")
    :evil-leader "tS")
  (spacemacs|add-toggle whitespace-strip-globally
    :status ws-butler-global-mode
    :on (ws-butler-global-mode)
    :off (ws-butler-global-mode -1)
    :documentation ("Globally strip whitespace on save.")
    :evil-leader "t C-S"))
