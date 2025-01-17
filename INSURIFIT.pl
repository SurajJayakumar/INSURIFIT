% Facts
age(jack,24).
male(jack).
wants_to_minimize_premium(jack).
rides_motorcycles(jack). %jack loves riding motorcycles
is_young_and_healthy(jack).
visits_dentist_often(jack). %jack is planning to get his wisdom teeth removed 


age(trevor,59).
male(trevor).
is_low_income(trevor).
wants_to_minimize_deductible(trevor). %wants to pay less for his treatment and medicines
disabled(trevor).
diabetic(trevor).
has_children(trevor).


age(ralph,40).
male(ralph).
wishes_to_consult_without_a_referral(ralph). %Ralph wants to consult doctors without requiring a referral from his family doctor




age(shania,26).
female(shania).
family_has_history_of_cancer(shania).
visits_OBGYN_often(shania).






%Predicates

has_chronic_issue(User):-disabled(User).
has_chronic_issue(User):- end_stage_renal_disease(User).
has_chronic_issue(User):-als(User).

eligible_for_medicare(User):-has_chronic_issue(User).
eligible_for_medicare(User):-is_above_65_years_old(User).


is_above_65_years_old(User):-
    age(User,X),
    X.>.65.



eligible_for_ACA_subsidy(User):- 
    -eligible_for_medicare(User),
    is_low_income(User),
    not is_employed_and_has_employer_plan(User).


eligible_for_catastrophic_insurance(User):-is_young_and_healthy(User).
eligible_for_catastrophic_insurance(User):-homeless(User).
eligible_for_catastrophic_insurance(User):-bankrupt(User).




wants_balanced_premium_and_deductible(User):-wants_to_minimize_premium(User),wants_to_minimize_deductible(User).%user cant minimize both premium and deuctible unless he wants to go for a balanced approach


requires_specialty_drugs(User):-diabetic(User). %Avastin: A drug that treats wet age-related macular degeneration and diabetic eye disease
requires_specialty_drugs(User):- hormonal_therapy(User). %Aveed and Eligard: Hormonal therapy drugs
requires_specialty_drugs(User):-family_has_history_of_cancer(User). %cancer preventative drugs
-requires_specialty_drugs(User):-is_young_and_healthy(User). %no need for specialty drugs if the user is healthy



 
-is_young_and_healthy(User):-is_on_medication(User).
-wants_to_minimize_premium(User):-wants_to_minimize_deductible(User).
-wants_to_minimize_deductible(User):-wants_to_minimize_premium(User).

needs_good_ER_support(User):- %young motorcyclists are prone to crashing
    rides_motorcycles(User),
    age(User,X),
    X.<.25.  

has_or_will_have_children(User):- %Women above 25 often have children
    female(User),
    age(User,X),
    X.>.25.


in_network_provider_is_too_far(Plan,User):- 
    visits_dentist_often(User),
    is_too_far(Plan,User,dentist).

in_network_provider_is_too_far(Plan,User):- 
    visits_pharmacy_often(User),
    is_too_far(Plan,User,pharmacy).

in_network_provider_is_too_far(Plan,User):-
    visits_OBGYN_often(User),
    is_too_far(Plan, User, obgyn).



% Rules for recommendation


recommend(medicare,User):-
    not is_young_and_healthy(User),
    eligible_for_medicare(User).

    

recommend(texas_farm_bureau_hdhp, User) :-%HDHP where health savings account etc are involved
    is_young_and_healthy(User),
    wants_to_minimize_premium(User),
    -eligible_for_ACA_subsidy(User),
    -wants_to_minimize_deductible(User).


recommend(aetna_gold_10_advanced, User) :-%gold HMO
    not is_young_and_healthy(User),
    wants_to_minimize_deductible(User),
    not travels_a_lot(User),
    not -has_or_will_have_children(User).


recommend(myblue_health_bronze_402, User) :-%bronze HMO with standard coinsurance
    not travels_a_lot(User),
    not -requires_specialty_drugs(User),
    has_or_will_have_children(User).



recommend(blue_advantage_security_hmo_200, User) :- %catastrophic hmo meaning very low premium but high deductible(good for young&healthy)
    eligible_for_catastrophic_insurance(User),
    not travels_a_lot(User), %because HMOs do not cover out of network healthcare providers
    wants_to_minimize_premium(User),
    not -has_or_will_have_children(User).




recommend(uhc_bronze_copay_focus_0_indiv_med_ded,User):-%HMO with zero deductible but high coinsurance
    -has_or_will_have_children(User),
    not -wants_to_minimize_deductible(User).


recommend(bsw_vital_bronze_epo_001, User):- %EPO plan which is an HMO but no need for primary care provider referral
    wishes_to_consult_without_a_referral(User),
    not -wants_to_minimize_premium(User).


recommend(blue_advantage_plus_bronze_305,User):- %POS plan with low premium and high coinsurance
    wants_to_minimize_premium(User),
    travels_a_lot(User),
    not -wishes_to_consult_without_a_referral(User).
    




% Negative Recommendations


-recommend(texas_farm_bureau_hdhp, User) :-
    disabled(User),
    not -has_or_will_have_children(User).



-recommend(myblue_health_bronze_402, User) :-
    wants_to_minimize_deductible(User),
    needs_good_ER_support(User).


-recommend(aetna_gold_10_advanced, User) :-
    travels_a_lot(User),
    not -wants_to_minimize_premium(User),
    not eligible_for_ACA_subsidy(User).



-recommend(blue_advantage_security_hmo_200, User) :-
    has_family(User),
    not is_young_and_healthy(User),
    disabled(User).


    
-recommend(uhc_bronze_copay_focus_0_indiv_med_ded,User):-
    travels_a_lot(User),
    is_low_income(User).



-recommend(uhc_bronze_copay_focus_0_indiv_med_ded,User):-
    in_network_provider_is_too_far(uhc_bronze_copay_focus_0_indiv_med_ded,User).



-recommend(blue_advantage_plus_bronze_305,User):-
    not travels_a_lot(User).


%database of in network healthcare providers which are too far away from the Users location (>10 miles). Sourced from google maps given Jack's location and UnitedHealthcare in-network providers map
is_too_far(uhc_bronze_copay_focus_0_indiv_med_ded,jack,dentist). %The in network dentist for this plan is too far away from jack
