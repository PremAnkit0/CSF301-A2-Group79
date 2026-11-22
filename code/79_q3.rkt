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
