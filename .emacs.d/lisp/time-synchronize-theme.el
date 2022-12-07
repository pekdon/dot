(defun time-synchronize-read-time (name)
  "Read time value with name from current buffer"
  (goto-char (point-min))
  (let ((start (search-forward (concat name "=\"")))
        (end (search-forward "\"")))
    (time-add
     (time-synchronize-strip-date
      (parse-time-string (buffer-substring start (- end 1))))
     (car (current-time-zone)))))

(defun time-synchronize-read-suninfo (filename)
  "Read sunrise and sunset information from filename."
  ;; Example file content:
  ;; time_sunrise="8:08:29 AM"
  ;; time_sunset="12:43:52 PM"
  (with-temp-buffer
    (insert-file-contents filename)
    (list (time-synchronize-read-time "time_sunrise")
          (time-synchronize-read-time "time_sunset"))))

(defun time-synchronize-strip-date (time)
  "Strip time list of date information"
  (pcase-let
      ((`(,second ,minute ,hour _ _ _ _ _ _) time))
    (encode-time (list second minute hour 0 0 0 0 nil nil))))

(defun time-synchronize-theme ()
  "Set theme based on time of date and sun rise and set information"
  (pcase-let ((now (time-synchronize-strip-date (decode-time (current-time))))
              (`(,rise ,set) (time-synchronize-read-suninfo "~/.time_info")))
    (let* ((is-dark (or (time-less-p now rise) (time-less-p set now)))
           (theme (if is-dark 'spacemacs-dark 'spacemacs-light))
           (old-theme (if is-dark 'spacemacs-light 'spacemacs-dark)))
      (if (equal theme time-synchronize-current-theme)
          nil
        (progn
          (disable-theme old-theme)
          (load-theme theme)
          (setq time-synchronize-current-theme theme))))))

(setq time-synchronize-current-theme nil)
(run-with-timer 0 300 'time-synchronize-theme)
