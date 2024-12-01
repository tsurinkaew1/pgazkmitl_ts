% IEEE 9-BUS TEST SYSTEM 
% Load Flow Analysis of IEEE 9-Bus System
% 1 - Slack Bus..
% 2 - PV Bus..
% 0 - PQ Bus..

% Bus Data 
%        Bus Bus   Voltage  Angle   ---Load---- -------Generator----- Static Mvar
%        No  code   Mag.    Degree  MW    Mvar  MW  Mvar   Qmin Qmax    +Qc/-Ql
bus.con = [
    1     1    1.040     0      0     0     71.64  27.05   -99   99       0;   % Slack Bus
    2     2    1.025     0      0     0    163.00   6.70   -99   99       0;   % PV Bus
    3     2    1.025     0      0     0     85.00 -10.90     0   99       0;   % PV Bus
    4     0    1.000     0      0     0      0      0        0    0       0;   % PQ Bus
    5     0    1.000     0    125    50      0      0        0    0       0;   % PQ Bus
    6     0    1.000     0     90    30      0      0        0    0       0;   % PQ Bus
    7     0    1.000     0      0     0      0      0        0    0       0;   % PQ Bus
    8     0    1.000     0    100    35      0      0        0    0       0;   % PQ Bus
    9     0    1.000     0      0     0      0      0        0    0       0;   % PQ Bus
];

% Line Data 
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
line.con = [
    1    4   0.0000   0.05760    0.0000         1;   % Line 1-4
    4    5   0.0100   0.08500    0.0880         1;   % Line 4-5
    4    6   0.0170   0.09200    0.0790         1;   % Line 4-6
    6    9   0.0390   0.17000    0.0179         1;   % Line 6-9
    5    7   0.0320   0.16100    0.0153         1;   % Line 5-7
    9    3   0.0000   0.05860    0.0000         1;   % Line 9-3
    7    2   0.0000   0.06250    0.0000         1;   % Line 7-2
    9    8   0.0119   0.10080    0.1045         1;   % Line 9-8
    7    8   0.0085   0.07200    0.0745         1;   % Line 7-8
];

