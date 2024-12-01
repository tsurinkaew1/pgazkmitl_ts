% IEEE 14-BUS TEST SYSTEM 
% Load Flow Analysis of IEEE 14-Bus System
% 1 - Slack Bus..
% 2 - PV Bus..
% 0 - PQ Bus..

% Bus Data 
%        Bus Bus  Voltage Angle   ---Load---- -------Generator----- Static Mvar
%        No  code Mag.    Degree  MW    Mvar  MW  Mvar Qmin Qmax     +Qc/-Ql
bus.con = [
    1	1	1.06	0	 0	     0    232.4	 -16.9	10	  50	    0;   % Slack Bus
    2	2	1.045	0	21.7	12.7   40	  42.4	50	 -40	    0;   % PV Bus
    3	2	1.01	0	94.2	19	    0	  23.4	40	   0	    0;   % PV Bus
    4	0	1	    0	47.8	-3.9	0	   0	  0	   0	    0;   % PQ Bus
    5	0	1   	0	 7.6	 1.6	0	   0	  0	   0	    0;   % PQ Bus
    6	2	1.07	0	11.2	 7.5	0	  12.2	24    -6	    0;   % PV Bus
    7	0	1	    0	 0	     0	    0	   0	  0	   0	    0;   % PQ Bus
    8	2	1.09	0	 0	     0	    0	  17.4	24    -6	    0;   % PV Bus
    9	0	1	    0	29.5	16.6	0	   0	  0	   0	    19;  % PQ Bus
    10	0	1   	0	 9	     5.8	0	   0	  0	   0	     0;  % PQ Bus
    11	0	1	    0	 3.5 	 1.8	0	   0	  0	   0	     0;  % PQ Bus
    12	0	1	    0	 6.1	 1.6	0	   0	  0	   0	     0;  % PQ Bus
    13	0	1       0	13.5	 5.8	0	   0	  0	   0	     0;  % PQ Bus
    14	0	1	    0	14.9	 5	    0	   0	  0	   0	     0;  % PQ Bus
];

% Line Data 
%         Bus bus   R      X     1/2 B   = 1 for lines
%         nl  nr  p.u.   p.u.   p.u.     > 1 or < 1 tr. tap at bus nl
line.con = [
    1	2	0.01938	0.05917	0.0264	1;   % Line 1-2
    1	5	0.05403	0.22304	0.0246	1;   % Line 1-5
    2	3	0.04699	0.19797	0.0219	1;   % Line 2-3
    2	4	0.05811	0.17632	0.0170	1;   % Line 2-4
    2	5	0.05695	0.17388	0.0173	1;   % Line 2-5
    3	4	0.06701	0.17103	0.0064	1;   % Line 3-4
    4	5	0.01335	0.04211	0	    1;   % Line 4-5
    4	7	0	    0.20912	0	    0.978; % Line 4-7
    4	9	0	    0.55618	0	    0.969; % Line 4-9
    5	6	0	    0.25202	0	    0.932; % Line 5-6
    6	11	0.09498	0.19890	0	    1;   % Line 6-11
    6	12	0.12291	0.25581	0	    1;   % Line 6-12
    6	13	0.06615	0.13027	0	    1;   % Line 6-13
    7	8	0	    0.17615	0	    1;   % Line 7-8
    7	9	0	    0.11001	0	    1;   % Line 7-9
    9	10	0.03181	0.08450	0	    1;   % Line 9-10
    9	14	0.12711	0.27038	0	    1;   % Line 9-14
    10	11	0.08205	0.19207	0	    1;   % Line 10-11
    12	13	0.22092	0.19988	0	    1;   % Line 12-13
    13	14	0.17093	0.34802	0	    1;   % Line 13-14
];
