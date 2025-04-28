% Copyright © Cyberismo Ltd and contributors 2025
%
% License: https://github.com/CyberismoCom/module-base/blob/main/LICENSE
% The use of the Cyberismo trademark: https://cyberismo.com/trademark-policy/
% This content is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE.

field(Card, "statusIndicator", "error") :-
    base_policyCheckFailure(Card, _, _, _),
    not base_disableDefaultStatusIndicator.

field(Card, "statusIndicator", StatusIndicator) :-
    not base_policyCheckFailure(Card, _, _, _),
    not field(Card, "progress", _),
    workflowState(Workflow, State, StatusIndicator),
    field(Card, "cardType", CardType),
    field(Card, "workflowState", State),
    field(CardType, "workflow", Workflow),
    not base_disableDefaultStatusIndicator.