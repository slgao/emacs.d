;; Prevent package.el from auto-initializing; init.el calls (package-initialize) explicitly.
(setq package-enable-at-startup nil)

;; Native-compilation warnings come from third-party package code quality, not
;; our config — log them to *Warnings* silently instead of popping up a buffer.
(setq native-comp-async-report-warnings-errors 'silent)
