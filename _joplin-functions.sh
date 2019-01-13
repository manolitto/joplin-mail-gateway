#!/usr/bin/env bash

#---
## Create a new Joplin note
## Usage: createNewNote notebook unique-name
## @return the note id
#---
function createNewNote {
    joplin use "$1"
    joplin mknote "$2"
    local LS_OUTPUT=(`joplin ls -l "$2"`)
    echo ${LS_OUTPUT[0]}
}

#---
## Usage: setNoteTitle note-id title
#---
function setNoteTitle {
    local TITLE="$2"
    if [[ "${TITLE}x" == "x" ]] ; then
        TITLE="${DEFAULT_TITLE_PREFIX} - `date`"
    fi
    echo "Set title to: $TITLE"
    joplin set "$1" title "$TITLE"
}

#---
## Usage: setNoteTags note-id tags
#---
function setNoteTags {
    for T in $2 ; do
        echo "Add tag: $T"
        joplin tag add "$T" "$1"
    done
}

#---
## Usage: extractMailParts mail-file dest-dir
#---
function extractMailParts {
    ripmime -i ${1} --mailbox -d ${2}
}

#---
## Usage: determineMailPartType mail-part-file
#---
function determineMailPartType {
    if [[ "$1" =~ ^.*\/textfile[0-9]*$ ]] ; then
        echo "CONTENT"
    elif [[ "$1" =~ ^.*\.txt$ ]] ; then
        echo "TXT"
    elif [[ "$1" =~ ^.*\.md$ ]] ; then
        echo "TXT"
    elif [[ "$1" =~ ^.*\.pdf$ ]] ; then
        echo "PDF"
    elif [[ "$1" =~ ^.*\.jpg$ ]] ; then
        echo "IMG"
    elif [[ "$1" =~ ^.*\.jpeg$ ]] ; then
        echo "IMG"
    elif [[ "$1" =~ ^.*\.png$ ]] ; then
        echo "IMG"
    elif [[ "$1" =~ ^.*\.gif$ ]] ; then
        echo "IMG"
    else
        echo "UNKNOWN"
    fi
}

#---
## Usage: createNoteBodyFromTextParts mail-parts-dir
#---
function getNoteBodyFromTextParts {
    find "$1" -type f -print0 | sort -z | while read -d $'\0' F; do
        local T=`determineMailPartType "${F}"`
        if [[ "$T" == "CONTENT" ]] ; then
            cat ${F}
        fi
    done
}

#---
## Usage: setNoteBodyFromTextParts note-id mail-parts-dir
#---
function setNoteBodyFromTextParts {
    local BODY=`getNoteBodyFromTextParts "${2}"`
    echo "Setting body"
    joplin set "$1" body "$BODY"
}

#---
## Usage: attachFile note-id file
#---
function attachFile {
	echo "Attach file `basename "$2"`"
	joplin attach "$1" "$2"
}

#---
## Usage: attachTextFromFile note-id text-file
#---
function attachTextFromFile {
	echo "Add text from `basename "$2"`"
	local ORIG_BODY=`joplin cat "$1" | tail -n +2`
	local TXT=`cat "$2"`
	joplin set "$1" body "`echo -e "${ORIG_BODY}\n${TXT}"`"
}

#---
## Usage: addPdfThumbnails note-id pdf-file
#---
function addPdfThumbnails {
    local TEMP_DIR=`mktemp -d`
	pdftoppm -scale-to 300 -png "$2" "$TEMP_DIR/thumb"
	find "$TEMP_DIR" -type f -name "thumb-*.png" -print0 | sort -z | while read -d $'\0' T
	do
		echo "Add pdf thumbnail: $T"
		joplin attach "$1" "$T"
		rm "$T"
	done
	rmdir ${TEMP_DIR}
}

#---
## Usage: addPdfThumbnails note-id
#---
function addLastImageAsLink {
	echo "Add explicit image link"
	local OLD_BODY=`joplin cat "$1" | tail -n +2`
	local LAST_LINE=`echo "$OLD_BODY" | tail -n 1`
	local LINK=`echo "$LAST_LINE" | cut -c 2-999`
	joplin set "$1" body "`echo -e "${OLD_BODY}\n${LINK}\n"`"
}

#---
## Usage: addAttachmentFromFile note-id file
#---
function addAttachmentFromFile {
    local T=`determineMailPartType "$2"`
    if [[ "$T" == "TXT" ]]; then
        attachTextFromFile "$1" "$2"
    elif [[ "$T" == "PDF" ]] ; then
        addPdfThumbnails "$1" "$2"
        attachFile "$1" "$2"
    elif [[ "$T" == "IMG" ]] ; then
        attachFile "$1" "$2"
        addLastImageAsLink "$1"
    elif [[ "$T" == "UNKNOWN" ]] ; then
        attachFile "$1" "$2"
    else
        :
    fi
}

#---
## Usage: addAttachmentsFromFileParts note-id mail-parts-dir
#---
function addAttachmentsFromFileParts {
    find "$2" -type f -print0 | sort -z | while read -d $'\0' F; do
        addAttachmentFromFile "$1" "$F"
    done
}

#---
## Usage: addPdfFulltext note-id pdf-file
#---
function addPdfFulltext {
	echo "Add pdf fulltext for `basename "$2"`"
	local ORIG_BODY=`joplin cat "$1" | tail -n +2`
	local TXT=`pdftotext -raw -nopgbrk "$2" -`
	joplin set "$1" body "`echo -e "${ORIG_BODY}\n\n---\n${TXT}"`"
}

