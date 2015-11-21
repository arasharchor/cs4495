% Local Feature Stencil Code
% CS 4495 / 6476: Computer Vision, Georgia Tech
% Written by James Hays

% Returns a set of feature descriptors for a given set of interest points. 

% 'image' can be grayscale or color, your choice.
% 'x' and 'y' are nx1 vectors of x and y coordinates of interest points.
%   The local features should be centered at x and y.
% 'feature_width', in pixels, is the local feature width. You can assume
%   that feature_width will be a multiple of 4 (i.e. every cell of your
%   local SIFT-like feature will have an integer width and height).
% If you want to detect and describe features at multiple scales or
% particular orientations you can add input arguments.

% 'features' is the array of computed features. It should have the
%   following size: [length(x) x feature dimensionality] (e.g. 128 for
%   standard SIFT)

function [features] = get_features(image, x, y, feature_width)

% To start with, you might want to simply use normalized patches as your
% local feature. This is very simple to code and works OK. However, to get
% full credit you will need to implement the more effective SIFT descriptor
% (See Szeliski 4.1.2 or the original publications at
% http://www.cs.ubc.ca/~lowe/keypoints/)

% Your implementation does not need to exactly match the SIFT reference.
% Here are the key properties your (baseline) descriptor should have:
%  (1) a 4x4 grid of cells, each feature_width/4.
%  (2) each cell should have a histogram of the local distribution of
%    gradients in 8 orientations. Appending these histograms together will
%    give you 4x4 x 8 = 128 dimensions.
%  (3) Each feature should be normalized to unit length
%
% You do not need to perform the interpolation in which each gradient
% measurement contributes to multiple orientation bins in multiple cells
% As described in Szeliski, a single gradient measurement creates a
% weighted contribution to the 4 nearest cells and the 2 nearest
% orientation bins within each cell, for 8 total contributions. This type
% of interpolation probably will help, though.

% You do not have to explicitly compute the gradient orientation at each
% pixel (although you are free to do so). You can instead filter with
% oriented filters (e.g. a filter that responds to edges with a specific
% orientation). All of your SIFT-like feature can be constructed entirely
% from filtering fairly quickly in this way.

% You do not need to do the normalize -> threshold -> normalize again
% operation as detailed in Szeliski and the SIFT paper. It can help, though.

% Another simple trick which can help is to raise each element of the final
% feature vector to some power that is less than one.

% Placeholder that you can delete. Empty features.
features = zeros(size(x,1), 128);
[height, width, layers] = size(image);
cutoff_frequency = 2;
small_guassian = fspecial('Gaussian', cutoff_frequency*4+1, cutoff_frequency);
image = imfilter(image, small_guassian);

smooth_filter = fspecial('Gaussian', 2*3+1, 3);

all_gradient = zeros(height, width, 8);
xd = fspecial('sobel')';

all_gradient(:,:,1) = imfilter(imfilter(image, xd), smooth_filter);
all_gradient(:,:,2) = imfilter(imfilter(image, imrotate(xd,45,'bilinear')), smooth_filter);
all_gradient(:,:,3) = imfilter(imfilter(image, imrotate(xd,90,'bilinear')), smooth_filter);
all_gradient(:,:,4) = imfilter(imfilter(image, imrotate(xd,135,'bilinear')), smooth_filter);
all_gradient(:,:,5) = imfilter(imfilter(image, imrotate(xd,180,'bilinear')), smooth_filter);
all_gradient(:,:,6) = imfilter(imfilter(image, imrotate(xd,225,'bilinear')), smooth_filter);
all_gradient(:,:,7) = imfilter(imfilter(image, imrotate(xd,270,'bilinear')), smooth_filter);
all_gradient(:,:,8) = imfilter(imfilter(image, imrotate(xd,315,'bilinear')), smooth_filter);


weight_filter = fspecial('Gaussian', feature_width*2+1, feature_width/2);
for i=1:size(x,1)
    xi = x(i);
    yi = y(i);

    feature_vector = zeros(1,128);
    window = all_gradient(yi-8:yi+7, xi-8:xi+7,:);
    filter = fspecial('gaussian', 5, 8);
    %window = imfilter(window, filter);
        for m = 0:3
            for n = 0:3
                cell4 = window(m*4+1:(m+1)*4, n*4+1:(n+1)*4, :);
                sumg = sum(sum(cell4));
                start = 8*(m*4+n)+1;
                feature_vector(1,start:start+7) = sumg;
                            
            end
        end
    
    norm_factor = 1/norm(feature_vector,1);
    feature_vector = feature_vector*norm_factor;
    maxval = max(feature_vector);
    threshold = 0.2;
    feature_vector(feature_vector > threshold) = threshold;

    norm_factor = 1/norm(feature_vector,1);
    feature_vector = feature_vector*norm_factor;
    size(feature_vector);
    size(features);
    features(i,:) = feature_vector;
    
end

    
end








