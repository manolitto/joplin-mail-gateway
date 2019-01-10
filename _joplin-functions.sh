#!/usr/bin/env bash

## Usage: addImageText note-id image-file
function addImageText {
	echo "Add image text body"
	local ORIG_BODY=`joplin cat "$1"`
	local TXT=`tesseract -l deu+eng "$2" -`
	joplin set "$1" body "`echo -e "${ORIG_BODY}\n\n---\n${TXT}"`"
}

