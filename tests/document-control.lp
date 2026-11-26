%* Assertion tests for document control (base/calculations/documentControl)

Run from the project root:

    cyberismo calc run tests/document-control.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Document control tests". A fixture
"X" is a controlled document, and "X_review" is its review task. The fixtures
use fixed dates and timestamps and a review period of 36500 days, so that the results do not
change over time.
*%

% Policy checks: base_test_expectPolicy(Identifier, Title).
% A fixture must have each expected policy check, and no other one.
base_test_expectPolicy("base_test_doc_approved_empty", "Owner is a required field").
base_test_expectPolicy("base_test_doc_approved_empty", "Approver is a required field").
base_test_expectPolicy("base_test_doc_approved_empty", "Approval date is a required field").
base_test_expectPolicy("base_test_doc_approved_empty", "Review period is a required field").
base_test_expectPolicy("base_test_doc_reviewer_is_owner", "Reviewer cannot be the same as document owner").
base_test_expectPolicy("base_test_doc_reviewer_is_owner_review", "Reviewer cannot be the same as document owner").
base_test_expectPolicy("base_test_doc_open_review", "The review subtasks of approved documents must be closed").
base_test_expectPolicy("base_test_doc_review_expired", "Review has expired").
% Without a review task, only "Review task missing" fails. "Review has expired"
% and "Failing policy checks in a review task" need a review task.
base_test_expectPolicy("base_test_doc_approved_no_reviews", "Review task missing").
% Separation of duties fails on the document and on the review task. One
% failing review of two is enough (strict rule).
base_test_expectPolicy("base_test_doc_one_failing_review", "Reviewer cannot be the same as document approver").
base_test_expectPolicy("base_test_doc_one_failing_review_review2", "Reviewer cannot be the same as document approver").
base_test_expectPolicy("base_test_doc_approved_failing_review", "Reviewer cannot be the same as document approver").
base_test_expectPolicy("base_test_doc_approved_failing_review", "Failing policy checks in a review task").
base_test_expectPolicy("base_test_doc_approved_failing_review_review2", "Reviewer cannot be the same as document approver").
% A field-level (5-arity) failure, made by the test rule at the end of this file.
base_test_expectPolicy("base_test_doc_review_field_failure_review", "Test field failure").
base_test_expectPolicy("base_test_doc_reopened_no_date_review", "Last reviewed is a required field").
% An approved document whose latest done review has no review date fails, so
% that the expiry of its review can be checked.
base_test_expectPolicy("base_test_doc_approved_no_date_review", "Last reviewed is a required field").
base_test_expectPolicy("base_test_doc_approved_no_date", "Failing policy checks in a review task").
base_test_expectStatus("base_test_doc_approved_no_date", "error").

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
base_test_expectStatus("base_test_doc_approved_failing_review", "error").
% A draft can be archived without an approval date.
base_test_expectStatus("base_test_doc_archived_draft", "closed").
% After approval, only the latest review counts. The earlier review has the
% owner of the document as the reviewer, and nothing fails.
base_test_expectStatus("base_test_doc_approved_old_failing_review", "closed").
base_test_expectStatus("base_test_doc_earlier_failing_review", "initial").

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
base_test_expectDenied("base_test_doc_reviewer_is_owner", "Approve", "Fix the policy failures of the review tasks before approving").
% A document without review tasks cannot be approved, and the message says why.
base_test_expectDenied("base_test_doc_no_reviews", "Approve", "Add a review task before approving").
base_test_expectNotDenied("base_test_doc_no_reviews", "Approve", "Fix the policy failures of the review tasks before approving").
base_test_expectAllowed("base_test_doc_ready", "Approve").
% A reopened draft needs a review closed after the reopen.
base_test_expectDenied("base_test_doc_reopened_stale", "Approve", "Complete a new review after reopening the document").
base_test_expectNotDenied("base_test_doc_reopened_stale", "Approve", "Complete the review task(s) before approving").
base_test_expectNotDenied("base_test_doc_ready", "Approve", "Complete a new review after reopening the document").
base_test_expectAllowed("base_test_doc_reopened_current", "Approve").
% A current review without a review date fails a policy check, and that blocks
% approval.
base_test_expectDenied("base_test_doc_reopened_no_date", "Approve", "Fix the policy failures of the review tasks before approving").
base_test_expectNotDenied("base_test_doc_reopened_no_date", "Approve", "Complete a new review after reopening the document").
% A change after the review, also later on the same day, does not block
% approval. It shows a notification, and the approver decides.
base_test_expectAllowed("base_test_doc_edited_after_review", "Approve").
base_test_expectNotification("base_test_doc_edited_after_review", "Changed after the review").
base_test_expectNoNotification("base_test_doc_reopened_current").
base_test_expectNoNotification("base_test_doc_ready").
% Earlier reviews do not count, and their failures do not block approval.
base_test_expectAllowed("base_test_doc_earlier_failing_review", "Approve").
% A review closed as not applicable does not count, and does not block.
base_test_expectDenied("base_test_doc_not_applicable", "Approve", "Add a review task before approving").
base_test_expectNotDenied("base_test_doc_not_applicable", "Approve", "Complete the review task(s) before approving").
base_test_expectAllowed("base_test_doc_ready_with_na", "Approve").
% Any failing review task blocks approval, also with a field-level failure.
base_test_expectDenied("base_test_doc_review_field_failure", "Approve", "Fix the policy failures of the review tasks before approving").
base_test_expectDenied("base_test_doc_one_failing_review", "Approve", "Fix the policy failures of the review tasks before approving").

