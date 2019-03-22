#!/bin/bash

#prepare own data
prep=$(./prepare_my_data.sh)
#cd /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/my-local/
spk2utt=$(../utils/utt2spk_to_spk2utt.pl < ../data/my_test_words/utt2spk > ../data/my_test_words/spk2utt)

cd ..
mfcc=$(steps/make_mfcc.sh data/my_test_words data/my_test_words/log data/my_test_words/data)
mkcmvn=$(steps/compute_cmvn_stats.sh data/my_test_words)

#run decode on own data

decode=$(steps/decode.sh --nj 2 --skip-scoring true exp/mono_10000/graph data/my_test_words exp/mono_10000/decode_my_test)

cd my-local
echo "Running WER for mono=10000"
score=$(./score_words.sh ../data/my_test_words ../exp/mono_10000/graph ../exp/mono_10000/decode_my_test)
wer=$(cat ../exp/mono_10000/decode_my_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")

test_like=$(cat ../exp/mono_10000/decode_my_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")

echo "Testing log-likelihood:$test_like">>../exp/mono_10000/run_log_mytest
echo "WER:$wer" >>../exp/mono_10000/run_log_mytest
