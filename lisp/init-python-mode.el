;;; Enable the python flyCheck with and jedi function
;;; flycheck need install: pip install flake8
;;; jedi need to install: pip install epc and  pip install virtualenv and M-X jedi:install-server

(setq auto-mode-alist
      (append '(("SConstruct\\'" . python-mode)
		("SConscript\\'" . python-mode))
              auto-mode-alist))
(require-package 'pip-requirements)
(require-package 'epc)
(require 'epcs)
(require-package 'jedi)
(add-hook 'python-mode-hook 'jedi:setup)
(setq jedi:complete-on-dot t)

(provide 'init-python-mode)
