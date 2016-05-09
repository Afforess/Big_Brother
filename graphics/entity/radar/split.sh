#!/bin/bash
files=(*.png)
count=64
for ((i=${#files[@]}-1; i >= 0; i--)); do
  convert -crop 306x262 "${files[$i]}" tile_%d.png
  for j in {0..3}; do
    mv "tile_$((3-${j})).png" "tile_${count}.png"
    echo "Moving tile_$((3-${j})).png to tile_${count}.png"
    count=$((count-1))
  done
done

