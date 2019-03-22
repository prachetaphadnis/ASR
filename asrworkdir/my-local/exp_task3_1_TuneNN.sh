#!/bin/bash
totgauss=15000
num_leaves=2000

hid_layers=(2 4 6 8 10)
hid_dim=(256 512 1024 2048)

dir=data/train_words
cd ..
split_data=$(utils/subset_data_dir_tr_cv.sh $dir ${dir}_tr90 ${dir}_cv10)
cd my-local

for i in "${hid_layers[@]}"
do
  for j in "${hid_dim[@]}"
  do
    echo "Running for hid-layers=$i hid-dim=$j"
    mkdir -p ../exp/tri_nn_$i\_$j
    chmod 777 ../exp/tri_nn_$i\_$j
    mkdir -p ../exp/tri_$totgauss\_$num_leaves\_ali
    chmod 777 ../exp/tri_$totgauss\_$num_leaves\_ali
    mkdir -p ../exp/tri_nn_$i\_$j\_ali
    chmod 777 ../exp/tri_nn_$i\_$j\_ali
    mkdir -p ../exp/tri_nn_$i\_$j\_nnet
    chmod 777 ../exp/tri_nn_$i\_$j\_nnet


    Start_Train=$SECONDS

    cd ..
    align_1=$(steps/align_si.sh --nj 4 data/train_words data/lang_wsj exp/tri_$totgauss\_$num_leaves exp/tri_$totgauss\_$num_leaves\_ali)
    lda_mllt=$(steps/train_lda_mllt.sh --splice-opts "--left-context=3 --right-context=3" $num_leaves $totgauss data/train_words data/lang_wsj exp/tri_$totgauss\_$num_leaves\_ali exp/tri_nn_$i\_$j)
    align_2=$(steps/align_si.sh --nj 4 data/train_words data/lang_wsj exp/tri_nn_$i\_$j exp/tri_nn_$i\_$j\_ali)
    train=$(steps/nnet/train.sh --hid-layers $i --hid-dim $j --splice 5 --learn-rate 0.008 data/train_words_tr90 data/train_words_cv10 data/lang_wsj exp/tri_nn_$i\_$j\_ali exp/tri_nn_$i\_$j\_ali exp/tri_nn_$i\_$j\_nnet)
    Elapsed_Train=$(( $SECONDS - $Start_Train ))
    cd my-local
    Start_Graph=$SECONDS
    graph=$(../utils/mkgraph.sh ../data/lang_wsj_test_bg ../exp/tri_nn_$i\_$j ../exp/tri_nn_$i\_$j/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    Start_Decode=$SECONDS
    cd ..
    decode=$(steps/nnet/decode.sh --nj 4 exp/tri_nn_$i\_$j/graph data/test_words exp/tri_nn_$i\_$j\_nnet/decode_test)
    Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
    cd my-local
    echo "Running WER for tri=$i $j"
    score=$(./score_words.sh ../data/test_words ../exp/tri_$totgauss\_$num_leaves/graph ../exp/tri_nn_$i\_$j\_nnet/decode_test)
    wer=$(cat ../exp/tri_nn_$i\_$j\_nnet/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
    echo "Training time:$Elapsed_Train">>../exp/tri_nn_$i\_$j\_nnet/run_log
    echo "Make graph time:$Elapsed_Graph">>../exp/tri_nn_$i\_$j\_nnet/run_log
    echo "Decode time:$Elapsed_Decode">>../exp/tri_nn_$i\_$j\_nnet/run_log
    echo "WER:$wer" >>../exp/tri_nn_$i\_$j\_nnet/run_log
  done
done
