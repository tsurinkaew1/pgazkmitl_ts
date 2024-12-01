% IEEE 4-BUS TEST SYSTEM 
%   Load Flow Analysis of IEEE 4-Bus System
% 1 - Slack Bus..
% 2 - PV Bus..
% 0 - PQ Bus..

% Bus Data 
%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax    +Qc/-Ql
bus.con = [
    1   1   1.04    0.0     0.0     0.0     80.0  30.0  10   50     0;   % Slack Bus
    2   2   1.02    0.0    50.0   -20.0     40.0  20.0  10   40     0;   % PV Bus
    3   0   1.00    0.0   100.0    50.0      0.0   0.0   0    0     0;   % PQ Bus
    4   0   1.00    0.0    30.0   -10.0      0.0   0.0   0    0     0;   % PQ Bus
];

% Line Data 
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
line.con = [
    1   2   0.02   0.06   0.03    1.0;   % Line 1-2 (ลด R, X ให้เหมาะสม)
    1   3   0.08   0.24   0.025   1.0;   % Line 1-3
    2   3   0.06   0.18   0.02    1.0;   % Line 2-3
    2   4   0.04   0.12   0.015   1.0;   % Line 2-4
    3   4   0.03   0.09   0.01    1.0;   % Line 3-4
];

