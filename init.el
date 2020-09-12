;; -*- coding: utf-8; lexical-binding: t; -*-

;; Without this comment emacs25 adds (package-initialize) here
;; (package-initialize)

;; @see https://emacs.stackexchange.com/a/4258/202
(setq user-init-file (or load-file-name (buffer-file-name)))
(setq user-emacs-directory (file-name-directory user-init-file))

(let* ((minver "25.1"))
  (when (version< emacs-version minver)
    (error "Emacs v%s or higher is required." minver)))

(defvar best-gc-cons-threshold
  4000000
  "Best default gc threshold value.  Should NOT be too big!")

;; don't GC during startup to save time
(setq gc-cons-threshold most-positive-fixnum)

(defun my-add-subdirs-to-load-path (my-lisp-dir)
  "Add sub-directories under MY-LISP-DIR into `load-path'."
  (let* ((default-directory my-lisp-dir))
    (setq load-path
          (append
           (delq nil
                 (mapcar (lambda (dir)
                           (unless (string-match-p "^\\." dir)
                             (expand-file-name dir)))
                         (directory-files my-site-lisp-dir)))
           load-path))))

(defconst my-emacs-d (file-name-as-directory user-emacs-directory)
  "Directory of emacs.d")

(defconst my-site-lisp-dir (concat my-emacs-d "site-lisp")
  "Directory of site-lisp")

(defconst my-lisp-dir (concat my-emacs-d "lisp")
  "Directory of lisp")

