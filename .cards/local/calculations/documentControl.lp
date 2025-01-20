transitionDenied(Card, "Review as OK", "Fix policy failures before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    policyCheckFailure(Card, _, _, _).

transitionDenied(Card, "Review as OK", "Complete Annual review task before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    field(ReviewTask, "base/fieldTypes/identifier", "subtaskAnnualReview"),
    not field(ReviewTask, "workflowState", "Closed as done").

transitionDenied(Card, "Review as OK", "Fix policy failures in Annual review task before reviewing as OK" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    parent(ReviewTask, Document),
    field(ReviewTask, "base/fieldTypes/identifier", "subtaskAnnualReview"),
    policyCheckFailure(ReviewTask, _, _, _).

transitionDenied(Card, "Approve", "Fix policy failures before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    policyCheckFailure(Card, _, _, _).

transitionDenied(Card, "Approve", "Fill in approver before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/approver", _).

transitionDenied(Card, "Approve", "Fill in approval date before approving" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    not field(Card, "base/fieldTypes/approvalDate", _).

editingContentDenied(Card, "You can't edit approved documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Approved").

editingContentDenied(Card, "You can't edit reviewed documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Reviewed").

editingContentDenied(Card, "You can't edit archived documents" ):-
    field(Card, "cardType", "base/cardTypes/controlledDocument"),
    field(Card, "workflowState", "Archived").

policyCheckFailure(Document, "ISMS", "Reviewer cannot be the same as document owner", "Owner of the Annual review task equals owner for this document. Change the owner of the Annual review.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "base/fieldTypes/identifier", "subtaskAnnualReview"),
    field(Document, "base/fieldTypes/owner", DocumentOwner),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentOwner = Reviewer.

policyCheckFailure(Document, "ISMS", "Reviewer cannot be the same as document approver", "Owner of the Annual review task equals approver for this document. Change the owner of the Annual review or approver of this document.") :-
    card(Document),
    field(Document, "cardType", "base/cardTypes/controlledDocument"),
    card(ReviewTask),
    parent(ReviewTask, Document),
    field(ReviewTask, "base/fieldTypes/identifier", "subtaskAnnualReview"),
    field(Document, "base/fieldTypes/approver", DocumentApprover),
    field(ReviewTask, "base/fieldTypes/owner", Reviewer),
    DocumentApprover = Reviewer.