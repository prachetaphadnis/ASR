#!/bin/bash
#dir_path='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/data/'
dir='/home/asrworkdir/ASR19_ALL'
conf='/home/asrworkdir/conf'

if [ -f $conf/asr_all_spk.list ]
then
  rm $conf/asr_all_spk.list
fi
$(ls $dir| grep ^a | grep -v a113 | sort >>$conf/asr_all_spk.list)

data_dir='/home/asrworkdir/data'
#cd $dir_path
for new_dir in my_test
do
  if [ -d $data_dir/$new_dir\_female ]
  then
    rm -r $data_dir/$new_dir\_female
  fi

  if [ -d $data_dir/$new_dir\_male ]
  then
    rm -r $data_dir/$new_dir\_male
  fi
done

for new_dir in my_test
do
  if [ ! -d $data_dir/$new_dir\_female ]
  then
    mkdir -p $data_dir/$new_dir\_female
  fi

  if [ ! -d $data_dir/$new_dir\_male ]
  then
    mkdir -p $data_dir/$new_dir\_male
  fi
done

# echo "Running for TIMIT train test"
# for gender in female male
# do
#   cp $data_dir/train_words/glm $data_dir/train_$gender
#   cp $data_dir/test_words/glm $data_dir/test_$gender
#   for file in cmvn.scp wav.scp text stm utt2spk spk2utt
#   do
#     if [ "$gender" == "female" ]
#     then
#       $(cat $data_dir/train_words/$file| grep ^f >>$data_dir/train_$gender/$file)
#       $(cat $data_dir/test_words/$file| grep ^f >>$data_dir/test_$gender/$file)
#     elif [ "$gender" == "male" ]
#     then
#       $(cat $data_dir/train_words/$file| grep ^m >>$data_dir/train_$gender/$file)
#       $(cat $data_dir/test_words/$file| grep ^m >>$data_dir/test_$gender/$file)
#     fi
#   done
# done
echo "Running for ASR_ALL test"
if [ -f $data_dir/my_test_female/text ]
then
rm $data_dir/my_test_female/text
fi
if [ -f $data_dir/my_test_female/wav.scp ]
then
rm $data_dir/my_test_female/wav.scp
fi
if [ -f $data_dir/my_test_female/utt2spk ]
then
rm $data_dir/my_test_female/utt2spk
fi

if [ -f $data_dir/my_test_male/text ]
then
rm $data_dir/my_test_male/text
fi
if [ -f $data_dir/my_test_male/wav.scp ]
then
rm $data_dir/my_test_male/wav.scp
fi
if [ -f $data_dir/my_test_male/utt2spk ]
then
rm $data_dir/my_test_male/utt2spk
fi

#change path as required
#path='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/MyAudio'
gender_dir='/home/asrworkdir/my-local'
while read spk
do
  spkid=$spk

  gen=$(cat $gender_dir/gender|grep $spkid| cut -f 2 -d " " )
  if [ "$gen" == 'f' ]
  then

    while read line
     do
      curr_line=$line
      uttid=$( cut -f 1 -d " " <<<$curr_line )
      utt=$( cut -f 2- -d " " <<<$curr_line | tr '[:lower:]' '[:upper:]' )

      echo $spkid-$uttid $utt >>$data_dir/my_test_female/text

      echo $spkid-$uttid $dir/$spkid/$uttid.wav >>$data_dir/my_test_female/wav.scp

      echo $spkid-$uttid $spkid >>$data_dir/my_test_female/utt2spk
    done < $dir/$spkid/*.txt
  elif [ "$gen" == 'm' ]
  then

    while read line
     do
      curr_line=$line
      uttid=$( cut -f 1 -d " " <<<$curr_line )
      utt=$( cut -f 2- -d " " <<<$curr_line | tr '[:lower:]' '[:upper:]' )

      echo $spkid-$uttid $utt >>$data_dir/my_test_male/text

      echo $spkid-$uttid $dir/$spkid/$uttid.wav >>$data_dir/my_test_male/wav.scp

      echo $spkid-$uttid $spkid >>$data_dir/my_test_male/utt2spk
    done < $dir/$spkid/00ulist.txt
  fi

done < $conf/asr_all_spk.list

spk2utt1=$(../utils/utt2spk_to_spk2utt.pl < $data_dir/my_test_female/utt2spk > $data_dir/my_test_female/spk2utt)
spk2utt2=$(../utils/utt2spk_to_spk2utt.pl < $data_dir/my_test_male/utt2spk > $data_dir/my_test_male/spk2utt)
