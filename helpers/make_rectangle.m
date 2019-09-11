function rect = make_rectangle(posx, posy, width, height)
% function rect = make_rectangle(posx, posy, width, height)
% 
% outputs a vector of positions [left top right bottom]

rect = [posx - width/2, posy - height/2, posx + width/2, posy + height/2];