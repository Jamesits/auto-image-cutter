% Automatic image cutter
% https://github.com/Jamesits/auto-image-cutter
%
% Copyright (C) 2015 James Swineson
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.


% ======================== Settings ========================

% Source image path. Should be valid image file.
image_path = 'sample/sample.bmp';

% Output image filename format. Should be vaild format string.
% CAUTION: any file with the same name will be OVERWRITTEN without warning!
output_filename_format = [image_path, '.cut%03d.bmp'];

% Bleed(pixels): Make actual cut position wider slightly, to avoid lose of
% some part of character. Usually more extra width is needed on the right
% side.
left_bleed = 8;
right_bleed = 12;

% Value from 0 to 1: a bigger offset will darken binarized image. Typically
% a bigger value makes the image looking better, but will bring bigger
% possibility of false positive result.
bw_threshold_detect_offset = 0.61803398874989484820458683436;

% Value from 0 to 1: a bigger threshold requires more blank pixels in a
% column to be detected as a blank column. A bigger value will lead to
% more narrow blank column.
blank_column_lightness_threshold = 0.985211;

% The minimal distance of two character blocks which will not be treated as
% one block for being too near.
run_length_encoding_minimal_distance = 10;
% ====================== Settings End ======================

% ========================= Program ========================

disp('Automatic image cutter version 1.0.2, Copyright (C) 2015 James Swineson');
disp('Automatic image cutter comes with ABSOLUTELY NO WARRANTY; for details see LICENSE.');
disp('This is free software, and you are welcome to redistribute it under certain conditions.');

% read source image
tic;
disp(strcat('[INFO]Reading image from''', image_path, '''...'));
source = imread(image_path);
figure(1);
imshow(source, 'InitialMagnification', 'fit');
title(strcat('Source Image: ', image_path));
toc;

% generate lightness histogram
tic;
disp('[INFO]Generating histogram...');
totalpixelnum = size(source, 2) * size(source, 1);
phistogram = zeros(1, 128);
for col = 1 : size(source, 2)
  for row = 1 : size(source, 1)
    lightness = int8(sum(source(row, col)) / 3 + 1);
    if (phistogram(1, lightness) < totalpixelnum / 8)
        phistogram(1, lightness) = phistogram(1, lightness) + 1;
    end
  end
end
x = 1 : 1 : 128;
figure(2);
findpeaks(phistogram, x, 'MinPeakProminence', 0.2 * max(phistogram), 'MinPeakDistance', 20); % draw the figure
title('Histogram');
xlabel('Brightness');
ylabel('Pixel Count');
toc;

% automatically figure out threshold based on histogram, then perform binarization
tic;
disp('[INFO]Running binarization process...');
[pks,locs] = findpeaks(phistogram, x, 'MinPeakProminence', 0.2 * max(phistogram), 'MinPeakDistance', 20);
bwthreshold = double(((max(locs) - min(locs)) * bw_threshold_detect_offset + min(locs)) ./ 128);
disp(num2str(bwthreshold * 100, '[INFO]Binarization threshold %.2f%%.'));
bwimage = im2bw(source, bwthreshold);
figure(3);
imshow(bwimage, 'InitialMagnification', 'fit');
title('Binarized Image');
toc;

% calculate average brightness
tic;
disp('[INFO]Detecting text areas...');
colavg = sum(bwimage);
x = 1 : 1 : size(colavg, 2);
guideline = zeros(size(colavg, 2)) + blank_column_lightness_threshold * max(colavg);
figure(4);
plot(x, colavg, x, guideline);
title('Colomn Average Brightness');
xlabel('Colomn');
ylabel('Total Black Point Count');
toc;

% figure out where to cut
tic;
figure(5);
text_area = find(colavg < blank_column_lightness_threshold * max(colavg));
histogram(text_area, size(colavg, 2));
title('Text Area (Sketch)');

% perform run length encoding
% reference: ihoque.bol.ucla.edu/presentation.ppt

text_area_edge_position = {text_area(1)};

for i = 2 : size(text_area, 2) - 1
    if text_area(i) >= text_area(i-1) + run_length_encoding_minimal_distance
        text_area_edge_position = [text_area_edge_position text_area(i - 1) text_area(i)]; %#ok<AGROW>
    end
end
text_area_edge_position = [text_area_edge_position text_area(size(text_area, 2))]; % append last value
text_area_edge_position = [text_area_edge_position{:}]; % convert from cell to 1D matrix
disp('[INFO]Text area edge:');
for i = 1 : 2 : size(text_area_edge_position, 2)
    disp([char(9), num2str([text_area_edge_position(i), text_area_edge_position(i + 1)], '[%d, %d]')]);
end
toc;

% cut and save image
tic;
disp('[INFO]Saving images...');
for i = 1 : 2 : size(text_area_edge_position, 2)
    filename = num2str((i + 1) ./ 2, output_filename_format);
    disp([char(9), filename]);
    imwrite(imcrop(bwimage, [text_area_edge_position(i) - left_bleed, 0, text_area_edge_position(i + 1) - text_area_edge_position(i) + left_bleed + right_bleed , size(bwimage, 1)]), filename);
end
toc;

disp('[INFO]Program finished.');
% ======================= Program End ======================
