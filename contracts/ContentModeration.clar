;; ContentModeration: A decentralized platform for content review and approval
;; Core Data Structures
(define-map moderators principal uint)        ;; Tracks moderators and their approved content
(define-map submissions uint uint)            ;; Tracks submissions and their approval counts
(define-data-var submission-counter uint u0)  ;; Keeps count of total content submissions

;; Public function to submit new content for review
(define-public (submit-content)
  (let ((submission-id (+ (var-get submission-counter) u1)))
    (map-set submissions submission-id u0)    ;; Initialize approvals for the new submission to 0
    (var-set submission-counter submission-id) ;; Increment submission-counter
    (ok submission-id)
  )
)

;; Public function to approve content
(define-public (approve-content (submission-id uint))
  (let ((moderator tx-sender))
    (if (is-some (map-get? moderators moderator))
        (err u6000)  ;; Error: Moderator has already approved content
        (if (is-none (map-get? submissions submission-id))
            (err u6001)  ;; Error: Submission does not exist
            (begin
              ;; Register the moderator's approval
              (map-set moderators moderator submission-id)
              ;; Increment the submission's approval count
              (map-set submissions submission-id (+ (default-to u0 (map-get? submissions submission-id)) u1))
              (ok submission-id)
            )
        )
    )
  )
)

;; Read-only function to get total approvals for content
(define-read-only (get-approval-count (submission-id uint))
  (default-to u0 (map-get? submissions submission-id))
)

;; Read-only function to check if a moderator has approved any content
(define-read-only (has-approved (moderator principal))
  (is-some (map-get? moderators moderator))
)

;; Read-only function to get the total number of submissions
(define-read-only (get-submission-count)
  (var-get submission-counter)
)

;; Read-only function to compare two values
(define-read-only (compare-approved (a uint) (b uint))
  (if (>= a b)
      a
      b
  )
)