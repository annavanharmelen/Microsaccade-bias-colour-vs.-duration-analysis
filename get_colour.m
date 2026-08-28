function [colour] = get_colour(colour_name, lightness)
%this function gets the appropriate colour from the colour palette created
%for this project
% simply call the colour you want in the lightness you want
if colour_name == "pink"
    if lightness == "dark"
        colour = hex2rgb("#4D1535");
    elseif lightness == "light"
        colour = hex2rgb("#EC6EB8");
    else
        colour = hex2rgb("#de4596");
    end

elseif colour_name == "red"
    if lightness == "dark"
        colour = hex2rgb("#4D1405");
    elseif lightness == "light"
        colour = hex2rgb("#E76B4A");
    else
        colour = hex2rgb("#de3e27");
    end

elseif colour_name == "green"
    if lightness == "dark"
        colour = hex2rgb("#084D1B");
    elseif lightness == "light"
        colour = hex2rgb("#48C76C");
    else
        colour = hex2rgb("#43b64a");
    end
    
elseif colour_name == "blue"
    if lightness == "dark"
        colour = hex2rgb("#00324D");
    elseif lightness == "light"
        colour = hex2rgb("#40B2F0");
    else
        colour = hex2rgb("#1C96DE");
    end

end