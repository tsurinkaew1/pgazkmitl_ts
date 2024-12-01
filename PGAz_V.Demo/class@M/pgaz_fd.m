ns = 0; Vm = 0; delta = 0; yload = 0; deltad = 0;
nbus = length(busdata(:,1));

for k = 1:nbus
    n = busdata(k,1);                  
    kb(n) = busdata(k,2);              
    Vm(n) = busdata(k,3);              
    delta(n) = busdata(k, 4);          
    Pd(n) = busdata(k,5);              
    Qd(n) = busdata(k,6);              
    Pg(n) = busdata(k,7);            
    Qg(n) = busdata(k,8);              
    Qmin(n) = busdata(k, 9);           
    Qmax(n) = busdata(k, 10);          
    Qsh(n) = busdata(k, 11);           

    if Vm(n) <= 0  
        Vm(n) = 1.0;                   
        V(n) = 1 + j*0;                
    else
        delta(n) = pi/180 * delta(n);   
        V(n) = Vm(n) * (cos(delta(n)) + j * sin(delta(n)));
        P(n) = (Pg(n) - Pd(n)) / basemva;   
        Q(n) = (Qg(n) - Qd(n) + Qsh(n)) / basemva;   
        S(n) = P(n) + j * Q(n);         
    end

    if kb(n) == 1
        ns = ns + 1;                   
    end
    nss(n) = ns;
end

Ym = abs(Ybus);                        
t = angle(Ybus);                       

ii = 0;
for ib = 1:nbus
    if kb(ib) == 0 || kb(ib) == 2
        ii = ii + 1;
        jj = 0;
        for jb = 1:nbus
            if kb(jb) == 0 || kb(jb) == 2
                jj = jj + 1;
                B1(ii,jj) = imag(Ybus(ib,jb));   
            end
        end
    end
end

ii = 0;
for ib = 1:nbus
    if kb(ib) == 0
        ii = ii + 1;
        jj = 0;
        for jb = 1:nbus
            if kb(jb) == 0
                jj = jj + 1;
                B2(ii,jj) = imag(Ybus(ib,jb));   
            end
        end
    end
end

B1inv = inv(B1);
B2inv = inv(B2);

maxerror = 1;
converge = 1;
iter = 0;

iteration_times = [];  
acc = [];             
total_time = 0;        

while maxerror >= accuracy && iter <= maxiter 
    iter = iter + 1;
    tic; 
    id = 0;
    iv = 0;

    for n = 1:nbus
        nn = n - nss(n);
        J11 = 0; J33 = 0;
        
        for i = 1:nbr
            if nl(i) == n || nr(i) == n
                if nl(i) == n, l = nr(i); end
                if nr(i) == n, l = nl(i); end
                J11 = J11 + Vm(n) * Vm(l) * Ym(n,l) * sin(t(n,l) - delta(n) + delta(l));
                J33 = J33 + Vm(n) * Vm(l) * Ym(n,l) * cos(t(n,l) - delta(n) + delta(l));
            end
        end
        
        Pk = Vm(n)^2 * Ym(n,n) * cos(t(n,n)) + J33;
        Qk = -Vm(n)^2 * Ym(n,n) * sin(t(n,n)) - J11;
        
        if kb(n) == 1
            P(n) = Pk; Q(n) = Qk;        
        end

        if kb(n) == 2
            Q(n) = Qk;
            Qgc = Q(n) * basemva + Qd(n) - Qsh(n);
            if Qmax(n) ~= 0
                if iter <= 20
                    if iter >= 10
                        if Qgc < Qmin(n), Vm(n) = Vm(n) + 0.005; 
                        elseif Qgc > Qmax(n), Vm(n) = Vm(n) - 0.005; end
                    end
                end
            end
        end

        if kb(n) ~= 1
            id = id + 1;
            DP(id) = P(n) - Pk;
            DPV(id) = (P(n) - Pk) / Vm(n);
        end
        if kb(n) == 0
            iv = iv + 1;
            DQ(iv) = Q(n) - Qk;
            DQV(iv) = (Q(n) - Qk) / Vm(n);
        end
    end
   
    Dd = -B1inv * DPV';
    DV = -B2inv * DQV';

    id = 0; iv = 0;
    for n = 1:nbus
        if kb(n) ~= 1
            id = id + 1;
            delta(n) = delta(n) + Dd(id);
        end
        if kb(n) == 0
            iv = iv + 1;
            Vm(n) = Vm(n) + DV(iv);
        end
    end

    maxerror = max(max(abs(DP)), max(abs(DQ)));
    acc = [acc; maxerror];  

    iteration_time = toc;  
    iteration_times = [iteration_times; iteration_time];  
    total_time = total_time + iteration_time;            
   
    if iter == maxiter && maxerror > accuracy
        fprintf('\nWARNING: Iterative solution did not converge after %g iterations.\n\n', iter);
        fprintf('Press Enter to terminate the iterations and print the results \n');
        converge = 0;
        pause;
    end
end

if converge ~= 1
    tech = '                      ITERATIVE SOLUTION DID NOT CONVERGE';
else
    tech = '                   Power Flow Solution by Fast Decoupled Method';
end

V = Vm .* cos(delta) + j * Vm .* sin(delta);
deltad = 180 / pi * delta;

for n = 1:nbus
    if kb(n) == 1
        S(n) = P(n) + j * Q(n);
        Pg(n) = P(n) * basemva + Pd(n);
        Qg(n) = Q(n) * basemva + Qd(n) - Qsh(n);
    elseif kb(n) == 2
        S(n) = P(n) + j * Q(n);
        Qg(n) = Q(n) * basemva + Qd(n) - Qsh(n);
    end
    yload(n) = (Pd(n) - j * Qd(n) + j * Qsh(n)) / (basemva * Vm(n)^2);
end

busdata(:,3) = Vm';
busdata(:,4) = deltad';

Pgt = sum(Pg); 
Qgt = sum(Qg); 
Pdt = sum(Pd); 
Qdt = sum(Qd); 
Qsht = sum(Qsh);

assignin('base', 'iter_time', iteration_times);
assignin('base', 'acc', acc);
assignin('base', 'total_times', total_time);

clear Pk Qk DP DQ J11 J33 B1 B1inv B2 B2inv DPV DQV Dd delta ib id ii iv jb jj

itersolve = iter;  
assignin('base', 'itersolve', itersolve);
