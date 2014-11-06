(when (< emacs-major-version 24)
  (require-package 'org))
(require-package 'org-fstree)
(when *is-a-mac*
  (require-package 'org-mac-link)
  (require-package 'org-mac-iCal))


(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)

;; Various preferences
(setq org-log-done t
      org-completion-use-ido t
      org-edit-timestamp-down-means-later t
      org-agenda-start-on-weekday nil
      org-agenda-span 14
      org-agenda-include-diary t
      org-agenda-window-setup 'current-window
      org-fast-tag-selection-single-key 'expert
      org-export-kill-product-buffer-when-displayed t
      org-tags-column 80)


; Refile targets include this file and any file contributing to the agenda - up to 5 levels deep
(setq org-refile-targets (quote ((nil :maxlevel . 5) (org-agenda-files :maxlevel . 5))))
; Targets start with the file name - allows creating level 1 tasks
(setq org-refile-use-outline-path (quote file))
; Targets complete in steps so we start with filename, TAB shows the next level of targets etc
(setq org-outline-path-complete-in-steps t)


(setq org-todo-keywords
      (quote ((sequence "TODO(t)" "STARTED(s)" "|" "DONE(d!/!)")
              (sequence "WAITING(w@/!)" "SOMEDAY(S)" "PROJECT(P@)" "|" "CANCELLED(c@/!)"))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Org clock
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persistence-insinuate t)
(setq org-clock-persist t)
(setq org-clock-in-resume t)

;; Change task state to STARTED when clocking in
(setq org-clock-in-switch-to-state "STARTED")
;; Save clock data and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)
;; Removes clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Show the clocked-in task - if any - in the header line
(defun sanityinc/show-org-clock-in-header-line ()
  (setq-default header-line-format '((" " org-mode-line-string " "))))

(defun sanityinc/hide-org-clock-from-header-line ()
  (setq-default header-line-format nil))

(add-hook 'org-clock-in-hook 'sanityinc/show-org-clock-in-header-line)
(add-hook 'org-clock-out-hook 'sanityinc/hide-org-clock-from-header-line)
(add-hook 'org-clock-cancel-hook 'sanityinc/hide-org-clock-from-header-line)

(after-load 'org-clock
  (define-key org-clock-mode-line-map [header-line mouse-2] 'org-clock-goto)
  (define-key org-clock-mode-line-map [header-line mouse-1] 'org-clock-menu))


;; ;; Show iCal calendars in the org agenda
;; (when (and *is-a-mac* (require 'org-mac-iCal nil t))
;;   (setq org-agenda-include-diary t
;;         org-agenda-custom-commands
;;         '(("I" "Import diary from iCal" agenda ""
;;            ((org-agenda-mode-hook #'org-mac-iCal)))))

;;   (add-hook 'org-agenda-cleanup-fancy-diary-hook
;;             (lambda ()
;;               (goto-char (point-min))
;;               (save-excursion
;;                 (while (re-search-forward "^[a-z]" nil t)
;;                   (goto-char (match-beginning 0))
;;                   (insert "0:00-24:00 ")))
;;               (while (re-search-forward "^ [a-z]" nil t)
;;                 (goto-char (match-beginning 0))
;;                 (save-excursion
;;                   (re-search-backward "^[0-9]+:[0-9]+-[0-9]+:[0-9]+ " nil t))
;;                 (insert (match-string 0))))))


;; define agenda's path
(setq org-agenda-files (list "~/Dropbox/org/now.org"
                             "~/Dropbox/org/later.org"))

;; mobileorg settings
(setq org-directory "~/Dropbox/org")
(setq org-mobile-inbox-for-pull "~/Dropbox/org/later.org")
(setq org-mobile-directory "~/Dropbox/Apps/MobileOrg")
(setq org-mobile-files '("~/Dropbox/org"))



(after-load 'org
  (define-key org-mode-map (kbd "C-M-<up>") 'org-up-element)
  (when *is-a-mac*
    (define-key org-mode-map (kbd "M-h") nil))
  (define-key org-mode-map (kbd "C-M-<up>") 'org-up-element)
  (when *is-a-mac*
    (autoload 'omlg-grab-link "org-mac-link")
    (define-key org-mode-map (kbd "C-c g") 'omlg-grab-link)))

;;; Setting the index global key for the remember
(setq org-default-notes-file (concat org-directory "/notes.org"))
;; Bind Org Capture to C-c r
(global-set-key "\C-cr" 'org-capture)

;; Org Capture
(setq org-capture-templates
      '(("t" "TODO" entry (file+headline (concat org-directory "/later.org") "TASKS")
         "* TODO %?\n %i\n")
        ("i" "IDEA" entry (file+headline (concat org-directory "/later.org") "IDEAS")
         "* TODO %?\n %i\n")
        ("w" "WAITING" entry (file+headline (concat org-directory "/later.org") "WAITING")
         "* WAITING %?\n %i\n")
        ))

;;; try to  solve the problem of Copy and Paste Problems on Mac http://nickhigham.wordpress.com/2013/09/25/solutions-to-some-emacs-problems/
(setq save-interprogram-paste-before-kill nil)

;;; Auto calendar function in osx
(add-hook 'after-save-hook
          (when *is-a-mac*
            (lambda ()
            (if (or (eq major-mode 'org-mode) (eq major-mode 'org-agenda-mode))
                (progn
                  (setq org-add-event-command (concat "< " buffer-file-name))
                  (call-process-shell-command "_org_file_handler" nil nil nil org-add-event-command))))))



;y; ;; Fork the work (async) of pushing to mobile
;; ;; https://gist.github.com/3111823 ASYNC org mobile push...
;; (require 'gnus-async)
;; ;; Define a timer variable
;; (defvar org-mobile-push-timer nil
;;   "Timer that `org-mobile-push-timer' used to reschedule itself, or nil.")
;; ;; Push to mobile when the idle timer runs out
;; (defun org-mobile-push-with-delay (secs)
;;    (when org-mobile-push-timer
;;     (cancel-timer org-mobile-push-timer))
;;   (setq org-mobile-push-timer
;;         (run-with-idle-timer
;;          (* 1 secs) nil 'org-mobile-push)))
;; ;; After saving files, start an idle timer after which we are going to push
;; (add-hook 'after-save-hook
;;  (lambda ()
;;    (if (or (eq major-mode 'org-mode) (eq major-mode 'org-agenda-mode))
;;      (dolist (file (org-mobile-files-alist))
;;        (if (string= (expand-file-name (car file)) (buffer-file-name))
;;            (org-mobile-push-with-delay 10)))
;;      )))
;; ;; Run after midnight each day (or each morning upon wakeup?).
;; (run-at-time "00:01" 86400 '(lambda () (org-mobile-push-with-delay 1)))
;; ;; Run 1 minute after launch, and once a day after that.
;; (run-at-time "1 min" 86400 '(lambda () (org-mobile-push-with-delay 1)))

;; ;; watch mobileorg.org for changes, and then call org-mobile-pull
;; ;; http://stackoverflow.com/questions/3456782/emacs-lisp-how-to-monitor-changes-of-a-file-directory
;; (defun install-monitor (file secs)
;;   (run-with-timer
;;    0 secs
;;    (lambda (f p)
;;      (unless (< p (second (time-since (elt (file-attributes f) 5))))
;;        (org-mobile-pull)))
;;    file secs))
;; (defvar monitor-timer (install-monitor (concat org-mobile-directory "/mobileorg.org") 30)
;;   "Check if file changed every 30 s.")

(provide 'init-org)
