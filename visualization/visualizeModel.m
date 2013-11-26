function visualizeModel(model,is_inverse)
configs=configsgen;
char_dims = model.char_dims;
r = floor(char_dims(1)/configs.bin_size);
c = floor(char_dims(2)/configs.bin_size);
filter = reshape(model.w,[r,c,configs.n_orients*4]);
if is_inverse
  ihog=invertHOG(filter);
  imshow(ihog)
else
  visualizeHOG(filter)
end
end