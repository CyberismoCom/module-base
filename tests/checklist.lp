%* Assertion tests for the checklist predicates (base/calculations/checklist)

Run from the project root:

    cyberismo calc run tests/checklist.lp

The tests pass when "results" is empty. Each result is one failed assertion.
The fixtures are under "Test content" > "Checklist tests".
*%

% Checklists: base_test_expectChecklist(Title, Result, Complete).
% Title is the title of a child card of the "Checklist tests" page.
base_test_expectChecklist("All items OK", "ok", "yes").
base_test_expectChecklist("OK and not applicable", "ok", "yes").
base_test_expectChecklist("All items not applicable", "notApplicable", "yes").
base_test_expectChecklist("Open items", "open", "no").
base_test_expectChecklist("Not applicable without a comment", "open", "no").
base_test_expectChecklist("Deviation and an open item", "deviation", "no").
base_test_expectChecklist("Complete with a deviation", "deviation", "yes").
base_test_expectChecklist("Deviation without a comment", "deviation", "no").
base_test_expectChecklist("Archived item", "ok", "yes").
% Reviews that passed
base_test_expectChecklist("Passed with a deviation", "deviation", "yes").
base_test_expectChecklist("Passed, then an item reopened", "open", "no").
% An instance of base/templates/checklist, where all items are open
base_test_expectChecklist("Checklist", "open", "no").

% Item counts: base_test_expectCount(Title, Result, Count).
base_test_expectCount("Open items", "open", 2).
base_test_expectCount("Open items", "ok", 1).
base_test_expectCount("Open items", "deviation", 0).
base_test_expectCount("Open items", "notApplicable", 0).
base_test_expectCount("Archived item", "ok", 1).
base_test_expectCount("Archived item", "deviation", 0).
base_test_expectCount("Checklist", "open", 4).

