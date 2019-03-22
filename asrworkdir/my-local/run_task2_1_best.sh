#!/bin/bash
#Finding Best Model based on WER
# totgauss=(5000 15000 20000 30000)
# num_leaves=(500 1000 1500 2000 2500 5000)
# wer=()
# idx_g=-1
# idx_l=-1
# min=1000
# for i in "${totgauss[@]}"
# do
#   for j in "${num_leaves[@]}"
#   do
#     wer_temp=$(cat ../exp/tri_$i\_$j/run_log|grep -Po "(?<=WER:)[0-9]*\.*[0-9]*")
#     wer+=($wer_temp)
#   done
# done
#
# i=0
# for j in "${wer[@]}"
# do
#   if [ $(echo "$j < $min" | bc) -eq 1 ]
#   then
#     echo $min
#     min=$j
#     idx_g=$(( $i/6 ))
#     idx_l=$(( $i%6 ))
#     echo $min
#   fi
#   i=$(( $i + 1 ))
# done
# echo $min
# echo $idx_g
# echo $idx_l
# echo "Best WER gauss: ${totgauss[$idx_g]} clusters: ${num_leaves[$idx_l]}"

#Running Best Model
#!/bin/bash
best=10000
i=15000 #totgauss
j=2000 #num_leaves


    echo "Running for totgauss=$i numleaves=$j"
    mkdir -p ../exp/tri_$i\_$j
    chmod 777 ../exp/tri_$i\_$j
    Start_Train=$SECONDS
    train=$(./train_deltas.sh $j $i ../data/train_words ../data/lang_wsj ../exp/mono_$best ../exp/tri_$i\_$j)
    Elapsed_Train=$(( $SECONDS - $Start_Train ))
    Start_Graph=$SECONDS
    graph=$(../utils/mkgraph.sh ../data/lang_wsj_test_bg ../exp/tri_$i\_$j ../exp/tri_$i\_$j/graph)
    Elapsed_Graph=$(( $SECONDS - $Start_Graph))
    Start_Decode=$SECONDS
    decode=$(../steps/decode.sh --nj 4 --skip-scoring true ../exp/tri_$i\_$j/graph ../data/test_words ../exp/tri_$i\_$j/decode_test)
    Elapsed_Decode=$(( $SECONDS - $Start_Decode ))
    echo "Running WER for tri=$i $j"
    score=$(./score_words.sh ../data/test_words ../exp/tri_$i\_$j/graph ../exp/tri_$i\_$j/decode_test)
    wer=$(cat ../exp/tri_$i\_$j/decode_test/scoring_kaldi/best_wer|grep -Po "(?<=WER )[0-9]*\.*[0-9]*")
    train_like=$(../steps/info/gmm_dir_info.pl ../exp/tri_$i\_$j|grep -Po "(?<=prob=)-*[0-9]*\.*[0-9]*")
    test_like=$(cat ../exp/tri_$i\_$j/decode_test/log/decode.1.log|grep -Po "(?<=Overall log-likelihood per frame is )-*[0-9]*\.*[0-9]*")
    echo "Training time:$Elapsed_Train">>../exp/tri_$i\_$j/run_log
    echo "Make graph time:$Elapsed_Graph">>../exp/tri_$i\_$j/run_log
    echo "Decode time:$Elapsed_Decode">>../exp/tri_$i\_$j/run_log
    echo "Training log-likelihood:$train_like">>../exp/tri_$i\_$j/run_log
    echo "Testing log-likelihood:$test_like">>../exp/tri_$i\_$j/run_log
    echo "WER:$wer" >>../exp/tri_$i\_$j/run_log
