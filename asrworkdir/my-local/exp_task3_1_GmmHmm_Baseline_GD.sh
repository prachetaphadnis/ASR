#!/bin/bash
cd ..
#mfcc=$(steps/make_mfcc.sh data/my_test_words data/my_test_words/log data/my_test_words/data)
#mkcmvn=$(steps/compute_cmvn_stats.sh data/my_test_words)

#run decode on own data
for gender in female male
do
decode=$(steps/decode.sh --nj 4 --skip-scoring true exp/tri_15000_2000/graph data/my_test_$gender exp/tri_15000_2000/decode_my_test_$gender)

cd my-local
echo "Running WER for gen=$gender"
score=$(./score_words.sh ../data/my_test_$gender ../exp/tri_15000_2000/graph ../exp/tri_15000_2000/decode_my_test_$gender)
wer=$(cat ../exp/tri_15000_2000/decode_my_test_$gender/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")

test_like=$(cat ../exp/tri_15000_2000/decode_my_test_$gender/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")

echo "Testing log-likelihood:$test_like">>../exp/tri_15000_2000/run_log_mytest_$gender
echo "WER:$wer" >>../exp/tri_15000_2000/run_log_mytest_$gender
cd ..
done