;; @see https://www.reddit.com/r/emacs/comments/55ork0/is_emacs_251_noticeably_slower_than_245_on_windows/
;; (setq garbage-collection-messages t) ; for debug
(setq best-gc-cons-threshold (* 64 1024 1024))
(setq gc-cons-percentage 0.5)
(run-with-idle-timer 5 t #'garbage-collect)

(defun add-code-file-type (mode &rest patterns)
  "Add entries to `auto-mode-alist' to use `MODE' for all given file `PATTERNS'."
  (dolist (pattern patterns)
    (add-to-list 'auto-mode-alist (cons pattern mode))))

;; {{ package stuff
;; optimization, no need to activate all the packages so early
(setq package-enable-at-startup nil)
;; @see https://www.gnu.org/software/emacs/news/NEWS.27.1
(package-initialize)

(defun my-package-generate-autoloads-hack (pkg-desc pkg-dir)
  "Stop package.el from leaving open autoload files lying around."
  (let* ((path (expand-file-name (concat
                                  ;; pkg-desc is string in emacs 24.3.1,
                                  (if (symbolp pkg-desc) (symbol-name pkg-desc) pkg-desc)
                                  "-autoloads.el")
                                 pkg-dir)))
    (with-current-buffer (find-file-existing path)
      (kill-buffer nil))))
(advice-add 'package-generate-autoloads :after #'my-package-generate-autoloads-hack)

(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
        ("melpa" . "https://melpa.org/packages/")))

;; On-demand installation of packages
(defun require-package (package &optional min-version no-refresh)
  "Ask elpa to install given PACKAGE."
  (cond
   ((package-installed-p package min-version)
    t)
   ((or (assoc package package-archive-contents) no-refresh)
    (package-install package))
   (t
    (package-refresh-contents)
    (require-package package min-version t))))

;;; shell and conf
(add-code-file-type 'conf-mode
               "\\.[^b][^a][a-zA-Z]*rc$"
               "\\.aspell\\.en\\.pws$"
               "\\.i3/config-base$"
               "\\mimeapps\\.list$"
               "\\mimeapps\\.list$"
               "\\.editorconfig$"
               "\\.meta$"
               "\\.?muttrc$"
               "\\.mailcap$")
;; racket
(add-code-file-type 'lisp-mode "\\.rkt$")
(add-code-file-type 'emacs-lisp-mode
               "\\.emacs-project$"
               "archive-contents$"
               "\\.emacs\\.bmk$" )
;;  ruby
(add-code-file-type 'enh-ruby-mode
               "\\.\\(rb\\|rake\\|rxml\\|rjs\\|irbrc\\|builder\\|ru\\|gemspec\\)$"
               "\\(Rakefile\\|Gemfile\\)$")
(add-code-file-type 'perl-mode
               "\\.\\([pP][Llm]\\|al\\)$"
               "\\.\\([pP][Llm]\\|al\\)$")
(add-code-file-type 'text-mode "\\.ctags$")
;; java
(add-code-file-type 'java-mode
               "\\.aj$"
               "\\.ninja$" )
(add-code-file-type 'groovy-mode
               "\\.groovy$"
               "\\.gradle$" )
(add-code-file-type 'sh-mode
               "\\.bash\\(_profile\\|_history\\|rc\\.local\\|rc\\)?$"
               "\\.z?sh$"
               "\\.env$")
(add-code-file-type 'cmake-mode
               "CMakeLists\\.txt$"
               "\\.cmake$" )
;; vimrc
(add-code-file-type 'vimrc-mode "\\.?vim\\(rc\\)?$")
(add-code-file-type 'csv-mode "\\.[Cc][Ss][Vv]$")
(add-code-file-type 'rust-mode "\\.rs$")
(add-code-file-type 'verilog-mode "\\.[ds]?vh?$")
(add-code-file-type 'adoc-mode "\\.adoc$")
(add-code-file-type 'texile-mode "\\.textile$")
(add-code-file-type 'tcl-mode "Portfile$")
(add-code-file-type 'yaml-mode "\\.ya?ml$")
;; web/html
(add-code-file-type 'web-mode
               "\\.\\(cmp\\|app\\|page\\|component\\|wp\\|vue\\|tmpl\\|php\\|module\\|inc\\|hbs\\|tpl\\|[gj]sp\\|as[cp]x\\|erb\\|mustache\\|djhtml\\|ftl\\|[rp]?html?\\|xul?\\|eex?\\|xml?\\|jst\\|ejs\\|erb\\|rbxlx\\)$")
(add-code-file-type 'js-mode
               "\\.js\\(\\.erb\\)?$"
               "\\.babelrc$"
               "\\.ja?son$"
               "\\.pac$"
               "\\.jshintrc$")
(add-code-file-type 'rjsx-mode "\\.jsx$")
(add-code-file-type 'typescript-mode "\\.ts$")
(add-code-file-type 'markdown-mode "\\.\\(md\\|markdown\\)$")
(add-code-file-type 'snippet-mode "\\.yasnippet$")
(add-code-file-type 'csharp-mode "\\.cs$")
(add-code-file-type 'basic-mode "\\.cs$")
(add-code-file-type 'go-mode "\\.go$")
(add-code-file-type 'swift-mode "\\.swift$")
(add-code-file-type 'dart-mode "\\.dart$")
(add-code-file-type 'd-mode "\\.d$")
(add-code-file-type 'julia-mode "\\.jl$")
(add-code-file-type 'fountain-mode "\\.fountain$")
(add-code-file-type 'cobol-mode "\\.cob$")
(add-code-file-type 'scala-mode "\\.\\(scala\\|sbt\\|worksheet\\.sc\\)$")
(add-code-file-type 'kotlin-mode "\\.kts?$")
(add-code-file-type 'ada-mode "\\.ada$")
(add-code-file-type 'haskell-mode "\\.l?hs$")
(add-code-file-type 'clojure-mode "\\.\\(clj\\|dtm\\|edn\\)$")
;; boot build scripts are Clojure source files
(add-code-file-type 'clojure-mode "\\(?:build\\|profile\\)\\.boot$")
(add-code-file-type 'clojurec-mode "\\.cljc$")
(add-code-file-type 'clojurescript-mode "\\.cljs$")
(add-code-file-type 'powershell-mode "\\.ps[dm]?1$")
;; }}

;; add packages in site-lisp to `load-path'
(my-add-subdirs-to-load-path (file-name-as-directory my-site-lisp-dir))
(require 'wucuo)
(require 'elpa-mirror)

;; {{ set up flyspell
(setq ispell-program-name "aspell")
(setq ispell-extra-args (wucuo-aspell-cli-args t))

(defun my-spell-check-directory (&optional directory)
  "Spell check DIRECTORY"
  (interactive)
  (unless (and directory (not (string= directory "")))
    ;; scan current directory by default
    (setq directory "."))
  (wucuo-spell-check-directory directory t))

(defun my-spell-check-file (file)
  "Spell check FILE."
  (cond
   ((file-exists-p file)
    (wucuo-spell-check-file file t))
   (t
    (message "%s dose not exist." (file-truename file)))))
;; }}

;; See `custom-file' for details.
(setq custom-file (expand-file-name (concat my-emacs-d "custom-set-variables.el")))
(if (file-exists-p custom-file) (load custom-file t t))

(let* ((my-custom-file (expand-file-name (concat my-emacs-d "my-custom.el"))))
  ;; my personal setup, other major-mode specific setup need it.
  ;; It's dependent on *.el in `my-site-lisp-dir'
  (if (file-exists-p my-custom-file) (load my-custom-file t t)))

;; install third party packages
(require-package 'csv-mode)
(require-package 'lua-mode)
(require-package 'yaml-mode)
(require-package 'scss-mode)
(require-package 'markdown-mode)
(require-package 'jade-mode)
(require-package 'groovy-mode)
(require-package 'cmake-mode)
(require-package 'js2-mode)
(require-package 'rjsx-mode)
(require-package 'web-mode)
(require-package 'adoc-mode) ; asciidoc files
(require-package 'vimrc-mode)
(require-package 'rust-mode)
(require-package 'typescript-mode)
(require-package 'verilog-mode)
(require-package 'csharp-mode)
(require-package 'basic-mode)
(require-package 'ess)
(require-package 'go-mode)
(require-package 'swift-mode)
(require-package 'enh-ruby-mode)
(require-package 'dart-mode)
(require-package 'd-mode)
(require-package 'julia-mode)
(require-package 'fountain-mode)
(require-package 'cobol-mode)
(require-package 'scala-mode)
(require-package 'kotlin-mode)
(require-package 'ada-mode)
(require-package 'haskell-mode)
(require-package 'clojure-mode)
(require-package 'powershell)

;; @see https://ess.r-project.org/Manual/ess.html#Activating-and-Loading-ESS
;; loading all ess features at start up
(require 'ess-site)

(setq gc-cons-threshold best-gc-cons-threshold)

;;; Local Variables:
;;; no-byte-compile: t
;;; End:
