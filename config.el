;;; $DOOMDIR.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Stamatis Vretinaris"
      user-mail-address "svretina@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-solarized-light)

;;(setq doom-theme 'doom-one)

;;(setq doom-theme 'doom-gruvbox)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

;; Change windows with M-arrows
;; (windmove-default-keybindings 'meta)

;; When saving a file that starts with `#!', make it executable.
(add-hook! 'after-save-hook
           'executable-make-buffer-file-executable-if-script-p)

(fset 'yes-or-no-p 'y-or-n-p)

;; When saving a file in a directory that doesn't exist, offer
;; to (recursively) create the file's parent directories.
(add-hook! 'before-save-hook
  (lambda ()
    (when buffer-file-name
      (let ((dir (file-name-directory buffer-file-name)))
        (when (and (not (file-exists-p dir))
                   (y-or-n-p (format "Directory %s does not exist. Create it?" dir)))
          (make-directory dir t))))))

;; Kill the buffer withouth asking
(defun kill-this-buffer ()	; for the menu bar
  "Kill the current buffer overrided to work always."
  (interactive)
  (kill-buffer (current-buffer))
  )
(global-set-key (kbd "C-x k") 'kill-this-buffer)

;; When opening a new buffer change to focus to it
(setq split-window-preferred-function 'my/split-window-func)
(defun my/split-window-func (&optional window)
  (let ((new-window (split-window-sensibly window)))
    (if (not (active-minibuffer-window))
        (select-window new-window))))

;; PDF-tools
(use-package! pdf-tools
  :ensure t
  :mode (("\\.pdf\\'" . pdf-view-mode))
  ;; Don't use swyper in pdf-tools
  :bind (:map pdf-view-mode-map
              ("C-s" . isearch-forward)

              ("C-r" . isearch-backward)
              )
  :config
  ;; Ensure pdf-tools is installed
  (pdf-tools-install)

  (setq-default pdf-view-display-size 'fit-page)

  ;; Sync tex and pdf
  (defun th/pdf-view-revert-buffer-maybe (file)
    (let ((buf (find-buffer-visiting file)))
      (when buf
        (with-current-buffer buf
          (when (derived-mode-p 'pdf-view-mode)
            (pdf-view-revert-buffer nil t))))))
  (add-hook! 'TeX-after-TeX-LaTeX-command-finished-hook
             #'th/pdf-view-revert-buffer-maybe)
  )
;; Fix flickering for pdf-tools
;; This should be already in Doom Emacs, but for some reason, it does
;; not work
;; (after! pdf-tools
;;      (use-package pdf-tools
;;        :magic ("%PDF" . pdf-view-mode)
;;        :mode (("\\.pdf\\'" . pdf-view-mode))
;;      ;; Don't use swyper in pdf-tools
;;        :bind (:map pdf-view-mode-map
;;                    ("C-s" . isearch-forward)
;;                    ("C-r" . isearch-backward)
;;                    ("g"   . my-revert-pdf)
;;              )
;;        )
;;      )

(global-auto-revert-mode t)

(use-package! tramp
  :defer t
  :init
  (setq tramp-ssh-controlmaster-options
	(substitute-in-file-name (concat
				  "-o ControlPath=$HOME/.ssh/ssh-%%r@%%h:%%p "
				  "-o ControlMaster=auto -o ControlPersist=yes")))
  (setq tramp-default-method "ssh")
  :config
  ;; Use $PATH of the remote machine
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (setq tramp-shell-prompt-pattern "\\(?:^\\|\r\\)[^]#$%>\n]*#?[]#$%>].* *\\(^[\\[[0-9;]*[a-zA-Z] *\\)*")
  )


(setq auto-save-default t
      truncate-string-ellipsis "…"
      )

(unless (string-match-p "^Power N/A" (battery))   ;; On laptops...
  (display-battery-mode 1))

(setq tab-always-indent t)


;;  Some sh-like files
(use-package! sh-script
  :mode (("\\.ebuild\\'" . sh-mode)
         ;; Einstein Toolkit
         ("\\.th\\'" . sh-mode)
         ("\\.ccl\\'" . sh-mode)
         ("\\.par\\'" . sh-mode)))


;; Flycheck shouls not be enabled for vterm.
;; For some reasons, sometimes I found it enabled, so here I force it
;; not to be enabled.
;; (after! flycheck
;;   (use-package! flycheck
;;     :init
;;     (setq flycheck-global-modes '(not vterm-mode))))

(setq confirm-kill-emacs nil)

(use-package! ivy
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-pretty)
  :init
  (global-set-key (kbd "C-s") #'swiper)
  (global-set-key (kbd "C-r") #'swiper)
  :config
  (define-key ivy-minibuffer-map (kbd "C-j") #'ivy-immediate-done)
  (define-key ivy-minibuffer-map (kbd "RET") #'ivy-alt-done)
  (setq ivy-use-virtual-buffers t)
  (setq counsel-search-engine 'google)
  )

(setq fancy-splash-image "~/.config/doom/black-hole.png")

(setq treemacs-file-ignore-extensions
      '(;; LaTeX
        "aux"
        "ptc"
        "fdb_latexmk"
        "fls"
        "synctex.gz"
        "toc"
        ;; LaTeX - glossary
        "glg"
        "glo"
        "gls"
        "glsdefs"
        "ist"
        "acn"
        "acr"
        "alg"
        ;; LaTeX - pgfplots
        "mw"
        ;; LaTeX - pdfx
        "pdfa.xmpi"
        ))

(setq treemacs-file-ignore-globs
      '(;; LaTeX
        "*/_minted-*"
        ;; AucTeX
        "*/.auctex-auto"
        "*/_region_.log"
        "*/_region_.tex"))

;; Buffer move
(require 'buffer-move)

(global-set-key (kbd "<C-s-up>")     'buf-move-up)
(global-set-key (kbd "<C-s-down>")   'buf-move-down)
(global-set-key (kbd "<C-s-left>")   'buf-move-left)
(global-set-key (kbd "<C-s-right>")  'buf-move-right)

;; windmove with meta
(global-set-key (kbd "<M-up>")     'windmove-up)
(global-set-key (kbd "<M-down>")   'windmove-down)
(global-set-key (kbd "<M-left>")   'windmove-left)
(global-set-key (kbd "<M-right>")  'windmove-right)

(map! :after vterm
      :map vterm-mode-map
      "<M-left>" #'windmove-left)

(map! :after vterm
      :map vterm-mode-map
      "<M-up>" #'windmove-up)

(map! :after vterm
      :map vterm-mode-map
      "<M-right>" #'windmove-right)

(map! :after vterm
      :map vterm-mode-map
      "<M-down>" #'windmove-down)

;; Legacy paste
(global-set-key (kbd "C-v") 'yank)

(global-set-key (kbd "M-/") 'undo)

(when (executable-find "ipython")
  (setq python-shell-interpreter "ipython"))

;; (use-package conda
;;   :init
;;   (setq conda-anaconda-home (expand-file-name "~/anaconda3"))
;;   (setq conda-env-home-directory (expand-file-name "~/anaconda3"))
;;   :config
;;   (conda-env-initialize-interactive-shells)
;;   (conda-env-initialize-eshell))


;; (setq-default TeX-engine 'xetex
;;               TeX-PDF-mode t)

(add-hook! LaTeX-mode
  (add-to-list TeX-command-list '("XeLaTeX" "%`xelatex%(mode)%' %t" TeX-run-TeX nil t))
  (setq TeX-command-default "XeLaTeX"
        TeX-save-query nil
        TeX-show-compilation t))

(setq-default TeX-engine 'xetex
              TeX-PDF-mode t)

;; (use-package! julia-snail
;;   :after julia
;;   (setq julia-snail-use-emoji-mode-lighter t)
;;   :config
;;   :ensure vterm
;;   :hook (julia-mode . julia-snail-mode))

;; (after! julia-snail-mode
;;   (map! :map julia-snail-mode-map "C-c C-c" #'julia-snail-send-buffer-file))

;; ((julia-mode . ((julia-snail-extra-args . ("--threads" "4")))))

;; (add-hook! 'julia-mode-hook 'julia-snail-mode)
;;(add-hook! 'julia-mode-hook 'julia-snail)
;; (setq +format-on-save-enabled-modes
;;       '(not emacs-lisp-mode  ; elisp's mechanisms are good enough
;; 	sql-mode         ; sqlformat is currently broken
;; 	tex-mode         ; latexindent is broken
;; 	latex-mode))

(setq lsp-julia-package-dir nil)
(setq lsp-diagnostics-provider :none)
(setq lsp-ui-sideline-enable nil)

(add-hook! julia-mode
  (add-hook 'before-save-hook 'lsp-format-buffer nil t))

;; (require 'julia-formatter)
;; (add-hook 'julia-mode-hook #'julia-formatter-mode)
;; (set-formatter! 'julia-formatter  "julia-formatter" :modes '(julia-mode))
;; (setq-hook! 'julia-mode-hook +format-with 'julia-formatter)
;;(setq eglot-connect-timeout 1200)
