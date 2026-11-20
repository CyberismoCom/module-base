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

% The review tasks of a document. A review task that is closed as not
% applicable does not count. The rules over the review tasks below need at
% least one review task.
base_documentReview(Document, ReviewTask) :-
    base_document(Document),
    parent(ReviewTask, Document),
    base_projectCardType(ReviewTask, "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as not applicable").

base_documentHasReview(Document) :-
    base_documentReview(Document, _).

% A review that is closed as done and has a review date.
base_documentDoneReview(Document, ReviewTask, LastReviewed) :-
    base_documentReview(Document, ReviewTask),
    field(ReviewTask, "workflowState", "Closed as done"),
    field(ReviewTask, "base/fieldTypes/lastReviewed", LastReviewed).

base_documentReviewed(Document) :-
    base_documentDoneReview(Document, _, _).

% A draft that was reopened. A new draft has no transitions.
base_documentReopened(Document, Reopened) :-
    base_document(Document),
    field(Document, "workflowState", "Draft"),
    field(Document, "lastTransitioned", Reopened).

% A review that counts for the next approval: for a new draft any done review,
% and for a reopened draft a review done on or after the day it was reopened.
base_documentCurrentReview(Document) :-
    base_documentDoneReview(Document, _, _),
    not base_documentReopened(Document, _).

base_documentCurrentReview(Document) :-
    base_documentDoneReview(Document, _, LastReviewed),
    base_documentReopened(Document, Reopened),
    @daysSince(LastReviewed) <= @daysSince(Reopened).

% Approval

transitionDenied(Document, "Approve", "Add a review task before approving") :-
    base_document(Document),
    not base_documentHasReview(Document).

transitionDenied(Document, "Approve", "Complete the review task(s) before approving") :-
    base_documentReview(Document, ReviewTask),
    not field(ReviewTask, "workflowState", "Closed as done").

transitionDenied(Document, "Approve", "Complete a new review after reopening the document") :-
    base_documentReopened(Document, _),
    base_documentReviewed(Document),
    not base_documentCurrentReview(Document).

transitionDenied(Document, "Approve", "Fix policy failures before approving") :-
    base_document(Document),
    base_policyCheckFailure(Document, _, _, _).

transitionDenied(Document, "Approve", "Fix the policy failures of the review tasks before approving") :-
    base_documentReview(Document, ReviewTask),
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
    base_document(Document),
    field(Document, "workflowState", "Approved").

base_documentLocked(Document, "You cannot edit archived documents") :-
    base_document(Document),
    field(Document, "workflowState", "Archived").

editingContentDenied(Document, Message) :-
    base_documentLocked(Document, Message).

editingFieldDenied(Document, "title", Message) :-
    base_documentLocked(Document, Message).

editingFieldDenied(Document, Field, Message) :-
    base_documentLocked(Document, Message),
    base_projectCardType(Document, CardType),
    customField(CardType, Field).

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
    base_documentReview(Document, ReviewTask),
    field(Document, "workflowState", "Approved"),
    not field(ReviewTask, "workflowState", "Closed as done").

policyCheckFailure(Document, "Document control", "Failing policy checks in a review task", "Fix the policy failures of the review tasks.") :-
    base_documentReview(Document, ReviewTask),
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

% Separation of duties. The check fails on the document and on the review task.

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    base_documentReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/owner", Owner),
    field(ReviewTask, "base/fieldTypes/owner", Owner).

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document owner", "The owner of this review task is also the owner of the document. Change the owner of this review task.") :-
    base_documentReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/owner", Owner),
    field(ReviewTask, "base/fieldTypes/owner", Owner).

policyCheckFailure(Document, "Document control", "Reviewer cannot be the same as document approver", "The owner of a review task is also the approver of this document. Change the owner of the review task or the approver of this document.") :-
    base_documentReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/approver", Approver),
    field(ReviewTask, "base/fieldTypes/owner", Approver).

policyCheckFailure(ReviewTask, "Document control", "Reviewer cannot be the same as document approver", "The owner of this review task is also the approver of the document. Change the owner of this review task or the approver of the document.") :-
    base_documentReview(Document, ReviewTask),
    field(Document, "base/fieldTypes/approver", Approver),
    field(ReviewTask, "base/fieldTypes/owner", Approver).
