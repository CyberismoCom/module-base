% Shared predicates: base_controlledDocumentCardType/1,
% base_relaxedDocumentControl/1, base_documentReview/2,
% base_documentHasReview/1, and base_documentReviewed/1. Each one has a
% predicate card in the base documentation, under "For module authors" >
% "Shared predicates".

% Document control for controlled documents and for the document card types
% of other modules. A module adds its own card type with a fact, for example:
%
%     base_controlledDocumentCardType("ismsa/cardTypes/statementOfApplicability").
%
% The card type must use the workflow base/workflows/controlledDocument.
base_controlledDocumentCardType("base/cardTypes/controlledDocument").

base_document(Document) :-
    base_controlledDocumentCardType(CardType),
    base_projectCardType(Document, CardType).

% Document control is strict by default. A project or module can relax it for
% some documents, for example for one card type:
%
%     base_relaxedDocumentControl(Document) :-
%         base_projectCardType(Document, "base/cardTypes/controlledDocument").
%
% For a relaxed document, approved and archived documents can be edited, a
% change after the review does not need a new review, and a failing review
% task does not block approval. A change after approval shows a notification.
#defined base_relaxedDocumentControl/1.

base_documentStrict(Document) :-
    base_document(Document),
    not base_relaxedDocumentControl(Document).

base_documentRelaxed(Document) :-
    base_document(Document),
    base_relaxedDocumentControl(Document).

% The review tasks of a document. A review task that is closed as not
% applicable does not count.
base_documentReview(Document, ReviewTask) :-
    base_document(Document),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as not applicable").

base_documentHasReview(Document) :-
    base_documentReview(Document, _).

% A review that is not closed yet.
base_documentPendingReview(Document, ReviewTask) :-
    base_documentReview(Document, ReviewTask),
    not field(ReviewTask, "workflowState", "Closed as done").

base_documentHasPendingReview(Document) :-
    base_documentPendingReview(Document, _).

% A review that is closed as done, and the time it was closed. Core writes
% both timestamps in UTC in the same format, so they compare as strings.
base_documentClosedReview(Document, ReviewTask, Closed) :-
    base_documentReview(Document, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "lastTransitioned", Closed).

% A review of the current version of a draft: closed after the last change of
% the document. Any change of the document, also a reopen, stamps
% lastUpdated. Reviews closed before the last change are earlier reviews, and
% the rules for approval ignore them. For a relaxed document, every closed
% review is current.
base_documentCurrentReview(Document, ReviewTask) :-
    base_documentClosedReview(Document, ReviewTask, Closed),
    base_documentStrict(Document),
    field(Document, "lastUpdated", LastUpdated),
    Closed >= LastUpdated.

base_documentCurrentReview(Document, ReviewTask) :-
    base_documentClosedReview(Document, ReviewTask, _),
    base_documentRelaxed(Document).

base_documentHasCurrentReview(Document) :-
    base_documentCurrentReview(Document, _).

% The last review that was closed. Approval stamps lastUpdated, so for an
% approved or archived document this is the review that it was approved with.
base_documentNewerReview(Document, Closed) :-
    base_documentClosedReview(Document, _, Closed),
    base_documentClosedReview(Document, _, Newer),
    Newer > Closed.

base_documentLatestReview(Document, ReviewTask) :-
    base_documentClosedReview(Document, ReviewTask, Closed),
    not base_documentNewerReview(Document, Closed).

% The reviews that the rules check: the open ones, and for a draft the
% current ones, or for other states the latest one.
base_documentCheckedReview(Document, ReviewTask) :-
    base_documentPendingReview(Document, ReviewTask).

base_documentCheckedReview(Document, ReviewTask) :-
    base_documentCurrentReview(Document, ReviewTask),
    field(Document, "workflowState", "Draft").

base_documentCheckedReview(Document, ReviewTask) :-
    base_documentLatestReview(Document, ReviewTask),
    not field(Document, "workflowState", "Draft").

% A review that is closed as done and has a review date.
base_documentDoneReview(Document, ReviewTask, LastReviewed) :-
    base_documentReview(Document, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", LastReviewed).

base_documentReviewed(Document) :-
    base_documentDoneReview(Document, _, _).

% Approval

transitionDenied(Document, "Approve", "Add a review task before approving") :-
    base_document(Document),
    not base_documentHasReview(Document).

transitionDenied(Document, "Approve", "Complete the review task(s) before approving") :-
    base_documentHasPendingReview(Document).

transitionDenied(Document, "Approve", "Complete a new review after the last change to the document") :-
    base_documentHasReview(Document),
    not base_documentHasPendingReview(Document),
    not base_documentHasCurrentReview(Document).

transitionDenied(Document, "Approve", "Fix policy failures before approving") :-
    base_document(Document),
    base_policyCheckFailure(Document, _, _, _).

transitionDenied(Document, "Approve", "Fix the policy failures of the review tasks before approving") :-
    base_documentStrict(Document),
    base_documentCheckedReview(Document, ReviewTask),
    base_policyCheckFailure(ReviewTask, _, _, _).

transitionDenied(Document, "Approve", "Fill in the owner field before approving") :-
    base_document(Document),
    not field(Document, "base/fieldTypes/owner", _).

transitionDenied(Document, "Approve", "Fill in the approver field before approving") :-
    base_document(Document),
    not field(Document, "base/fieldTypes/approver", _).

transitionDenied(Document, "Approve", "Fill in the information classification field before approving") :-
    base_document(Document),
    not field(Document, "base/fieldTypes/informationClassification", _).

onTransitionSetField(Document, "Approve", Document, "base/fieldTypes/approvalDate", @today) :-
    base_document(Document).

% Editing approved and archived documents

base_documentLocked(Document, "You cannot edit approved documents") :-
    base_documentStrict(Document),
    field(Document, "workflowState", "Approved").

base_documentLocked(Document, "You cannot edit archived documents") :-
    base_documentStrict(Document),
    field(Document, "workflowState", "Archived").

editingContentDenied(Document, Message) :-
    base_documentLocked(Document, Message).

editingFieldDenied(Document, "title", Message) :-
    base_documentLocked(Document, Message).

% Core sets the fields of a transition after the new state is saved, and skips
% locked fields. The fields that Approve sets stay unlocked.
editingFieldDenied(Document, Field, Message) :-
    base_documentLocked(Document, Message),
    base_projectCardType(Document, CardType),
    customField(CardType, Field),
    not onTransitionSetField(Document, "Approve", Document, Field, _).

% Review tasks

transitionDenied(ReviewTask, "Start progress", "Fill in the owner field before starting progress" ):-
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "base/fieldTypes/owner", _).