% Items: base_test_expectItem(Identifier, Result, Complete, PolicyFailure, StatusIndicator).
base_test_expectItem("base_test_cl_ok_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_ok_2", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_okna_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_okna_2", "notApplicable", "yes", "no", "closed").
base_test_expectItem("base_test_cl_na_1", "notApplicable", "yes", "no", "closed").
base_test_expectItem("base_test_cl_na_2", "notApplicable", "yes", "no", "closed").
base_test_expectItem("base_test_cl_open_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_open_2", "open", "no", "no", "initial").
base_test_expectItem("base_test_cl_open_3", "open", "no", "no", "initial").
base_test_expectItem("base_test_cl_nanc_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_nanc_2", "notApplicable", "no", "yes", "error").
base_test_expectItem("base_test_cl_devopen_1", "deviation", "yes", "no", "active").
base_test_expectItem("base_test_cl_devopen_2", "open", "no", "no", "initial").
base_test_expectItem("base_test_cl_dev_1", "deviation", "yes", "no", "active").
base_test_expectItem("base_test_cl_dev_2", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_devnc_1", "deviation", "no", "yes", "error").
base_test_expectItem("base_test_cl_devnc_2", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_arch_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_pdev_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_pdev_2", "deviation", "yes", "no", "active").
base_test_expectItem("base_test_cl_preopen_1", "ok", "yes", "no", "closed").
base_test_expectItem("base_test_cl_preopen_2", "open", "no", "no", "initial").

% Items that are not part of a checklist
base_test_expectExcluded("base_test_cl_arch_2").

% Reviews: base_test_expectReview(Title, Progress). A checklist that is a
% review has a progress percentage of complete items. Other checklists have no
% progress.
base_test_expectReview("All items OK", 100).
base_test_expectReview("Open items", 33).
base_test_expectReview("Deviation without a comment", 50).
base_test_expectReview("Passed with a deviation", 100).
base_test_expectReview("Passed, then an item reopened", 50).

% Failures of items that a review shows as its own:
% base_test_expectLifted(Title, ItemIdentifier).
base_test_expectLifted("Deviation without a comment", "base_test_cl_devnc_1").

% Other failures of a review: base_test_expectFailure(Title, FailureTitle).
base_test_expectFailure("Passed, then an item reopened", "Open checklist items after the review passed").

% "Mark as passed": base_test_expectPassDenied(Title, Message) and
% base_test_expectPassAllowed(Title). A review passes only with a complete
% checklist. Deviations do not stop it.
base_test_expectPassDenied("Open items", "Complete the checklist before passing the review: 2 open, 0 comment(s) missing.").
base_test_expectPassDenied("Deviation without a comment", "Complete the checklist before passing the review: 0 open, 1 comment(s) missing.").
base_test_expectPassAllowed("All items OK").

% Notifications: base_test_expectNotification(Title, NotificationTitle).
base_test_expectNotification("Passed with a deviation", "Passed with deviations").

% Bind the expectations to the fixture cards

base_test_page(Page) :-
    projectCard(Page),
    field(Page, "title", "Checklist tests").

base_test_checklist(Title, Card) :-
    base_test_expectChecklist(Title, _, _),
    base_test_page(Page),
    parent(Card, Page),
    field(Card, "title", Title).

base_test_item(Id, Card) :-
    field(Card, "base/fieldTypes/identifier", Id),
    projectCard(Card).

% Checklist assertions

base_test_failure(Title, "missing") :-
    base_test_expectChecklist(Title, _, _),
    not base_test_checklist(Title, _).

base_test_failure(Title, "result") :-
    base_test_checklist(Title, Card),
    base_test_expectChecklist(Title, Expected, _),
    not base_checklistResult(Card, Expected).

base_test_failure(Title, "result count") :-
    base_test_checklist(Title, Card),
    #count { R : base_checklistResult(Card, R) } != 1.

base_test_failure(Title, "complete") :-
    base_test_checklist(Title, Card),
    base_test_expectChecklist(Title, _, "yes"),
    not base_checklistComplete(Card).

base_test_failure(Title, "not complete") :-
    base_test_checklist(Title, Card),
    base_test_expectChecklist(Title, _, "no"),
    base_checklistComplete(Card).

base_test_failure(Title, @concatenate("count ", Result)) :-
    base_test_expectCount(Title, Result, Expected),
    base_test_checklist(Title, Card),
    not base_checklistItemCount(Card, Result, Expected).

% Item assertions

base_test_failure(Id, "missing") :-
    base_test_expectItem(Id, _, _, _, _),
    not base_test_item(Id, _).

base_test_failure(Id, "missing") :-
    base_test_expectExcluded(Id),
    not base_test_item(Id, _).

base_test_failure(Id, "not a checklist item") :-
    base_test_expectItem(Id, _, _, _, _),
    base_test_item(Id, Card),
    not base_checklistItem(Card, _).

base_test_failure(Id, "result") :-
    base_test_expectItem(Id, Expected, _, _, _),
    base_test_item(Id, Card),
    not base_checklistItemResult(Card, Expected).

base_test_failure(Id, "result count") :-
    base_test_expectItem(Id, _, _, _, _),
    base_test_item(Id, Card),
    #count { R : base_checklistItemResult(Card, R) } != 1.

base_test_failure(Id, "complete") :-
    base_test_expectItem(Id, _, "yes", _, _),
    base_test_item(Id, Card),
    not base_checklistItemComplete(Card).

base_test_failure(Id, "not complete") :-
    base_test_expectItem(Id, _, "no", _, _),
    base_test_item(Id, Card),
    base_checklistItemComplete(Card).

base_test_failure(Id, "policy failure") :-
    base_test_expectItem(Id, _, _, "yes", _),
    base_test_item(Id, Card),
    not policyCheckFailure(Card, "Checklist", "Comment missing", _, "base/fieldTypes/comment").

base_test_failure(Id, "no policy failure") :-
    base_test_expectItem(Id, _, _, "no", _),
    base_test_item(Id, Card),
    base_policyCheckFailure(Card, _, _, _).

base_test_failure(Id, "status indicator") :-
    base_test_expectItem(Id, _, _, _, Expected),
    base_test_item(Id, Card),
    not field(Card, "statusIndicator", Expected).

base_test_failure(Id, "status indicator count") :-
    base_test_expectItem(Id, _, _, _, _),
    base_test_item(Id, Card),
    #count { S : field(Card, "statusIndicator", S) } != 1.

base_test_failure(Id, "excluded item is in a checklist") :-
    base_test_expectExcluded(Id),
    base_test_item(Id, Card),
    base_checklistItem(Card, _).

% Review assertions

base_test_failure(Title, "not a review") :-
    base_test_expectReview(Title, _),
    base_test_checklist(Title, Card),
    not base_checklistReview(Card).

base_test_failure(Title, @concatenate("progress is not ", Expected)) :-
    base_test_expectReview(Title, Expected),
    base_test_checklist(Title, Card),
    not field(Card, "progress", Expected).

base_test_failure(Title, "progress count") :-
    base_test_expectReview(Title, _),
    base_test_checklist(Title, Card),
    #count { P : field(Card, "progress", P) } != 1.

base_test_failure(Title, "progress on a checklist that is not a review") :-
    base_test_checklist(Title, Card),
    not base_test_expectReview(Title, _),
    field(Card, "progress", _).

base_test_failure(Title, @concatenate("failure of item not shown: ", Id)) :-
    base_test_expectLifted(Title, Id),
    base_test_checklist(Title, Card),
    base_test_item(Id, Item),
    field(Item, "title", ItemTitle),
    not policyCheckFailure(Card, "Checklist", "Comment missing",
        @concatenate("Checklist item \"", ItemTitle, "\": ",
            "A Deviation or Not applicable result needs a comment. Explain the result in the Comment field.")).

base_test_failure(Title, "status indicator is not error") :-
    base_test_expectLifted(Title, _),
    base_test_checklist(Title, Card),
    not field(Card, "statusIndicator", "error").

base_test_expectedFailureTitle(Title, "Comment missing") :- base_test_expectLifted(Title, _).
base_test_expectedFailureTitle(Title, Failure) :- base_test_expectFailure(Title, Failure).

base_test_failure(Title, @concatenate("unexpected policy check: ", Failure)) :-
    base_test_checklist(Title, Card),
    base_policyCheckFailure(Card, _, Failure, _),
    not base_test_expectedFailureTitle(Title, Failure).

base_test_failure(Title, @concatenate("policy check missing: ", Failure)) :-
    base_test_expectFailure(Title, Failure),
    base_test_checklist(Title, Card),
    not base_policyCheckFailure(Card, "Checklist", Failure, _).

base_test_failure(Title, @concatenate("not denied: ", Message)) :-
    base_test_expectPassDenied(Title, Message),
    base_test_checklist(Title, Card),
    not transitionDenied(Card, "Mark as passed", Message).

base_test_failure(Title, "pass denied") :-
    base_test_expectPassAllowed(Title),
    base_test_checklist(Title, Card),
    transitionDenied(Card, "Mark as passed", _).

base_test_failure(Title, @concatenate("notification missing: ", Notification)) :-
    base_test_expectNotification(Title, Notification),
    base_test_checklist(Title, Card),
    not notification(Card, "Checklist", Notification, _).

base_test_failure(Title, @concatenate("unexpected notification: ", Notification)) :-
    base_test_checklist(Title, Card),
    notification(Card, _, Notification, _),
    not base_test_expectNotification(Title, Notification).

base_test_failure(Title, "not passed") :-
    base_test_expectNotification(Title, _),
    base_test_checklist(Title, Card),
    not field(Card, "workflowState", "Passed").

% The items are hidden in the navigation tree, and the checklists are not

base_test_failure(Id, "not hidden") :-
    base_test_expectItem(Id, _, _, _, _),
    base_test_item(Id, Card),
    not hiddenInTreeView(Card).

base_test_failure(Id, "not hidden") :-
    base_test_expectExcluded(Id),
    base_test_item(Id, Card),
    not hiddenInTreeView(Card).

base_test_failure(Title, "checklist is hidden") :-
    base_test_checklist(Title, Card),
    hiddenInTreeView(Card).

% Negative tests: cards that are not checklists

base_test_failure("Checklist tests", "is a checklist") :-
    base_test_page(Page),
    base_checklist(Page).

base_test_failure(Card, "template card is a checklist") :-
    base_checklist(Card),
    not projectCard(Card).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
