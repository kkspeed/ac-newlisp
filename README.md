ac-newlisp
==========

Auto-complete integration for newlisp-mode

This is an auto-completion integration for newlisp
It depends on newlisp-mode by kosh04:

https://github.com/kosh04/newlisp-mode

Usage:

    (require 'ac-newlisp)
    (add-hook 'newlisp-mode-hook 'ac-newlisp-setup)

Enable auto-complete in newlisp-mode

    (eval-after-load "auto-complete"
     '(add-to-list 'ac-modes 'newlisp-mode))

