% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-base/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

onTransitionSetField(Card, "Create", Card, "title", @concatenate(@today(), " Untitled meeting notes")) :-
    field(Card, "cardType", "base/cardTypes/page"),
    field(Card, "title", "Untitled meeting notes").
