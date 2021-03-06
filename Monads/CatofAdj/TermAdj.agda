open import Categories
open import Monads

module Monads.CatofAdj.TermAdj {a b}{C : Cat {a}{b}}(M : Monad C) where

open import Library
open import Functors
open import Monads.CatofAdj M
open import Categories.Terminal
open import Monads.CatofAdj.TermAdjObj M
open import Monads.CatofAdj.TermAdjHom M
open import Monads.CatofAdj.TermAdjUniq M

EMIsTerm : Term CatofAdj EMObj
EMIsTerm = record { 
  t   = λ {A} → EMHom A;
  law = λ {A} {V} →
    HomAdjEq _ _  (FunctorEq _ _ (omaplem A V)
                                 (iext λ _ → iext λ _ → ext $ hmaplem A V))}