% Editing: base_test_expectEditDenied(Identifier, Message) and
% base_test_expectEditAllowed(Identifier).
base_test_expectEditDenied("base_test_doc_current", "You cannot edit approved documents").
base_test_expectEditDenied("base_test_doc_approved_empty", "You cannot edit approved documents").
base_test_expectEditDenied("base_test_doc_archived", "You cannot edit archived documents").
base_test_expectEditAllowed("base_test_doc_ready").
base_test_expectEditAllowed("base_test_doc_ready_review").

% Field editing: base_test_expectFieldEditDenied(Identifier, Field, Message)
% and base_test_expectFieldEditAllowed(Identifier, Field).
base_test_expectFieldEditDenied("base_test_doc_current", "title", "You cannot edit approved documents").
base_test_expectFieldEditDenied("base_test_doc_current", "base/fieldTypes/owner", "You cannot edit approved documents").
base_test_expectFieldEditDenied("base_test_doc_archived", "base/fieldTypes/reviewPeriod", "You cannot edit archived documents").
base_test_expectFieldEditAllowed("base_test_doc_ready", "title").
base_test_expectFieldEditAllowed("base_test_doc_ready", "base/fieldTypes/owner").

% Relaxed document control: base_test_relaxed(Identifier) turns it on for a
% fixture.
base_test_relaxed("base_test_doc_relaxed_edited_after_review").
base_test_relaxed("base_test_doc_relaxed_review_field_failure").
base_test_relaxed("base_test_doc_relaxed_approved_changed").
base_test_relaxed("base_test_doc_relaxed_approved_same_day").
base_test_relaxed("base_test_doc_relaxed_reopened_earlier_failing").
base_test_relaxed("base_test_doc_relaxed_approved_no_date").
base_test_relaxed("base_test_doc_relaxed_draft_no_date").

% A relaxed document also needs a review date on its last review, so that the
% expiry of the review can be checked.
base_test_expectPolicy("base_test_doc_relaxed_approved_no_date", "Review date missing").
base_test_expectPolicy("base_test_doc_relaxed_approved_no_date_review", "Last reviewed is a required field").
base_test_expectStatus("base_test_doc_relaxed_approved_no_date", "error").
base_test_expectDenied("base_test_doc_relaxed_draft_no_date", "Approve", "Fill in the review date of the review task before approving").
base_test_expectPolicy("base_test_doc_relaxed_draft_no_date_review", "Last reviewed is a required field").

% A relaxed draft can be approved after a change, and with a failing review.
% A reopened relaxed draft needs no new review, and its earlier reviews do not
% count.
base_test_expectAllowed("base_test_doc_relaxed_edited_after_review", "Approve").
base_test_expectNotification("base_test_doc_relaxed_edited_after_review", "Changed after the review").
base_test_expectAllowed("base_test_doc_relaxed_reopened_earlier_failing", "Approve").
base_test_expectAllowed("base_test_doc_relaxed_review_field_failure", "Approve").
base_test_expectPolicy("base_test_doc_relaxed_review_field_failure_review", "Test field failure").
% A relaxed approved document can be edited, and a change on a later day than
% the approval shows a notification.
base_test_expectEditAllowed("base_test_doc_relaxed_approved_changed").
base_test_expectFieldEditAllowed("base_test_doc_relaxed_approved_changed", "title").
base_test_expectFieldEditAllowed("base_test_doc_relaxed_approved_changed", "base/fieldTypes/owner").
base_test_expectStatus("base_test_doc_relaxed_approved_changed", "closed").
base_test_expectNotification("base_test_doc_relaxed_approved_changed", "Changed after approval").
base_test_expectNoNotification("base_test_doc_relaxed_approved_same_day").
base_test_expectNoNotification("base_test_doc_current").

% Bind the expectations to the fixture cards

base_relaxedDocumentControl(Card) :-
    base_test_relaxed(Id),
    base_test_fixture(Id, Card).

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
base_test_expected(Id) :- base_test_expectFieldEditDenied(Id, _, _).
base_test_expected(Id) :- base_test_expectFieldEditAllowed(Id, _).
base_test_expected(Id) :- base_test_relaxed(Id).
base_test_expected(Id) :- base_test_expectNotification(Id, _).
base_test_expected(Id) :- base_test_expectNoNotification(Id).

% A field-level policy check failure on one review task. Base has no such
% check on review tasks, but other modules can add one.
policyCheckFailure(Card, "Document control", "Test field failure", "Test.", "base/fieldTypes/owner") :-
    base_test_fixture("base_test_doc_review_field_failure_review", Card).

policyCheckFailure(Card, "Document control", "Test field failure", "Test.", "base/fieldTypes/owner") :-
    base_test_fixture("base_test_doc_relaxed_review_field_failure_review", Card).

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

base_test_failure(Id, @concatenate("field editing not denied: ", Field)) :-
    base_test_expectFieldEditDenied(Id, Field, Message),
    base_test_fixture(Id, Card),
    not editingFieldDenied(Card, Field, Message).

base_test_failure(Id, @concatenate("field editing denied: ", Field)) :-
    base_test_expectFieldEditAllowed(Id, Field),
    base_test_fixture(Id, Card),
    editingFieldDenied(Card, Field, _).

base_test_failure(Id, @concatenate("notification missing: ", Title)) :-
    base_test_expectNotification(Id, Title),
    base_test_fixture(Id, Card),
    not notification(Card, "Document control", Title, _).

base_test_failure(Id, @concatenate("unexpected notification: ", Title)) :-
    base_test_expectNoNotification(Id),
    base_test_fixture(Id, Card),
    notification(Card, "Document control", Title, _).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
