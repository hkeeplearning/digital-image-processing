function out = ReadRawData(fn, img_row, img_col)
    fid = fopen(fn, 'rb');
    d = fread(fid, 'uint16');
    fclose(fid);
    out = reshape(d, img_row, img_col);
    out = out';
end