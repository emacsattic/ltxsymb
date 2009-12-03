;;; ltxsymb --- Display LaTeX symbols

;; Copyright (C) 2002 Triet Hoai Lai
;; Author:     Triet Hoai Lai <thlai@mail.usyd.edu.au>
;; Keywords:   LaTeX, symbol
;; Version:    0.1
;; X-URL:      http://ee.usyd.edu.au/~thlai/emacs/
;; X-RCS: $Id: ltxsymb.el,v 1.1 2002/01/28 04:23:35 thlai Exp $

;; This file is *NOT* part of (X)Emacs.

;; This program is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.

;; This program is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
;; more details.

;; You should have received a copy of the GNU General Public License along with
;; GNU Emacs; see the file COPYING.  If not, write to the Free Software
;; Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.

;;; Commentary:

;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Install
;; -------
;;
;; - Put ltxsymb.el some directory, e.g. ~/elisp/ltxsymb and the pixmaps
;;   (included in latex-toolbar package) to ~/elisp/ltxsymb/pic.
;;
;; - Byte compile ltxsymb.el
;;
;; - Put the following lines into your .emacs
;;      (add-to-list 'load-path "~/elisp/ltxsymb")
;;
;;
;; Usage:
;; -----
;;
;; M-x ltxsymb-display
;; 
;;
;; Known bugs:
;; ----------
;;
;;
;; Acknowledgements
;; ----------------
;;
;; A lot of pixmaps are taken from `latex-symbols' package
;; (http://www.math.washington.edu/~palmieri/).  Special thanks to John Palmieri
;; <palmieri@math.washington.edu>, without his package I would not have courage
;; and time to make all the pixmaps.
;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; code:



(require 'cl)
(require 'latex)

(defgroup ltxsymb nil
  "Display and provide an convenient way to insert LaTeX symbols."
  :group 'LaTeX)

(defcustom ltxsymb-icon-directory
  (let ((lib (locate-library "ltxsymb")))
    (expand-file-name "pic"
     (cond (lib
	    (concat (file-name-directory lib)))
	   (t
	    "."))
     ))
  "Directory where the icons are installed."
  :type 'directory
  :group 'ltxsymb)

(defcustom ltxsymb-widest-pixmap
  (expand-file-name "longmapsto.xpm" ltxsymb-icon-directory)
  "The widest pixmap.
It is used to determine how many pixmaps fit in the width of current selected
window."
  :type 'file
  :group 'ltxsymb)

(defcustom ltxsymb-mode-hooks nil
  "List of hooks to call when entering ltxsymb-mode."
  :type 'hook
  :group 'ltxsymb)



(defvar ltxsymb-math-list
  '(
    (nil "mathring" "Accents")
    (nil "varepsilon" "greek")
    (nil "vartheta" "greek")
    (nil "iota" "greek")
    (nil "xi" "greek")
    (nil "varpi" "greek")
    (nil "varrho" "greek")
    (nil "varsigma" "greek")
    (nil "varphi" "greek")
    (nil "Xi" "greek")
    (nil "notin" "Relational")
    (nil "sqcup" "Binary Op")
    (nil "inoplus" "Binary Op")
    (nil "iff" "Arrows")
    (nil "leadsto" "Arrows")
    (nil "dots" "Misc Symbol")
    (nil "dag" "Non-math")
    (nil "ddag" "Non-math")
    (nil "S" "Non-math")
    (nil "P" "Non-math")
    (nil "copyright" "Non-math")
    (nil "pounds" "Non-math")
    (nil "rightrightarrows" ("AMS" "Arrows"))
    (nil "rightleftarrows" ("AMS" "Arrows"))
    (nil "Rrightarrow" ("AMS" "Arrows"))
    (nil "twoheadrightarrow" ("AMS" "Arrows"))
    (nil "rightarrowtail" ("AMS" "Arrows"))
    (nil "precneqq" ("AMS" "Neg Rel I"))
    (nil "succneqq" ("AMS" "Neg Rel II"))
    (nil "nsubseteqq" ("AMS" "Neg Rel III"))
    (nil "nVdash" ("AMS" "Neg Rel III"))
    )
  "Additional math symbols which are not defined in `LaTeX-math-default'.")

;; Stolen from AucTeX (latex.el)
(let ((math ltxsymb-math-list)
      (map (lookup-key LaTeX-math-keymap LaTeX-math-abbrev-prefix)))
  (while math
    (let* ((entry (car math))
	   (key (nth 0 entry))
	   value menu name defined-p)
      (setq math (cdr math))
      (if (listp (cdr entry))
	  (setq value (nth 1 entry)
		menu (nth 2 entry))
	(setq value (cdr entry)
	      menu nil))
      (if (stringp value)
	  (progn
	    (setq defined-p (intern-soft (concat "LaTeX-math-" value)))
	    (unless defined-p
	      (setq name (intern (concat "LaTeX-math-" value)))
	      (fset name (list 'lambda (list 'arg) (list 'interactive "*P")
			       (list 'LaTeX-math-insert value 'arg)))))
	(setq name value))
      (if (and key (not defined-p))
	  (progn 
	    (setq key (if (numberp key) (char-to-string key) (vector key)))
	    (define-key map key name)))
      (if (and menu (not defined-p))
	  (let ((parent LaTeX-math-menu))
	    (if (listp menu)
		(progn 
		  (while (cdr menu)
		    (let ((sub (assoc (car menu) LaTeX-math-menu)))
		      (if sub
			  (setq parent sub)
			(setcdr parent (cons (list (car menu)) (cdr parent))))
		      (setq menu (cdr menu))))
		  (setq menu (car menu))))
	    (let ((sub (assoc menu parent)))
	      (if sub 
		  (if (stringp value)
		      (setcdr sub (cons (vector value name t) (cdr sub)))
		    (error "Cannot have multiple special math menu items"))
		(setcdr parent
			(cons (if (stringp value)
				  (list menu (vector value name t))
				(vector menu name t))
			      (cdr parent))))))))))

(defconst ltxsymb-symbols-list
  '(
    ("Greek" .
     ;; Each element of the list must string or [NAME FILE FUNC-or-POS HELP]
     (;; lower case
      "alpha" "beta" "gamma" "delta" "epsilon" "varepsilon" "zeta" "eta" "theta"
      "vartheta" "iota" "kappa" "lambda" "mu" "nu" "xi" "pi" "varpi" "rho"
      "varrho" "sigma" "varsigma" "tau" "upsilon" "phi" "varphi" "chi" "psi"
      "omega"
      ;; upper case
      "Gamma" "Delta" "Theta" "Lambda" "Xi" "Pi" "Sigma" "Upsilon" "Phi" "Psi"
      "Omega")
     )
    ("accents" .
     ("hat" "check" "tilde" "acute" "grave" "dot" "ddot" "breve" "bar" "vec")
     )
    ("relations" .
     ("le" "ll" "prec" "preceq" "subset" "subseteq"
      ["sqsubset" "sqsubset.xpm" nil "sqsubset (latexsymb package)"]
      "sqsubseteq" "in" "vdash" "mid" "smile" "ge" "gg" "succ" "succeq" "supset"
      "supseteq"
      ["sqsupset" "sqsupset.xpm" nil "sqsupset (latexsymb package)"]
      "sqsupseteq" "ni" "dashv" "parallel" "frown" "notin" "equiv" "doteq" "sim"
      "simeq" "approx" "cong"
      ["Join" "Join.xpm" nil "Join (latexsymb package)"]
      "bowtie" "propto" "models" "perp" "asymp" "neq")
     )
    ("operators" .
     ("pm" "cdot" "times" "cup" "sqcup" "vee" "oplus" "odot" "otimes" "bigtriangleup"
      ["lhd" "lhd.xpm" nil "lhd (latexsymb package)"]
      ["unlhd" "unlhd.xpm" nil "unlhd (latexsymb package)"]
      "mp" "div" "setminus" "cap" "sqcap" "wedge" "ominus" "oslash" "bigcirc"
      "bigtriangledown"
      ["rhd" "rhd.xpm" nil "rhd (latexsymb package)"]
      ["unrhd" "unrhd.xpm" nil "unrhd (latexsymb package)"]
      "triangleleft" "triangleright" "star" "ast" "circ" "bullet" "diamond"
      "uplus" "amalg" "dagger" "ddagger" "wr")
     )
    ("variable operators" .
     ("sum" "prod" "coprod" "int" "bigcup" "bigcap" "bigsqcup" "oint" "bigvee"
      "bigwedge" "bigoplus" "bigotimes" "bigodot" "biguplus")
     )
    ("arrows" .
     ("leftarrow" "rightarrow" "leftrightarrow" "Leftarrow" "Rightarrow"
      "Leftrightarrow" "mapsto" "hookleftarrow" "leftharpoonup" "leftharpoondown"
      "rightleftharpoons" "longleftarrow" "longrightarrow" "longleftrightarrow"
      "Longleftarrow" "Longrightarrow" "Longleftrightarrow" "longmapsto"
      "hookrightarrow" "rightharpoonup" "rightharpoondown" "iff" "uparrow"
      "downarrow" "updownarrow" "Uparrow" "Downarrow" "Updownarrow" "nearrow"
      "searrow" "swarrow" "nwarrow"
      ["leadsto" "leadsto.xpm" nil "leadsto (latexsymb package)"])
     )
    ("delimiters" .
     ("langle" "lfloor" "lceil" "rangle" "rfloor" "rceil" "backslash"
      "uparrow" "updownarrow" "Uparrow" "Downarrow" "Updownarrow")
     )
    ("large delimiters" .
     ("lgroup" "rgroup" "lmoustache" "rmoustache" "arrowvert" "Arrowvert"
      "bracevert")
     )
    ("misc" .
     ("dots" "cdots" "vdots" "ddots" "hbar" "imath" "jmath" "ell" "Re" "Im"
      "aleph" "wp" "forall" "exists"
      ["mho" "mho.xpm" nil "mho (latexsymb package)"]
      "partial" "prime" "emptyset" "infty" "nabla" "triangle"
      ["Box" "Box.xpm" nil "Box (latexsymb package)"]
      ["Diamond" "diamondsuit.xpm" nil "Diamond (latexsymb package)"]
      "bot" "top" "angle" "surd" "diamondsuit" "heartsuit" "clubsuit" "spadesuit"
      "neg" "flat" "natural" "sharp")
     )
    ("non-mathematical" .
     ("dag" "ddag" "S" "P" "copyright" "pounds")
     )
    ("AMS Greek" .
     ( "ulcorner" "urcorner" "llcorner" "lrcorner" "digamma" "varkappa" "beth"
       "daleth" "gimel")
     )
    ("AMS relations" .
     ("lessdot" "leqslant" "eqslantless" "leqq" "lll" "lesssim" "lessapprox"
      "lessgtr" "lesseqgtr" "lesseqqgtr" "preccurlyeq" "curlyeqprec" "precsim"
      "precapprox" "subseteqq" "Subset" "sqsubset" "therefore" "shortmid"
      "smallsmile" "vartriangleleft" "trianglelefteq" "gtrdot" "geqslant"
      "eqslantgtr" "geqq" "ggg" "gtrsim" "gtrapprox" "gtrless" "gtreqless"
      "gtreqqless" "succcurlyeq" "curlyeqsucc" "succsim" "succapprox"
      "supseteqq" "Supset" "sqsupset" "because" "shortparallel" "smallfrown"
      "vartriangleright" "trianglerighteq" "doteqdot" "risingdotseq"
      "fallingdotseq" "eqcirc" "circeq" "triangleq" "bumpeq" "Bumpeq" "thicksim"
      "thickapprox" "approxeq" "backsim" "backsimeq" "vDash" "Vdash" "Vvdash"
      "backepsilon" "varpropto" "between" "pitchfork" "blacktriangleleft"
      "blacktriangleright")
     )
    ("AMS arrows" .
     ("dashleftarrow" "leftleftarrows" "leftrightarrows" "Lleftarrow"
      "twoheadleftarrow" "leftarrowtail" "leftrightharpoons" "Lsh"
      "looparrowleft" "curvearrowleft" "circlearrowleft" "dashrightarrow"
      "rightrightarrows" "rightleftarrows" "Rrightarrow" "twoheadrightarrow"
      "rightarrowtail" "rightleftharpoons" "Rsh" "looparrowright"
      "curvearrowright" "circlearrowright" "multimap" "upuparrows"
      "downdownarrows" "upharpoonleft" "upharpoonright" "downharpoonleft"
      "downharpoonright" "rightsquigarrow" "leftrightsquigarrow" "nleftarrow"
      "nLeftarrow" "nleftrightarrow" "nLeftrightarrow" "nrightarrow" "nRightarrow")
     )
    ("AMS negated relations and arrows" .
     ("nless" "lneq" "nleq" "nleqslant" "lneqq" "lvertneqq" "nleqq" "lnsim"
      "lnapprox" "nprec" "npreceq" "precneqq" "precnsim" "precnapprox" "subsetneq"
      "varsubsetneq" "nsubseteq" "subsetneqq" "nleftarrow" "nLeftarrow"
      "ngtr" "gneq" "ngeq" "ngeqslant" "gneqq" "gvertneqq" "ngeqq" "gnsim"
      "gnapprox" "nsucc" "nsucceq" "succneqq" "succnsim" "succnapprox" "supsetneq"
      "varsupsetneq" "nsupseteq" "supsetneqq" "nrightarrow" "nRightarrow"
      "varsubsetneqq" "varsupsetneqq" "nsubseteqq" "nsupseteqq" "nmid"
      "nparallel" "nshortmid" "nshortparallel" "nsim" "ncong" "nvdash" "nvDash"
      "nVdash" "nVDash" "ntriangleleft" "ntriangleright" "ntrianglelefteq"
      "ntrianglerighteq" "nleftrightarrow" "nLeftrightarrow")
     )
    ("AMS operators" .
     ("dotplus" "ltimes" "Cup" "veebar" "boxplus" "boxtimes" "leftthreetimes"
      "curlyvee" "centerdot" "rtimes" "Cap" "barwedge" "boxminus" "boxdot"
      "rightthreetimes" "curlywedge" "intercal" "divideontimes" "smallsetminus"
      "doublebarwedge" "circleddash" "circledcirc" "circledast")
     )
    ("AMS misc" .
     ("hbar" "square" "vartriangle" "triangledown" "lozenge" "angle" "diagup"
      "nexists" "eth" "hslash" "blacksquare" "blacktriangle" "blacktriangledown"
      "blacklozenge" "measuredangle" "diagdown" "Finv" "mho" "Bbbk" "circledS"
      "complement" "Game" "bigstar" "sphericalangle" "backprime" "varnothing")
     )
    ("math alphabets" .
     (["mathrm" "mathrm.xpm" -1 "mathrm"]
      ["mathit" "mathit.xpm" -1 "mathit"]
      ["mathnormal" "mathnormal.xpm" -1 "mathnormal"]
      ["mathcal" "mathcal.xpm" -1 "mathcal"]
      ["mathfrak" "mathfrak.xpm" -1 "mathfrak (eufrak package)"]
      ["mathbb" "mathbb.xpm" -1 "mathbb (amsfonts or amssymb package)"])
      )
    ("math constructs" .
     ("widetilde" "overleftarrow" "overbrace" "widehat" "overrightarrow"
      "underline" "underbrace"
      ["sqrt" "sqrt.xpm" -1 "sqrt"]
      ["sqrt" "sqrtn.xpm" nil "sqrt[n]"]
      "frac")
     )
    ))



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun ltxsymb-insert (str cnt)
  (insert str)
  (forward-char cnt))

