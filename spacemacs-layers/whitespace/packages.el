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
