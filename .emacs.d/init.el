(add-to-list 'load-path "~/.emacs.d/lisp")

(setenv "PATH" (concat "/usr/local/bin:" (getenv "PATH")))
(setenv "LANG" "en_US.UTF-8")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)

;; cmake-project lsp-mode go-mode

(load-file "~/.emacs.d/lisp/time-synchronize-theme.el")
(set-face-attribute 'default nil :family "JuliaMono" :height 120)

(global-set-key (kbd "M-g") 'goto-line)
(global-set-key (kbd "C-x C-b") 'bs-show)

(setq-default indent-tabs-mode t)
(setq-default tab-width 8)

(setq ring-bell-function 'ignore)
(show-paren-mode t)
(setq column-number-mode t)
(if window-system
  (tool-bar-mode -1))

(defun maybe-cmake-project-mode ()
  (if (or (file-exists-p "CMakeLists.txt")
          (file-exists-p
	   (expand-file-name "CMakeLists.txt"
			     (car (project-roots (project-current))))))
      (cmake-project-mode)))

(setq-default cmake-project-default-build-dir-name "build/")

(setq-default c-basic-offset 8)
(add-hook 'c-mode-hook 'maybe-cmake-project-mode)
(add-hook 'c-mode-hook 'whitespace-mode)

(add-hook 'c++-mode-hook 'maybe-cmake-project-mode)
(add-hook 'c++-mode-hook 'whitespace-mode)

(add-hook 'cmake-mode-hook 'maybe-cmake-project-mode)

(require 'lsp)
(add-hook 'go-mode-hook 'linum-mode)
(add-hook 'go-mode-hook 'hl-line-mode)
(add-hook 'go-mode-hook #'lsp)

(autoload 'lux-mode "lux-mode" "Lux Mode" t)
(add-to-list 'auto-mode-alist '("\\.lux\\'" . lux-mode))
(add-to-list 'auto-mode-alist '("\\.luxinc\\'" . lux-mode))
(add-to-list 'auto-mode-alist '("\\.plux\\'" . lux-mode))
(add-to-list 'auto-mode-alist '("\\.pluxinc\\'" . lux-mode))

(setf host-init-file (concat "~/.emacs.d/" (getenv "HOSTNAME") ".el"))
(if (file-exists-p host-init-file)
    (load host-init-file))
