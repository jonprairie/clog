;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; CLOG - The Common Lisp Omnificent GUI                                 ;;;;
;;;; (c) 2020-2021 David Botton                                            ;;;;
;;;; License BSD 3 Clause                                                  ;;;;
;;;;                                                                       ;;;;
;;;; clog-web.lisp                                                         ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; Like clog-gui, clog-web uses w3.css as the underlying framework. w3.css is
;;; a public domain css only framework for layouts, is fast and efficient and
;;; does not require additional components outside of the css file. The goal
;;; of clog-web is to help make it easier to create "webpage" style apps
;;; (page layout instead of a more direct layout around the browser window
;;; as in clog-gui the mimics a desktop environment) or actual webpages
;;; (traditional hyper-linking, submition of forms and minimal need for an
;;; active clog connection).

(mgl-pax:define-package :clog-web
  (:documentation "CLOG-WEB a web page style abstraction for CLOG")
  (:use #:cl #:parse-float #:clog #:mgl-pax))

(cl:in-package :clog-web)

(defsection @clog-web (:title "CLOG Web Objects")
  "CLOG-WEB - Web page abstraction for CLOG"
  (clog-web-initialize              function)
  (set-maximum-page-width-in-pixels function)

  "CLOG-WEB - General Containers"
  (clog-web-panel     class)
  (create-web-panel   generic-function)
  (clog-web-content   class)
  (create-web-content generic-function)

  "CLOG-WEB - Auto Layout System"
  (clog-web-auto-row      class)
  (create-web-auto-row    generic-function)
  (clog-web-auto-column   class)
  (create-web-auto-column generic-function)
			
  "CLOG-WEB - 12 Column Grid Layout System"
  (clog-web-row         class)
  (create-web-row       generic-function)
  (clog-web-container   class)
  (create-web-container generic-function)

  (full-row-on-mobile     generic-function)
  (hide-on-small-screens  generic-function)
  (hide-on-medium-screens generic-function)
  (hide-on-large-screens  generic-function))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - clog-web - CLOG Web page abstraction
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-web ()
  ((body
    :accessor body
    :documentation "Top level access to browser window")))

;;;;;;;;;;;;;;;;;;;;;
;; create-clog-web ;;
;;;;;;;;;;;;;;;;;;;;;

(defun create-clog-web (clog-body)
  "Create a clog-web object and places it in CLOG-BODY's connection-data as
\"clog-web\". (Private)"
  (let ((clog-web (make-instance 'clog-web)))
    (setf (connection-data-item clog-body "clog-web") clog-web)
    (setf (body clog-web) clog-body)
    clog-web))

;;;;;;;;;;;;;;;;;;;;;;;;;
;; clog-web-initialize ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defun clog-web-initialize (clog-body &key (w3-css-url "/css/w3.css"))
  "Initializes clog-web and installs a clog-web object on connection."
  (create-clog-web clog-body)
  (when w3-css-url
    (load-css (html-document clog-body) w3-css-url)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; set-maximum-page-width-in-pixels ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun set-maximum-page-width-in-pixels (clog-body width)
  "The default width is 980 pixels."
  (add-class clog-body "w3-content")
  (setf (maximum-width clog-body) (unit "px" width)))

;;;;;;;;;;;;;;;;;;;;;;;;
;; full-row-on-mobile ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(defgeneric full-row-on-mobiile (clog-element)
  (:documentation "Change element to display:block, take up the full row, when
screen size smaller then 601 pixels DP"))

(defmethod full-row-on-mobile ((obj clog-element))
  (add-class obj "w3-mobile"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hide-on-small-screens ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgeneric hide-on-small-screens (clog-element)
  (:documentation "Hide element on screens smaller then 601 pixels DP"))

(defmethod hide-on-small-screens ((obj clog-element))
  (add-class obj "w3-hide-small"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hide-on-medium-screens ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgeneric hide-on-medium-screens (clog-element)
  (:documentation "Hide element on screens smaller then 993 pixels DP"))

(defmethod hide-on-medium-screens ((obj clog-element))
  (add-class obj "w3-hide-medium"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; hide-on-large-screens ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defgeneric hide-on-large-screens (clog-element)
  (:documentation "Hide element on screens smaller then 993 pixels DP"))

(defmethod hide-on-large-screens ((obj clog-element))
  (add-class obj "w3-hide-large"))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - General Containers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Container          -  Sample Uses
;; -----------------     --------------------------------------------
;; Content            -  Fixed size centered Content
;; Panel              -  Notes, Quote boxes, Notifications
;; Display-Container  -  Image text overlays
;; Code               -  Code blocks
;; Side-Bar           -  Sidebar to main content, optional collapsable
;; Main               -  Mark main contact when using a side-bar

;;;;;;;;;;;;;;;;;;;;;;
;; create-web-panel ;;
;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-web-panel (clog-div)()
  (:documentation "Panel for web content"))

(defgeneric create-web-panel (clog-obj &key content hidden class html-id)
  (:documentation "Create a clog-web-panel. General container with 16px left
and right padding and 16x top and bottom margin. If hidden is t then then the
visiblep propetery will be set to nil on creation."))

(defmethod create-web-panel ((obj clog-obj) &key (content "")
		 				  (hidden nil)
						  (class nil)
						  (html-id nil))
  (let ((div (create-div obj :content content
			     :hidden t :class class :html-id html-id)))
    (add-class div "w3-panel")
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-panel)))

;;;;;;;;;;;;;;;;;;;;;;;;
;; create-web-content ;;
;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-web-content (clog-div)()
  (:documentation "Content for web content"))

(defgeneric create-web-content (clog-obj &key content maximum-width
					   hidden class html-id)
  (:documentation "Create a clog-web-content. General container with 16px left
and right padding. If hidden is t then then the visiblep propetery will be set
to nil on creation."))

(defmethod create-web-content ((obj clog-obj) &key (content "")
						(maximum-width nil)
		 				(hidden nil)
						(class nil)
						(html-id nil))
  (let ((div (create-div obj :content content
			     :hidden t :class class :html-id html-id)))
    (add-class div "w3-content")
    (when maximum-width      
      (setf (maximum-width div) (unit "px" maximum-width)))
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-content)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - Auto Layout
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Container          -  Sample Uses
;; -----------------     ----------------------------------------------------
;; Auto-Row           -  Container of Auto-Columns
;; Auto-Column        -  Columns size adjusts width to fix contents of all
;;                       columns to fill 100% and all heights equal

;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-web-auto-row ;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defclass clog-web-auto-row (clog-div)()
  (:documentation "Content for web content"))

(defgeneric create-web-auto-row (clog-obj &key hidden class html-id)
  (:documentation "Create a clog-web-auto-row. Container for auto-columns
If hidden is t then then the visiblep propetery will be set to nil on
creation."))

(defmethod create-web-auto-row ((obj clog-obj) &key (hidden nil)
						 (class nil)
						 (html-id nil))
  (let ((div (create-div obj :hidden t :class class :html-id html-id)))
    (add-class div "w3-cell-row")
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-auto-row)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-web-auto-column ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftype vertical-align-type () '(member :top :middle :bottom))

(defclass clog-web-auto-column (clog-div)()
  (:documentation "Content for web content"))

(defgeneric create-web-auto-column (clog-obj &key content vertical-align
					   hidden class html-id)
  (:documentation "Create a clog-web-auto-column. Container for auto-columns
If hidden is t then then the visiblep propetery will be set to nil on
creation."))

(defmethod create-web-auto-column ((obj clog-obj) &key (content "")
						  (vertical-align nil)
		 				  (hidden nil)
						  (class nil)
						  (html-id nil))
  (let ((div (create-div obj :content content
			     :hidden t :class class :html-id html-id)))
    (add-class div "w3-cell")
    (when vertical-align
      (add-class div (format nil "w3-cell-~A"
			     (string-downcase vertical-align))))
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-auto-column)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Implementation - Responsive 12 part grid
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Container          -  Sample Uses
;; -----------------     ----------------------------------------------------
;; Row                -  Container of grid columns (Containers)
;; Container          -  Headers, Footers, General, 12 part Grid Columns

;;;;;;;;;;;;;;;;;;;;
;; create-web-row ;;
;;;;;;;;;;;;;;;;;;;;

(defclass clog-web-row (clog-div)()
  (:documentation "Row to contain columns of web content in 12 column grid"))

(defgeneric create-web-row (clog-obj &key padding hidden class html-id)
  (:documentation "Create a clog-web-row. If padding is true 8px left and
right padding is addded. If hidden is t then then the visiblep propetery will
be set to nil on creation."))

(defmethod create-web-row ((obj clog-obj) &key (padding nil)
		 			    (hidden nil)
					    (class nil)
					    (html-id nil))
  (let ((div (create-div obj :hidden t :class class :html-id html-id)))
    (if padding
	(add-class div "w3-row-padding")
	(add-class div "w3-row"))
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-row)))

;;;;;;;;;;;;;;;;;;;;;;;;;;
;; create-web-container ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftype container-size-type () '(member :half :third :twothird :quarter
				  :threequarter :rest :col))

(defclass clog-web-container (clog-div)()
  (:documentation "Container cells for web content in 12 column grid"))

(defgeneric create-web-container (clog-obj &key content
					     column-size
					     hidden class html-id)
  (:documentation "Create a clog-web-container. COLUMN-SIZE can be of type
container-size-type when to set size displayed on medium and large screens
or can use a string of \"s1-12 m1-12 l1-12\" s m or l followed by how many
columns this container uses on small, medium or large screens. Small screens
are always displayed full row. Total columns must add to 12 or one needs to
be of type :w3-rest to fill space. If hidden is t then then the visiblep
propetery will be set to nil on creation."))

(defmethod create-web-container ((obj clog-obj) &key (content "")
						  (column-size nil)
		 				  (hidden nil)
						  (class nil)
						  (html-id nil))
  (let ((div (create-div obj :content content
			     :hidden t :class class :html-id html-id)))
    (add-class div "w3-container")
    (when column-size
      (add-class div (format nil "w3-~A" (string-downcase column-size))))
    (unless hidden
      (setf (visiblep div) t))
    (change-class div 'clog-web-container)))
