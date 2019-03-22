#!/bin/bash

if [ $# != 1 ]; then
    echo "Usage: $0 <project-id>"
    echo "E.g. $0 s1043206-asrlab"
    exit 1
fi

gcloud config set project $1

gcloud compute instances create asr-lab4 --zone=us-west1-b --machine-type=n1-standard-4 --subnet=default --network-tier=PREMIUM --maintenance-policy=TERMINATE --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append --accelerator=type=nvidia-tesla-k80,count=1 --image=asr-lab4 --image-project=oklejch-asrlab --boot-disk-size=100GB --boot-disk-type=pd-standard --boot-disk-device-name=asr-lab4
