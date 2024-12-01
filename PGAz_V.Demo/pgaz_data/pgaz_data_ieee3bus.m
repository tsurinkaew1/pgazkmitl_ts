% Load Flow Analysis of IEEE 3-Bus System
% 1 - Slack Bus..
% 2 - PV Bus..
% 0 - PQ Bus..

% Bus Data 
%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax    +Qc/-Ql
% ------------------------------------------------------------------------------------------------------
bus.con = [
    1   1   1.05    0.0     0.0     0.0     0.0  0.0   0   0   0;  % Slack Bus
    2   2   1.0     0.0   256.6   110.2    40.0  0.0   10  40  0;  % PV Bus
    3   0   1.0     0.0   138.6    45.2     0.0  0.0   0   0   0;  % PQ Bus
];

% Line Data 
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
% ------------------------------------------------------------------------------------------------------
line.con = [
    1   2   0.02    0.04   0.00    1.0;  % Line 1-2
    1   3   0.01    0.03   0.00    1.0;  % Line 1-3
    2   3   0.0125  0.025  0.00    1.0;  % Line 2-3
];

