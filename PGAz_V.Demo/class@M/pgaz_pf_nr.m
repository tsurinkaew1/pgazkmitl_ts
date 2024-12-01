function pgaz_pf_nr()

    busdata = evalin('base', 'busdata');
    linedata = evalin('base', 'linedata');
    nbus = length(busdata(:,1));
    nbr = length(linedata(:,1));
    basemva = evalin('base', 'basemva');
    accuracy = evalin('base', 'accuracy');
    accel = evalin('base', 'accel');
    maxiter = evalin('base', 'maxiter');

    pgaz_y
    pgaz_nr

    num_generators = 0;
    num_loads = 0;
    num_transformers = 0;

    for k = 1:nbus
        n = busdata(k,1);
        kb(n) = busdata(k,2);       
        Pd(n) = busdata(k,5);       
        Qd(n) = busdata(k,6);       
        Pg(n) = busdata(k,7);       
        Qg(n) = busdata(k,8);       

        if Pg(n) ~= 0 || Qg(n) ~= 0
            num_generators = num_generators + 1;
        end
      
        if Pd(n) ~= 0 || Qd(n) ~= 0
            num_loads = num_loads + 1;
        end
    end

    for i = 1:nbr
        if linedata(i, 6) ~= 1 
            num_transformers = num_transformers + 1;
        end
    end

    if evalin('base', 'exist(''LocationImportData'', ''var'')')
        LocationImportData = evalin('base', 'LocationImportData');
    else
        LocationImportData = '';
    end

    if evalin('base', 'exist(''itersolve'', ''var'')')
        itersolve = evalin('base', 'itersolve');
    else
        itersolve = '';
    end
    
    if evalin('base', 'exist(''total_times'', ''var'')')
        total_times = evalin('base', 'total_times');
    else
        total_times = '';
    end

    fprintf('POWER FLOW REPORT\n'); 
    fprintf('\nP G A z v 1.0.0 a\n\n');   
    fprintf('Power Flow Solution by Newton Raphson Method\n\n');
    fprintf('File:  %s\n',LocationImportData);
    fprintf('Date:  %s\n\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'));
    fprintf('NETWORK STATISTICS\n\n');
    fprintf('Bus:                               %d\n',nbus);
    fprintf('Lines:                             %d\n',nbr);
    fprintf('Transformers:                      %d\n',num_transformers);
    fprintf('Generators:                        %g\n', num_generators);
    fprintf('Loads:                             %d\n\n',num_loads);
    fprintf('SOLUTION STATISTICS\n\n')
    fprintf('Number of Iterations:              %.4g\n', itersolve);
    fprintf('Computational time:                %.4f\n', total_times);
    fprintf('Maximum Power Mismatch:            %g\n', maxerror);
    fprintf('Power rate [MVA]:                  100\n\n');

    outputStringStats = sprintf('NETWORK STATISTICS\n\n');
    outputStringStats = [outputStringStats sprintf('Bus:   %d\n', nbus)];
    outputStringStats = [outputStringStats sprintf('Lines:   %d\n', nbr)];
    outputStringStats = [outputStringStats sprintf('Transformers:   %d\n', num_transformers)];
    outputStringStats = [outputStringStats sprintf('Generators:   %g\n', num_generators)];
    outputStringStats = [outputStringStats sprintf('Loads:   %d\n\n', num_loads)];
    outputStringStats = [outputStringStats sprintf('SOLUTION STATISTICS\n\n')];
    outputStringStats = [outputStringStats sprintf('Number of Iterations:   %.4g\n', itersolve)];
    outputStringStats = [outputStringStats sprintf('Computational time:   %.4f\n', total_times)];
    outputStringStats = [outputStringStats sprintf('Maximum Power Mismatch:   %g\n', maxerror)];
    outputStringStats = [outputStringStats sprintf('Power rate [MVA]:   100\n\n')];

    assignin('base', 'NetworkSolutionStatsChar', outputStringStats);

    fprintf('POWER FLOW RESULTS\n\n');
    head = ['Bus            V               phase           P gen           Q gen           Injected        P load          Q load '
            '               [Mag.]          [Degree]        [MW]            [Mvar]          [Mvar]          [MW]            [Mvar] '];
    disp(head)
    fprintf('\n')

    n_values = cell(1, nbus);  
    maxBusNumberLength = 4; 
    Vm_values = zeros(1, nbus);  % Preallocate an array to store Vm values
    deltad_values = zeros(1, nbus);  % Preallocate an array to store deltad values
    Pg_values = zeros(1, nbus);
    Qg_values = zeros(1, nbus);
    Qsh_values = zeros(1, nbus);
    Qd_values = zeros(1, nbus);
    Pd_values = zeros(1, nbus);

    for n = 1:nbus
    
        Vm_values(n) = round(Vm(n), 3);
        deltad_values(n) = round(deltad(n), 3);
        Pg_values(n) = round(Pg(n), 3);
        Pd_values(n) = round(Pd(n), 3);
        Qg_values(n) = round(Qg(n), 3);
        Qsh_values(n) = round(Qsh(n), 3);
        Qd_values(n) = round(Qd(n), 3);
  
        format_value = @(value) sprintf('% .3f', value);
    
        if n < 10
            busLabel = sprintf('  [%d]  ', n);  % ช่องว่าง 1 ตัวสำหรับหมายเลข 1 ถึง 9
        else
            busLabel = sprintf('[%d]  ', n);   % ไม่มีช่องว่างสำหรับหมายเลข 10 ขึ้นไป
        end
        
        formatted_value = sprintf('%s %s', busLabel, format_value(Vm_values(n)));
        deltadformatted_value = sprintf('%s %s', busLabel, format_value(deltad_values(n)));
        Pg_value = sprintf('%s %s', busLabel, format_value(Pg_values(n)));
        Pd_value = sprintf('%s %s', busLabel, format_value(Pd_values(n)));
        Qg_value = sprintf('%s %s', busLabel, format_value(Qg_values(n)));
        Qsh_value = sprintf('%s %s', busLabel, format_value(Qsh_values(n)));
        Qd_value = sprintf('%s %s', busLabel, format_value(Qd_values(n)));
   
        n_values{n} = [busLabel ' Bus ' num2str(n)];
        
        Vm_values_formatted{n} = formatted_value;
        deltad_values_formatted{n} = deltadformatted_value;
        Pg_values_formatted{n} = Pg_value;
        Pd_values_formatted{n} = Pd_value;
        Qg_values_formatted{n} = Qg_value;
        Qsh_values_formatted{n} = Qsh_value;
        Qd_values_formatted{n} = Qd_value;
    
        fprintf('Bus %2g', n), fprintf('  %13s', format_value(Vm(n))),
        fprintf(' %15s', format_value(deltad(n))), fprintf(' %15s', format_value(Pg(n))),
        fprintf(' %15s', format_value(Qg(n))),  fprintf(' %15s', format_value(Qsh(n))),
        fprintf(' %15s', format_value(Pd(n))), fprintf(' %15s\n', format_value(Qd(n)))
    end

    assignin('base', 'n_values', n_values);  
    assignin('base', 'deltad_formatted', deltad_values_formatted); 
    assignin('base', 'Vm_values_formatted', Vm_values_formatted);
    assignin('base', 'Pg_values_formatted', Pg_values_formatted);
    assignin('base', 'Pd_values_formatted', Pd_values_formatted);
    assignin('base', 'Qg_values_formatted', Qg_values_formatted);
    assignin('base', 'Qsh_values_formatted', Qsh_values_formatted);
    assignin('base', 'Qd_values_formatted', Qd_values_formatted);
    
    SLT = 0;
    fprintf('\n')
    fprintf('LINE FLOWS\n\n');
    fprintf('From Bus       To Bus          P Flow          Q Flow          S Flow          P Loss          Q Loss          Transformer\n')
    fprintf('                               [MW]            [Mvar]          [MVA]           [MW]            [Mvar]              tap\n    ')
    for n = 1:nbus
    busprt = 0;
       for L = 1:nbr
           if busprt == 0
           fprintf('   \n'), fprintf('Bus %2g', n), fprintf('      %26.3f', P(n)*basemva)
           fprintf('%15.3f', Q(n)*basemva), fprintf('%17.3f\n', abs(S(n)*basemva))
    
           busprt = 1;
           end
           if nl(L)==n      
               k = nr(L);
               In = (V(n) - a(L)*V(k))*y(L)/a(L)^2 + Bc(L)/a(L)^2*V(n);
               Ik = (V(k) - V(n)/a(L))*y(L) + Bc(L)*V(k);
           elseif nr(L)==n  
               k = nl(L);
               In = (V(n) - V(k)/a(L))*y(L) + Bc(L)*V(n);
               Ik = (V(k) - a(L)*V(n))*y(L)/a(L)^2 + Bc(L)/a(L)^2*V(k);
           else
               continue
           end
           Snk = V(n)*conj(In)*basemva;
           Skn = V(k)*conj(Ik)*basemva;
           SL  = Snk + Skn;
           SLT = SLT + SL;

           fprintf('Bus %2g', n);
           fprintf('         Bus %2g', k),
           fprintf('%17.3f', real(Snk)), fprintf('%15.3f', imag(Snk))
           fprintf('%17.3f', abs(Snk)),
           fprintf('%15.3f', real(SL)),
           if nl(L) == n && a(L) ~= 1
               fprintf('%16.3f', imag(SL)), fprintf('%16.3f\n', a(L))
           else
               fprintf('%16.3f\n', imag(SL))
           end
           
       end
    end

    SLT = SLT / 2;
    
    fprintf('\n')
    fprintf('GLOBAL SUMMARY REPORT\n');
    fprintf('\nTOTAL GENERATION\n\n');
    fprintf('REAL POWER [MW]                %9.3f\n', Pgt);
    fprintf('REACTIVE POWER [Mvar]          %9.3f\n', Qgt);
    fprintf('INJECTED [Mvar]                %9.3f\n\n', Qsht);
    
    assignin('base', 'Pgt', Pgt);
    assignin('base', 'Qgt', Qgt);
    assignin('base', 'Qsht', Qsht);
    
    fprintf('TOTAL LOAD\n\n');
    fprintf('REAL POWER [MW]                %9.3f\n', Pdt);
    fprintf('REACTIVE POWER [Mvar]          %9.3f\n\n', Qdt);
    
    assignin('base', 'Pdt', Pdt);
    assignin('base', 'Qdt', Qdt);
    
    fprintf('TOTAL LOSSES\n\n');
    fprintf('REAL POWER [MW]                %9.3f\n', real(SLT));
    fprintf('REACTIVE POWER [Mvar]          %9.3f\n\n', imag(SLT));

    assignin('base', 'SLT_real', real(SLT));
    assignin('base', 'SLT_imag', imag(SLT));

    outputString = sprintf('TOTAL GENERATION\n\n');
    outputString = [outputString sprintf('REAL POWER [MW]:   %9.3f\n', Pgt)];
    outputString = [outputString sprintf('REACTIVE POWER [Mvar]:   %9.3f\n', Qgt)];
    outputString = [outputString sprintf('INJECTED [Mvar]:   %9.3f\n', Qsht)];
    
    outputString = [outputString sprintf('\nTOTAL LOAD\n\n')];
    outputString = [outputString sprintf('REAL POWER [MW]:   %9.3f\n', Pdt)];
    outputString = [outputString sprintf('REACTIVE POWER [Mvar]:   %9.3f\n\n', Qdt)];
    
    outputString = [outputString sprintf('TOTAL LOSSES\n\n')];
    outputString = [outputString sprintf('REAL POWER [MW]:   %9.3f\n', real(SLT))];
    outputString = [outputString sprintf('REACTIVE POWER [Mvar]:   %9.3f\n\n', imag(SLT))];
    
    assignin('base', 'PowerFlowResultsChar', outputString);

    report = sprintf('   POWER FLOW REPORT\n');
    report = [report, sprintf('   P G A z v 1.0.0 a\n\n')];
    report = [report, sprintf('   Power Flow Solution by Newton Raphson Method\n')];
    report = [report, sprintf('   File:   %s\n', LocationImportData)];
    report = [report, sprintf('   Date:   %s\n', datestr(now, 'dd-mmm-yyyy HH:MM:SS'))];
    report = [report, sprintf('\n   NETWORK STATISTICS\n\n')];
    report = [report, sprintf('   Bus:   %g\n',nbus)];
    report = [report, sprintf('   Lines:   %g\n',nbr)];
    report = [report, sprintf('   Transformers:   %g\n',num_transformers)];
    report = [report, sprintf('   Generators:   %g\n', num_generators)];
    report = [report, sprintf('   Loads:   %g\n\n',num_loads)];
    report = [report, sprintf('   SOLUTION STATISTICS\n\n')];
    report = [report, sprintf('   Number of Iterations:   %1.4g\n', itersolve)];
    report = [report, sprintf('   Computational time:   %1.4f\n', total_times)];
    report = [report, sprintf('   Maximum Power Mismatch:   %g\n', maxerror)];
    report = [report, sprintf('   Power rate [MVA]:   100\n\n')];

    assignin('base', 'PowerFlowReportcomman', report);
    assignin('base', 'maxerror', maxerror);
    
    NetSolBoxHandle = findobj('Tag', 'NetSolBox');
        if ~isempty(NetSolBoxHandle)
            set(NetSolBoxHandle, 'String', report);
        else
            disp('NetSolBox not found.');
        end

        clear Ik In SL SLT Skn Snk
    end
