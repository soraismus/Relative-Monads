{-# OPTIONS --type-in-type #-}
module REM2 where

open import Relation.Binary.HeterogeneousEquality
open ≅-Reasoning renaming (begin_ to proof_)
open import Equality
open import Categories
open import Functors
open import RMonads2

open Cat
open Fun

record RAlg {C D : Cat}{J : Fun C D}(M : RMonad J) : Set where
  open RMonad M 
  field acar  : Obj D
        astr  : ∀ {Z} → Hom D (OMap J Z) acar → Hom D (T Z) acar
        alaw1 : ∀ {Z}{f : Hom D (OMap J Z) acar} →
                f ≅ comp D (astr f) η
        alaw2 : ∀{Z}{W}{k : Hom D (OMap J Z) (T W)}
                {f : Hom D (OMap J W) acar} →
                astr (comp D (astr f) k) ≅ comp D (astr f) (bind k)
open RAlg


open RMonad
astrnat : ∀{C D}{J : Fun C D}{M : RMonad J}(alg : RAlg M){X Y : Obj C}
          (f : Hom C X Y)
          (g : Hom D (OMap J X) (acar alg))
          (g' : Hom D (OMap J Y) (acar alg)) →
          comp D g' (HMap J f) ≅ g → 
          comp D (astr alg g') (bind M (comp D (η M) (HMap J f))) ≅ astr alg g
astrnat {C}{D} alg f g g' p = 
  trans (sym (alaw2 alg)) 
        (cong (astr alg) 
              (trans (sym (ass D))
                     (trans (cong₂ (comp D) (sym (alaw1 alg)) refl) p)))

record RAlgMorph {C D : Cat}{J : Fun C D}{M : RMonad J}(A B : RAlg M) : Set 
  where
  field amor : Hom D (acar A) (acar B)
        ahom : ∀{Z}{f : Hom D (OMap J Z) (acar A)} → 
               comp D amor (astr A f) ≅ astr B (comp D amor f)
open RAlgMorph

RAlgMorphEq : ∀{C D}{J : Fun C D}{M : RMonad J}{X Y : RAlg M}
              {f g : RAlgMorph X Y} → amor f ≅ amor g → f ≅ g
RAlgMorphEq {C}{D}{J}{M}{X}{Y}{f}{g} p = funnycong
  {Hom D (acar X) (acar Y)}
  {λ amor → ∀{Z}{f : Hom D (OMap J Z) (acar X)} → 
              comp D amor (astr X f) ≅ astr Y (comp D amor f)}
  p
  (iext λ Z → iext λ h → fixtypes (
    proof
    astr Y (comp D (amor f) h) 
    ≅⟨ sym (ahom f) ⟩ 
    comp D (amor f) (astr X h) 
    ≅⟨ cong (λ f₁ → comp D f₁ (astr X h)) p ⟩ 
    comp D (amor g) (astr X h) 
    ∎))
  λ x y → record{amor = x;ahom = y} 

IdMorph : ∀{C D}{J : Fun C D}{M : RMonad J}{A : RAlg M} → RAlgMorph A A
IdMorph {C}{D}{J}{M}{A} = record {
  amor = iden D;
  ahom = trans (idl D) (cong (astr A) (sym (idl D)))}

CompMorph : ∀{C D}{J : Fun C D}{M : RMonad J}{X Y Z : RAlg M} → 
            RAlgMorph Y Z → RAlgMorph X Y → RAlgMorph X Z
CompMorph {C}{D}{J}{M}{X}{Y}{Z} f g = record {
  amor = comp D (amor f) (amor g);
  ahom = trans (trans (trans (ass D) 
                             (cong (comp D (amor f)) (ahom g)))
                      (ahom f)) 
               (cong (astr Z) (sym (ass D)))}

idlMorph : ∀{C D}{J : Fun C D}{M : RMonad J}{X Y : RAlg M}{f : RAlgMorph X Y} →
           CompMorph IdMorph f ≅ f
idlMorph {C}{D} = RAlgMorphEq (idl D)

idrMorph : ∀{C D}{J : Fun C D}{M : RMonad J}{X Y : RAlg M}{f : RAlgMorph X Y} →
           CompMorph f IdMorph ≅ f
idrMorph {C}{D} = RAlgMorphEq (idr D) 

assMorph : ∀{C D}{J : Fun C D}{M : RMonad J}{W X Y Z : RAlg M}
           {f : RAlgMorph Y Z}{g : RAlgMorph X Y}{h : RAlgMorph W X} →
           CompMorph (CompMorph f g) h ≅ CompMorph f (CompMorph g h)
assMorph {C}{D} = RAlgMorphEq (ass D)

EM : ∀{C D}{J : Fun C D} → RMonad J → Cat
EM {C}{D}{J} M = record{
  Obj  = RAlg M;
  Hom  = RAlgMorph;
  iden = IdMorph;
  comp = CompMorph;
  idl  = idlMorph;
  idr  = idrMorph;
  ass  = λ{W}{X}{Y}{Z}{f}{g}{h} → assMorph {C}{D}{J}{M}{W}{X}{Y}{Z}{f}{g}{h}}
