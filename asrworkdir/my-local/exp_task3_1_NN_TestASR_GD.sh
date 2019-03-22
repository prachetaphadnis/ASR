#!/bin/bash

#prepare own data
#prep=$(./prepare_my_data.sh)
#cd /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/my-local/
#spk2utt=$(../utils/utt2spk_to_spk2utt.pl < ../data/my_test_words/utt2spk > ../data/my_test_words/spk2utt)
i=6
j=1024
cd ..

# for dir in my_test
# do
#   echo "Running MFCC for $dir"
#   mfcc=$(steps/make_mfcc.sh data/$dir\_female data/$dir\_female/log data/$dir\_female/data)
#   mfcc=$(steps/make_mfcc.sh data/$dir\_male data/$dir\_male/log data/$dir\_male/data)
#   echo "Running cmvn for $dir"
#   mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_female)
#   mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_male)
# done
#mfcc=$(steps/make_mfcc.sh data/my_test_words data/my_test_words/log data/my_test_words/data)
#mkcmvn=$(steps/compute_cmvn_stats.sh data/my_test_words)

#run decode on own data
for gender in male
do
decode=$(steps/nnet/decode.sh --nj 4  --skip-scoring true exp/tri_nn_$i\_$j\_$gender/graph data/my_test_$gender exp/tri_nn_$i\_$j\_nnet_$gender/decode_test_$gender)
cd my-local
echo "Running WER for gender=$gender"
score=$(./score_words.sh ../data/my_test_$gender ../exp/tri_$gender/graph ../exp/tri_nn_$i\_$j\_nnet_$gender/decode_test_$gender)
wer=$(cat ../exp/tri_nn_$i\_$j\_nnet_$gender/decode_test_$gender/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
echo "Training time:$Elapsed_Train">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log_$gender
echo "Make graph time:$Elapsed_Graph">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log_$gender
echo "Decode time:$Elapsed_Decode">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log_$gender
echo "WER:$wer" >>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log_$gender
cd ..
done
