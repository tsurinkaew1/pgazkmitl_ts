classdef class_handle_toolbar
    methods (Static)

    function pgaz_handle_newfile()
        disp('The "New File" option has been selected.');
    
        if exist('pgaz_maingui', 'file') == 2
            pgaz_maingui;
            disp('The "New File" has been successfully executed.');
            OperationSuccess = 'New File has been successfully executed.';
            assignin('base', 'OperationSuccess', OperationSuccess);
        else
            disp('Error: Unable to execute "New File" as the file "pgaz_maingui.m" is not found.');
            OperationSuccess = 'Error: Unable to execute "New File" as the file "pgaz_maingui.m" is not found.';
            assignin('base', 'OperationSuccess', OperationSuccess);
        end
        BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('BuildBox not found.');
            end
    end

    function pgaz_handle_datafile()
        [file, path] = uigetfile('*.m', 'Select an M-file');
        
        if isequal(file, 0)
            OperationSuccess = 'File selection was canceled by the user.';
            assignin('base', 'OperationSuccess', OperationSuccess);
            return;
        else
            fullpath = fullfile(path, file);
            [~, name, ~] = fileparts(fullpath);
            assignin('base', 'NameDatainput', name);
            assignin('base', 'LocationImportData', fullpath);
            
            try
                evalin('base', sprintf('run(''%s'');', fullpath));
            catch ME
                OperationSuccess = sprintf('Error while executing the file: %s', ME.message);
                assignin('base', 'OperationSuccess', OperationSuccess);
                return;
            end
            
            if evalin('base', 'exist(''bus'', ''var'') && isstruct(bus)')
                bus_struct = evalin('base', 'bus');
                if isfield(bus_struct, 'con')
                    busdata = bus_struct.con;
                    assignin('base', 'busdata', busdata);
                end
            end
            
            if evalin('base', 'exist(''line'', ''var'') && isstruct(line)')
                line_struct = evalin('base', 'line');
                if isfield(line_struct, 'con')
                    linedata = line_struct.con;
                    assignin('base', 'linedata', linedata);
                end
            end
            
            DataFileBoxHandle = findobj('Tag', 'DataFileBox');
            if ~isempty(DataFileBoxHandle)
                set(DataFileBoxHandle, 'String', fullpath);
            else
                disp('');
            end
            
    
            disp(['File "', name, '" loaded successfully and data imported into the Workspace.']);
            OperationSuccess = ['Workspace file "', name, '" loaded successfully and data imported into the Workspace.'];
            assignin('base', 'OperationSuccess', OperationSuccess);
    
            BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('');
            end
        end
    end

    function pgaz_handle_saved_system()
        [file, path] = uigetfile('*.mat', 'Select Workspace File');
        
        if isequal(file, 0)
            disp('Workspace file selection was canceled by the user.');
            OperationSuccess = 'Workspace file selection was canceled by the user.';
            assignin('base', 'OperationSuccess', OperationSuccess);
        else
            fullFileName = fullfile(path, file);
            
            loadedData = load(fullFileName);
            
            vars = fieldnames(loadedData);
            for i = 1:length(vars)
                assignin('base', vars{i}, loadedData.(vars{i}));
            end
            
            disp(['File "', file, '" loaded successfully and data imported into the Workspace.']);
            OperationSuccess = ['Workspace file "', file, '" loaded successfully and data imported into the Workspace.'];
            assignin('base', 'OperationSuccess', OperationSuccess);
        end
    
        BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('');
            end
    end

    function pgaz_handle_discard_datafile()
        % Find the parent figure of the uicontrol triggering the callback
        fig = gcbf; % Get the current figure handle
        
        % Variables to remove from the workspace
        varsToRemove = {'bus', 'gen', 'line', 'lineflow', ...
                        'LocationImportData', 'NameDatainput', ...
                        'Pd', 'Ps', 'busdata', 'linedata'};
        
        % Clear the variables in the base workspace
        for i = 1:length(varsToRemove)
            evalin('base', sprintf('if exist(''%s'', ''var''), clear(''%s''); end', varsToRemove{i}, varsToRemove{i}));
        end
        
        % Reset the DataFileBox display
        DataFileBox = findobj(fig, 'Tag', 'DataFileBox'); % Find the DataFileBox handle
        if ~isempty(DataFileBox)
            set(DataFileBox, 'String', ''); % Clear the displayed string
        end
        
        % Feedback message
        OperationSuccess = 'The data file variables have been successfully removed from the workspace.';
        assignin('base', 'OperationSuccess', OperationSuccess);
        disp(OperationSuccess);
        
        BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('BuildBox not found.');
            end
    end

    function pgaz_handle_current_system()
        [file, path] = uiputfile('*.mat', 'Save Workspace As');
        
        if isequal(file, 0)
            disp('Workspace save operation was canceled by the user.');
            OperationSuccess = 'Workspace save operation was canceled by the user.';
            assignin('base', 'OperationSuccess', OperationSuccess);
        else
            fullFileName = fullfile(path, file);
            
            save(fullFileName);
            evalin('base', ['save(''' fullFileName ''', ''-append'')']);
            
            disp(['Workspace saved successfully to: ', fullFileName]);
            OperationSuccess = ['Workspace saved successfully to: ', fullFileName];
            assignin('base', 'OperationSuccess', OperationSuccess);
        end
    
        BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('');
            end
    end

    function pgaz_handle_close()

        choice = questdlg('Are you sure you want to exit PGAz?', ...
                          'Exit PGAz', ...
                          'OK', 'Cancel', 'Cancel');
        movegui(gcf, 'center');
    
        switch choice
            case 'OK'
                disp('User confirmed to exit PGAz.');
                close all;
                
            case 'Cancel'
                disp('User canceled the exit from PGAz.');
                return;
         end
    end

    function pgaz_handle_clear_workspace()
        OperationSuccess = 'All variables have been cleared from the workspace.';
        assignin('base', 'OperationSuccess', OperationSuccess);
        
        evalin('base', 'clearvars -except OperationSuccess');
        
        disp('All variables have been cleared from the workspace.');
        
        BuildBoxHandle = findobj('Tag', 'BuildBox');
            if ~isempty(BuildBoxHandle)
                set(BuildBoxHandle, 'String', OperationSuccess);
            else
                disp('');
            end
    end
    end
end
