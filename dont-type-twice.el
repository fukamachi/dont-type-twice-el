;;;; dont-type-twice.el --- Supports your effective text editing.

;; Copyright (C) 2010  深町英太郎 (E. Fukamachi) <e.arrows@gmail.com>

;; Author: 深町英太郎 (E. Fukamachi) <e.arrows@gmail.com>
;; Twitter: http://twitter.com/nitro_idiot
;; Blog: http://e-arrows.sakura.ne.jp/
;;
;; Created: Jun 1, 2010
;; Version: 1.0
;; Keywords: convenience instructor

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the

;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; dont-type-twice.el is an utility to make you not to type same thing twice.
;; This library notifies when you typed same command twice.

;;; Qualification:
;;
;; This library tested with GNU Emacs 23.1 on Ubuntu 10.04 and Mac OS 10.6 only.

;;; Installation:
;;
;; Download dont-type-twice.el (this file) and put into your load-path.
;;
;; If you are ready to use auto-install.el (http://www.emacswiki.org/emacs/auto-install.el), just put below code to your *scratch* and eval it.
;;
;;     (auto-install-from-url "http://github.com/fukamachi/dont-type-twice-el/raw/master/dont-type-twice.el")

;;; Settings:
;;
;; Put following code into your .emacs.el.
;;
;;     (require 'dont-type-twice)
;;     (global-dont-type-twice t)
;;
;; And you open a file, then find to be notified on minibuffer when you did something stupid.
;; Isn't it enough? You can change notification func as you like.
;; Set `dt2-notify-send' to dt2-notify-func, for example,
;;
;;     (setq dt2-notify-func 'dt2-notify-send)
;;
;; You would receive notification with notify-send.
;;
;; For Mac users, it would be `dt2-growl' instead.

;;; Code:

(eval-when-compile (require 'cl))

(defgroup dont-type-twice nil
  "Make you to be efficient"
  :group 'convenience
  :prefix "dt2-")

(defvar dt2-key-log (make-list 100 0))
(defvar dt2-command-set-num 5 "for `dt2-detect-pattern'")

;;====================
;; Customize
;;====================
(defcustom dt2-modes
  '(emacs-lisp-mode
    list-interaction-mode
    scheme-mode
    clojure-mode
    common-lisp-mode
    perl-mode cperl-mode
    ecmascript-mode javascript-mode js2-mode
    ruby-mode
    python-mode
    java-mode malabar-mode
    php-mode
    c-mode cc-mode c++-mode)
  "Major modes `dont-type-twice' can run on."
  :type '(list symbol)
  :group 'dont-type-twice)

(defcustom dt2-notify-func 'dt2-message
  "Function to notify inefficient actions"
  :type '(symbol)
  :group 'dont-type-twice)

(defcustom dt2-limit-count 2
  "How many times you could type the same key"
  :type '(integer)
  :group 'dont-type-twice)

(defcustom dt2-ignore-keys nil
  "Keys to ignore even if it typed many times"
  :type '(list string)
  :group 'dont-type-twice)

;;====================
;; Minor mode
;;====================
(defun dont-type-twice-maybe ()
  (if (and (not (minibufferp (current-buffer)))
           (memq major-mode dt2-modes))
      (dont-type-twice 1)))

(define-minor-mode dont-type-twice
  "Make you to be efficient"
  :lighter " DT2"
  :group 'dont-type-twice
  (if dont-type-twice
      (add-hook 'post-command-hook 'dt2-cast-keys nil t)
    (remove-hook 'post-command-hook 'dt2-cast-keys t)))

(define-global-minor-mode global-dont-type-twice
  dont-type-twice dont-type-twice-maybe
  :group 'dont-type-twice)

;;====================
;; Utilities
;;====================
(defun dt2-count-while (lst val)
  (loop for e in lst
        while (equal e val)
        count 1))

(defun dt2-take (num lst)
  (loop for e in lst
        repeat num collect e))

(defun dt2-compare-subseq (forvec vec)
  (let ((subvec (dt2-take (length forvec) vec)))
    (equal subvec forvec)))

(defmacro dt2-aif (test then &optional else)
  `(let ((it ,test))
     (if it ,then ,else)))

(defun dt2-every (pred lst)
  (loop for e in lst
        always (funcall pred e)))

(defun dt2-every-same-as (val lst)
  (dt2-every (lambda (e) (equal val e)) lst))

;;====================
;; Key Cast
;;====================
(defun dt2-detect-pattern ()
  "Detect same pattern"
  (dotimes (i (- dt2-command-set-num dt2-limit-count))
    (let* ((j (+ i dt2-limit-count))
           (subv (dt2-take j dt2-key-log)))
      (if (and (not (dt2-every-same-as (car dt2-key-log) subv))
               (dt2-compare-subseq subv (nthcdr j dt2-key-log)))
          (return (nreverse subv))))))

(defun dt2-cast-keys ()
  "Check the command keys have not typed before"
  (let ((key-name (key-description (this-command-keys))))
    (unless (or (string= "" key-name) (member key-name dt2-ignore-keys))
      (setq dt2-key-log (cons key-name (butlast dt2-key-log)))
      (let ((cnt (dt2-count-while dt2-key-log key-name)))
        (if (<= dt2-limit-count cnt)
            (funcall dt2-notify-func
                     "Don't Type Twice!!"
                     (format "%s [%d times]" key-name cnt)
                     key-name))
        (dt2-aif (dt2-detect-pattern)
                 (funcall dt2-notify-func
                          "Don't Type Same Pattern!!" (format "%s" it)))))))

;;====================
;; Notifications
;;====================
(defun dt2-message (title message &optional id)
  "Notify to *Messages* (default)"
  (message (format "%s : %s" title message)))

(defun dt2-growl (title message &optional id)
  "Notify with Growl (for Mac users)"
  (start-process "dont-type-twice" "*growl*" "growlnotify"
                 title "-w" "-d" id)
  (process-send-string "*growl*" (concat message "\n"))
  (process-send-eof "*growl*"))

(defun dt2-notify-send (title message &optional id)
  "Notify with notify-send
   (Growl-like notification tool included in libnotify-bin)"
  (start-process "dont-type-twice" nil "notify-send"
                 "-t" "1000" title message))

(provide 'dont-type-twice)
;;; dont-type-twice.el ends here
