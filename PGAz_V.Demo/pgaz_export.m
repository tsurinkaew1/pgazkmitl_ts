function pgaz_export()
    % ตรวจสอบว่าตัวแปร Export มีอยู่ใน workspace หรือไม่
    if evalin('base', 'exist(''Export'', ''var'') == 0')
        disp('Export variable not found in the workspace.');
        return;
    end
    
    % ดึงข้อมูลจากตัวแปรใน workspace
    Export = evalin('base', 'Export');
    
    % สร้างหน้าต่างให้ผู้ใช้เลือกชนิดไฟล์ที่ต้องการบันทึก
    [file, path, filterindex] = uiputfile({'*.txt', 'Text File (*.txt)'; ...
                                           '*.pdf', 'PDF File (*.pdf)'}, ...
                                           'Save As');
    if isequal(file, 0)
        disp('User canceled the save.');
        return;
    else
        filePath = fullfile(path, file);
        
        % บันทึกไฟล์ตามชนิดที่เลือก
        switch filterindex
            case 1  % Save as txt
                saveAsTxt(filePath, Export);
            case 2  % Save as pdf
                saveAsPDF(filePath, Export);
            otherwise
                disp('Invalid option selected.');
        end
    end
end

%%
function saveAsTxt(filePath, Export)
    % บันทึก Export เป็นไฟล์ txt
    fileID = fopen(filePath, 'w');
    if ischar(Export)
        fprintf(fileID, '%s\n', Export);
    elseif iscell(Export)
        for i = 1:numel(Export)
            fprintf(fileID, '%s\n', Export{i});
        end
    else
        fprintf(fileID, '%s\n', num2str(Export));
    end
    fclose(fileID);
    disp(['File saved as .txt at: ' filePath]);
end

%%
function saveAsPDF(filePath, Export)
    % บันทึก PowerFlowReportcomman เป็นไฟล์ PDF ขนาด A4 ตัวอักษรขนาด 6 และระยะห่างขอบ 0.5 นิ้ว
    if ischar(Export)
        content = Export;
    elseif iscell(Export)
        content = strjoin(Export, '\n');
    else
        content = num2str(Export);
    end

    % แบ่งข้อมูลออกเป็นบรรทัดตามฟอร์มเดิม
    lines = strsplit(content, '\n');
    numLines = length(lines);
    
    % ตั้งค่าบรรทัดสูงสุดในแต่ละหน้า
    maxLinesFirstPage = 108;  % ไฟล์แรกมี 40 บรรทัด
    maxLinesPerPage = 108;    % หน้าถัดไปใช้จำนวนบรรทัดตามความเหมาะสม (65 บรรทัดต่อหน้า)

    % ตรวจสอบจำนวนหน้า
    if numLines <= maxLinesFirstPage
        numPages = 1;
    else
        numPages = ceil((numLines - maxLinesFirstPage) / maxLinesPerPage) + 1;
    end

    % แบ่งข้อมูลและบันทึกไฟล์ PDF ตามจำนวนบรรทัดในแต่ละหน้า
    for page = 1:numPages
        % สร้างรูปแบบการแสดงผลแบบไม่มีเส้นกรอบและขนาด A4
        fig = figure('Visible', 'off', 'PaperType', 'A4', 'PaperPositionMode', 'manual');
        set(fig, 'PaperUnits', 'inches', 'PaperPosition', [0.5 0.5 6.8 10.8]); % ระยะห่างขอบ 0.5 นิ้วทุกด้าน

        % ดึงข้อมูลสำหรับแต่ละหน้า
        if page == 1
            startIdx = 1;
            endIdx = min(maxLinesFirstPage, numLines);
        else
            startIdx = maxLinesFirstPage + (page - 2) * maxLinesPerPage + 1;
            endIdx = min(maxLinesFirstPage + (page - 1) * maxLinesPerPage, numLines);
        end
        
        pageContent = strjoin(lines(startIdx:endIdx), '\n');
        
        % สร้างแกนกราฟและกำหนดค่าตำแหน่ง
        axes('Position', [0 0 1 1], 'Units', 'normalized');
        axis off; % ปิดแกน
        text(0, 1, pageContent, 'FontSize', 6, 'Interpreter', 'none', ...
             'VerticalAlignment', 'top', 'FontName', 'FixedWidth', ...
             'Units', 'normalized', 'Position', [0 1]);

        % บันทึกไฟล์ PDF แยกหน้าละไฟล์
        pageFilePath = sprintf('%s_page%d.pdf', filePath, page); % ตั้งชื่อไฟล์แต่ละหน้า
        print(fig, pageFilePath, '-dpdf'); % บันทึกแต่ละหน้าเป็น PDF
        close(fig);
    end
    
    disp(['Files saved as .pdf at: ' filePath ' (multiple pages)']);
end


