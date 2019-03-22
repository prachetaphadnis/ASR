#!/bin/bash
totgauss=15000
num_leaves=2000

i=6 #hid-layers
j=1024 #hid-dim

echo "Starting prepare data"
#prepare own data
$(./separate_gender_gcloud.sh)
#cd /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/my-local/
#spk2utt=$(../utils/utt2spk_to_spk2utt.pl < ../data/my_test_words/utt2spk > ../data/my_test_words/spk2utt)
echo "Prepare data ended"
cd ..
for dir in train test
do
  echo "Running MFCC for $dir"
  mfcc=$(steps/make_mfcc.sh data/$dir\_female data/$dir\_female/log data/$dir\_female/data)
  mfcc=$(steps/make_mfcc.sh data/$dir\_male data/$dir\_male/log data/$dir\_male/data)
  echo "Running cmvn for $dir"
  mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_female)
  mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir\_male)
done

dir_f=data/train_female
dir_m=data/train_male

split_data=$(utils/subset_data_dir_tr_cv.sh $dir_f ${dir_f}_tr90 ${dir_f}_cv10)
split_data=$(utils/subset_data_dir_tr_cv.sh $dir_m ${dir_m}_tr90 ${dir_m}_cv10)

cd my-local

for gender in female male
do
    echo "Running for gender=$gender"
    mkdir -p ../exp/tri_nn_$i\_$j\_$gender
    chmod 777 ../exp/tri_nn_$i\_$j\_$gender
    mkdir -p ../exp/tri_$totgauss\_$num_leaves\_ali_$gender
    chmod 777 ../exp/tri_$totgauss\_$num_leaves\_ali_$gender
    mkdir -p ../exp/tri_nn_$i\_$j\_ali_$gender
    chmod 777 ../exp/tri_nn_$i\_$j\_ali_$gender
    mkdir -p ../exp/tri_nn_$i\_$j\_nnet_$gender
    chmod 777 ../exp/tri_nn_$i\_$j\_nnet_$gender


    Start_Train=$SECONDS

    cd ..
    train=$(steps/train_mono.sh --nj 4 --totgauss 10000 data/train_$gender data/lang_wsj exp/mono_$gender)
    train=$(steps/train_deltas.sh 2000 15000 data/train_$gender data/lang_wsj exp/mono_$gender exp/tri_$gender)
    Start_Graph=$SECONDS
    graph=$(utils/mkgraph.sh data/lang_wsj_test_bg exp/tri_$gender exp/tri_$gender/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    align_1=$(steps/align_si.sh --nj 4 data/train_$gender data/lang_wsj exp/tri_$gender exp/tri_$totgauss\_$num_leaves\_ali_$gender)
    dim_reduce=$(steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3" $num_leaves $totgauss data/train_$gender data/lang_wsj exp/tri_$totgauss\_$num_leaves\_ali_$gender exp/tri_nn_$i\_$j\_$gender)
    align_2=$(steps/align_si.sh --nj 4 data/train_$gender data/lang_wsj exp/tri_nn_$i\_$j\_$gender exp/tri_nn_$i\_$j\_ali_$gender)
    train=$(steps/nnet/train.sh --hid-layers $i --hid-dim $j --splice 5 --learn-rate 0.008 data/train_$gender\_tr90 data/train_$gender\_cv10 data/lang_wsj exp/tri_nn_$i\_$j\_ali_$gender exp/tri_nn_$i\_$j\_ali_$gender exp/tri_nn_$i\_$j\_nnet_$gender)
    Elapsed_Train=$(( $SECONDS - $Start_Train ))
    cd my-local
    Start_Graph=$SECONDS
    graph=$(../utils/mkgraph.sh ../data/lang_wsj_test_bg ../exp/tri_nn_$i\_$j\_$gender ../exp/tri_nn_$i\_$j\_$gender/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    Start_Decode=$SECONDS
    cd ..
    decode=$(steps/nnet/decode.sh --nj 4 exp/tri_nn_$i\_$j\_$gender/graph data/test_$gender exp/tri_nn_$i\_$j\_nnet_$gender/decode_test)
    Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
    cd my-local
    echo "Running WER for gender=$gender"
    score=$(./score_words.sh ../data/test_$gender ../exp/tri_$gender/graph ../exp/tri_nn_$i\_$j\_nnet_$gender/decode_test)
    wer=$(cat ../exp/tri_nn_$i\_$j\_nnet_$gender/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
    echo "Training time:$Elapsed_Train">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log
    echo "Make graph time:$Elapsed_Graph">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log
    echo "Decode time:$Elapsed_Decode">>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log
    echo "WER:$wer" >>../exp/tri_nn_$i\_$j\_nnet_$gender/run_log
  done
