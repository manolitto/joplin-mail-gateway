#!/bin/bash

readonly POP3_USER=$1
readonly POP3_PW=$2

echo "==============================="
echo "`date`"

readonly RXS="(.*)\.([[:alnum:]]{1,4})"

readonly TEMPFOLDER=`mktemp -d`
echo "Using temporary folder: $TEMPFOLDER"

function setCreationDate {
	if [[ "$2" != "" ]]; then
		local DATINT=`date -jf "%Y-%m-%d %H.%M.%S" "$2" +%s`
   		echo "Set creation date $2 (${DATINT}000)"
		joplin set "$1" user_created_time ${DATINT}000
	fi
} 

function addTags {
	for T in $2; do
		echo "Add tag '$T'"
		joplin tag add ${T} "$1"
	done
} 

function setTitle {
	echo "Set title to: $2"
    joplin set "$1" title "$2"
}

function addPdfText {
	echo "Add pdf text body"
	local ORIGBODY=`joplin cat "$1"`
	local TXT=`pdftotext -raw -nopgbrk "$2" -`
	joplin set "$1" body "`echo -e "${ORIGBODY}\n\n---\n${TXT}"`"
}  

function addPdfThumbnails {
	pdftoppm -scale-to 300 -png "$2" "$TEMPFOLDER/thumb"
	find "$TEMPFOLDER" -type f -name "thumb-*.png" -print0 | sort -z | while read -d $'\0' PNG
	do
		echo "Add pdf as image: $PNG"
		joplin attach "$1" "$PNG"
		rm "$PNG"
	done
}  

function addImageText {
	echo "Add image text body"
	local ORIGBODY=`joplin cat "$1"`
	local TXT=`tesseract -l deu+eng "$2" -`
	joplin set "$1" body "`echo -e "${ORIGBODY}\n\n---\n${TXT}"`"
}  

function addLastImageAsLink {
	echo "Add explicit image link"
	local ORIGBODY=`joplin cat "$1"`
	local LASTLINE=`echo "$ORIGBODY" | tail -n 1`
	local LINK=`echo "$LASTLINE" | cut -c 2-999`
	joplin set "$1" body "`echo -e "${ORIGBODY}\n${LINK}\n"`"
}  

function addMarkdownText {
	echo "Add markdown text body"
	local ORIGBODY=`joplin cat "$1"`
	local TXT=`cat "$2"`
	joplin set "$1" body "`echo -e "${ORIGBODY}\n\n---\n${TXT}"`"
}  

function attachFile {
	echo "Attach file: $2"
	joplin attach "$1" "$2"
}  

function getNamePart {
	echo "$1" | sed -E "s/$RXS/\\$2/g"
}  

joplin use Import

echo "Start fetching mails"
getmail_fetch -v -s -p 995 pop.gmail.com "$POP3_USER" "$POP3_PW" ~/joplin-mailbox/

find "/home/manolito/joplin-mailbox/new" -type f -print0 | sort -z | while read -d $'\0' M
do

  echo "processing $M"

  SUBJECT=`cat ${M} | grep "Subject:" | cut -c 10-999`
  echo "Subject: $SUBJECT"

  NOTE=`basename "$M"`
  echo "Create note $NOTE"
  joplin mknote "$NOTE"

  TD=`mktemp -d`
  echo "using temp dir: $TD"

  ~/bin/ripmime -i ${M} --mailbox -d ${TD}

  touch ${TD}/textfile-all
  find "$TD" -type f -print0 | sort -z | while read -d $'\0' F
  do
    if [[ "$F" =~ ^.*\/textfile[0-9]*$ ]] ; then
      echo "text $F"
      cat ${F} >> ${TD}/textfile-all
      rm "$F"
    fi
  done
  BODY=`cat ${TD}/textfile-all`
  joplin set "$NOTE" body "$BODY" 
  rm ${TD}/textfile-all

  find "$TD" -type f -print0 | sort -z | while read -d $'\0' F
  do
    echo "file $F"
    EXT=`getNamePart "$F" "2"`
    echo "Extension: $EXT"
    if [[ "$EXT" == "txt" ]] || [[ "$EXT" == "md" ]]; then
        addMarkdownText "$NOTE" "$F"
    elif [[ "$EXT" == "pdf" ]]; then
        addPdfThumbnails "$NOTE" "$F"
        attachFile "$NOTE" "$F"
        addPdfText "$NOTE" "$F"
    elif [[ "$EXT" == "png" ]] || [[ "$EXT" == "jpg" ]] || [[ "$EXT" == "gif" ]] ; then
        attachFile "$NOTE" "$F"
        addLastImageAsLink "$NOTE"
        addImageText "$NOTE" "$F"
    else
        echo "WARNING: unsupported generic file type $EXT"
        attachFile "$NOTE" "$F"
    fi
    rm "$F"
  done

#  joplin cat -v "$NOTE"

  joplin set "$NOTE" title "$SUBJECT"

  rmdir ${TD}

  mv "$M" "/home/manolito/joplin-mailbox/cur/$NOTE:2"

done

echo "--------------------------"
echo "Finished"

rmdir ${TEMPFOLDER}

joplin sync

