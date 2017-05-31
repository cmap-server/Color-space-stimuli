color = 'blue';

switch color
    case 'red'
        RGB = [1 0 0];
    case 'green'
        RGB = [0 1 0];
    case 'blue'
        RGB = [0 0 1];
    case 'white'
        RGB = [0 0 0];
end

img = zeros(1080,1920,3);
img(:,:,1) = RGB(1);
img(:,:,2) = RGB(2);
img(:,:,3) = RGB(3);
figure
imshow(img)