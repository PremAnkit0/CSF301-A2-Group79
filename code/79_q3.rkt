#lang racket/base
;; CS F301 Assignment 2, S1: binary tree traversals (group 79)
;; A tree is either () or a three-element list (value left right).

;; (node-value tree) -> the value stored at the root of a non-empty tree
;; Reading: the value is the first element of (value left right).
;; Tail recursive: not recursive.
(define (node-value tree) (car tree))

;; (node-left tree) -> the left subtree of a non-empty tree
;; Reading: the left subtree is the second element of (value left right).
;; Tail recursive: not recursive.
(define (node-left tree) (cadr tree))

;; (node-right tree) -> the right subtree of a non-empty tree
;; Reading: the right subtree is the third element of (value left right).
;; Tail recursive: not recursive.
(define (node-right tree) (caddr tree))

;; (empty-tree? tree) -> #t when tree is the empty tree ()
;; Reading: the empty tree is exactly the empty list.
;; Tail recursive: not recursive.
(define (empty-tree? tree) (null? tree))

;; (leaf? tree) -> #t when tree is a node whose two subtrees are both ()
;; Reading: the empty tree is not a leaf; a node is a leaf when left and right are empty.
;; Tail recursive: not recursive.
(define (leaf? tree)
  (and (not (empty-tree? tree))
       (empty-tree? (node-left tree))
       (empty-tree? (node-right tree))))

;; (inorder-list tree) -> list of the values of tree in inorder (left, node, right)
;; Reading: walk puts the inorder values of t in front of acc. For () that is acc;
;; for a node it is the left values, then the node value, then the right values,
;; so the right subtree is walked first (into acc) and the left subtree last.
;; Uses an accumulator instead of append. Tail recursive: the outer call to walk is
;; a tail call; the inner call on the right subtree is not (depth = tree height).
(define (inorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (empty-tree? t)
        acc
        (walk (node-left t)
              (cons (node-value t)
                    (walk (node-right t) acc))))))

;; (print-inorder tree) -> prints the inorder list of tree, then a newline
;; Reading: build the inorder list, display it, end the line.
;; Tail recursive: not recursive.
(define (print-inorder tree)
  (display (inorder-list tree))
  (newline))

;; (preorder-list tree) -> list of the values of tree in preorder (node, left, right)
;; Reading: walk puts the preorder values of t in front of acc. For () that is acc;
;; for a node it is the node value, then the left values, then the right values.
;; Uses an accumulator instead of append. Tail recursive: no (the cons waits for
;; the walks of the subtrees); recursion depth is the tree height.
(define (preorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (empty-tree? t)
        acc
        (cons (node-value t)
              (walk (node-left t)
                    (walk (node-right t) acc))))))

;; (postorder-list tree) -> list of the values of tree in postorder (left, right, node)
;; Reading: walk puts the postorder values of t in front of acc. For () that is acc;
;; for a node it is the left values, then the right values, then the node value,
;; so the node value is consed onto acc first and the left subtree is walked last.
;; Uses an accumulator instead of append. Tail recursive: the outer call to walk is
;; a tail call; the inner call on the right subtree is not (depth = tree height).
(define (postorder-list tree)
  (let walk ((t tree) (acc '()))
    (if (empty-tree? t)
        acc
        (walk (node-left t)
              (walk (node-right t)
                    (cons (node-value t) acc))))))

;; (print-all-traversals tree) -> prints the inorder, preorder and postorder lists
;; of tree, each on its own line.
;; Reading: one display + newline per traversal, in the order in, pre, post.
;; Tail recursive: not recursive.
(define (print-all-traversals tree)
  (display (inorder-list tree))
  (newline)
  (display (preorder-list tree))
  (newline)
  (display (postorder-list tree))
  (newline))

;; (tree-height tree) -> height of tree: () has height 0, a node has height
;; 1 + the larger of the heights of its two subtrees.
;; Reading: for () the height is 0; otherwise it is one more than the max of the
;; heights of the smaller left and right subtrees.
;; Tail recursive: no (needs both subtree heights); recursion depth = tree height.
(define (tree-height tree)
  (if (empty-tree? tree)
      0
      (+ 1 (max (tree-height (node-left tree))
                (tree-height (node-right tree))))))
