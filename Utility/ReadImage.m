function [Img, gantryAngle, collimatorAngle, Dose, Offset] = ReadImage(filenamePrefix, imgRow, imgCol, varargin)
% Read raw image and do offset correction
% Parameters description:
%     filenamePrefix is the file name we want to read, for example 1.2.156.112605.14038001338998.20180827080014.50.10868.1
%     imgRow is the image width
%     imgCol is the image height
%     varargin is used for setting image number we want to read 
    if length(varargin) == 1 && varargin{1} > 0
        iImageCount = ceil(varargin{1});
    else 
        iImageCount = 0;
    end
    % Index file header size 
    inputOffsetImageFrameHeaderSize = 128+8+8+24+256;
    % Raw image header size
    inputImageFrameHeaderSize       = 256;
    
    % Read raw images 
    [Image, gantryAngle, collimatorAngle, Dose]  = ReadImgOut([filenamePrefix '.raw'], imgRow, imgCol, inputImageFrameHeaderSize, iImageCount);
    % Read offset image
    Offset = ReadOffset([filenamePrefix '.index'], imgRow, imgCol, inputOffsetImageFrameHeaderSize);
    
    % Offset Correction
    Img = zeros(size(Image));
    for i = 1:size(Image, 3)
        
        Img(:, :, i) = Image(:, :, i) - Offset;
        
    end
end

function [Image, gantryAngle, collimatorAngle, Dose] = ReadImgOut(fn, imgRow, imgCol, headerSize, iImageCount)
    imgSize = imgRow * imgCol * 2 + headerSize;
    fid = fopen(fn, 'rb');
    fseek(fid, 0, 1);
    fsize = ftell(fid);
    imgNum = fsize / imgSize;
    assert(iImageCount <= imgNum);
    if iImageCount > 0
        imgNum = iImageCount;
    end
    
    Image = zeros(imgRow, imgCol, imgNum);
    gantryAngle = zeros(imgNum, 1);
    collimatorAngle = zeros(imgNum, 1);
    Dose = zeros(imgNum, 1);
    fseek(fid, 0, -1);
    for i = 1: imgNum
        preData = fread(fid, 64, 'single');
        gantryAngle(i) = preData(27);
        Dose(i) = preData(28);
        collimatorAngle(i) = preData(42);
        d = fread(fid, imgRow * imgCol, 'uint16');
        Image(:, :, i) = reshape(d, imgRow, imgCol);
    end
    
    fclose(fid);
end

function Offset = ReadOffset(fn, imgRow, imgCol, headerSize)
    fid = fopen(fn, 'rb');
    fseek(fid, headerSize, -1);
    data = fread(fid, imgRow * imgCol, 'uint16');
    Offset = reshape(data, imgRow, imgCol);
    fclose(fid);
end