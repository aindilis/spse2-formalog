(defvar spse2-formalog-agent-name "SPSE2-Formalog-Agent1")

(global-set-key "\C-c\C-k\C-vsp" 'spse2-formalog-quick-start)

(global-set-key "\C-c\C-spe" 'spse2-formalog-edit-spse2-formalog-file)
(global-set-key "\C-c\C-spgl" 'spse2-formalog-action-get-line)
(global-set-key "\C-c\C-spws" 'spse2-formalog-set-windows)
(global-set-key "\C-c\C-sps" 'spse2-formalog-quick-start)
(global-set-key "\C-c\C-spr" 'spse2-formalog-restart)
(global-set-key "\C-c\C-spk" 'spse2-formalog-kill)
(global-set-key "\C-c\C-spc" 'spse2-formalog-clear-context)
(global-set-key "\C-c\C-spm" 'spse2-formalog-reload-all-modified-source-files)

(global-set-key "\C-c\C-spop" 'spse2-formalog-open-source-file)
(global-set-key "\C-c\C-spoP" 'spse2-formalog-open-source-file-reload)

(defvar spse2-formalog-default-context "Org::FRDCSA::SPSE2-Formalog")
(defvar spse2-formalog-source-files nil)

(defun spse2-formalog-issue-command (query)
 ""
 (interactive)
 (uea-query-agent-raw nil spse2-formalog-agent-name
  (freekbs2-util-data-dumper
   (list
    (cons "_DoNotLog" 1)
    (cons "Eval" query)))))

(defun spse2-formalog-action-get-line ()
 ""
 (interactive)
 (see (spse2-formalog-issue-command
  (list "_prolog_list"
   (list "_prolog_list" 'var-Result)
   (list "emacsCommand"
    (list "_prolog_list" "kmax-get-line")
    'var-Result)))))

(defun spse2-formalog-quick-start ()
 ""
 (interactive)
 
 (spse2-formalog)
 (spse2-formalog-fix-windows)
 (spse2-formalog-select-windows))

(defun spse2-formalog (&optional load-command)
 ""
 (interactive)
 (if (spse2-formalog-running-p)
  (error "ERROR: SPSE2-Formalog Already running.")
  (progn
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/spse2-formalog/scripts" "*SPSE2-Formalog*")
   (sit-for 3.0)
   (ushell)
   (sit-for 1.0)
   (pop-to-buffer "*SPSE2-Formalog*")
   (insert (or load-command "./spse2-formalog-start -u"))
   (comint-send-input)
   (sit-for 3.0)
   (run-in-shell "cd /var/lib/myfrdcsa/codebases/minor/spse2-formalog/scripts && ./spse2-formalog-start-repl" "*SPSE2-Formalog-REPL*" nil 'formalog-repl-mode)
   (setq formalog-agent spse2-formalog-agent-name)
   (sit-for 1.0))))

(defun spse2-formalog-set-windows ()
 ""
 (interactive)
 (spse2-formalog-fix-windows)
 (spse2-formalog-select-windows))

(defun spse2-formalog-fix-windows ()
 ""
 (interactive)
 (delete-other-windows)
 (split-window-vertically)
 (split-window-horizontally)
 (other-window 2)
 (split-window-horizontally)
 (other-window -2))

(defun spse2-formalog-select-windows ()
 ""
 (interactive)
 (switch-to-buffer "*SPSE2-Formalog*")
 (other-window 1)
 (switch-to-buffer "*ushell*")
 (other-window 1)
 (switch-to-buffer "*SPSE2-Formalog-REPL*")
 (other-window 1)
 (ffap "/var/lib/myfrdcsa/codebases/minor/spse2-formalog/spse2.pl"))

(defun spse2-formalog-restart ()
 ""
 (interactive)
 (if (yes-or-no-p "Restart SPSE2-Formalog? ")
  (progn
   (spse2-formalog-kill)
   (spse2-formalog-quick-start))))

(defun spse2-formalog-kill ()
 ""
 (interactive)
 (flp-kill-processes)
 (shell-command "killall -9 \"spse2-formalog-start\"")
 (shell-command "killall -9 \"spse2-formalog-start-repl\"")
 (shell-command "killall-grep SPSE2-Formalog-Agent1")
 (kmax-kill-buffer-no-ask (get-buffer "*SPSE2-Formalog*"))
 (kmax-kill-buffer-no-ask (get-buffer "*SPSE2-Formalog-REPL*"))
 ;; (kmax-kill-buffer-no-ask (get-buffer "*ushell*"))
 (spse2-formalog-running-p))

(defun spse2-formalog-running-p ()
 (interactive)
 (setq spse2-formalog-running-tmp t)
 (let* ((matches nil)
	(processes (split-string (shell-command-to-string "ps auxwww") "\n"))
	(failed nil))
  (mapcar 
   (lambda (process)
    (if (not (kmax-util-non-empty-list-p (kmax-grep-v-list-regexp (kmax-grep-list-regexp processes process) "grep")))
     (progn
      (see process 0.0)
      (setq spse2-formalog-running-tmp nil)
      (push process failed))))
   spse2-formalog-process-patterns)
  (setq spse2-formalog-running spse2-formalog-running-tmp)
  (if (kmax-util-non-empty-list-p failed)
   (see failed 0.1))
  spse2-formalog-running))

(defun spse2-formalog-clear-context (&optional context-arg)
 (interactive)
 (let* ((context (or context-arg spse2-formalog-default-context)))
  (if (yes-or-no-p (concat "Clear Context <" context ">?: "))
   (freekbs2-clear-context context))))

(defvar spse2-formalog-process-patterns
 (list
  "spse2-formalog-start"
  "spse2-formalog-start-repl"
  "/var/lib/myfrdcsa/codebases/internal/unilang/unilang-client"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/kbs2-server"
  "/var/lib/myfrdcsa/codebases/internal/freekbs2/data/theorem-provers/vampire/Vampire1/Bin/server.pl"
  ))

(defun spse2-formalog-eval-function-and-map-to-integer (expression)
 ""
 (interactive)
 (spse2-formalog-serpro-map-object-to-integer
  (funcall (car expression) (cdr expression))))

(defun spse2-formalog-serpro-map-object-to-integer (object)
 ""
 (interactive)
 (see object)
 (see (formalog-query (list 'var-integer) (list "prolog2TermAlgebra" object 'var-integer) nil "SPSE2-Formalog-Agent1")))

(defun spse2-formalog-serpro-map-integer-to-object (integer)
 ""
 (interactive)
 (see integer)
 (see (formalog-query (list 'var-integer) (list "termAlgebra2prolog" object 'var-integer) nil "SPSE2-Formalog-Agent1")))

(defun spse2-formalog-edit-spse2-formalog-file ()
 ""
 (interactive)
 (ffap "/var/lib/myfrdcsa/codebases/minor/spse2-formalog/spse2-formalog.el"))

(defun spse2-formalog-reload-all-modified-source-files ()
 ""
 (interactive)
 (kmax-move-buffer-to-end-of-buffer (get-buffer "*SPSE2-Formalog*"))
 (formalog-query
  nil
  (list "make")
  nil "SPSE2-Formalog-Agent1"))

;; emacsCommand(['kmax-get-line'],Result). 
;; (see (freekbs2-importexport-convert (list (list 'var-Result) (list "emacsCommand" (list "kmax-get-line") 'var-Result)) "Interlingua" "Perl String"))

;; "Eval" => {
;;           "_prolog_list" => {
;;                             "_prolog_list" => [
;;                                               \*{'::?Result'}
;;                                             ],
;;                             "emacsCommand" => [
;;                                               [
;;                                                 "_prolog_list",
;;                                                 "kmax-get-line"
;;                                               ],
;;                                               \*{'::?Result'}
;;                                             ]
;;                           }
;;         },

;; "Eval" => [
;;           [
;;             "_prolog_list",
;;             [
;;               "_prolog_list",
;;               \*{'::?Result'}
;;             ],
;;             [
;;               "emacsCommand",
;;               [
;;                 "_prolog_list",
;; 	        "kmax-get-line",
;;               ],
;;               \*{'::?Result'}
;;             ]
;;           ]
;;         ],


;; <message>
;;   <id>1</id>
;;   <sender>SPSE2-Formalog-Agent1</sender>
;;   <receiver>Emacs-Client</receiver>
;;   <date>Sat Apr  1 10:16:28 CDT 2017</date>
;;   <contents>eval (run-in-shell \"ls\")</contents>
;;   <data>$VAR1 = {
;;           '_DoNotLog' => 1,
;;           '_TransactionSequence' => 0,
;;           '_TransactionID' => '0.667300679865178'
;;         };
;;   </data>
;; </message>

;; (see (eval (read "(run-in-shell \"ls\")")))
;; (see (cons "Result" nil ))

;; (see (freekbs2-util-data-dumper
;;      (list
;;       (cons "_DoNotLog" 1)
;;       (cons "Result" nil)
;;       )
;;       ))

;; ;; (see '(("_DoNotLog" . 1) ("Result")))
;; ;; (see '(("Result"))

;; (freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))
;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '(("_DoNotLog" . 1) ("Result")))

;; (see '(("_DoNotLog" . 1) ("Result")))
;; (see '(("Result")))
;; (see '(("_DoNotLog" . 1)))

;; (join ", " (mapcar 'freekbs2-util-convert-from-emacs-to-perl-data-structures '("Result")))


;; (spse2-formalog-eval-function-and-map-to-integer (list 'buffer-name))




;;;;;;;;;;;;;;;; FIX Academician to use SPSE2-Formalog
;; see /var/lib/myfrdcsa/codebases/minor/academician/academician-spse2-formalog.el

;; (spse2-formalog-retrieve-file-id "/var/lib/myfrdcsa/codebases/internal/digilib/data-git/game/16/c/Knowledge Representation and Reasoning.pdf")

(defun spse2-formalog-retrieve-file-id (file)
 (let* ((chased-original-file (kmax-chase file))
	(results
	 (formalog-query
	  (list 'var-FileIDs)
	  (list "retrieveFileIDs" chased-original-file 'var-FileIDs)
	  nil "SPSE2-Formalog-Agent1")))
  (see (car (cdadar results)))))

;; (defun academician-get-title-of-publication (&optional overwrite)
;;  ""
;;  (interactive "P")
;;  (let* ((current-cache-dir (doc-view--current-cache-dir))
;; 	(current-document-hash (gethash current-cache-dir academician-parscit-hash))
;; 	(title0 (gethash current-cache-dir academician-title-override-hash)))
;;   (if (non-nil title0)
;;    title0
;;    (progn
;;     (academician-process-with-parscit overwrite)
;;     (let* ((title1
;; 	    (progn
;; 	     ;; (see current-document-hash)
;; 	     (cdr (assoc "content" 
;; 		   (cdr (assoc "title" 
;; 			 (cdr (assoc "variant" 
;; 			       (cdr (assoc "ParsHed" 
;; 				     (cdr (assoc "algorithm" current-document-hash))))))))))))
;; 	   (title2
;; 	    (cdr (assoc "content" 
;; 		  (cdr (assoc "title" 
;; 			(cdr (assoc "variant" 
;; 			      (cdr (assoc "SectLabel" 
;; 				    (cdr (assoc "algorithm" current-document-hash)))))))))))
;; 	   (title 
;; 	    (chomp (or title1 title2))))
;;      (if (not (equal title "nil"))
;;       title
;;       (academician-override-title)))))))

;; (defun academician-process-with-parscit (&optional overwrite)
;;  "Take the document in the current buffer, process the text of it
;;  and return the citations, allowing the user to add the citations
;;  to the list of papers to at-least-skim"
;;  (interactive "P")
;;  (if (derived-mode-p 'doc-view-mode)
;;   (if doc-view--current-converter-processes
;;    (message "Academician: DocView: please wait till conversion finished.")
;;    (let ((academician-current-buffer (current-buffer)))
;;     (academician-doc-view-open-text-without-switch-to-buffer)
;;     (while (not academician-converted-to-text)
;;      (sit-for 0.1))
;;     (let* ((filename (buffer-file-name))
;; 	   (current-cache-dir (doc-view--current-cache-dir))
;; 	   (txt (expand-file-name "doc.txt" current-cache-dir)))
;;      (if (equal "fail" (gethash current-cache-dir academician-parscit-hash "fail"))
;;       (progn
;;        ;; check to see if there is a cached version of the parscit data
;;        (if (file-readable-p txt)
;; 	(let* ((command
;; 		(concat 
;; 		 "/var/lib/myfrdcsa/codebases/minor/academician/scripts/process-parscit-results.pl -f "
;; 		 (shell-quote-argument filename)
;; 		 (if overwrite " -o " "")
;; 		 " -t "
;; 		 (shell-quote-argument txt)
;; 		 " | grep -vE \"^(File is |Processing with ParsCit: )\""
;; 		 ))
;; 	       (debug-1 (if academician-debug (see (list "command: " command))))
;; 	       (result (progn
;; 			(message (concat "Processing with ParsCit: " txt " ..."))
;; 			(shell-command-to-string command)
;; 			)))
;; 	 (if academician-debug (see (list "result: " result)))
;; 	 (ignore-errors
;; 	  (puthash current-cache-dir (eval (read result)) academician-parscit-hash))
;; 	 )
;; 	(message (concat "File not readable: " txt)))
;;        ;; (freekbs2-assert-formula (list "has-title") academician-default-context)
;;        )))))))


;; (global-set-key "\C-ctt" )

;; (defun spse2-formalog-roll ()
;;  ""
;;  (interactive)
;;  )


(add-to-list 'load-path "/var/lib/myfrdcsa/codebases/minor/spse2-formalog/frdcsa/emacs")

(defun spse2-formalog-open-source-file-reload ()
 (interactive)
 (setq spse2-formalog-source-files nil)
 (spse2-formalog-open-source-file)
 (spse2-formalog-get-actual-source-files))

(defun spse2-formalog-open-source-file ()
 (interactive)
 (spse2-formalog-load-source-files)
 (let ((file (ido-completing-read "Source File: " (spse2-formalog-get-actual-source-files))))
  (ffap file)
  (end-of-buffer)
  (spse2-formalog-complete-from-predicates-in-current-buffer)))

(defun spse2-formalog-get-actual-source-files ()
 ""
 (mapcar 'shell-quote-argument
  (kmax-grep-list spse2-formalog-source-files
   (lambda (value)
    (and (stringp value) (file-exists-p value))))))

(defun spse2-formalog-complete-from-predicates-in-current-buffer ()
 ""
 (interactive)
 (if spse2-formalog-complete-from-predicates
  (let ((predicates (spse2-formalog-util-get-approximately-all-predicates-in-current-file buffer-file-name)))
   (insert (concat (ido-completing-read "Predicate: " predicates) "()."))
   (backward-char 2))))

(defun spse2-formalog-load-source-files ()
 ""
 (if (not (non-nil spse2-formalog-source-files))
  (progn
   (setq spse2-formalog-source-files
    (cdr
     (nth 1
      (nth 0
       (formalog-query (list 'var-X) (list "listFiles" 'var-X) nil "SPSE2-Formalog-Agent1")))))
   (setq spse2-formalog-source-files-chase-alist (kmax-file-list-chase-alist spse2-formalog-source-files)))))

