;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PET ADOPTION EXPERT SYSTEM
;; Domain: Animal Adoption Assessment
;; Author: Eric James & ChatGPT (2025)
;; Compatible with pet_adoption.py GUI
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; TEMPLATES
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate adopter
  (slot AdoptionBudget)          ; Numeric - initial adoption cost
  (slot HasPetExperience)        ; Boolean symbol TRUE/FALSE
  (slot HomeType)                ; apartment | house | yard
  (slot AvailableSpace)          ; small | medium | large
  (slot PreferredPetType)        ; dog | cat | rabbit | other
  (slot HasChildrenOrOtherPets)  ; Boolean symbol TRUE/FALSE
  (slot MonthlyPetBudget)        ; Numeric - monthly care budget
  (slot AloneHours)              ; Integer - hours pet will be alone
  (slot AdopterHistoryGood))     ; Boolean symbol TRUE/FALSE


(deftemplate decision
  (slot AdoptionStatus (default pending))
  (slot CareBudget (default pending))
  (slot SpaceMatch (default pending))
  (slot ExperienceMatch (default pending))
  (slot AdoptionRecommendation (default pending))
  (slot FinalDecision (default pending)))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; RULES - PHASE 1: INDIVIDUAL CRITERIA CHECKS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule check-budget
  (declare (salience 100))
  (adopter (AdoptionBudget ?b) (PreferredPetType ?pet))
  ?d <- (decision (CareBudget pending))
  =>
  (bind ?required
    (if (eq ?pet "dog") then 5000
     else if (eq ?pet "cat") then 3000
     else if (eq ?pet "rabbit") then 2000
     else 1500))
  (if (>= ?b ?required)
      then (modify ?d (CareBudget Sufficient))
      else (modify ?d
            (CareBudget Insufficient)
            (FinalDecision (str-cat "Adoption Rejected - Insufficient budget (need at least ₱" ?required ")")))))


(defrule check-space
  (declare (salience 100))
  (adopter (AvailableSpace ?s) (PreferredPetType ?pet) (HomeType ?ht))
  ?d <- (decision (SpaceMatch pending))
  =>
  (bind ?suitable
    (or
      (eq ?pet "rabbit")
      (and (or (eq ?s "medium") (eq ?s "large"))
           (or (eq ?ht "house") (eq ?ht "yard")))))
  (if ?suitable
      then (modify ?d (SpaceMatch Suitable))
      else (modify ?d
            (SpaceMatch Unsuitable)
            (FinalDecision "Adoption Rejected - Insufficient space (need house/yard for dogs/cats)"))))


(defrule check-experience
  (declare (salience 100))
  (adopter (HasPetExperience ?e) (PreferredPetType ?pet))
  ?d <- (decision (ExperienceMatch pending))
  =>
  (if (and (eq ?e TRUE) (or (eq ?pet "dog") (eq ?pet "cat")))
      then (modify ?d (ExperienceMatch StronglyApproved))
      else (modify ?d (ExperienceMatch Neutral))))


(defrule check-availability
  (declare (salience 100))
  (adopter (AloneHours ?hours) (AdopterHistoryGood ?history))
  ?d <- (decision (AdoptionStatus pending))
  =>
  (if (eq ?history FALSE)
      then (modify ?d
            (AdoptionStatus Rejected)
            (FinalDecision "Adoption Rejected - Applicant has negative history"))
      else if (> ?hours 12)
      then (modify ?d
            (AdoptionStatus Rejected)
            (FinalDecision "Adoption Rejected - Pet would be left alone too long (>12 hours)"))
      else (modify ?d (AdoptionStatus Approved))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 2: RECOMMENDATION BASED ON FAMILY / PET SIZE
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule recommendation
  (declare (salience 50))
  (adopter (HasChildrenOrOtherPets ?hasOthers) (PreferredPetType ?pet))
  ?d <- (decision (AdoptionRecommendation pending))
  =>
  (if (and (eq ?hasOthers TRUE) (eq ?pet "dog"))
      then (modify ?d
            (AdoptionRecommendation NotRecommended)
            (FinalDecision "Adoption Not Recommended - Large dogs not ideal with children/other pets"))
      else (modify ?d (AdoptionRecommendation Recommended))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; PHASE 3: FINAL DECISIONS
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule final-approval
  (declare (salience 5))
  ?d <- (decision
          (AdoptionStatus Approved)
          (CareBudget Sufficient)
          (SpaceMatch Suitable)
          (AdoptionRecommendation Recommended)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Approved - All criteria met!")))


(defrule final-conditional
  (declare (salience 5))
  ?d <- (decision
          (AdoptionStatus Approved)
          (CareBudget Sufficient)
          (SpaceMatch Suitable)
          (ExperienceMatch Neutral)
          (AdoptionRecommendation Recommended)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Conditionally Approved - Consider gaining pet experience first")))


(defrule final-reject-budget
  (declare (salience 5))
  ?d <- (decision
          (CareBudget Insufficient)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Rejected - Budget insufficient for chosen pet type")))


(defrule final-reject-space
  (declare (salience 5))
  ?d <- (decision
          (SpaceMatch Unsuitable)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Rejected - Living space unsuitable for this pet type")))


(defrule final-reject-children-large-dog
  (declare (salience 5))
  ?d <- (decision
          (AdoptionRecommendation NotRecommended)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Not Recommended - Family conditions unsuitable for large dogs")))


(defrule final-multiple-fail
  (declare (salience 5))
  ?d <- (decision
          (CareBudget Insufficient)
          (SpaceMatch Unsuitable)
          (FinalDecision pending))
  =>
  (modify ?d (FinalDecision "Adoption Rejected - Multiple criteria failed (budget + space)")))
