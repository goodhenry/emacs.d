;;; This is custome file for eww which is inside html paser

(require 'eww)

(global-set-key (kbd "C-x g") 'eww-open)

(defcustom eww-search-prefix-google "http://www.google.com.au/search?hl=en&q="
  "Prefix URL to search engine"
  :version "24.4"
  :group 'eww
  :type 'string)


(defun eww-open (url)
  "Fetch URL and render the page.
If the input doesn't look like an URL or a domain name, the
word(s) will be searched for via `eww-search-prefix'."
  (interactive "sEnter URL or keywords: ")
  (cond ((string-match-p "\\`file://" url))
        ((string-match-p "\\`ftp://" url)
         (user-error "FTP is not supported."))
        (t
         (if (and (= (length (split-string url)) 1)
                 (or (and (not (string-match-p "\\`[\"\'].*[\"\']\\'" url))
                          (> (length (split-string url "\\.")) 1))
                     (string-match eww-local-regex url)))
             (progn
               (unless (string-match-p "\\`[a-zA-Z][-a-zA-Z0-9+.]*://" url)
                 (setq url (concat "http://" url)))
               ;; some site don't redirect final /
               (when (string= (url-filename (url-generic-parse-url url)) "")
                 (setq url (concat url "/"))))
           (setq url (concat eww-search-prefix-google
                             (replace-regexp-in-string " " "+" url))))))
  (url-retrieve url 'eww-render (list url)))

(provide 'init-eww)
