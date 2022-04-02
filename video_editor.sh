#!/bin/sh
# This video editor uses FFMPEG tool
# Files passed to the stdin should be in the same folder as the running program
# The following is the description of the list.txt file:
#   First line is the output file name
#   Each of the next lines are divided into groups of 3:
#     The first line contains the input file name
#     The second line contains the start at which you want to record
#     The third line contains the end at which you want to stop recording
#   Keep adding groups of 3 as you wish :)

#	Read list of videos
i=0
IFS=
while read -r LIST[$i]
do
	i=$(($i + 1))
done < <(tr -d '\r' < list.txt)

#	Prepare for concatenation
mkdir -p ./tmp
i=1
while [ "${LIST[$i]}" ]
do
	if [ $i -ne 1 ]; then
		INPUT="${INPUT}|"
	fi
	j=$((($i - 1) / 3))
	TMP[$j]="./tmp/${j}.ts"
	INPUT="${INPUT}${TMP[$j]}"
	COMMAND="ffmpeg"
	COMMAND="${COMMAND} -ss ${LIST[$(($i + 1))]}.00"
	COMMAND="${COMMAND} -to ${LIST[$(($i + 2))]}.99"
	COMMAND="${COMMAND} -i \"${LIST[$i]}\" -c copy -bsf:v h264_mp4toannexb -f mpegts \"${TMP[$j]}\""
	eval "${COMMAND}"
	i=$(($i + 3))
done

#	Concatenate the list
ffmpeg -i "concat:${INPUT}" -y -c copy -bsf:a aac_adtstoasc "${LIST[0]}.mp4"

#	Remove temporary files
i=0
while [ "${TMP[$i]}" ]
do
	rm -f "${TMP[$i]}"
	i=$(($i + 1))
done
