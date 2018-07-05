function image = fillBlanks(image)
    
for j=2:size(image, 2)
    prevCol = image(:, j - 1);
    curCol = image(:, j);

    curCol(isnan(curCol)) = prevCol(isnan(curCol));

    image(:, j) = curCol;
end
for j=size(image, 1) - 1:-1:1
    prevRow = image(j + 1, :);
    curRow = image(j, :);

    curRow(isnan(curRow)) = prevRow(isnan(curRow));

    image(j, :) = curRow;
end

for j=size(image, 2) - 1:-1:1
    prevCol = image(:, j + 1);
    curCol = image(:, j);

    curCol(isnan(curCol)) = prevCol(isnan(curCol));

    image(:, j) = curCol;
end

for j=2:size(image, 1)
    prevRow = image(j - 1, :);
    curRow = image(j, :);

    curRow(isnan(curRow)) = prevRow(isnan(curRow));

    image(j, :) = curRow;
end   

end