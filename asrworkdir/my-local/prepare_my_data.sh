#!/bin/bash
#dir_path='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/data/'
dir='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/data/my_test_words'
#cd $dir_path
if [ ! -d $dir ]
then
mkdir -p $dir
fi

cd $dir
if [ -f text ]
then
rm text
fi

if [ -f wav.scp ]
then
rm wav.scp
fi
if [ -f utt2spk ]
then
rm utt2spk
fi

#change path as required
path='/afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/MyAudio'
while read spk
do
  if [ "$spk" == "a138" ]
  then
    path1=$path/ASR19_OWN-1
  elif [ "$spk" == "a156" ]
  then
    path1=$path/ASR19_OWN-2
  fi
  while read line
   do
    curr_line=$line
    uttid=$( cut -f 1 -d " " <<<$curr_line )
    utt=$( cut -f 2- -d " " <<<$curr_line | tr '[:lower:]' '[:upper:]' )

    echo $spk-$uttid $utt >>text

    echo $spk-$uttid $path1/$uttid.wav >>wav.scp

    echo $spk-$uttid $spk >>utt2spk
  done < /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/my-local/$spk.txt
done < /afs/inf.ed.ac.uk/user/s17/s1789342/asrworkdir/conf/own_test_spk.list
