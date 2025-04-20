;;; init.el --- Global settings -*- lexical-binding: t; -*-

(unless (>= emacs-major-version 29)
  (error "This init requires Emacs 29 or newer; you’re on %s" emacs-version))

;; The default is 800 kilobytes. Measured in bytes.
(setq gc-cons-threshold (* 50 1024 1024))

(defun expand-config-directory (relative-path)
  "Takes RELATIVE-PATH as a str and expands that onto user-emacs-directory
  confirming the directory itselfs and creating it otherwise."
  (let ((config-path (expand-file-name relative-path user-emacs-directory)))
    (unless (file-directory-p config-path)
      (make-directory config-path t))
    (convert-standard-filename config-path)))


;; Emacs lisp source/compiled preference
;; Prefer loading newest compiled .el file
(customize-set-variable 'load-prefer-newer t)

;; Silence compiler warnings as they can be pretty disruptive
(setq native-comp-async-report-warnings-errors nil)

;;; Native compilation settings
(when (featurep 'native-compile)
  ;; Make native compilation happens asynchronously
  (setq native-comp-deferred-compilation t)
  (let ((eln-dir (expand-config-directory "var/eln-cache")))
    (add-to-list 'native-comp-eln-load-path eln-dir)
    (startup-redirect-eln-cache eln-dir)))


;; Make the initial buffer load faster by setting its mode to fundamental-mode
(customize-set-variable 'initial-major-mode 'fundamental-mode)


;; Loads a nice blue theme, avoids the white screen flash on startup.
(load-theme 'deeper-blue t)

(require 'package)

(add-to-list 'package-archives '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("nongnu" . "https://elpa.nongnu.org/nongnu/"))
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))

(customize-set-variable 'package-archive-priorities
                        '(("gnu"    . 99)   ; prefer GNU packages
                          ("nongnu" . 80)   ; use non-gnu packages if
                                            ; not found in GNU elpa
                          ("stable" . 70)   ; prefer "released" versions
                                            ; from melpa
                          ("melpa"  . 0)))  ; if all else fails, get it
                                            ; from melpa

(package-initialize)

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)

(setq use-package-always-ensure t)

(use-package quelpa
  :ensure)

(use-package quelpa-use-package
  :demand
  :config
  (quelpa-use-package-activate-advice))


(setq org-id-locations-file
      (expand-file-name "org-id-locations"
                        (expand-config-directory "var")))


;; Load README.org where the primary configuration lives
(org-babel-load-file
 (expand-file-name "README.org"
                   user-emacs-directory))
