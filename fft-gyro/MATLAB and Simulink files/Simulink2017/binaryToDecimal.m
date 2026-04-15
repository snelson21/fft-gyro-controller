function decimal = binaryToDecimal(binaryVector,bitOrder)
    
    binaryVector = binaryVector(:)';
    n = length(binaryVector);

    if strcmpi(bitOrder, 'MSB')
        weights = 2.^(n-1:-1:0); % MSB 
    elseif strcmpi(bitOrder, 'LSB')
        weights = 2.^(0:1:n-1); % LSB 
    else
        weights = 2.^(0:1:n-1); % LSB 
    end

    decimal = sum(binaryVector .* weights);

end