transitionDenied(ReviewTask, "Done", "Fill in the owner field before completing the task" ):-
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "base/fieldTypes/owner", _).

% Policy checks on the document

policyCheckFailure(Document, "Document control", "Owner is a required field", "Fill in the owner field.", "base/fieldTypes/owner"):-
    base_document(Document),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "Document control", "Approver is a required field", "Fill in the approver field.", "base/fieldTypes/approver"):-
    base_document(Document),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/approver", _).

% A draft can be archived without approval, so only approved documents need
% an approval date.
policyCheckFailure(Document, "Document control", "Approval date is a required field", "Fill in the approval date field.", "base/fieldTypes/approvalDate"):-
    base_document(Document),
    field(Document, "workflowState", "Approved"),
    not field(Document, "base/fieldTypes/approvalDate", _).

% Only for the card types that have a review period field.
policyCheckFailure(Document, "Document control", "Review period is a required field", "Fill in the review period field.", "base/fieldTypes/reviewPeriod"):-
    base_document(Document),
    base_projectCardType(Document, CardType),
    customField(CardType, "base/fieldTypes/reviewPeriod"),
    not field(Document, "workflowStateCategory", "initial"),
    not field(Document, "base/fieldTypes/reviewPeriod", _).

policyCheckFailure(Document, "Document control", "Review task missing", "Add a review task and complete it.") :-
    base_document(Document),
    field(Document, "workflowState", "Approved"),
    not base_documentHasReview(Document).

policyCheckFailure(Document, "Document control", "The review subtasks of approved documents must be closed", "Complete review task(s)" ):-
    base_documentHasPendingReview(Document),
    field(Document, "workflowState", "Approved").

policyCheckFailure(Document, "Document control", "Failing policy checks in a review task", "Fix the policy failures of the review tasks.") :-
    base_documentStrict(Document),
    base_documentCheckedReview(Document, ReviewTask),
    field(Document, "workflowState", "Approved"),
    base_policyCheckFailure(ReviewTask, _, _, _).

% Expired when all done reviews are older than the review period. A document
% without a done review fails other checks instead.
policyCheckFailure(Document, "Document control", "Review has expired", "Complete a new review of this document.") :-
    base_documentReviewed(Document),
    field(Document, "workflowState", "Approved"),
    field(Document, "base/fieldTypes/reviewPeriod", ReviewPeriod),
    @daysSince(LastReviewed) > ReviewPeriod :
    base_documentDoneReview(Document, _, LastReviewed).

% A relaxed approved document that was changed on a later day than its
% approval. The approval itself changes the document, so a change on the day
% of the approval does not show.
notification(Document, "Document control", "Changed after approval", "This document was changed after it was approved. Reopen it and have it reviewed again.") :-
    base_documentRelaxed(Document),
    field(Document, "workflowState", "Approved"),
    field(Document, "base/fieldTypes/approvalDate", ApprovalDate),
    field(Document, "lastUpdated", LastUpdated),
    LastUpdated > @concatenate(ApprovalDate, "T23:59:59.999Z").

% Policy checks on the review tasks that the rules check

policyCheckFailure(ReviewTask, "Document control", "Last reviewed is a required field", "Fill in the last reviewed field.", "base/fieldTypes/lastReviewed") :-
    base_documentCheckedReview(_, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    not field(ReviewTask, "base/fieldTypes/lastReviewed", _).

% Separation of duties. The check fails on the document and on the review task.

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_documentCheckedReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/owner", Owner),
    field(ReviewTask, "base/fieldTypes/owner", Owner).

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document owner", "The owner of this review task is also the owner of the document. Change the owner of this review task.") :-
    base_documentCheckedReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/owner", Owner),
    field(ReviewTask, "base/fieldTypes/owner", Owner).

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document approver", "The owner of a review task is also the approver of this document. Change the owner of the review task or the approver of this document.") :-
    base_documentCheckedReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/approver", Approver),
    field(ReviewTask, "base/fieldTypes/owner", Approver).

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document approver", "The owner of this review task is also the approver of the document. Change the owner of this review task or the approver of the document.") :-
    base_documentCheckedReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/approver", Approver),
    field(ReviewTask, "base/fieldTypes/owner", Approver).
