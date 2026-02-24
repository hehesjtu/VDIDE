function UI
    fig = uifigure('Name', '', ... 
                   'Position', [100 100 900 500]); 
    
    btnLoad = uibutton(fig, 'push', 'Text', 'Load Image', ...
        'Position', [30 440 100 30], 'ButtonPushedFcn', @(btn,event) loadImage());
        
    btnSave = uibutton(fig, 'push', 'Text', 'Save Result', ...
        'Position', [140 440 120 30], 'Enable', 'off', 'ButtonPushedFcn', @(btn,event) saveEnhancedImage());
        
    initialFactor = 4.0;
    uilabel(fig, 'Text', 'Enhancement Factor:', 'Position', [280 445 130 20], 'FontWeight', 'bold');
    sldEnhance = uislider(fig, 'Position', [410 455 160 3], 'Limits', [0 10], 'Value', initialFactor, 'Enable', 'off', ...
        'ValueChangingFcn', @(sld,event) onSliderMove(event)); 
    lblFactorValue = uilabel(fig, 'Text', sprintf('%.1f', initialFactor), 'Position', [580 445 40 20]);

    axOriginal = uiimage(fig, 'Position', [30 80 400 320], 'ScaleMethod', 'fit');
    uilabel(fig, 'Text', 'Original Image', 'Position', [180 50 100 20], 'HorizontalAlignment', 'center');
    
    axEnhanced = uiimage(fig, 'Position', [470 80 400 320], 'ScaleMethod', 'fit');
    uilabel(fig, 'Text', 'Enhanced Image', 'Position', [620 50 120 20], 'HorizontalAlignment', 'center');
    
    originalImage = []; 
    enhancedImage = []; 
    originalFileName = ''; 
    calculatedDetails = []; 
    
    function Details = calculateDetails(img_uint8) 
        img = double(img_uint8); 
        Details = zeros(size(img));
        for c = 1:3
            [~, Res] = VDIDE(img(:,:,c)); 
            Details(:,:,c) = imresize(Res, [size(img,1), size(img,2)], 'bilinear');
        end
    end

    function out = applyFactor(img_uint8, Details, factor)
        img = double(img_uint8);
        out_double = img + Details * factor;
        out = uint8(min(max(out_double, 0), 255)); 
    end

    function loadImage()
        [file, path] = uigetfile({'*.jpg;*.png;*.bmp;*.tif', 'Image Files (*.jpg, *.png, *.bmp, *.tif)'}, 'Select Input Image');
        if isequal(file,0), return; end
        
        [~, name, ~] = fileparts(file);
        originalFileName = name;
        
        d = uiprogressdlg(fig, 'Title', 'Please Wait', 'Message', 'Processing image...');
        
        tempImage = imread(fullfile(path, file));
        if size(tempImage,3) == 1; originalImage = repmat(tempImage,[1 1 3]);
        else; originalImage = tempImage; end
        
        axOriginal.ImageSource = originalImage;
        calculatedDetails = calculateDetails(originalImage);
        enhancedImage = applyFactor(originalImage, calculatedDetails, sldEnhance.Value);
        axEnhanced.ImageSource = enhancedImage;
        
        btnSave.Enable = 'on'; 
        sldEnhance.Enable = 'on'; 
        close(d);
    end

    function onSliderMove(event)
        new_factor = event.Value;
        lblFactorValue.Text = sprintf('%.1f', new_factor); 
        if isempty(originalImage), return; end
        enhancedImage = applyFactor(originalImage, calculatedDetails, new_factor);
        axEnhanced.ImageSource = enhancedImage;
    end

    function saveEnhancedImage() 
        if isempty(enhancedImage), return; end
        defaultName = [originalFileName, '_result.png'];
        [file, path] = uiputfile('*.png', 'Export Enhanced Image', defaultName); 
        if isequal(file,0), return; end
        imwrite(enhancedImage, fullfile(path, file));
    end
end