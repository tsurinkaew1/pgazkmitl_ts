Vm = 0; delta = 0; yload = 0; deltad = 0;
nbus = length(busdata(:,1)); 

for k = 1:nbus
    n = busdata(k,1);
    kb(n) = busdata(k,2);       
    Vm(n) = busdata(k,3);       
    delta(n) = busdata(k,4);    
    Pd(n) = busdata(k,5);       
    Qd(n) = busdata(k,6);      
    Pg(n) = busdata(k,7);       
    Qg(n) = busdata(k,8);      
    Qmin(n) = busdata(k,9);     
    Qmax(n) = busdata(k,10);    
    Qsh(n) = busdata(k,11);  

    if Vm(n) <= 0
        Vm(n) = 1.0; V(n) = 1 + 1j*0; 
    else
        delta(n) = pi / 180 * delta(n); 
        V(n) = Vm(n) * (cos(delta(n)) + 1j * sin(delta(n))); 
        P(n) = (Pg(n) - Pd(n)) / basemva;
        Q(n) = (Qg(n) - Qd(n) + Qsh(n)) / basemva; 
        S(n) = P(n) + 1j * Q(n); 
    end

    DV(n) = 0; 
end

num = 0; AcurBus = 0; converge = 1;
Vc = zeros(nbus,1) + 1j*zeros(nbus,1); 
Sc = zeros(nbus,1) + 1j*zeros(nbus,1); 

iter = 0;
maxerror = 10;
iteration_times = []; 
acc = [];              

while maxerror >= accuracy && iter <= maxiter
    iter = iter + 1;
    
    tic;  
    
    for n = 1:nbus
        YV = 0 + 1j*0;

        for L = 1:nbr
            if nl(L) == n
                k = nr(L);
                YV = YV + Ybus(n,k) * V(k);
            elseif nr(L) == n
                k = nl(L);
                YV = YV + Ybus(n,k) * V(k);
            end
        end

        Sc = conj(V(n)) * (Ybus(n,n) * V(n) + YV);
        Sc = conj(Sc);
        DP(n) = P(n) - real(Sc);
        DQ(n) = Q(n) - imag(Sc);

        if kb(n) == 1
            S(n) = Sc; 
            P(n) = real(Sc); 
            Q(n) = imag(Sc); 
            DP(n) = 0; 
            DQ(n) = 0;
            Vc(n) = V(n);
        elseif kb(n) == 2
            Q(n) = imag(Sc); 
            S(n) = P(n) + 1j * Q(n);

            if Qmax(n) ~= 0
                Qgc = Q(n) * basemva + Qd(n) - Qsh(n);
                if abs(DQ(n)) <= 0.005 && iter >= 10 
                    if DV(n) <= 0.045 
                        if Qgc < Qmin(n)
                            Vm(n) = Vm(n) + 0.005; 
                            DV(n) = DV(n) + 0.005;
                        elseif Qgc > Qmax(n)
                            Vm(n) = Vm(n) - 0.005; 
                            DV(n) = DV(n) + 0.005;
                        end
                    end
                end
            end
        end

        if kb(n) ~= 1
            Vc(n) = (conj(S(n)) / conj(V(n)) - YV) / Ybus(n,n);
        end

        if kb(n) == 0
            V(n) = V(n) + accel * (Vc(n) - V(n));
        elseif kb(n) == 2
            VcI = imag(Vc(n));
            VcR = sqrt(Vm(n)^2 - VcI^2);
            Vc(n) = VcR + 1j * VcI;
            V(n) = V(n) + accel * (Vc(n) - V(n));
        end
    end

    maxerror = max(max(abs(real(DP))), max(abs(imag(DQ))));
    acc = [acc; maxerror];  

    iteration_time = toc; 
    iteration_times = [iteration_times; iteration_time];      
    if iter == maxiter && maxerror > accuracy
        warningMessage = sprintf(['\nWARNING: Iterative solution did not converge after %g iterations.' ...
                                  '\n\nPress Enter to terminate the iterations and print the results \n'], iter);
        fprintf('%s', warningMessage);
        assignin('base', 'Debug1', warningMessage);
        converge = 0; 
        pause;
    else
        warningMessage = sprintf('');
        assignin('base', 'Debug1', warningMessage);
        converge = 1;
    end
end

total_time = sum(iteration_times); 
assignin('base', 'iter_time', iteration_times);  
assignin('base', 'acc', acc);                       
assignin('base', 'total_times', total_time);           

k = 0;
for n = 1:nbus
    Vm(n) = abs(V(n)); 
    deltad(n) = angle(V(n)) * 180 / pi;

    if kb(n) == 1
        S(n) = P(n) + 1j * Q(n);
        Pg(n) = P(n) * basemva + Pd(n);
        Qg(n) = Q(n) * basemva + Qd(n) - Qsh(n);
        k = k + 1;
        Pgg(k) = Pg(n);
    elseif kb(n) == 2
        k = k + 1;
        Pgg(k) = Pg(n);
        S(n) = P(n) + 1j * Q(n);
        Qg(n) = Q(n) * basemva + Qd(n) - Qsh(n);
    end

    yload(n) = (Pd(n) - 1j * Qd(n) + 1j * Qsh(n)) / (basemva * Vm(n)^2);
end

busdata(:,3) = Vm'; 
busdata(:,4) = deltad';

Pgt = sum(Pg);  
Qgt = sum(Qg);  
Pdt = sum(Pd);  
Qdt = sum(Qd);  
Qsht = sum(Qsh);

clear AcurBus DP DQ DV L Sc Vc VcI VcR YV converge delta

itersolve = iter;  
itersolveleng = iter;    
assignin('base', 'itersolve', itersolve);  
assignin('base', 'itersolveleng', itersolveleng); 
