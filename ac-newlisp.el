;;; ac-newlisp.el --- Auto-complete integration for newlisp

;; Copyright (C) 2014

;; Author:  leilmyxwz@gmail.com
;; Keywords: lisp, languages, extensions

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This is an auto-completion integration for newlisp
;; It depends on newlisp-mode by kosh04:
;; https://github.com/kosh04/newlisp-mode

;;; Usage:
;; (require 'ac-newlisp)
;; (add-hook 'newlisp-mode-hook 'ac-newlisp-setup)
;; Enable auto-complete in newlisp-mode
;; (eval-after-load "auto-complete"
;;  '(add-to-list 'ac-modes 'newlisp-mode))


;;; Code:


(require 'auto-complete)
(require 'newlisp-mode)

(defun newlisp-ordinary-insertion-filter (proc string)
  "An insertion filter to insert grab output from process, based on ordinary-insertion-filter
   at http://www.gnu.org/software/emacs/manual/html_node/elisp/Filter-Functions.html"
  (when (buffer-live-p (process-buffer proc))
    (with-current-buffer (process-buffer proc)
      (let ((moving (= (point) (process-mark proc))))
        (save-excursion
          ;; Insert the text, advancing the process marker.
          (goto-char (process-mark proc))
          (insert string)
          (set-marker (process-mark proc) (point)))
        (if moving (goto-char (process-mark proc)))))))


(defun newlisp-command (com &optional buf proc)
  "Execute newlisp command"
  (unless buf
    (setq buf (get-buffer-create "*newlisp-command-output*")))
  (let* ((sproc (newlisp-process))
         (oldpb (process-buffer sproc))
         (oldpf (process-filter sproc))
         (oldpm (process-mark sproc)))
    (unwind-protect
        (progn
          (set-process-buffer sproc buf)
          (set-process-filter sproc 'newlisp-ordinary-insertion-filter)
          (with-current-buffer buf
            (setq buffer-read-only nil)
            (erase-buffer)
            (set-marker (process-mark sproc) (point-min))
            (process-put sproc 'busy t)
            (process-put sproc 'sec-prompt nil)
            (process-send-string sproc com)
            (sleep-for 0.020)
            (goto-char (point-max))
            (delete-region (point-at-bol) (point-max)))
          (set-process-buffer sproc oldpb)
          (set-process-filter sproc oldpf)
          (set-marker (process-mark sproc) oldpm)))
    buf))

(defun ac-newlisp-candidates ()
  (let ((buf (newlisp-command "(map string (symbols))\n")))
    (with-current-buffer buf
      (goto-char (point-min))
      (read buf))))

(defvar ac-source-newlisp
  '((candidates . ac-newlisp-candidates)))

(defun ac-newlisp-setup ()
  (interactive)
  (add-to-list 'ac-sources 'ac-source-newlisp))

(provide 'ac-newlisp)
;;; ac-newlisp.el ends here
