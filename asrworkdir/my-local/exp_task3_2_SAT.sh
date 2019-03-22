#!/bin/bash
totgauss=15000
num_leaves=2000

i=6 #hid-layers
j=1024 #hid-dim

echo "Starting prepare data"
#prepare own data
$(./prepare_asr_all_gcloud.sh)

echo "Prepare data ended"
cd ..
for dir in test_asr_all
do
  echo "Running MFCC for $dir"
  mfcc=$(steps/make_mfcc.sh data/$dir data/$dir/log data/$dir/data)
  echo "Running cmvn for $dir"
  mkcmvn=$(steps/compute_cmvn_stats.sh data/$dir)
done

dir=data/train

split_data=$(utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10)

cd my-local


    echo "Running for gender=$gender"
    mkdir -p ../exp/tri_nn_$i\_$j\_fmllr
    chmod 777 ../exp/tri_nn_$i\_$j\_fmllr
    mkdir -p ../exp/tri_$totgauss\_$num_leaves\_ali_fmllr
    chmod 777 ../exp/tri_$totgauss\_$num_leaves\_ali_fmllr
    mkdir -p ../exp/tri_nn_$i\_$j\_ali_fmllr
    chmod 777 ../exp/tri_nn_$i\_$j\_ali_fmllr
    mkdir -p ../exp/tri_nn_$i\_$j\_nnet_fmllr
    chmod 777 ../exp/tri_nn_$i\_$j\_nnet_fmllr


    Start_Train=$SECONDS

    cd ..
    train=$(steps/train_mono.sh --nj 4 --totgauss 10000 data/train_words data/lang_wsj exp/mono_fmllr)
    train=$(steps/train_deltas.sh 2000 15000 data/train_words data/lang_wsj exp/mono_fmllr exp/tri_fmllr)
    Start_Graph=$SECONDS
    graph=$(utils/mkgraph.sh data/lang_wsj_test_bg exp/tri_fmllr exp/tri_fmllr/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    align_1=$(steps/align_si.sh --nj 4 data/train_words data/lang_wsj exp/tri_fmllr exp/tri_ali_fmllr)
    dim_reduce=$(steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3" $num_leaves $totgauss data/train_words data/lang_wsj exp/tri_ali_fmllr exp/tri_lda_$i\_$j\_fmllr)
    align_2=$(steps/align_fmllr.sh --nj 4 data/train_words data/lang_wsj exp/tri_lda_$i\_$j\_fmllr exp/tri_lda_$i\_$j\_ali_fmllr)
    fmllr=$(steps/train_sat.sh $num_leaves $totgauss data/train_words data/lang_wsj exp/tri_lda_$i\_$j\_ali_fmllr exp/tri_nn_$i\_$j\_fmllr)
    align_3=$(steps/align_fmllr.sh --nj 4 data/train_words data/lang_wsj exp/tri_nn_$i\_$j\_fmllr exp/tri_nn_$i\_$j\_ali_fmllr)
    train=$(steps/nnet/train.sh --hid-layers $i --hid-dim $j --splice 5 --learn-rate 0.008 data/train_words_tr90 data/train_words_cv10 data/lang_wsj exp/tri_nn_$i\_$j\_ali_fmllr exp/tri_nn_$i\_$j\_ali_fmllr exp/tri_nn_$i\_$j\_nnet_fmllr)
    Elapsed_Train=$(( $SECONDS - $Start_Train ))
    cd my-local
    Start_Graph=$SECONDS
    graph=$(../utils/mkgraph.sh ../data/lang_wsj_test_bg ../exp/tri_nn_$i\_$j\_fmllr ../exp/tri_nn_$i\_$j\_fmllr/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    Start_Decode=$SECONDS
    cd ..
    decode=$(steps/nnet/decode.sh --nj 4 --skip-scoring true exp/tri_nn_$i\_$j\_fmllr/graph data/test_words exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test)
    decode_all=$(steps/nnet/decode.sh --nj 4 --skip-scoring true exp/tri_nn_$i\_$j\_fmllr/graph data/test_asr_all exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test_asrall)
    Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
    cd my-local
    echo "Running WER"
    score=$(./score_words.sh ../data/test_words ../exp/tri_fmllr/graph ../exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test)
    wer=$(cat ../exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")

    score=$(./score_words.sh ../data/test_asr_all ../exp/tri_fmllr/graph ../exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test_asrall)
    wer2=$(cat ../exp/tri_nn_$i\_$j\_nnet_fmllr/decode_test_asrall/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
    echo "Training time:$Elapsed_Train">>../exp/tri_nn_$i\_$j\_nnet_fmllr/run_log
    echo "Make graph time:$Elapsed_Graph">>../exp/tri_nn_$i\_$j\_nnet_fmllr/run_log
    echo "Decode time:$Elapsed_Decode">>../exp/tri_nn_$i\_$j\_nnet_fmllr/run_log
    echo "WER:$wer" >>../exp/tri_nn_$i\_$j\_nnet_fmllr/run_log
    echo "WER:$wer2" >>../exp/tri_nn_$i\_$j\_nnet_fmllr/run_log
