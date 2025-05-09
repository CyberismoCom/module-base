% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-base/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

% a helper term for finding failures regardless of they have a field or not
base_policyCheckFailure(Card, Category, Title, Message) :-
    policyCheckFailure(Card, Category, Title, Message).

base_policyCheckFailure(Card, Category, Title, Message) :-
    policyCheckFailure(Card, Category, Title, Message, Field).
