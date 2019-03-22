#!/bin/bash
hid_layers=(2 4 6 8 10)
hid_dim=(256 512 1024 2048)
wer=()
idx_g=-1
idx_l=-1
min=1000
for i in "${hid_layers[@]}"
do
  for j in "${hid_dim[@]}"
  do
    wer_temp=$(cat ../exp/tri_nn_$i\_$j\_nnet/run_log|grep -Po "(?<=WER:)[0-9]*\.*[0-9]*")
    wer+=($wer_temp)
  done
done

i=0
for j in "${wer[@]}"
do
  if [ $(echo "$j < $min" | bc) -eq 1 ]
  then
    echo $min
    min=$j
    idx_g=$(( $i/4 ))
    idx_l=$(( $i%4 ))
    echo $min
  fi
  i=$(( $i + 1 ))
done
echo $min
echo $idx_g
echo $idx_l
echo "Best WER gauss: ${hid_layers[$idx_g]} clusters: ${hid_dim[$idx_l]}"
