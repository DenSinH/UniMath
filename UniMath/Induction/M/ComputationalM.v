(** ** Refinement of M-types

    M-types can be refined to satisfy the right definitional equalities.
    This idea is from Felix Rech's Bachelor's thesis.

    Author: Dominik Kirst (@dominik-kirst)

    with help by Ralph Matthes (CNRS): proof of [P_isaprop] and change to def. of [destrM'] so that the proof of [eq3] became trivial

 *)

Require Import UniMath.Foundations.All.
Require Import UniMath.MoreFoundations.All.

Require Import UniMath.CategoryTheory.Core.Categories.
Require Import UniMath.CategoryTheory.Core.Functors.
Require Import UniMath.CategoryTheory.FunctorCoalgebras.
Require Import UniMath.CategoryTheory.categories.Type.Core.

Require Import UniMath.Induction.PolynomialFunctors.
Require Import UniMath.Induction.M.Core.
Require Import UniMath.Induction.M.Uniqueness.

Section Upstream.

  (** mostly copied from Felix Rech *)

  Lemma total2_symmetry (A B : UU) (C : A -> B -> UU) :
    (∑ a b, C a b)
      ≃ (∑ b a, C a b).
  Proof.
    use weq_iso.
    - intros abc; induction abc as [a [b c]].
      exact (b,, a,, c).
    - intros bac; induction bac as [b [a c]].
      exact (a,, b,, c).
    - reflexivity.
    - reflexivity.
  Defined.

  Lemma sec_total2_distributivity (A : UU) (B : A -> UU) (C : ∏ a, B a -> UU) :
    (∏ a : A, ∑ b : B a, C a b)
      ≃ (∑ b : ∏ a : A, B a, ∏ a, C a (b a)).
  Proof.
    use weq_iso.
    - intros f.
      exists (λ a, pr1 (f a)).
      exact (λ a, pr2 (f a)).
    - intros fg; induction fg as [f g].
      exact (λ a, f a,, g a).
    - reflexivity.
    - reflexivity.
  Defined.

  Lemma weq_functor_sec_id (A : UU) (B C : A -> UU) :
    (∏ a, B a ≃ C a) ->
    (∏ a, B a) ≃ (∏ a, C a).
  Proof.
    intros e.
    use weq_iso.
    - exact (λ f a, e a (f a)).
    - exact (λ f a, invmap (e a) (f a)).
    - cbn.
      intros f.
      apply funextsec; intros a.
      apply homotinvweqweq.
    - cbn.
      intros f.
      apply funextsec; intros a.
      apply homotweqinvweq.
  Defined.

  Lemma tpair_eta X (Y : X -> UU) :
    forall (p : ∑ x, Y x), p = (pr1 p,,pr2 p).
  Proof.
    intros p. apply idpath.
  Qed.

  Definition transportf_sec_constant X Y (Z : X -> Y -> UU) x1 x2 (p : x1 = x2) f y :
    transportf (λ x, forall y, Z x y) p f y = transportf (λ x, Z x y) p (f y).
  Proof.
    destruct p. apply idpath.
  Defined.

  Definition transportf_total2_const X Y (Z : X -> Y -> UU) x y1 y2 (p : y1 = y2) z :
    transportf (λ y, ∑ a, Z a y) p (x,, z) = x,, transportf (Z x) p z.
  Proof.
    destruct p. apply idpath.
  Defined.

End Upstream.

Section Refinement.

  Context (A : UU).
  Context (B : A → UU).
  Local Notation F := (polynomial_functor A B).

  Variable M0 : coalgebra F.
  Local Notation carrierM0 := (coalgebra_ob _  M0).
  Local Notation destrM0 := (coalgebra_mor _ M0).

  Variable finalM0 : is_final M0.
  Local Notation corecM0 C := (pr11 (finalM0 C)).

  Local Open Scope cat.
  Local Open Scope functions.

  (* Refinement of the final coalgebra to computable elements *)

  Definition carrierM := ∑ m0 : carrierM0, ∃ C c, corecM0 C c = m0.

  (* Definition of the corecursor *)

  Definition corecM (C : coalgebra F) (c : coalgebra_ob _ C) : carrierM.
  Proof.
    exists (corecM0 C c). apply hinhpr. exists C, c. apply idpath.
  Defined.

  (* Definition of a proposition we factor the computation through *)

  Local Definition P (m0 : carrierM0) :=
    ∑ af : F carrierM, destrM0 m0 = # F pr1 af.

  (** in order to show [P] to be a proposition, a not obviously equivalent
    formulation is given for which it is easy to show [isaprop] *)
  Local Definition P' (m0 : carrierM0) :=
    ∑ ap : ∑ a : A, pr1 (destrM0 m0) = a,
                 ∏ (b : B (pr1 ap)),
                 ∑ mp : ∑ m0' : carrierM0,
                                transportf (λ a, B a  -> carrierM0)
                                           (pr2 ap)
                                           (pr2 (destrM0 m0)) b =
                                m0',
                                ∃ C c, corecM0 C c = pr1 mp.

  (** the easy auxiliary lemma *)
  Local Lemma P'_isaprop m0 :
    isaprop (P' m0).
  Proof.
    apply isofhleveltotal2.
    - apply isofhlevelcontr.
      apply iscontrcoconusfromt.
    - intro ap; induction ap as [a p].
      apply impred; intros b.
      apply isofhleveltotal2.
      + apply isofhlevelcontr.
        apply iscontrcoconusfromt.
      + intro mp; induction mp as [m0' q].
        apply isapropishinh.
  Qed.

  (** the crucial lemma *)
  Local Lemma P_isaprop (m0 : carrierM0) :
    isaprop (P m0).
  Proof.
    use (@isofhlevelweqb _ _ (P' m0) _ (P'_isaprop m0)).
    simple refine (weqcomp (weqtotal2asstor _ _) _).
    simple refine (weqcomp _ (invweq (weqtotal2asstor _ _))).
    apply weqfibtototal; intro a.
    intermediate_weq (
        ∑ f : B a  → carrierM,
              ∑ p : pr1 (destrM0 m0) = a,
                    transportf
                      (λ a, B a -> carrierM0)
                      p
                      (pr2 (destrM0 m0)) =
                    fun b => pr1 (f b)).
    {
      apply weqfibtototal; intro f.
      apply total2_paths_equiv.
    }
    intermediate_weq (∑ p : pr1 (destrM0 m0) = a,
                            ∑ f : B a → carrierM,
                                  transportf
                                    (λ a, B a → carrierM0)
                                    p
                                    (pr2 (destrM0 m0)) =
                                  fun b => pr1 (f b)).
    { apply total2_symmetry. }
    apply weqfibtototal; intro p.
    intermediate_weq (∑ fg : ∑ f : B a -> carrierM0,
                                   ∏ b, ∃ C c, corecM0 C c = f b,
                        transportf
                          (λ a, B a -> carrierM0)
                          p
                          (pr2 (destrM0 m0)) =
                        pr1 fg).
    { use weqbandf.
      - apply weqfuntototaltototal.
      - cbn.
        intro f.
        apply idweq.
    }
    intermediate_weq (∑ f : B a  → carrierM0,
                            ∑ _ : ∏ b, ∃ C c, corecM0 C c = f b,
                        transportf
                          (λ a, B a  → carrierM0)
                          p
                          (pr2 (destrM0 m0)) =
                        f).
    { apply weqtotal2asstor. }
    intermediate_weq (∑ f : B a → carrierM0,
                            ∑ _ : ∏ b, ∃ C c, corecM0 C c = f b,
                        ∏ b, transportf
                               (λ a, B a → carrierM0)
                               p
                               (pr2 (destrM0 m0)) b =
                             f b).
    { apply weqfibtototal; intro f.
      apply weqfibtototal; intros _.
      apply weqtoforallpaths.
    }
    intermediate_weq (∑ f : B a → carrierM0,
                            ∏ b, ∑ _ : ∃ C c, corecM0 C c = f b,
                        transportf
                          (λ a, B a  → carrierM0)
                          p
                          (pr2 (destrM0 m0)) b =
                        f b).
    { apply weqfibtototal; intro f.
      apply invweq.
      apply sec_total2_distributivity.
    }
    intermediate_weq (∏ b, ∑ m0' : carrierM0,
                                   ∑ _ : ∃ C c, corecM0 C c = m0',
                        transportf
                          (λ a, B a -> carrierM0)
                          p
                          (pr2 (destrM0 m0)) b =
                        m0').
    { apply invweq.
      apply sec_total2_distributivity.
    }
    apply weq_functor_sec_id; intro b.
    intermediate_weq (∑ m0' : carrierM0,
                              ∑ _ : transportf
                                      (λ a, B a -> carrierM0)
                                      p
                                      (pr2 (destrM0 m0)) b =
                                    m0',
                                    ∃ C c, corecM0 C c = m0').
    {
      apply weqfibtototal; intro m0'.
      apply weqdirprodcomm.
    }
    intermediate_weq (∑ mp : ∑ m0', transportf (λ a, B a → carrierM0) p
                                               (pr2 (destrM0 m0)) b = m0',
                             ∃ C c, corecM0 C c = pr1 mp).
    {
      apply invweq.
      apply weqtotal2asstor.
    }
    use weqbandf.
    - apply weqfibtototal; intro m0'.
      apply idweq.
    - cbn. intro mp.
      apply idweq.
  Qed.

  (* Now the destructor of M can be defined *)

  Local Definition destrM' (m : carrierM) : P (pr1 m).
  Proof.
    induction m as [m0 H]. apply (squash_to_prop H); try apply P_isaprop.
    intros [C [c H1]].
    refine ((# F (corecM C) ∘ (pr2 C)) c,, _). cbn [pr1]. clear H.
    assert (H : is_coalgebra_homo F (corecM0 C)).
    { destruct finalM0 as [[G H] H']. apply H. }
    apply toforallpaths in H.
    apply pathsinv0.
    intermediate_path (destrM0 (corecM0 C c)).
    - apply H.
    - apply maponpaths. assumption.
  Defined.

  Definition destrM (m : carrierM) : F carrierM :=
    pr1 (destrM' m).

  Definition M : coalgebra F :=
    (carrierM,, destrM).

  (* The destructor satisfies the corecursion equation definitionally *)

  Lemma corec_computation C c :
    destrM (corecM C c) = # F (corecM C) (pr2 C c).
  Proof.
    apply idpath.
  Qed.

  (* The two carriers are equal *)

  Lemma eq_corecM0 m0 :
    corecM0 M0 m0 = m0.
  Proof.
    induction finalM0 as [[G H1] H2]. cbn.
    specialize (H2 (coalgebra_homo_id F M0)).
    change (pr1 (G,, H1) m0 = pr1 (coalgebra_homo_id F M0) m0).
    apply (maponpaths (fun X => pr1 X m0)).
    apply pathsinv0.
    assumption.
  Qed.

  Definition injectM0 m0 :
    ∃ C c, corecM0 C c = m0.
  Proof.
    apply hinhpr. exists M0, m0. apply eq_corecM0.
  Defined.

  Lemma carriers_weq :
    carrierM ≃ carrierM0.
  Proof.
    apply (weq_iso pr1 (λ m0, m0,, injectM0 m0)).
    - intros [m H]. cbn. apply maponpaths, ishinh_irrel.
    - intros x. cbn. apply idpath.
  Defined.

  Lemma carriers_eq :
    carrierM = carrierM0.
  Proof.
    apply weqtopaths, carriers_weq.
  Defined. (** needs to be transparent *)

  (* The two coalgebras are equal *)

  Local Lemma eq1 (m0 : carrierM0) :
    transportf (λ X, X → F X) carriers_eq destrM m0
    = transportf (λ X, F X) carriers_eq (destrM (transportf (λ X, X) (!carriers_eq) m0)).
  Proof.
    destruct carriers_eq. apply idpath.
  Qed.

  Local Lemma eq2 (m0 : carrierM0) :
    transportf (λ X, X) (!carriers_eq) m0 = m0,, injectM0 m0.
  Proof.
    apply (transportf_pathsinv0' (idfun UU) carriers_eq).
    unfold carriers_eq. rewrite weqpath_transport. apply idpath.
  Qed.

  Local Lemma eq3 m0 :
    destrM (m0,, injectM0 m0) = pr1 (destrM0 m0),, corecM M0 ∘ pr2 (destrM0 m0).
  Proof.
    apply idpath.
  Qed.

  Lemma coalgebras_eq :
    M = M0.
  Proof.
    use total2_paths_f; try apply carriers_eq.
    apply funextfun. intro m0.
    rewrite eq1. rewrite eq2. rewrite eq3.
    cbn. unfold polynomial_functor_obj.
    rewrite transportf_total2_const.
    rewrite tpair_eta. use total2_paths_f; try apply idpath.
    cbn. apply funextsec. intros b. rewrite transportf_sec_constant.
    unfold carriers_eq. rewrite weqpath_transport.
    cbn. rewrite eq_corecM0. apply idpath.
  Qed.

  (* Thus M is final *)

  Lemma finalM : is_final M.
  Proof.
    rewrite coalgebras_eq. apply finalM0.
  Defined.

End Refinement.
