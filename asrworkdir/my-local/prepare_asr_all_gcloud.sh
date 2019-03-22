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

if [ -d $data_dir/test_asr_all ]
then
  rm -r $data_dir/test_asr_all
fi
if [ ! -d $data_dir/test_asr_all ]
then
  mkdir -p $data_dir/test_asr_all
fi

echo "Running for ASR_ALL test"
if [ -f $data_dir/test_asr_all/text ]
then
rm $data_dir/test_asr_all/text
fi
if [ -f $data_dir/test_asr_all/wav.scp ]
then
rm $data_dir/test_asr_all/wav.scp
fi
if [ -f $data_dir/test_asr_all/utt2spk ]
then
rm $data_dir/test_asr_all/utt2spk
fi

#change path as required
#path='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/MyAudio'
gender_dir='/home/asrworkdir/my-local'
while read spk
do
  spkid=$spk
    while read line
     do
      curr_line=$line
      uttid=$( cut -f 1 -d " " <<<$curr_line )
      utt=$( cut -f 2- -d " " <<<$curr_line | tr '[:lower:]' '[:upper:]' )

      echo $spkid-$uttid $utt >>$data_dir/test_asr_all/text

      echo $spkid-$uttid $dir/$spkid/$uttid.wav >>$data_dir/test_asr_all/wav.scp

      echo $spkid-$uttid $spkid >>$data_dir/test_asr_all/utt2spk
    done < $dir/$spkid/00ulist.txt

done < $conf/asr_all_spk.list

spk2utt1=$(../utils/utt2spk_to_spk2utt.pl < $data_dir/test_asr_all/utt2spk > $data_dir/test_asr_all/spk2utt)
spk2utt2=$(../utils/utt2spk_to_spk2utt.pl < $data_dir/test_asr_all/utt2spk > $data_dir/test_asr_all/spk2utt)
