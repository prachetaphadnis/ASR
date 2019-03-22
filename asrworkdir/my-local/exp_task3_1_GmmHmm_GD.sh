#!/bin/bash

echo "Starting prepare data"
#prepare own data
$(./separate_gender.sh)
#cd /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/my-local/
#spk2utt=$(../utils/utt2spk_to_spk2utt.pl < ../data/my_test_words/utt2spk > ../data/my_test_words/spk2utt)
echo "Prepare data ended"
cd ..
for dir in train test my_test
do
  echo "Running MFCC for $dir"
  mfcc=$(steps/make_mfcc.sh data/$dir\_female data/$dir\_female/log data/$dir\_female/data)
  mfcc=$(steps/make_mfcc.sh data/$dir\_male data/$dir\_male/log data/$dir\_male/data)
  echo "Running cmvn for $dir"
  mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_female)
  mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_male)
done

cd my-local

for i in female male
do
  echo "Running for gender=$i"
  mkdir -p ../exp/mono_$i
  chmod 777 ../exp/mono_$i
  mkdir -p ../exp/tri_$i
  chmod 777 ../exp/tri_$i
  cd ..
  Start_Train=$SECONDS
  train=$(steps/train_mono.sh --nj 4 --totgauss 10000 data/train_$i data/lang_wsj exp/mono_$i)
  train=$(steps/train_deltas.sh 2000 15000 data/train_$i data/lang_wsj exp/mono_$i exp/tri_$i)
  Elapsed_Train=$(( $SECONDS - $Start_Train ))
  Start_Graph=$SECONDS
  graph=$(utils/mkgraph.sh data/lang_wsj_test_bg exp/tri_$i exp/tri_$i/graph)
  Elapsed_Graph=$(( $SECONDS - $Start_Graph))
  Start_Decode=$SECONDS
  decode=$(steps/decode.sh --nj 4 --skip-scoring true exp/tri_$i/graph data/test_$i exp/tri_$i/decode_test)
  Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
  cd my-local
  echo "Running WER for gender=$i"
  score=$(./score_words.sh ../data/test_$i ../exp/tri_$i/graph ../exp/tri_$i/decode_test)
  wer=$(cat ../exp/tri_$i/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
  train_like=$(../steps/info/gmm_dir_info.pl ../exp/tri_$i|grep -Po "(?<=prob=)-*[0-9]*\.*[0-9]*")
  test_like=$(cat ../exp/tri_$i/decode_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")
  echo "Training time:$Elapsed_Train">>../exp/tri_$i/run_log
  echo "Make graph time:$Elapsed_Graph">>../exp/tri_$i/run_log
  echo "Decode time:$Elapsed_Decode">>../exp/tri_$i/run_log
  echo "Training log-likelihood:$train_like">>../exp/tri_$i/run_log
  echo "Testing log-likelihood:$test_like">>../exp/tri_$i/run_log
  echo "WER:$wer" >>../exp/tri_$i/run_log

done
  cd ..
#mfcc=$(steps/make_mfcc.sh data/my_test_words data/my_test_words/log data/my_test_words/data)
#mkcmvn=$(steps/compute_cmvn_stats.sh data/my_test_words)

#run decode on own data
for gender in female male
do
decode=$(steps/decode.sh --nj 4 --skip-scoring true exp/tri_$gender/graph data/my_test_$gender exp/tri_$gender/decode_my_test)

cd my-local
echo "Running WER for gen=$gender"
score=$(./score_words.sh ../data/my_test_$gender ../exp/tri_$gender/graph ../exp/tri_$gender/decode_my_test)
wer=$(cat ../exp/tri_$gender/decode_my_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")

test_like=$(cat ../exp/tri_$gender/decode_my_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")

echo "Testing log-likelihood:$test_like">>../exp/tri_$gender/run_log_mytest
echo "WER:$wer" >>../exp/tri_$gender/run_log_mytest
cd ..
done
