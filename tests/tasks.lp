%* Assertion tests for tasks (base/calculations/task) and adoption steps
(base/calculations/adoptionStep)

Run from the project root:

    cyberismo calc run tests/tasks.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Task tests". They use fixed dates far
in the past or the future, so that the results do not change over time.
*%

% Policy checks: base_test_expectPolicy(Identifier, Title).
% A fixture must have each expected policy check, and no other one.
base_test_expectPolicy("base_test_task_overdue", "Due date passed").
base_test_expectPolicy("base_test_task_closed_no_review", "Date of latest review missing").
base_test_expectPolicy("base_test_task_review_expired", "Review expired").

% Status indicators: base_test_expectStatus(Identifier, Indicator).
base_test_expectStatus("base_test_task_overdue", "error").
base_test_expectStatus("base_test_task_due_later", "initial").
base_test_expectStatus("base_test_task_closed_overdue", "closed").
base_test_expectStatus("base_test_task_no_justification", "initial").
base_test_expectStatus("base_test_task_justification", "initial").
base_test_expectStatus("base_test_task_closed_no_review", "error").
base_test_expectStatus("base_test_task_review_current", "closed").
base_test_expectStatus("base_test_task_review_expired", "error").
base_test_expectStatus("base_test_task_open_no_review", "initial").
base_test_expectStatus("base_test_task_step2", "initial").
base_test_expectStatus("base_test_task_step1", "initial").
base_test_expectStatus("base_test_task_step3", "initial").
base_test_expectStatus("base_test_task_nostep", "initial").

% Denied transitions: base_test_expectDenied(Identifier, Transition) and
% base_test_expectAllowed(Identifier, Transition).
base_test_expectDenied("base_test_task_no_justification", "Review as not applicable").
base_test_expectAllowed("base_test_task_justification", "Review as not applicable").

% Adoption steps: base_test_expectGreater(Higher, Lower) and
% base_test_expectNotGreater(Card1, Card2).
base_test_expectGreater("base_test_task_step2", "base_test_task_step1").
base_test_expectGreater("base_test_task_step3", "base_test_task_step2").
base_test_expectGreater("base_test_task_step2", "base_test_task_nostep").
base_test_expectNotGreater("base_test_task_step1", "base_test_task_step2").
base_test_expectNotGreater("base_test_task_step2", "base_test_task_step3").
base_test_expectNotGreater("base_test_task_nostep", "base_test_task_step2").
% Siblings are not compared
base_test_expectNotGreater("base_test_task_step3", "base_test_task_step1").

% Bind the expectations to the fixture cards

base_test_page(Page) :-
    projectCard(Page),
    field(Page, "title", "Task tests").

base_test_fixture(Id, Card) :-
    base_test_page(Page),
    ancestor(Card, Page),
    projectCard(Card),
    field(Card, "base/fieldTypes/identifier", Id).

base_test_expected(Id) :- base_test_expectPolicy(Id, _).
base_test_expected(Id) :- base_test_expectStatus(Id, _).
base_test_expected(Id) :- base_test_expectDenied(Id, _).
base_test_expected(Id) :- base_test_expectAllowed(Id, _).
base_test_expected(Id) :- base_test_expectGreater(Id, _).
base_test_expected(Id) :- base_test_expectGreater(_, Id).
base_test_expected(Id) :- base_test_expectNotGreater(Id, _).
base_test_expected(Id) :- base_test_expectNotGreater(_, Id).

% Assertions

base_test_failure(Id, "missing") :-
    base_test_expected(Id),
    not base_test_fixture(Id, _).

base_test_failure(Id, @concatenate("policy check missing: ", Title)) :-
    base_test_expectPolicy(Id, Title),
    base_test_fixture(Id, Card),
    not base_policyCheckFailure(Card, "Task", Title, _).

base_test_failure(Id, @concatenate("unexpected policy check: ", Title)) :-
    base_test_fixture(Id, Card),
    base_policyCheckFailure(Card, _, Title, _),
    not base_test_expectPolicy(Id, Title).

base_test_failure(Id, @concatenate("status indicator is not ", Expected)) :-
    base_test_expectStatus(Id, Expected),
    base_test_fixture(Id, Card),
    not field(Card, "statusIndicator", Expected).

base_test_failure(Id, "status indicator count") :-
    base_test_expectStatus(Id, _),
    base_test_fixture(Id, Card),
    #count { S : field(Card, "statusIndicator", S) } != 1.

base_test_failure(Id, @concatenate("not denied: ", Transition)) :-
    base_test_expectDenied(Id, Transition),
    base_test_fixture(Id, Card),
    not transitionDenied(Card, Transition, _).

base_test_failure(Id, @concatenate("denied: ", Transition)) :-
    base_test_expectAllowed(Id, Transition),
    base_test_fixture(Id, Card),
    transitionDenied(Card, Transition, _).

base_test_failure(Higher, @concatenate("not higher than ", Lower)) :-
    base_test_expectGreater(Higher, Lower),
    base_test_fixture(Higher, Card1),
    base_test_fixture(Lower, Card2),
    not base_greaterAdoptionStep(Card1, Card2).

base_test_failure(Card1Id, @concatenate("higher than ", Card2Id)) :-
    base_test_expectNotGreater(Card1Id, Card2Id),
    base_test_fixture(Card1Id, Card1),
    base_test_fixture(Card2Id, Card2),
    base_greaterAdoptionStep(Card1, Card2).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