#---
## Usage: addImageFulltext note-id image-file
#---
function addImageFulltext {
	echo "Add image fulltext for `basename "$2"`"
	local ORIG_BODY=`joplin cat "$1" | tail -n +2`
	local TXT=`tesseract -l deu+eng "$2" -`
	joplin set "$1" body "`echo -e "${ORIG_BODY}\n\n---\n${TXT}"`"
}

#---
## Usage: addFulltextFromFile note-id file
#---
function addFulltextFromFile {
    local T=`determineMailPartType "$2"`
    if [[ "$T" == "PDF" ]] ; then
        addPdfFulltext "$1" "$2"
    elif [[ "$T" == "IMG" ]] ; then
        addImageFulltext "$1" "$2"
    else
        :
    fi
}

#---
## Usage: addFulltextFromFileParts note-id mail-parts-dir
#---
function addFulltextFromFileParts {
    find "$2" -type f -print0 | sort -z | while read -d $'\0' F; do
        addFulltextFromFile "$1" "$F"
    done
}


#---
## Usage: setCreationDate note-id date
#---
function setCreationDate {
	if [[ "$2" != "" ]]; then
		local DATINT=`date -jf "%Y-%m-%d %H.%M.%S" "$2" +%s`
   		echo "Set creation date $2 (${DATINT}000)"
		joplin set "$1" user_created_time ${DATINT}000
	fi
}




## Usage: addNewNoteFromMailFile mail-file
function addNewNoteFromMailFile {

    local FILE="$1"
    local NOTE_NAME=`basename "$FILE"`
    local SUBJECT=`getMailSubject "$FILE"`
    local TITLE=`getTitleFromSubject "$SUBJECT"`
    local TAGS=`getTagsFromSubject "$SUBJECT"`
    local NOTEBOOK=`getNotebookFromSubject "$SUBJECT" "$DEFAULT_NOTEBOOK"`

    echo "Create new note with name '${NOTE_NAME}' in '${NOTEBOOK}'"
    local NOTE_ID=`createNewNote ${NOTEBOOK} ${NOTE_NAME}`
    echo "New note created - ID is: $NOTE_ID"

    setNoteTitle "$NOTE_ID" "$TITLE"
    setNoteTags "$NOTE_ID" "$TAGS"

    local TEMP_DIR=`mktemp -d`
    echo "Using temp dir: $TEMP_DIR"

    extractMailParts "${FILE}" "${TEMP_DIR}"
    setNoteBodyFromTextParts "$NOTE_ID" "${TEMP_DIR}"
    addAttachmentsFromFileParts "$NOTE_ID" "${TEMP_DIR}"
    addFulltextFromFileParts "$NOTE_ID" "${TEMP_DIR}"

    echo "Removing temp dir: $TEMP_DIR"
    rm -r ${TEMP_DIR}

}


## Usage: getCreationDateFromFilename filename
function getCreationDateFromFilename {
    echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.search("^(\d\d\d\d-\d\d-\d\d)(?:\s(\d\d.\d\d.\d\d)\s)?",s); print() if (s is None) else print(s.group(1)+" 00.00.00") if (s.group(2) is None) else print(s.group(1)+" "+s.group(2));'
}

## Usage: getTitleFromFilename filename
function getTitleFromFilename {
    echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.search("^(?:\d\d\d\d-\d\d-\d\d(?:\s\d\d.\d\d.\d\d)?\s?-?\s?)?(.+?)(?:\[\s*\w+(?:\s+\w+)*\s*\])?(?:\.\w+)*?$",s); print(s.group(1)) if s else print();'
}

## Usage: getNotebookFromFilename filename default-notebook
function getNotebookFromFilename {
    # todo
    echo "$2"
}

## Usage: getTagsFromFilename filename
function getTagsFromFilename {
    echo -n "$1" | python3 -c 'import sys,re; s=sys.stdin.read(); s=re.search("^.*\[\s*(\w+(?:\s+\w+)*)\s*\](?:\.\w+)*?$",s); print(s.group(1)) if s else print();'
}




## Usage: addNewNoteFromGenericFile notebook file
function addNewNoteFromGenericFile {

    local FILE="$2"
    local FILE_NAME=`basename "$FILE"`

    if [[ "$FILE_NAME" =~ ^\..*$ ]] ; then
        echo "Ignore hidden file $FILE_NAME"
        return 1
    fi

    local TITLE=`getTitleFromFilename "$FILE_NAME"`
    local TAGS=`getTagsFromFilename "$FILE_NAME"`
    local NOTEBOOK="$1"
    if [[ "${NOTEBOOK}x" == "x" ]]; then
        NOTEBOOK="$DEFAULT_NOTEBOOK"
    fi
    local CREATION_DATE=`getCreationDateFromFilename "$FILE_NAME"`

    echo "Create new note with name '${FILE_NAME}' in '${NOTEBOOK}'"
    local NOTE_ID=`createNewNote ${NOTEBOOK} ${FILE_NAME}`
    echo "New note created - ID is: $NOTE_ID"

    setNoteTitle "$NOTE_ID" "$TITLE"
    setNoteTags "$NOTE_ID" "$TAGS"
    setCreationDate "$NOTE_ID" "$CREATION_DATE"

    addAttachmentFromFile "$NOTE_ID" "$FILE"
    addFulltextFromFile "$NOTE_ID" "$FILE"

}