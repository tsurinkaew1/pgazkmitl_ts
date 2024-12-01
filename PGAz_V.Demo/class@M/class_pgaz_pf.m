classdef class_pgaz_pf
    methods (Static)
        function pgaz_pf(msggph,dowstatus)
    if evalin('base', 'exist(''methodIdx'', ''var'')') 
        methodIdx = evalin('base', 'methodIdx');
        switch methodIdx
            case 1
                pgaz_pf_nr();
                disp('Power flow analysis using the Newton-Raphson method completed successfully.');
                OperationSuccess='Power flow analysis using the Newton-Raphson method completed successfully.';
                assignin('base', 'OperationSuccess', OperationSuccess);
                BuildBoxHandle = findobj('Tag', 'BuildBox');
                    if ~isempty(BuildBoxHandle)
                        set(BuildBoxHandle, 'String', OperationSuccess);
                    else
                        disp('BuildBox not found.');
                    end
            case 2
                pgaz_pf_gs();
                disp('Power flow analysis using the Gauss-Seidel method completed successfully.');
                OperationSuccess='Power flow analysis using the Gauss-Seidel method completed successfully.';
                assignin('base', 'OperationSuccess', OperationSuccess);
                BuildBoxHandle = findobj('Tag', 'BuildBox');
                    if ~isempty(BuildBoxHandle)
                        set(BuildBoxHandle, 'String', OperationSuccess);
                    else
                        disp('BuildBox not found.');
                    end
            case 3
                pgaz_pf_fd();
                disp('Power flow analysis using the Fast-Decoupled method completed successfully.');
                OperationSuccess='Power flow analysis using the Fast-Decoupled method completed successfully.';
                assignin('base', 'OperationSuccess', OperationSuccess);
                BuildBoxHandle = findobj('Tag', 'BuildBox');
                    if ~isempty(BuildBoxHandle)
                        set(BuildBoxHandle, 'String', OperationSuccess);
                    else
                        disp('BuildBox not found.');
                    end
            case 4
                pgaz_pf_iw();
                disp('Power flow analysis using the Iwamoto Method method completed successfully.');
                OperationSuccess='Power flow analysis using the Iwamoto Method method completed successfully.';
                assignin('base', 'OperationSuccess', OperationSuccess);
                BuildBoxHandle = findobj('Tag', 'BuildBox');
                    if ~isempty(BuildBoxHandle)
                        set(BuildBoxHandle, 'String', OperationSuccess);
                    else
                        disp('BuildBox not found.');
                    end
            otherwise
                disp('The selected method is not supported. Please verify your selection.');
        end
    else
        disp('');
    end

    % ดึงค่าจาก workspace
    try
        % Retrieve variables from the workspace
        acc = evalin('base', 'acc');
        itersolve = evalin('base', 'itersolve');
        accuracy = evalin('base', 'accuracy');
        total_times = evalin('base', 'total_times');

        % Check if variables are empty
        if isempty(acc) || isempty(itersolve) || isempty(accuracy) || isempty(total_times)
            error('One or more variables are empty.');
        end

        % Clear previous plot
        cla(msggph, 'reset');

        % Set axis range and number of iterations
        iteration_number = 1:length(acc);
        axes(msggph); % Set the current axes to msggph
        xlim(msggph, [1, length(acc)]);
        ylim(msggph, [min(acc) - 0.1, max(acc) + 0.1]); % Add buffer for axis boundaries

        % Set pause time for dynamic plotting
        pause_time = total_times / length(acc);

        % Dynamic plotting
        hold(msggph, 'on');
        for i = 1:length(acc)
            plot(msggph, iteration_number(i), acc(i), 'o-', ...
                'MarkerEdgeColor', [0 0 1], ...
                'MarkerFaceColor', [1 1 1], ...
                'MarkerSize', 5, 'LineWidth', 1.5);
            pause(pause_time); % Pause to simulate dynamic plotting
        end
        hold(msggph, 'off');

        % Configure grid and axis colors
        grid(msggph, 'off');
        set(msggph, 'XColor', 'k', 'YColor', 'k'); % Set axis colors
    catch
        msgbox('Unable to plot the graph.', 'Error', 'error');
    end

    % ตรวจสอบและดึงค่าจาก workspace
if evalin('base', 'exist(''total_times'', ''var'')')
    total_times = evalin('base', 'total_times');
else
    error('Variable total_times does not exist in the workspace.');
end

% Clear previous plot
cla(dowstatus, 'reset');

% ตั้งค่าพารามิเตอร์
nSteps = 100; % จำนวนขั้นตอน (0 ถึง 100)
stepTime = total_times / nSteps; % เวลาแต่ละขั้นตอน

% ปิดเส้นสเกลและกริด
axis(dowstatus, 'off');

% เพิ่มแท่งบาร์แนวนอน
hBar = rectangle('Parent', dowstatus, ...
                 'Position', [0, 0, 1, 1], ... % เริ่มต้นที่กว้าง 0
                 'FaceColor', [1, 0.6, 0.2], ... % สีส้ม [R, G, B]
                 'EdgeColor', 'none'); % ไม่มีขอบ

% เพิ่มข้อความ "Success" ตรงกลางแท่งบาร์
hText = text(0.5, 0.5, 'Success', ...
             'Parent', dowstatus, ...
             'Color', 'white', ...       % สีของข้อความ
             'FontSize', 8, ...         % ขนาดตัวอักษร
             'FontWeight', 'bold', ...   % น้ำหนักตัวอักษร
             'HorizontalAlignment', 'center', ... % จัดกึ่งกลางแนวนอน
             'VerticalAlignment', 'middle');      % จัดกึ่งกลางแนวตั้ง
         
% แสดงแอนิเมชัน
for i = 0:nSteps
    % คำนวณความกว้างของแท่ง (0 ถึง 1)
    progress = i / nSteps;
    set(hBar, 'Position', [0, 0, progress, 1]); % อัปเดตกว้างของแท่ง
    % หยุดชั่วคราวเพื่อแสดงผล
    pause(stepTime);
end


    end

    end
end