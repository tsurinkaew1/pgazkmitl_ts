function pgaz_static_report
    screenSize = get(0, 'ScreenSize');
    guiWidth = 945;
    guiHeight = 510;
    guiX = (screenSize(3) - guiWidth) / 2;
    guiY = (screenSize(4) - guiHeight) / 2;

    fig = figure('Name', 'Static Report', ...
                 'Position', [guiX, guiY, guiWidth, guiHeight], ...
                 'MenuBar', 'none', ...
                 'NumberTitle', 'off', ...
                 'Resize', 'off', ...
                 'Color', [1, 1, 1]);

    msgStatus = axes('Parent', fig, ...
                     'Units', 'normalized', ...
                     'Position', [0, 0.95, 1, 0.05], ...
                     'Color', [0, 0, 0.5], ...
                     'XColor', 'none', 'YColor', 'none', ...
                     'XTick', [], 'YTick', [], ...
                     'Tag', 'StatusAxes');
    text(0.5, 0.5, ' Power Flow and Continuation Power Flow Report', ...
         'FontName', 'Arial', ...
         'FontWeight', 'bold', ...
         'FontSize', 9, ...
         'HorizontalAlignment', 'center', ...
         'VerticalAlignment', 'middle', ...
         'Parent', msgStatus, ...
         'Color', [1, 1, 1]);

   % Create table headers and list boxes for the data
labels = {'Bus', 'Vm', 'Va [rad]', 'P gen [MW]', 'Q gen [Mvar]', ...
          'Injected [Mvar]', 'P load [MW]', 'Q load [Mvar]'};
numCols = numel(labels);
colWidth = (guiWidth - 20) / numCols;

