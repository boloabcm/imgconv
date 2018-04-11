#!/bin/bash
# Project: Image converter
# File: imgconv.sh
# Version: 0.1
# Create by: Rom1 <rom1@canel.ch> - CANEL - https://www.canel.ch
# Date: 11/04/2018
# Licence: GNU GENERAL PUBLIC LICENSE v3
# Language: Bash
# Description: Script pour convertir des images

exif_data_artist="Musée Bolo"
exif_data_copyright="CC-BY-SA"

dest="$(pwd)/cpy"
logo="$(pwd)/logo.png"

logo_padding=10
logo_size_x=$(identify -format %w ${logo})
logo_size_y=$(identify -format %h ${logo})

exif_modif_data=0
exif_only=0
extension="jpg"
script_aw=0

usage()
{
	echo "Usage: $(basename $0)  [-ehjopw] [-x <width>] [-y <height>]  <file> [...] | <directory>"
	echo -e "\t-e\tModify exif"
	echo -e "\t-o\tModify only exif"
	echo -e "\t-h\thelp"
	echo -e "\t-j\tConvert to JPG"
	echo -e "\t-p\tConvert to PNG"
	echo -e "\t-w\tUse script Autowhite"
	echo -e "\t-x <x>\tResize image width"
	echo -e "\t-y <y>\tResize image height"
}


exifModifData()
{
	file="$1"
	[ -z "$file" ] && return 1
	exiftool -q -overwrite_original \
		 -Artist="${exif_data_artist}" \
		 -Copyright="${exif_data_copyright}" \
		 ${file}
}


convertion()
{
	image="$1"
	name=$(basename $image)
	[ -z "$extension" ] && extension=${name##*.}
	converted=${dest}/${name%.*}.${extension}

	convert -resize "$px_x"x"$px_y" \
		${image} ${converted}
	[ $? -ne 0 ] && return 1

	[ $script_aw -eq 1 ] && bash autowhite -m 1 ${converted} ${converted}

	composite -compose Over -geometry \
		  +${logo_padding}+$(expr $(identify -format %H ${converted}) - ${logo_size_y} - ${logo_padding}) ${logo} \
		  ${converted} ${converted}
	[ $? -ne 0 ] && return 1

	return 0
}


modify()
{
	file="$1"

	echo -n "${file} "

	if [ $exif_modif_data -eq 1 ]
	then
		exifModifData "$file"
		[ $? -ne 0 ] && echo "[KO]" && return 1

	fi

	if [ -f "$file" -a $exif_only -ne 1 ]
	then
		convertion "$file"
		[ $? -ne 0 ] && echo "[KO]" && return 1
	fi
	echo "[OK]"
}

trap 'echo "CANCEL" ; exit 1' INT

while getopts "ehjopwx:y:" sel
do
	case $sel in
		e)
			exif_modif_data=1
			;;
		h)
			usage
			exit 0
			;;
		j)
			extension="jpg"
			;;
		o)
			exif_only=1
			;;
		p)
			extension="png"
			;;
		w)
			script_aw=1
			;;
		x)
			if [[ "$OPTARG" =~ ^[0-9]+$ ]]
				then
				px_x="$OPTARG"
			else
				echo "Error: Bad width value"
				usage
				exit 1
			fi
			;;
	 	y)
			if [[ "$OPTARG" =~ ^[0-9]+$ ]]
			then
				px_y="$OPTARG"
			else
				echo "Error: Bad height value"
				usage
				exit 1
			fi
			;;
		*)
			echo "Error: Bad argument"
			usage
			exit 1
			;;
	esac
done

shift $((OPTIND-1))


[ -z "$px_x" -a -z "$px_y" ] && px_x=1000
[ ! -d "$dest" -a $exif_only -ne 1 ] && mkdir -p $dest


if [ -d "$1" -a -z "$2" ]
then
	for file in $(find ${1} -maxdepth 1 -type f -print)
	do
		modify "$file"
	done
elif [ -f "$1" ]
then
	for file
	do
		modify "$file"
		shift
	done
else
	echo "Error: Choose a directory or file(s)"
	usage
	exit 1
fi


exit 0
