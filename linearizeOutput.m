%RGB is the vector of RGB triplets on 0:255 which need to be linearized
%gammaTable is a 256x1 lookup table for transformations


function RGB = linearizeOutput(RGB,gammaTable)
% if max(RGB)>1
%     RGB = RGB./255;
% end
% RGB(1) = max(0,RGB(1));
% RGB(2) = max(0,RGB(2));
% RGB(3) = max(0,RGB(3));

R = gammaTable(round(RGB(1)) + 1);
G = gammaTable(round(RGB(2)) + 1);
B = gammaTable(round(RGB(3)) + 1);

RGB = 255.*[R G B];

end