(defvar ltxsymb-current-latex-buffer nil)
(defvar ltxsymb-prefix-buffer-name "*ltxsymb-")
(defvar ltxsymb-buffer-format (concat ltxsymb-prefix-buffer-name "%s*"))
(defvar ltxsymb-window-config nil)

(defun ltxsymb-get-buffer (group-name)
  (let ((buf-name (format ltxsymb-buffer-format group-name)))
    (get-buffer buf-name)))

(defun ltxsymb-get-buffer-create (group-name)
  (let ((buf-name (format ltxsymb-buffer-format group-name)))
    (get-buffer-create buf-name)))

(defvar ltxsymb-max-glyph-width
  (let (glyph)
    (or (file-readable-p ltxsymb-widest-pixmap)
	(error "cannot find pixmap %s" ltxsymb-widest-pixmap))
    (setq glyph (make-glyph (vector 'xpm :file ltxsymb-widest-pixmap)))
    (glyph-width glyph))
  "Width of the widest glyph.")

(defvar ltxsymb-keymap
  (let ((map (make-sparse-keymap)))
    (define-key map [(button1)] 'ltxsymb-mouse-insert)
    map)
  "Keymap for mouse event when it moves over icon.")

(defvar ltxsymb-mode-map
  (let ((map (make-sparse-keymap)))
    (suppress-keymap map)
    (define-key map [return] 'ltxsymb-key-insert)
    (define-key map "j" 'ltxsymb-next-line)
    (define-key map [down] 'ltxsymb-next-line)
    (define-key map "k" 'ltxsymb-prev-line)
    (define-key map [up] 'ltxsymb-prev-line)
    (define-key map "l" 'ltxsymb-next)
    (define-key map "n" 'ltxsymb-next)
    (define-key map [space] 'ltxsymb-next)
    (define-key map [right] 'ltxsymb-next)
    (define-key map "h" 'ltxsymb-prev)
    (define-key map "p" 'ltxsymb-prev)
    (define-key map [delete] 'ltxsymb-prev)
    (define-key map [left] 'ltxsymb-prev)
    (define-key map "\?" 'ltxsymb-help)
    (define-key map "q" 'ltxsymb-bury-buffer)
    (define-key map "x" 'ltxsymb-kill-buffer)
    (define-key map "X" 'ltxsymb-kill-all)
    map)
  "Keymap used in ltxsymb buffer.")

(defun ltxsymb-mode ()
  "Major mode displays and provides an easy way to insert LaTeX symbols.

\\{ltxsymb-mode-map}"
  (use-local-map ltxsymb-mode-map)
  (setq buffer-read-only t)
  (setq mode-name "ltxsymb")
  (setq major-mode 'ltxsymb-mode)
  (run-hooks 'ltxsymb-mode-hooks))

(defun ltxsymb-insert-icon (icon)
  (let (file cmd help glyph ext math-cmd key fop p)
    (cond ((stringp icon)
	   (setq file (concat icon ".xpm"))
	   (setq math-cmd (intern-soft (concat "LaTeX-math-" icon)))
	   (setq help icon))
	  ((vectorp icon)
	   (setq file (elt icon 1))
	   (setq fop (elt icon 2))
	   (cond ((null fop)
		  (setq math-cmd (intern-soft (concat "LaTeX-math-" (elt icon 0)))))
		 ((integerp fop)
		  (setq cmd (list 'ltxsymb-insert
				  (format "\\%s" (elt icon 0)) cmd)))
		 ((or (functionp fop) (listp fop))
		  (setq cmd fop))
		 (t
		  (error "wrong type of icon descriptor")))
	   (setq help (elt icon 3)))
	  (t
	   (error "Icon descriptor must be a string or vector")))
    (if math-cmd
	(progn
	  (setq cmd (list 'call-interactively math-cmd))
	  (if (setq key (where-is-internal math-cmd LaTeX-math-keymap))
	      (setq help (format "%s (math-mode: %s)" help key)))))
    (or cmd
	(error "don't know the corresponding LaTeX command"))

    (setq file (expand-file-name file ltxsymb-icon-directory))
    (or (file-readable-p file)
	(error "cannot find pixmap %s" file))

    (setq p (point))
    (insert ?\ )
    (setq ext (make-extent p (point)))
    (set-extent-property ext 'ltxsymb-latex-command cmd)
    (set-extent-property ext 'start-open t)
    (set-extent-property ext 'end-open t)
    (set-extent-property ext 'read-only t)
    (set-extent-property ext 'mouse-face 'highlight)
    (set-extent-property ext 'help-echo help)
    (set-extent-property ext 'balloon-help help)
    (set-extent-property ext 'keymap ltxsymb-keymap)
    (setq glyph (make-glyph (vector 'xpm :file file)))
    (set-extent-begin-glyph ext glyph)
    (glyph-width glyph)
    ))


(defun ltxsymb-insert-icons (icons)
  (let* ((avg-char-width (/ (window-text-area-pixel-width)
			    (window-width)))
	 (total-width 0)
	 (max-width (- (window-text-area-pixel-width)
		       ltxsymb-max-glyph-width
		       avg-char-width))
	 sym-width)
    (dolist (i icons)
      (setq sym-width (+ (ltxsymb-insert-icon i) avg-char-width))
      (setq total-width (+ sym-width total-width))
      (if (< max-width total-width)
	  (progn
	    (insert "\n")
	    (setq total-width 0))))))

(defun ltxsymb-display-1 (group-name)
  (let ((buf (ltxsymb-get-buffer group-name))
	group symbols)
    (if buf
	(display-buffer buf)
      (setq group (assoc group-name ltxsymb-symbols-list))
      (if group
	  (progn
	    (setq symbols (cdr group))
	    (setq buf (ltxsymb-get-buffer-create group-name))
	    (set-buffer buf)
	    (ltxsymb-insert-icons symbols)
	    (ltxsymb-mode)
	    (display-buffer buf))
	(error "Group %s doesn't exists" group-name)))))

(defun ltxsymb-display ()
  (interactive)
  (let ((group (completing-read "Group: " ltxsymb-symbols-list nil t)))
    (unless (string= "" group)
      (setq ltxsymb-current-latex-buffer (current-buffer))
      (setq ltxsymb-window-config (current-window-configuration))
      (ltxsymb-display-1 group))))

(defun ltxsymb-insert-internal (cmd)
  (let (head tail)
    (cond ((symbolp cmd)
	   (funcall cmd))
	  ((listp cmd)
	   (setq head (car cmd))
	   (setq tail (cdr cmd))
	   (cond ((symbolp head)
		  (apply head tail))
		 (t
		  (error "unknown list command type %s"
			 (prin1-to-string head)))))
	  (t
	   (error "unknown command type %s"
		  (prin1-to-string cmd))))))

(defun ltxsymb-mouse-insert (event)
  "Insert latex symbol with mouse."
  (interactive "e")
  (let ((ep (event-closest-point event))
	(ew (event-window event))
	ext cmd)
    (if (and ep ew)
	(progn
	  (or
	   (setq ext (extent-at
		      ep (window-buffer ew) 'ltxsymb-latex-command
		      nil 'at))
	   (error "no extent at point"))
	  (or
	   (setq cmd (extent-property ext 'ltxsymb-latex-command))
	   (error "no latex command found"))
	  ;; (set-buffer ltxsymb-current-latex-buffer)
	  (ltxsymb-insert-internal cmd)))))

(defun ltxsymb-key-insert ()
  (interactive)
  (or (eq major-mode 'ltxsymb-mode)
      (error "not in ltxsymb buffer"))
  (let ((ext (extent-at (point) nil 'ltxsymb-latex-command nil 'at))
	(ok t)
	cmd)
    (or ext
	(error "no extent at point"))
    (or (setq cmd (extent-property ext 'ltxsymb-latex-command))
	(error "no latex command found"))
    (or ltxsymb-current-latex-buffer
	(error "don't know which buffer to insert the symbol"))
    (unless (eq ltxsymb-current-latex-buffer
		(window-buffer (previous-window)))
      (setq ok (yes-or-no-p
		(format "insert to buffer %s "
			(buffer-name ltxsymb-current-latex-buffer)))))
    (if ok
	(save-excursion
	  (set-buffer ltxsymb-current-latex-buffer)
	  (ltxsymb-insert-internal cmd)))))

(defun ltxsymb-help ()
  (interactive)
  (or (eq major-mode 'ltxsymb-mode)
      (error "not in ltxsymb buffer"))
  (let ((ext (extent-at (point) nil 'ltxsymb-latex-command nil 'at))
	help)
    (or ext
	(error "no extent at point"))
    (or (setq help (extent-property ext 'help-echo))
	(setq help "no help"))
    (message help)))

(defun ltxsymb-next (&optional count)
  (interactive "P")
  (forward-char count)
  (ltxsymb-help))

(defun ltxsymb-prev (&optional count)
  (interactive "P")
  (backward-char count)
  (ltxsymb-help))

(defun ltxsymb-next-line (&optional count)
  (interactive "P")
  (or count (setq count 1))
  (forward-line count)
  (ltxsymb-help))

(defun ltxsymb-prev-line (&optional count)
  (interactive "P")
  (or count (setq count 1))
  (forward-line (- 0 count))
  (ltxsymb-help))

(defun ltxsymb-bury-buffer ()
  (interactive)
  (bury-buffer)
  (set-window-configuration ltxsymb-window-config))

(defun ltxsymb-kill-buffer ()
  (interactive)
  (or (eq major-mode 'ltxsymb-mode)
      (error "not in ltxsymb buffer"))
  (kill-buffer (current-buffer))
  (set-window-configuration ltxsymb-window-config))

(defun ltxsymb-kill-all ()
  (interactive)
  (let ((bufs (mapcar (function buffer-name) (buffer-list))))
    (mapcar (function
	     (lambda (buf)
	       (if (string-match ltxsymb-prefix-buffer-name buf)
		   (kill-buffer buf))))
	    bufs)))

(provide 'ltxsymb)

;; ltxsymb ends here

