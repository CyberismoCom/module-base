%* Assertion tests for the module documentation
(base/calculations/moduleDocumentation)

Run from the project root, once in each context:

    cyberismo calc run tests/module-documentation.lp -c localApp
    cyberismo calc run tests/module-documentation.lp -c exportedSite
    cyberismo calc run tests/module-documentation.lp -c exportedDocument

The tests pass when "results" is empty. Each result is one failed assertion.
The tests use the top-level cards "Base module" (the documentation) and "Test
content".
*%

base_test_exportContext :- exportedSite.
base_test_exportContext :- exportedDocument.

% Bind the expectations to the top-level cards

base_test_root("documentation", Card) :-
    projectCard(Card),
    not parent(Card, _),
    field(Card, "title", "Base module").

base_test_root("test content", Card) :-
    projectCard(Card),
    not parent(Card, _),
    field(Card, "title", "Test content").

base_test_expected("documentation"; "test content").

base_test_inTree(Root, Root) :- base_test_root(_, Root).
base_test_inTree(Root, Card) :- base_test_root(_, Root), ancestor(Card, Root).

base_test_documentation(Card) :-
    base_test_root("documentation", Root),
    base_test_inTree(Root, Card).

base_test_testContent(Card) :-
    base_test_root("test content", Root),
    base_test_inTree(Root, Card).

% Assertions

base_test_failure(Name, "missing") :-
    base_test_expected(Name),
    not base_test_root(Name, _).

base_test_failure(Card, "test content root has no label test-content") :-
    base_test_root("test content", Card),
    not base_testContent(Card).

% In an export, the test content and all its descendants are hidden
base_test_failure(Card, "test content not hidden in an export") :-
    base_test_exportContext,
    base_test_testContent(Card),
    not hiddenInTreeView(Card).

% In the app and on the command line, the test content root is shown
base_test_failure(Card, "test content hidden in the app") :-
    not base_test_exportContext,
    base_test_root("test content", Card),
    hiddenInTreeView(Card).

% The documentation is shown in every context. Checklist items are hidden in
% every context by base/calculations/checklist, so they are not checked here.
base_test_failure(Card, "documentation card hidden") :-
    base_test_documentation(Card),
    hiddenInTreeView(Card),
    not base_projectCardType(Card, "base/cardTypes/checklistItem").

% The documentation does not link to the test content
base_test_failure(Card, "documentation links to test content") :-
    base_test_documentation(Card),
    base_test_testContent(Other),
    link(Card, Other, _).

base_test_failure(Card, "documentation links to test content") :-
    base_test_documentation(Card),
    base_test_testContent(Other),
    link(Card, Other, _, _).

result((Subject, Reason)) :- base_test_failure(Subject, Reason).
