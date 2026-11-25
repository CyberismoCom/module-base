%* Assertion tests for the status indicator of cards with an assessment
(base/calculations/statusIndicator and base/fieldTypes/assessment)

Run from the project root:

    cyberismo calc run tests/assessment-status.lp

The tests pass when "results" is empty. Each result is one failed assertion.

Base has no card type with the field "Assessment", so the fixtures are facts
in this file: one card for each assessment value, of a test card type that
has the field. The card "error" also fails a policy check.
*%

base_test_assessedCardType("base_test/cardTypes/assessed").
customField(T, "base/fieldTypes/assessment") :- base_test_assessedCardType(T).

% base_test_assessed(Card, Assessment, Expected status indicator)
base_test_assessed("base_test_assessed_open", "open", "initial").
base_test_assessed("base_test_assessed_notStarted", "notStarted", "initial").
base_test_assessed("base_test_assessed_inProgress", "inProgress", "active").
base_test_assessed("base_test_assessed_notOk", "notOk", "active").
base_test_assessed("base_test_assessed_ok", "ok", "closed").
base_test_assessed("base_test_assessed_notApplicable", "notApplicable", "closed").
base_test_assessed("base_test_assessed_error", "notStarted", "error").

projectCard(Card) :- base_test_assessed(Card, _, _).
field(Card, "cardType", T) :-
    base_test_assessed(Card, _, _),
    base_test_assessedCardType(T).
field(Card, "base/fieldTypes/assessment", A) :- base_test_assessed(Card, A, _).

policyCheckFailure("base_test_assessed_error", "Test", "Fails", "A policy check that fails").

% Assertions

base_test_failure(Card, @concatenate("status indicator is not ", Expected)) :-
    base_test_assessed(Card, _, Expected),
    not field(Card, "statusIndicator", Expected).

base_test_failure(Card, "status indicator count") :-
    base_test_assessed(Card, _, _),
    #count { S : field(Card, "statusIndicator", S) } != 1.

% Every value of the field type has a status indicator.

base_test_failure(Value, "no status indicator for this assessment value") :-
    enumValue("base/fieldTypes/assessment", Value),
    not base_test_assessed(_, Value, _).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
