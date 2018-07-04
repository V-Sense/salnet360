function [patch ind phi theta] = extractPatch(img, offsetX, offsetY, verticalPx, horizontalPx)

verticalFOV = 90; %deg
horizontalFOV = 90; %deg
degToRad = pi/180;

cosPhi = cos(offsetY*degToRad);
sinPhi = sin(offsetY*degToRad);
cosTheta = cos(offsetX*degToRad);
sinTheta = sin(offsetX*degToRad);

x = [-horizontalPx/2 + 0.5:1:horizontalPx/2];
y = [verticalPx/2 - 0.5:-1:-verticalPx/2];
z = ones(verticalPx, horizontalPx)*horizontalPx/(2*tan(horizontalFOV*degToRad/2));

x = repmat(x, verticalPx, 1);
y = repmat(y', 1, horizontalPx);

x2 = x*cosPhi + sinPhi*(y*sinTheta + z*cosTheta);
y2 = y*cosTheta - z*sinTheta;
z2 = -x*sinPhi + cosPhi*(y*sinTheta + z*cosTheta);

n = sqrt(x2.^2 + y2.^2 + z2.^2);

x = x2./n;
y = y2./n;
z = z2./n;

phi = asin(y);
theta = atan(x./z);

thetaSign = (z < 0)*pi;
theta = theta + thetaSign;

imWidth = size(img, 2);
imHeight = size(img, 1);

phiPx = (phi + pi/2)/pi*imHeight;
thetaPx = (theta + pi/2)/(2*pi)*imWidth;

xCoord = uint16(thetaPx);
yCoord = uint16(phiPx);

yCoord = imHeight - yCoord;

xCoord(xCoord == 0) = 1;
yCoord(yCoord == 0) = 1;

if(size(img, 3) == 3)
    R = img(:, :, 1);
    G = img(:, :, 2);
    B = img(:, :, 3);

    ind = sub2ind([imHeight imWidth], yCoord, xCoord);

    patch(:, :, 1) = R(ind);
    patch(:, :, 2) = G(ind);
    patch(:, :, 3) = B(ind);
else
   ind = sub2ind([imHeight imWidth], yCoord, xCoord);
   
   patch = img(ind);
end

end