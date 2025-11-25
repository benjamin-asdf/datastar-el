;;; datastar.el --- A minor mode for datastar projects  -*- lexical-binding: t; -*-

;; Author: Benjamin Janos Schwerdner <Benjamin.Schwerdtner@gmail.com>
;; Version: 0.1
;; Keywords: datastar, web, javascript, html
;; Package-Requires: ((emacs "26.1"))
;; URL: https://github.com/benjamin-asdf/datastar-el

;;; Commentary:

;; This package provides a minor mode for working with datastar projects.
;; It provides completion for datastar attributes.
;; See the Readme provided with the source code of this package.

;;; Code:

(require 'url)
(require 'json)

(defvar datastar--data nil
  "The datastar data, fetched from the web.")

(defun datastar--fetch-data ()
  "Fetch the datastar data from the web."
  (message "datastar--fetch-data: fetch datastar data")
  (let ((url "https://raw.githubusercontent.com/starfederation/datastar/refs/heads/develop/tools/vscode-extension/src/data-attributes.json")
        (json-object-type 'hash-table)
        (json-array-type 'list))
    (with-current-buffer
        (url-retrieve-synchronously
         url)
      (goto-char (point-min))
      (search-forward "\n\n")
      (json-read))))

(defun datastar-data ()
  "Return the datastar data, fetching it if necessary."
  (or datastar--data
      (setq datastar--data
            (datastar--fetch-data))))

(defgroup datastar nil
  "A minor mode for datastar.js projects."
  :group 'datastar)

(defun datastar-completion-at-point ()
  "Provide completion for datastar attributes."
  (when (re-search-backward "data-" nil t)
    (let* ((bounds (bounds-of-thing-at-point
                    'symbol))
           (prefix (buffer-substring-no-properties
                    (car bounds)
                    (cdr bounds)))
           (completions '()))
      (maphash
       (lambda (key value)
         (let ((completion-prefix (gethash "prefix" value)))
           (when (string-prefix-p
                  prefix
                  completion-prefix)
             (let* ((body (gethash "body" value))
                    (description (gethash "description" value))
                    (annotation (when (require 'marginalia nil t)
                                  (datastar-marginalia-annotator
                                   completion-prefix)))
                    (metadata `((display . ,(propertize
                                             completion-prefix
                                             'face
                                             'font-lock-keyword-face))
                                (annotation-function . (lambda (cand) ,annotation))
                                (help-echo . ,description))))
               (push
                (propertize
                 completion-prefix
                 'completion-metadata
                 metadata
                 'completion-extra-properties
                 `(:datastar-body . ,body))
                completions)))))
       (datastar-data))
      (when completions
        (list
         (car bounds)
         (cdr bounds)
         completions
         (completion-table-dynamic
          (lambda (_) completions))
         :exclusive 'no)))))

(defun datastar-complete ()
  "Manually trigger datastar completion."
  (interactive)
  (completion-at-point))

(defun datastar--find-entry-by-prefix (prefix data)
  "Find an entry in DATA hash-table by its PREFIX."
  (let ((found-entry nil))
    (maphash
     (lambda (key value)
       (when (string=
              prefix
              (gethash "prefix" value))
         (setq found-entry value)))
     data)
    found-entry))

(defun datastar-attribute-help ()
  "Show help for a datastar attribute."
  (interactive)
  (let* ((candidates (let ((completions '()))
                       (maphash
                        (lambda (key value)
                          (push
                           (gethash "prefix" value)
                           completions))
                        (datastar-data))
                       completions))
         (symbol-at-point (thing-at-point 'symbol))
         (candidate (if (and symbol-at-point
                             (member
                              symbol-at-point
                              candidates))
                        symbol-at-point
                      (completing-read
                       "Datastar attribute: "
                       candidates))))
    (when candidate
      (let* ((data (datastar-data))
             (entry (datastar--find-entry-by-prefix
                     candidate
                     data)))
        (when entry
          (with-help-window
              "*datastar-help*"
            (insert
             (propertize (gethash "prefix" entry)
                         'face '(:height 1.5 :weight bold)))
            (newline)
            (newline)
            (insert "body: " (gethash "body" entry))
            (newline)
            (insert "Description:\n")
            (insert
             (gethash "description" entry))
            (let ((references (gethash "references" entry)))
              (when references
                (insert "\n\nReferences:\n")
                (dolist (ref
                         (mapcar #'identity references))
                  (let ((name (gethash "name" ref))
                        (url (gethash "url" ref)))
                    (insert (format "- %s: " name))
                    (insert-button
                     url
                     `(browse-url ,url))
                    (insert "\n")))))))))))

(defun datastar-marginalia-annotator (candidate)
  "Annotate datastar completions with marginalia."
  (let* ((data (datastar-data))
         (entry (datastar--find-entry-by-prefix candidate data)))
    (when entry
      (format " %s" (gethash "description" entry)))))

;;;###autoload
(define-minor-mode datastar-mode
  "A minor mode for datastar projects."
  :lighter " d*"
  :keymap (let ((map (make-sparse-keymap)))
            (define-key map (kbd "C-c C-c") 'datastar-complete)
            map)
  (if datastar-mode
      (add-hook 'completion-at-point-functions 'datastar-completion-at-point nil t)
    (remove-hook 'completion-at-point-functions 'datastar-completion-at-point t)))

;;;###autoload
(defun datastar-turn-on-mode ()
  "Turn on `datastar-mode`."
  (datastar-mode 1))

(provide 'datastar)
;;; datastar.el ends here