for i = 1:numCols
    % Create table headers
    uicontrol('Style', 'text', ...
              'String', labels{i}, ...
              'HorizontalAlignment', 'center', ...
              'FontSize', 9, ...
              'FontWeight', 'bold', ...
              'BackgroundColor', [1, 1, 1], ...
              'Position', [10 + (i-1) * colWidth, guiHeight - 50, colWidth - 10, 20]);
    
    % Create listbox
    listBox = uicontrol('Style', 'listbox', ...
                        'Position', [15 + (i-1) * colWidth, guiHeight - 250, colWidth - 10, 200], ...
                        'BackgroundColor', [1, 1, 1]);
    
    % Map variables to corresponding columns
    switch i
        case 1 % Bus column
            variableName = 'n_values';
        case 2 % Vm column
            variableName = 'Vm_values_formatted';
        case 3 % Va column
            variableName = 'deltad_formatted';
        case 4 % P gen column
            variableName = 'Pg_values_formatted';
        case 5 % Q gen column
            variableName = 'Qg_values_formatted';
        case 6 % Injected column
            variableName = 'Qsh_values_formatted';
        case 7 % P load column
            variableName = 'Pd_values_formatted';
        case 8 % Q load column
            variableName = 'Qd_values_formatted';
        otherwise
            variableName = '';
    end
    
    % Load variable data from workspace if available
    if ~isempty(variableName)
        try
            % Check if variable exists in the workspace
            if evalin('base', ['exist(''' variableName ''', ''var'')'])
                % Retrieve variable
                variableData = evalin('base', variableName);
                
                % Check if variable is a cell or numeric array
                if iscell(variableData)
                    listBox.String = variableData; % Use cell array directly
                elseif isnumeric(variableData)
                    listBox.String = arrayfun(@num2str, variableData, 'UniformOutput', false); % Convert to cell array
                else
                    listBox.String = {['Invalid format for ' variableName]};
                end
            else
                listBox.String = {[variableName ' not found']};
            end
        catch ME
            listBox.String = {['Error reading ' variableName]};
            disp(ME.message); % Display error details in Command Window
        end
    else
        % Leave other columns empty
        listBox.String = {};
    end
end

    

    % Create a label for Network & Solution Statistics
uicontrol('Style', 'text', ...
          'String', 'Network & Solution Statistics', ...
          'FontName', 'Arial', ...
          'HorizontalAlignment', 'left', ...
          'FontSize', 9, ...
          'FontWeight', 'bold', ...
          'BackgroundColor', [1, 1, 1], ...
          'Position', [15, 230, (guiWidth/2)-15, 20]);

% Create the listbox
listBox = uicontrol('Style', 'listbox', ...
                    'Position', [15, 15, (guiWidth/2)-20, 210], ...
                    'BackgroundColor', [1, 1, 1]);

% Load NetworkSolutionStatsChar from the workspace
try
    % Check if NetworkSolutionStatsChar exists in workspace
    if evalin('base', 'exist(''NetworkSolutionStatsChar'', ''var'')')
        % Retrieve the variable
        NetworkSolutionStatsChar = evalin('base', 'NetworkSolutionStatsChar');
        
        % Check if it's a cell array or numeric
        if iscell(NetworkSolutionStatsChar)
            listBox.String = NetworkSolutionStatsChar; % Use the cell array directly
        elseif isnumeric(NetworkSolutionStatsChar)
            listBox.String = arrayfun(@num2str, NetworkSolutionStatsChar, 'UniformOutput', false); % Convert numeric array to cell array of strings
        elseif ischar(NetworkSolutionStatsChar)
            listBox.String = {NetworkSolutionStatsChar}; % Convert single string to cell array
        else
            listBox.String = {'Invalid format for NetworkSolutionStatsChar'};
        end
    else
        listBox.String = {'NetworkSolutionStatsChar not found'};
    end
catch ME
    listBox.String = {'Error reading NetworkSolutionStatsChar'};
    disp(ME.message); % Display error details in the Command Window
end


    % Create a label for Global Summary Report
uicontrol('Style', 'text', ...
          'String', 'Global Summary Report', ...
          'FontName', 'Arial', ...
          'HorizontalAlignment', 'left', ...
          'FontSize', 9, ...
          'FontWeight', 'bold', ...
          'BackgroundColor', [1, 1, 1], ...
          'Position', [(guiWidth/2)+5, 229, (guiWidth/2)-15, 20]);

% Create the listbox
listBox = uicontrol('Style', 'listbox', ...
                    'Position', [(guiWidth/2)+5, 64, (guiWidth/2)-20, 160], ...
                    'BackgroundColor', [1, 1, 1]);

% Load PowerFlowResultsChar from the workspace
try
    % Check if PowerFlowResultsChar exists in workspace
    if evalin('base', 'exist(''PowerFlowResultsChar'', ''var'')')
        % Retrieve the variable
        PowerFlowResultsChar = evalin('base', 'PowerFlowResultsChar');
        
        % Check if it's a cell array or numeric
        if iscell(PowerFlowResultsChar)
            listBox.String = PowerFlowResultsChar; % Use the cell array directly
        elseif isnumeric(PowerFlowResultsChar)
            listBox.String = arrayfun(@num2str, PowerFlowResultsChar, 'UniformOutput', false); % Convert numeric array to cell array of strings
        elseif ischar(PowerFlowResultsChar)
            listBox.String = {PowerFlowResultsChar}; % Convert single string to cell array
        else
            listBox.String = {'Invalid format for PowerFlowResultsChar'};
        end
    else
        listBox.String = {'PowerFlowResultsChar not found'};
    end
catch ME
    listBox.String = {'Error reading PowerFlowResultsChar'};
    disp(ME.message); % Display error details in the Command Window
end


    uicontrol('Style', 'pushbutton', ...
              'FontName', 'Arial', ...
              'String', 'Export', ...
              'FontSize', 8, ...
              'BackgroundColor', [1, 1, 1], ...
              'Position', [(guiWidth/2)+120, 20, 80, 25], ...
              'Callback', @reportCallback);

    % Add the Close button
    uicontrol('Style', 'pushbutton', ...
              'String', 'Close', ...
              'FontName', 'Arial', ...
              'FontSize', 8, ...
              'Position', [(guiWidth/2)+220, 20, 80, 25], ...
              'BackgroundColor', [1, 1, 1], ...
              'Callback', @(src, event) close(fig));

    imageFolder = fullfile(pwd, 'pgaz_images');
    imageFile = 'pgaz_logo.png';
    imagePath = fullfile(imageFolder, imageFile);
    
    if exist(imagePath, 'file')
        % สร้าง axes โดยใช้ units เป็น normalized เพื่อให้ปรับตามขนาดหน้าต่าง
        axLogo = axes('Parent', fig, ...
                      'Units', 'normalized', ...
                      'Position', [0.84, 0, 0.13, 0.13], ... % [left, bottom, width, height]
                      'Tag', 'LogoAxes');
        
        % อ่านและแสดงภาพ
        img = imread(imagePath);
        imshow(img, 'Parent', axLogo, 'InitialMagnification', 'fit'); % ปรับขนาดอัตโนมัติ
    else
        warning('The image file "%s" was not found in the folder "%s".', ...
                imageFile, imageFolder);
    end

end

function reportCallback(~, ~)
    % ตรวจสอบ methodIdx ใน workspace
    try
        % ดึงค่า methodIdx จาก workspace
        methodIdx = evalin('base', 'methodIdx');
        
        % ตรวจสอบค่าของ methodIdx
        if methodIdx == 1
            % กรณี methodIdx == 1
            nroutputtxt = evalc('pgaz_pf_nr()');  % เก็บผลลัพธ์จากฟังก์ชัน
            assignin('base', 'Export', nroutputtxt);  % บันทึกตัวแปร 'Export' ลงใน Workspace
            pgaz_export();  % เรียกฟังก์ชัน pgaz_export
        elseif methodIdx == 2
            % กรณี methodIdx == 2
            gsoutputtxt = evalc('pgaz_pf_gs()');  % เก็บผลลัพธ์จากฟังก์ชัน
            assignin('base', 'Export', gsoutputtxt);  % บันทึกตัวแปร 'Export' ลงใน Workspace
            pgaz_export();  % เรียกฟังก์ชัน pgaz_export
        elseif methodIdx == 3
            % กรณี methodIdx == 3
            fdoutputtxt = evalc('pgaz_pf_fd()');  % เก็บผลลัพธ์จากฟังก์ชัน
            assignin('base', 'Export', fdoutputtxt);  % บันทึกตัวแปร 'Export' ลงใน Workspace
            pgaz_export();  % เรียกฟังก์ชัน pgaz_export
        elseif methodIdx == 4
            % กรณี methodIdx == 3
            iwoutputtxt = evalc('pgaz_pf_iw()');  % เก็บผลลัพธ์จากฟังก์ชัน
            assignin('base', 'Export', iwoutputtxt);  % บันทึกตัวแปร 'Export' ลงใน Workspace
            pgaz_export();  % เรียกฟังก์ชัน pgaz_export
        else
            % กรณี methodIdx มีค่าอื่นที่ไม่ใช่ 1, 2, หรือ 3
            disp('error !');
        end
    catch ME
        % จัดการข้อผิดพลาดในกรณี methodIdx ไม่มีอยู่ใน workspace
        disp('Error: methodIdx not found in workspace or invalid.');
        disp(ME.message);
    end
end

function cpfCallback(~, ~)
    disp('CPF button clicked');
end
