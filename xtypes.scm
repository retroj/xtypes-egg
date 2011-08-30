
(module xtypes
        (
         make-xrectangle xrectangle-x xrectangle-y
         xrectangle-width xrectangle-height
         xrectangle-x-set! xrectangle-y-set!
         xrectangle-width-set! xrectangle-height-set!

         make-xglyphinfo xglyphinfo-x xglyphinfo-y xglyphinfo-width
         xglyphinfo-height xglyphinfo-xoff xglyphinfo-yoff

         make-xrendercolor xrendercolor-red xrendercolor-green
         xrendercolor-blue xrendercolor-alpha
         )

(import chicken scheme foreign foreigners)

(foreign-declare "#include <X11/Xlib.h>")
(foreign-declare "#include <X11/extensions/Xrender.h>")

;;;
;;; Utils
;;;

(define (inexact->int n)
  (inexact->exact (round n)))


;;;
;;; Xlib
;;;

;; XRectangle
;;
(define-foreign-record-type (xrectangle XRectangle)
  (constructor: %make-xrectangle)
  (destructor: %free-xrectangle)
  (short x xrectangle-x xrectangle-x-set!)
  (short y xrectangle-y xrectangle-y-set!)
  (unsigned-short width xrectangle-width xrectangle-width-set!)
  (unsigned-short height xrectangle-height xrectangle-height-set!))

(define (make-xrectangle x y width height)
  (let ((r (%make-xrectangle)))
    (set-finalizer! r %free-xrectangle)
    (xrectangle-x-set! r x)
    (xrectangle-y-set! r y)
    (xrectangle-width-set! r width)
    (xrectangle-height-set! r height)
    r))


;;;
;;; XRender
;;;

;; XGlyphInfo
;;
(define-foreign-record-type (xglyphinfo XGlyphInfo)
  (constructor: %make-xglyphinfo)
  (destructor: %free-xglyphinfo)
  (unsigned-short width xglyphinfo-width)
  (unsigned-short height xglyphinfo-height)
  (short x xglyphinfo-x)
  (short y xglyphinfo-y)
  (short xOff xglyphinfo-xoff)
  (short yOff xglyphinfo-yoff))

(define (make-xglyphinfo)
  (let ((g (%make-xglyphinfo)))
    (set-finalizer! g %free-xglyphinfo)
    g))


;; XRenderColor
;;
(define-foreign-record-type (xrendercolor XRenderColor)
  (constructor: %make-xrendercolor)
  (destructor: %free-xrendercolor)
  (unsigned-short red %xrendercolor-red %xrendercolor-red-set!)
  (unsigned-short green %xrendercolor-green %xrendercolor-green-set!)
  (unsigned-short blue %xrendercolor-blue %xrendercolor-blue-set!)
  (unsigned-short alpha %xrendercolor-alpha %xrendercolor-alpha-set!))

(define make-xrendercolor
  (case-lambda
   ((r g b a)
    (define (scale x)
      (inexact->int (* 65535 (cond ((> x 1.0) 1.0)
                                   ((< x 0.0) 0.0)
                                   (else x)))))
    (let ((c (%make-xrendercolor)))
      (%xrendercolor-red-set! c (scale r))
      (%xrendercolor-green-set! c (scale g))
      (%xrendercolor-blue-set! c (scale b))
      (%xrendercolor-alpha-set! c (scale a))
      (set-finalizer! c %free-xrendercolor)
      c))
   ((r g b) (make-xrendercolor r g b 1.0))))

(define (xrendercolor-red c)
  (/ (%xrendercolor-red c) 65535.0))

(define (xrendercolor-green c)
  (/ (%xrendercolor-green c) 65535.0))

(define (xrendercolor-blue c)
  (/ (%xrendercolor-blue c) 65535.0))

(define (xrendercolor-alpha c)
  (/ (%xrendercolor-alpha c) 65535.0))

)
