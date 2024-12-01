function pgaz_btn_export_results(parentFig, imagePath, position, tooltip, tag, callback)
       % ตรวจสอบว่าไฟล์รูปภาพมีอยู่หรือไม่
    if exist(imagePath, 'file')
        % อ่านรูปภาพ
        img = imread(imagePath);

        % สร้างปุ่ม
        uicontrol('Style', 'pushbutton', ...
                  'Parent', parentFig, ...       % ใช้ parentFig เป็น Parent
                  'Units', 'pixels', ...
                  'Position', position, ...     % ตำแหน่งและขนาดของปุ่ม
                  'BackgroundColor', 'white', ...
                  'CData', img, ...             % ใส่รูปภาพในปุ่ม 
                  'TooltipString', tooltip, ... % ข้อความ Tooltip
                  'Tag', tag, ...               % กำหนด Tag ให้ปุ่ม
                  'Callback', callback);        % กำหนด Callback ฟังก์ชัน
    else
        warning('The image file "%s" was not found.', imagePath);
    end
end
