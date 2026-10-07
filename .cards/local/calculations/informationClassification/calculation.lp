% Information classification is inherited down the card tree.
%
% A card type that declares the field calculated and overridable takes the
% classification of its parent card. A value entered on a card becomes a
% fieldOverride, which wins over this rule and is in turn inherited by that
% card's descendants: setting the classification anywhere reclassifies the
% whole branch below it.
%
% The chain has to start somewhere. A project's top-level card carries an
% explicit classification, either because its card type declares the field as
% a plain (non-calculated) field, or because a value was entered on it.

fieldCalculated(Card, "base/fieldTypes/informationClassification", Classification) :-
    projectCard(Card),
    parent(Card, Parent),
    field(Parent, "base/fieldTypes/informationClassification", Classification).
