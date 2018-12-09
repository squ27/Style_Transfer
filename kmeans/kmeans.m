clc
close all
clear
img = imread('../img/7.jpg');
style_img = imread('../output/generated_image.jpg');
img = double(img);
img = imresize(img, 500/size(img,1));
style_img = imresize(style_img, 500/size(style_img,1));

densitymap = double(generateDensityMap(img, 40));
% figure;imshow(detailmap/max(max(detailmap)));

[m, n, ~] = size(img);
k = 2;
locationscale = 1.2;
wd = 1.4;

wx = locationscale * 255/n;
wy = locationscale * 255/m;
m = round(wx*m);
n = round(wy*n);
densitymap = densitymap * 255 * wd / max(max(densitymap));
d = round(max(max(densitymap)));
[y, x] = find(img(:,:,1)<999999999);
r = img(:,:,1);
g = img(:,:,2);
b = img(:,:,3);
im = [r(:) g(:) b(:) wx*x wy*y wd*densitymap(:)];
c1 = [randi([1 255]) randi([1 255]) randi([1 255]) randi([1 n]) randi([1 m]) randi([1 d])];
c2 = [-1 -1 -1 -1 -1 -1];
while sum(c1 == c2) ~= 0 || sum(c2 == -1) ~= 0
    c2 = [randi([1 255]) randi([1 255]) randi([1 255]) randi([1 n]) randi([1 m]) randi([1 d])];
end
lable1 = [];
lable2 = [];
while 1
    dist1 = sum((im - c1).^2,2);
    dist2 = sum((im - c2).^2,2);
    lable1 = find(dist1 < dist2);
    lable2 = find(dist1 >= dist2);
    mean1 = sum(im(lable1,:))/size(im(lable1),1);
    mean2 = sum(im(lable2,:))/size(im(lable2),1);
    if sum(c1 - mean1) == 0 && sum(c2 - mean2) == 0
        break
    end
    c1 = mean1;
    c2 = mean2;
end
im1 = ones(size(im(:,1:3)));
size(im1);
im1(lable1,:) = 0;
im2 = ones(size(im(:,1:3)));
im2(lable2,:) = 0;
im1 = uint8(reshape(im1,size(img)));
im2 = uint8(reshape(im2,size(img)));
% figure; imshow(im1.*uint8(img));
% figure; imshow(im2.*uint8(img));

figure; imshow(uint8(img));
while 1
    try 
        temp = int32(ginput(1));
    catch
        break;
    end
    index = uint8(sum(im1(temp(2), temp(1),:)) == 0);
    imshow((1-index)*im1.*style_img + (1-index)*im2.*uint8(img) + index*im1.*uint8(img) + index*im2.*style_img);
end