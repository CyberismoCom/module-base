%* Assertion tests for document control (base/calculations/documentControl)

Run from the project root:

    cyberismo calc run tests/document-control.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Document control tests". A fixture
"X" is a controlled document, and "X_review" is its review task. The fixtures
use fixed dates and a review period of 36500 days, so that the results do not
change over time.
*%

% Policy checks: base_test_expectPolicy(Identifier, Title).
% A fixture must have each expected policy check, and no other one.
base_test_expectPolicy("base_test_doc_approved_empty", "Owner is a required field").
base_test_expectPolicy("base_test_doc_approved_empty", "Approver is a required field").
base_test_expectPolicy("base_test_doc_approved_empty", "Approval date is a mandatory field").
base_test_expectPolicy("base_test_doc_approved_empty", "Review period is a required field").
base_test_expectPolicy("base_test_doc_reviewer_is_owner", "Reviewer cannot be the same as document owner").
base_test_expectPolicy("base_test_doc_reviewer_is_owner_review", "Reviewer cannot be the same as document owner").
base_test_expectPolicy("base_test_doc_open_review", "The review subtasks of approved documents must be closed").
base_test_expectPolicy("base_test_doc_review_expired", "Review has expired").
% Without a review task, only "Review task missing" fails. "Review has expired"
% and "Failing policy checks in all review tasks" need a review task.
base_test_expectPolicy("base_test_doc_approved_no_reviews", "Review task missing").

% Status indicators: base_test_expectStatus(Identifier, Indicator).
base_test_expectStatus("base_test_doc_draft_empty", "initial").
base_test_expectStatus("base_test_doc_draft_empty_review", "initial").
base_test_expectStatus("base_test_doc_ready", "initial").
base_test_expectStatus("base_test_doc_ready_review", "closed").
base_test_expectStatus("base_test_doc_no_reviews", "initial").
base_test_expectStatus("base_test_doc_approved_empty", "error").
base_test_expectStatus("base_test_doc_reviewer_is_owner", "error").
base_test_expectStatus("base_test_doc_reviewer_is_owner_review", "error").
base_test_expectStatus("base_test_doc_open_review", "error").
base_test_expectStatus("base_test_doc_open_review_review", "initial").
base_test_expectStatus("base_test_doc_review_expired", "error").
base_test_expectStatus("base_test_doc_current", "closed").
base_test_expectStatus("base_test_doc_current_review", "closed").
base_test_expectStatus("base_test_doc_archived", "closed").
base_test_expectStatus("base_test_doc_approved_no_reviews", "error").

% Denied transitions: base_test_expectDenied(Identifier, Transition, Message),
% base_test_expectNotDenied(Identifier, Transition, Message), and
% base_test_expectAllowed(Identifier, Transition).
base_test_expectDenied("base_test_doc_draft_empty", "Approve", "Fill in the owner field before approving").
base_test_expectDenied("base_test_doc_draft_empty", "Approve", "Fill in the approver field before approving").
base_test_expectDenied("base_test_doc_draft_empty", "Approve", "Complete the review task(s) before approving").
base_test_expectDenied("base_test_doc_draft_empty_review", "Start progress", "Fill in the owner field before starting progress").
base_test_expectDenied("base_test_doc_draft_empty_review", "Done", "Fill in the owner field before completing the task").
base_test_expectDenied("base_test_doc_reviewer_is_owner", "Approve", "Complete the review task(s) before approving").
base_test_expectDenied("base_test_doc_reviewer_is_owner", "Approve", "Fix policy failures before approving").
base_test_expectDenied("base_test_doc_reviewer_is_owner", "Approve", "Fix policy failures in at least one of the review subtask(s) before approving").
% A document without review tasks cannot be approved, and the message says why.
base_test_expectDenied("base_test_doc_no_reviews", "Approve", "Add a review task before approving").
base_test_expectNotDenied("base_test_doc_no_reviews", "Approve", "Fix policy failures in at least one of the review subtask(s) before approving").
base_test_expectAllowed("base_test_doc_ready", "Approve").

% Editing: base_test_expectEditDenied(Identifier, Message) and
% base_test_expectEditAllowed(Identifier).
base_test_expectEditDenied("base_test_doc_current", "You cannot edit approved documents").
base_test_expectEditDenied("base_test_doc_approved_empty", "You cannot edit approved documents").
base_test_expectEditDenied("base_test_doc_archived", "You cannot edit archived documents").
base_test_expectEditAllowed("base_test_doc_ready").
base_test_expectEditAllowed("base_test_doc_ready_review").

% Bind the expectations to the fixture cards

base_test_page(Page) :-
    projectCard(Page),
    field(Page, "title", "Document control tests").

base_test_fixture(Id, Card) :-
    base_test_page(Page),
    ancestor(Card, Page),
    projectCard(Card),
    field(Card, "base/fieldTypes/identifier", Id).

base_test_expected(Id) :- base_test_expectPolicy(Id, _).
base_test_expected(Id) :- base_test_expectStatus(Id, _).
base_test_expected(Id) :- base_test_expectDenied(Id, _, _).
base_test_expected(Id) :- base_test_expectNotDenied(Id, _, _).
base_test_expected(Id) :- base_test_expectAllowed(Id, _).
base_test_expected(Id) :- base_test_expectEditDenied(Id, _).
base_test_expected(Id) :- base_test_expectEditAllowed(Id).

% Assertions

base_test_failure(Id, "missing") :-
    base_test_expected(Id),
    not base_test_fixture(Id, _).

base_test_failure(Id, @concatenate("policy check missing: ", Title)) :-
    base_test_expectPolicy(Id, Title),
    base_test_fixture(Id, Card),
    not base_policyCheckFailure(Card, "Document control", Title, _).

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

base_test_failure(Id, @concatenate("not denied: ", Message)) :-
    base_test_expectDenied(Id, Transition, Message),
    base_test_fixture(Id, Card),
    not transitionDenied(Card, Transition, Message).

base_test_failure(Id, @concatenate("denied: ", Message)) :-
    base_test_expectNotDenied(Id, Transition, Message),
    base_test_fixture(Id, Card),
    transitionDenied(Card, Transition, Message).

base_test_failure(Id, @concatenate("denied: ", Transition)) :-
    base_test_expectAllowed(Id, Transition),
    base_test_fixture(Id, Card),
    transitionDenied(Card, Transition, _).

base_test_failure(Id, @concatenate("editing not denied: ", Message)) :-
    base_test_expectEditDenied(Id, Message),
    base_test_fixture(Id, Card),
    not editingContentDenied(Card, Message).

base_test_failure(Id, "editing denied") :-
    base_test_expectEditAllowed(Id),
    base_test_fixture(Id, Card),
    editingContentDenied(Card, _).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
