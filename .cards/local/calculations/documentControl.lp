transitionDenied(Card, "Review as OK", "Fix policy failures before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    policyCheckFailure(Card, _, _, _).

transitionDenied(Card, "Review as OK", "Fill in the owner field before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/owner", _).

transitionDenied(Card, "Review as OK", "Fill in the information classification field before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/informationClassification", _).

transitionDenied(Card, "Approve", "Fill in the approval date field before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/approvalDate", _).

transitionDenied(Card, "Review as OK", "Complete review task(s) before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Card),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    not field(ReviewTask, "workflowState", "Closed as done").

transitionDenied(Card, "Review as OK", "Fix policy failures in review task(s) before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Card),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    policyCheckFailure(ReviewTask, _, _, _).

transitionDenied(Card, "Approve", "Fix policy failures before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    policyCheckFailure(Card, _, _, _).

transitionDenied(Card, "Approve", "Fill in the approver field before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/approver", _).

transitionDenied(Card, "Approve", "Fill in the approval date field before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/approvalDate", _).

editingContentDenied(Card, "You can't edit approved documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Approved").

editingContentDenied(Card, "You cannot edit reviewed documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Reviewed").

editingContentDenied(Card, "You cannot edit archived documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Archived").

transitionDenied(Card, "Start progress", "Fill in the owner field before starting progess" ):-
    field(Card, "cardType", "base/cardTypes/reviewTask"),
    not field(Card, "base/fieldTypes/owner", _).

transitionDenied(Card, "Done", "Fill in the owner field before completing the task" ):-
    field(Card, "cardType", "base/cardTypes/reviewTask"),
    not field(Card, "base/fieldTypes/owner", _).

policyCheckFailure(Document, "ISMS", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(ReviewTask, "ISMS", "Reviewer cannot be the same as document owner", "The owner of a review task is also the owner of this document. Change the owner of the review task.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(Document, "ISMS", "Reviewer cannot be the same as document approver", "The owner of a review task is also the approver for this document. Change the owner of the review task or the approver of this document.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/approver", DocumentApprover),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentApprover = Reviewer.

policyCheckFailure(ReviewTask, "ISMS", "Reviewer cannot be the same as document approver", "The owner of a review task is also the approver of this document. Change the owner of the review task or the approver of this document.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "cardType", "base/cardTypes/reviewTask"),
    field(Document, "base/fieldTypes/approver", DocumentApprover),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentApprover = Reviewer.