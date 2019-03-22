#!/bin/bash
totgauss=10000
#############################################
#Result directories:
#mono_$totgauss_1=with variancce norm
#mono_$totgauss_2=without mean and var norm
#mono_$totgauss_3=no delta_opts
#mono_$totgauss_4=only delta
#############################################
#'--norm-vars true'
#'--cmvn-opts "--norm-means=false"'
#'--add_delta_opts '--delta-order=0'' '--add_delta_opts '--delta-order=1''
options=('--norm-vars true' '--cmvn-opts "--norm-means=false"' '--add_delta_opts "--delta-order=0"' '--add_delta_opts "--delta-order=1"')
j=1
for i in "${options[@]}"
do
  echo "Running for $i"
  mkdir -p ../exp/mono_$totgauss\_$j
  chmod 777 ../exp/mono_$totgauss\_$j
  Start_Train=$SECONDS
  train=$(./train_mono.sh --nj 4 $i ../data/train_words ../data/lang_wsj ../exp/mono_$totgauss\_$j $totgauss)
  Elapsed_Train=$(( $SECONDS - $Start_Train ))
  Start_Graph=$SECONDS
  graph=$(../utils/mkgraph.sh --mono ../data/lang_wsj_test_bg ../exp/mono_$totgauss\_$j ../exp/mono_$totgauss\_$j/graph)
  Elapsed_Graph=$(( $SECONDS - $Start_Graph))
  Start_Decode=$SECONDS
  decode=$(../steps/decode.sh --nj 4 --skip-scoring true ../exp/mono_$totgauss\_$j/graph ../data/test_words ../exp/mono_$totgauss\_$j/decode_test)
  Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
  echo "Running WER for mono=$i"
  score=$(./score_words.sh ../data/test_words ../exp/mono_$totgauss\_$j/graph ../exp/mono_$totgauss\_$j/decode_test)
  wer=$(cat ../exp/mono_$totgauss\_$j/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
  train_like=$(../steps/info/gmm_dir_info.pl ../exp/mono_$totgauss\_$j|grep -Po "(?<=prob=)-*[0-9]*\.*[0-9]*")
  test_like=$(cat ../exp/mono_$totgauss\_$j/decode_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")
  echo "Training time:$Elapsed_Train">>../exp/mono_$totgauss\_$j/run_log
  echo "Make graph time:$Elapsed_Graph">>../exp/mono_$totgauss\_$j/run_log
  echo "Decode time:$Elapsed_Decode">>../exp/mono_$totgauss\_$j/run_log
  echo "Training log-likelihood:$train_like">>../exp/mono_$totgauss\_$j/run_log
  echo "Testing log-likelihood:$test_like">>../exp/mono_$totgauss\_$j/run_log
  echo "WER:$wer" >>../exp/mono_$totgauss\_$j/run_log
  j=$((j + 1))

done
