(* ************************************************************************* *)
(** * Biequivalence

     Marco Maggesi, Niels van der Weide
     July 2019                                                               *)
(* ************************************************************************* *)

Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.
Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.PrecategoryBinProduct.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.Bicat. Import Bicat.Notations.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.Univalence.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.BicategoryLaws.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.EquivToAdjequiv.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.Invertible_2cells.
Require Import UniMath.CategoryTheory.Bicategories.Bicategories.Adjunctions.
Require Import UniMath.CategoryTheory.Bicategories.PseudoFunctors.Display.PseudoFunctorBicat.
Require Import UniMath.CategoryTheory.Bicategories.PseudoFunctors.PseudoFunctor.
Require Import UniMath.CategoryTheory.Bicategories.PseudoFunctors.Examples.Composition.
Require Import UniMath.CategoryTheory.Bicategories.PseudoFunctors.Examples.Identity.
Require Import UniMath.CategoryTheory.Bicategories.Transformations.PseudoTransformation.
Require Import UniMath.CategoryTheory.Bicategories.Modifications.Modification.

Import PseudoFunctor.Notations.

Local Open Scope cat.
Local Open Scope bicategory_scope.

Section Biequivalence.

Definition is_biequivalence_unit_counit {C D : bicat}
           (F : psfunctor C D) (G : psfunctor D C)
  : UU
  := pstrans (ps_comp G F) (ps_id_functor C) ×
     pstrans (ps_comp F G) (ps_id_functor D).

Definition unit_of_is_biequivalence {C D : bicat}
           {F : psfunctor C D}
           {G : psfunctor D C}
           (e : is_biequivalence_unit_counit F G)
  : pstrans (ps_comp G F) (ps_id_functor C)
  := pr1 e.

Definition counit_of_is_biequivalence {C D : bicat}
           {F : psfunctor C D}
           {G : psfunctor D C}
           (e : is_biequivalence_unit_counit F G)
  : pstrans (ps_comp F G) (ps_id_functor D)
  := pr2 e.

Definition is_biequivalence_adjoints {C D : bicat}
           {F : psfunctor C D}
           {G : psfunctor D C}
           (e : is_biequivalence_unit_counit F G)
  : UU
  := left_adjoint_equivalence (unit_of_is_biequivalence e) ×
     left_adjoint_equivalence (counit_of_is_biequivalence e).

Definition is_biequivalence_adjoint_unit {C D : bicat}
           {F : psfunctor C D}
           {G : psfunctor D C}
           {e : is_biequivalence_unit_counit F G}
           (a : is_biequivalence_adjoints e)
  : left_adjoint_equivalence (unit_of_is_biequivalence e)
  := pr1 a.

Definition is_biequivalence_adjoint_counit {C D : bicat}
           {F : psfunctor C D}
           {G : psfunctor D C}
           {e : is_biequivalence_unit_counit F G}
           (a : is_biequivalence_adjoints e)
  : left_adjoint_equivalence (counit_of_is_biequivalence e)
  := pr2 a.

Definition is_biequivalence {C D : bicat} (F : psfunctor C D) : UU
  := ∑ (G : psfunctor D C) (e : is_biequivalence_unit_counit F G),
     is_biequivalence_adjoints e.

Definition inv_psfunctor_of_is_biequivalence
           {C D : bicat} {F : psfunctor C D}
           (e : is_biequivalence F)
  : psfunctor D C
  := pr1 e.

Coercion unit_counit_from_is_biequivalence
           {C D : bicat} {F : psfunctor C D}
           (e : is_biequivalence F)
  : is_biequivalence_unit_counit F
      (inv_psfunctor_of_is_biequivalence e)
  := pr12 e.

Coercion adjoints_from_is_biequivalence
           {C D : bicat} {F : psfunctor C D}
           (e : is_biequivalence F)
  : is_biequivalence_adjoints e
  := pr22 e.

Definition biequivalence (C D : bicat) : UU
  := ∑ F : psfunctor C D, is_biequivalence F.

Coercion psfunctor_of_biequivalence {C D : bicat}
         (e : biequivalence C D)
  : psfunctor C D
  := pr1 e.

Coercion is_biequivalence_of_biequivalence {C D : bicat} (e : biequivalence C D)
  : is_biequivalence (psfunctor_of_biequivalence e)
  := pr2 e.

End Biequivalence.

Section Builder.

Context {C D : bicat} (F : psfunctor C D) (G : psfunctor D C)
        (η : pstrans (ps_id_functor C) (ps_comp G F))
        (ηinv : pstrans (ps_comp G F) (ps_id_functor C))
        (ε : pstrans (ps_comp F G) (ps_id_functor D))
        (εinv : pstrans (ps_id_functor D) (ps_comp F G))
        (pη : invertible_modification
               (id_trans (ps_comp G F))
               (comp_trans ηinv η))
        (qη : invertible_modification
               (comp_trans η ηinv)
               (id_trans (ps_id_functor C)))
        (pε : invertible_modification
               (id_trans (ps_comp F G))
               (comp_trans ε εinv))
        (qε : invertible_modification
               (comp_trans εinv ε)
               (id_trans (ps_id_functor D))).

Definition make_is_biequivalence : is_biequivalence F.
Proof.
  refine (G,, _).
  refine ((ηinv,, ε),, _).
  split.
  - apply equiv_to_isadjequiv.
    + use tpair.
      * use tpair.
        ** exact η.
        ** split.
           *** exact (pr1 pη).
           *** exact (pr1 qη).
      * split.
        ** apply pη.
        ** apply qη.
  - apply equiv_to_isadjequiv.
    + use tpair.
      * use tpair.
        ** exact εinv.
        ** split.
           *** exact (pr1 pε).
           *** exact (pr1 qε).
      * split.
        ** apply pε.
        ** apply qε.
Defined.

End Builder.


Section Pointwise.

Context {C D : bicat}
        (HC : is_univalent_2 C)
        (HD : is_univalent_2 D)
        (e : biequivalence C D).

Definition biequivalence_to_object_equivalence
  : ob C ≃ ob D.
Proof.
  pose (F := psfunctor_of_biequivalence e).
  pose (G := inv_psfunctor_of_is_biequivalence e).
  pose (η := is_biequivalence_adjoint_unit (pr2 e)).
  pose (ε := is_biequivalence_adjoint_counit (pr2 e)).
  use make_weq.
  - exact (λ x, F x).
  - use gradth.
    + exact (λ x, G x).
    + intro x.
      cbn.
      apply (isotoid_2_0 (pr1 HC)).
      use tpair.
      * exact (unit_of_is_biequivalence (pr2 e) x).
      * cbn.
        apply (pointwise_adjequiv (unit_of_is_biequivalence (pr2 e))).
        apply η.
    + intro y.
      cbn.
      apply (isotoid_2_0 (pr1 HD)).
      use tpair.
      * exact (counit_of_is_biequivalence (pr2 e) y).
      * cbn.
        apply (pointwise_adjequiv (counit_of_is_biequivalence (pr2 e))).
        apply ε.
Defined.

End Pointwise.
