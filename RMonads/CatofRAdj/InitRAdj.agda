open import Categories
open import Functors
open import RMonads

module RMonads.CatofRAdj.InitRAdj {a b c d}{C : Cat {a}{b}}{D : Cat {c}{d}}
                                  {J : Fun C D}(M : RMonad J) where

open import Library
open import Naturals hiding (Iso; module Iso)
open import RAdjunctions
open import RMonads.CatofRAdj M
open import Categories.Initial
open import RMonads.RKleisli M
open import RMonads.RKleisli.Functors M
open import RMonads.RKleisli.Adjunction M
open import RAdjunctions.RAdj2RMon

open Cat
open Fun
open RMonad M
open NatT
open RAdj

lemX : R KlAdj ○ L KlAdj ≅ TFun M
lemX = FunctorEq _ _ refl refl

KlObj : Obj CatofAdj
KlObj = record { 
  E   = Kl; 
  adj = KlAdj; 
  law = lemX;
  ηlaw = refl;
  bindlaw = λ{X}{Y}{f} → 
    cong bind (stripsubst (Hom D (OMap J X)) 
                          f
                          (fcong Y (cong OMap (sym lemX))))}
  where 
        open Cat

open ObjAdj
open import Isomorphism
open Iso

lemZ : {F G G' : Fun C D} → G ≅ G' → {α : NatT F G}{β : NatT F G'} → 
       α ≅ β → 
       ∀{X} → cmp α {X} ≅ cmp β {X}
lemZ refl refl = refl

lemZ' : ∀{a b c d}{C : Cat {a}{b}}{D : Cat {c}{d}}{F F' G G' : Fun C D} → 
        F ≅ F' → G ≅ G' → 
        {α : NatT F G}{β : NatT F' G'} → α ≅ β → 
        ∀{X} → cmp α {X} ≅ cmp β {X}
lemZ' refl refl refl = refl


lemfid : ∀{e f}{E : Cat {e}{f}}(L : Fun C E)(R : Fun E D)
  (T : Fun C D) 
  (p : T ≅ R ○ L) 
  (η : ∀ {X} → Hom D (OMap J X) (OMap T X))
  (right : {X : Obj C}{Y : Obj E} → 
           Hom D (OMap J X) (OMap R Y) → Hom E (OMap L X) Y) →
  (left : {X : Obj C}{Y : Obj E} → 
          Hom E (OMap L X) Y → Hom D (OMap J X) (OMap R Y)) → 
  (q : {X : Obj C}{Y : Obj E}(f : Hom E (OMap L X) Y) → right (left f) ≅ f) → 
  (r : {X : Obj C} → left (iden E {OMap L X}) ≅ η {X}) → 
  {X : Obj C} → 
  right (subst (Hom D (OMap J X)) (fcong X (cong OMap p)) η) 
  ≅ 
  iden E {OMap L X}
lemfid {E = E} L R .(R ○ L) refl η right left q r {X} = 
  trans (cong right (sym r)) (q (iden E))

lemfcomp : ∀{e f}{E : Cat {e}{f}}(L : Fun C E)(R : Fun E D)(T : Fun C D) 
  (p : T ≅ R ○ L)
  (bind : ∀{X Y} → Hom D (OMap J X) (OMap T Y) → Hom D (OMap T X) (OMap T Y)) →
  (right : {X : Obj C} {Y : Obj E} → 
           Hom D (OMap J X) (OMap R Y) → Hom E (OMap L X) Y) →
  (q : {X Y : Obj C} {f : Hom D (OMap J X) (OMap T Y)} → 
       HMap R (right (subst (Hom D (OMap J X)) (fcong Y (cong OMap p)) f)) 
       ≅
       bind f) → 
  (r : {X X' : Obj C}{Y Y' : Obj E}
       (f : Hom C X' X)(g : Hom E Y Y')
       (h : Hom D (OMap J X) (OMap R Y)) → 
       right (comp D (HMap R g) (comp D h (HMap J f))) 
       ≅ 
       comp E g (comp E (right h) (HMap L f))) → 
  ∀{X Y Z : Obj C}
  {f : Hom D (OMap J Y) (OMap T Z)}
  {g : Hom D (OMap J X) (OMap T Y)} →
  right (subst (Hom D (OMap J X)) (fcong Z (cong OMap p)) (comp D (bind f) g))
  ≅
  comp E (right (subst (Hom D (OMap J Y)) (fcong Z (cong OMap p)) f))
         (right (subst (Hom D (OMap J X)) (fcong Y (cong OMap p)) g))
lemfcomp {E = E} L R .(R ○ L) refl bind right q r {X}{Y}{Z}{f}{g} = 
  trans (cong₂ (λ f g → right (comp D f g)) (sym (q {f = f})) (sym (idr D)))
        (trans (cong (λ h → right (comp D (HMap R (right f)) (comp D g h)))
                     (sym (fid J))) 
               (trans (r (iden C) (right f) g) 
                      (cong (comp E (right f))
                            (trans (cong (comp E (right g)) (fid L)) 
                                   (idr E)))))

lemLlaw : ∀{e f}{E : Cat {e}{f}}(J : Fun C D)(L : Fun C E)(R : Fun E D)(T : Fun C D)
          (p : T ≅ R ○ L)
          (η : ∀ {X} → Hom D (OMap J X) (OMap T X)) → 
          (right : {X : Obj C} {Y : Obj E} → 
                   Hom D (OMap J X) (OMap R Y) → Hom E (OMap L X) Y) →
          (left : {X : Obj C} {Y : Obj E} → 
                  Hom E (OMap L X) Y → Hom D (OMap J X)  (OMap R Y)) → 
          (q : {X : Obj C} {Y : Obj E} (f : Hom E (OMap L X) Y) →
               right (left f) ≅ f) → 
          (r : {X : Obj C} → left (iden E {OMap L X}) ≅ η {X}) → 
          (t : {X X' : Obj C}{Y Y' : Obj E}
                   (f : Hom C X' X)(g : Hom E Y Y')
                   (h : Hom D (OMap J X) (OMap R Y)) → 
                   right (comp D (HMap R g) (comp D h (HMap J f))) 
                   ≅ 
                   comp E g (comp E (right h) (HMap L f)) ) → 
          {X Y : Obj C} (f : Hom C X Y) →
          right (subst (Hom D (OMap J X)) 
                       (fcong Y (cong OMap p))  
                       (comp D η (HMap J f)))
          ≅
          HMap L f
lemLlaw {E = E} J L R .(R ○ L) refl η right left q r t {X}{Y} f = 
  trans (cong (λ g → right (comp D g (HMap J f))) (sym r)) 
        (trans (cong right 
                     (trans (sym (idl D)) 
                            (cong (λ g → comp D g (comp D (left (iden E))
                                                          (HMap J f))) 
                                  (sym (fid R)))))
               (trans (trans (trans (t f (iden E) (left (iden E)))
                                    (idl E))
                             (cong (λ g → comp E g (HMap L f)) (q (iden E))))
                      (idl E)))

K' : ∀{e}{f}(A : Obj (CatofAdj {e}{f})) → Fun (E KlObj) (E A)
K' A = record { 
    OMap  = OMap (L (adj A)); 
    HMap  = λ{X}{Y} f → 
      right (adj A) (subst (Hom D (OMap J X)) 
                           (fcong Y (cong OMap (sym (ObjAdj.law A)))) 
                           f); 
    fid   = lemfid
                   (L (adj A)) 
                   (R (adj A)) 
                   (TFun M) 
                   (sym (law A)) 
                   η
                   (right (adj A)) 
                   (left (adj A))
                   (lawa (adj A))
                   (ObjAdj.ηlaw A); 
    fcomp = lemfcomp 
                     (L (adj A))
                     (R (adj A))
                     (TFun M) 
                     (sym (law A)) 
                     bind
                     (right (adj A)) 
                     (bindlaw A) 
                     (natright (adj A))}

Llaw' : ∀{e}{f}(A : Obj (CatofAdj {e}{f})) → K' A ○ L (adj KlObj) ≅ L (adj A)
Llaw' A = FunctorEq 
   _ 
   _ 
   refl 
   (iext λ _ → iext λ _ → ext $ lemLlaw J 
     (L (adj A))
     (R (adj A)) 
     (TFun M) 
     (sym (law A)) 
     η
     (right (adj A)) 
     (left (adj A))
     (lawa (adj A))
     (ηlaw A) 
     (natright (adj A)))


Rlaw' : ∀{e}{f}(A : Obj (CatofAdj {e}{f})) → R (adj KlObj) ≅ R (adj A) ○ K' A
Rlaw' A = FunctorEq _ _ (cong OMap (sym (law A)))
                        (iext λ _ → iext λ _ → ext λ _ → sym (bindlaw A))

rightlaw' : ∀{e f}(A : Obj (CatofAdj {e}{f})) → 
            {X : Obj C} {Y : Obj (E KlObj)}
            {f : Hom D (OMap J X) (OMap (R (adj KlObj)) Y)} →
            HMap (K' A) (right (adj KlObj) f) ≅ 
            right (adj A) (subst (Hom D (OMap J X)) (fcong Y (cong OMap (Rlaw' A))) f)
rightlaw' A {X}{Y}{f} = cong (right (adj A)) (trans (stripsubst (Hom D (OMap J X)) f (fcong Y (cong OMap (sym (law A))))) (sym (stripsubst (Hom D (OMap J X)) f (fcong Y (cong OMap (Rlaw' A))))) )

KlHom : {A : Obj CatofAdj} → Hom CatofAdj KlObj A
KlHom {A = A} = record {
  K        = K' A;
  Llaw     = Llaw' A;
  Rlaw     = Rlaw' A;
  rightlaw = rightlaw' A}

KlIsInit : Init CatofAdj KlObj
KlIsInit = record { 
  i   = KlHom;
  law = λ {X} {V} → HomAdjEq 
    _ 
    _ 
    ((FunctorEq _ _ (cong OMap (sym (HomAdj.Llaw V)))
             (iext λ A → iext λ B → ext λ f →
                trans
                (cong₂ (λ B₁ → right (adj X) {A} {B₁})
                 (sym (fcong B (cong OMap (HomAdj.Llaw V)))) 
                 (trans
                    (stripsubst (Hom D (OMap J A)) f
                     (fcong B (cong OMap (sym (law X)))))
                    (sym
                     (stripsubst (Hom D (OMap J A)) f
                      (fcong B (cong OMap (HomAdj.Rlaw V)))))))
                (sym (HomAdj.rightlaw V)))))}
-- -}
