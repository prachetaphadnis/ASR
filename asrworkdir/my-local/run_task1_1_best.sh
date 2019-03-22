#!/bin/bash

#Finding best gaussian based on WER
# totgauss=(1 10 100 1000 2000 5000 10000 11000 13000 15000 17000 20000)
# wer=()
# idx=-1
# min=1000
# for i in "${totgauss[@]}"
# do
#   wer_temp=$(cat ../exp/mono_$i/run_log|grep -Po "(?<=WER:)[0-9]*\.*[0-9]*")
#   wer+=($wer_temp)
# done
#
# i=0
# for j in "${wer[@]}"
# do
#   if [ $(echo "$j < $min" | bc) -eq 1 ]
#   then
#     echo $min
#     min=$j
#     idx=$i
#     echo $min
#   fi
#   i=$(( $i + 1 ))
# done
#
# echo "Best WER: ${totgauss[$idx]}"

#Running best model
i=10000 #i is totgauss

  echo "Running for totgauss=$i"
  mkdir -p ../exp/mono_$i
  chmod 777 ../exp/mono_$i
  Start_Train=$SECONDS
  train=$(./train_mono.sh --nj 4 ../data/train_words ../data/lang_wsj ../exp/mono_$i $i)
  Elapsed_Train=$(( $SECONDS - $Start_Train ))
  Start_Graph=$SECONDS
  graph=$(../utils/mkgraph.sh --mono ../data/lang_wsj_test_bg ../exp/mono_$i ../exp/mono_$i/graph)
  Elapsed_Graph=$(( $SECONDS - $Start_Graph))
  Start_Decode=$SECONDS
  decode=$(../steps/decode.sh --nj 4 --skip-scoring true ../exp/mono_$i/graph ../data/test_words ../exp/mono_$i/decode_test)
  Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
  echo "Running WER for mono=$i"
  score=$(./score_words.sh ../data/test_words ../exp/mono_$i/graph ../exp/mono_$i/decode_test)
  wer=$(cat ../exp/mono_$i/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
  train_like=$(../steps/info/gmm_dir_info.pl ../exp/mono_$i|grep -Po "(?<=prob=)-*[0-9]*\.*[0-9]*")
  test_like=$(cat ../exp/mono_$i/decode_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")
  echo "Training time:$Elapsed_Train">>../exp/mono_$i/run_log
  echo "Make graph time:$Elapsed_Graph">>../exp/mono_$i/run_log
  echo "Decode time:$Elapsed_Decode">>../exp/mono_$i/run_log
  echo "Training log-likelihood:$train_like">>../exp/mono_$i/run_log
  echo "Testing log-likelihood:$test_like">>../exp/mono_$i/run_log
  echo "WER:$wer" >>../exp/mono_$i/run_log
