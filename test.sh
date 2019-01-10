#!/usr/bin/env bash

# include functions
readonly CURR_WD=`pwd`
cd "$(dirname "$0")";
. ./_util-functions.sh
. ./_mail-functions.sh
. ./_joplin-functions.sh
cd ${CURR_WD}


#joplin sync

#getTitleFromSubject "this is a test #foo #bar @Import #baz hallo"
#getTitleFromSubject "this is a test hallo"
#
#getTagsFromSubject "this is a test #foo #bar @Import #baz"
#getTagsFromSubject "this is a test @Import"
#
#getNotebookFromSubject "this is a test #foo #bar @Import #baz"
#getNotebookFromSubject "this is a test #foo #bar #baz"

#addNewNoteFromMailFile "$1"

echo "---"
filename="this is a test[foo bar].txt"
echo "$filename"
getTitleFromFilename "$filename"
getTagsFromFilename "$filename"
getNotebookFromFilename "$filename" "$DEFAULT_NOTEBOOK"
getCreationDateFromFilename "$filename"

echo "---"
filename="2018-06-19 08.52.06 - Evolve Bamboo GTX E-Longboard.md"
echo "$filename"
getTitleFromFilename "$filename"
getTagsFromFilename "$filename"
getNotebookFromFilename "$filename" "$DEFAULT_NOTEBOOK"
getCreationDateFromFilename "$filename"

echo "---"
filename="2017-09-07 Zahnarzt Rechnung[gesundheit].pdf.txt"
echo "$filename"
getTitleFromFilename "$filename"
getTagsFromFilename "$filename"
getNotebookFromFilename "$filename" "$DEFAULT_NOTEBOOK"
getCreationDateFromFilename "$filename"

echo "---"
filename="test"
echo "$filename"
getTitleFromFilename "$filename"
getTagsFromFilename "$filename"
getNotebookFromFilename "$filename" "$DEFAULT_NOTEBOOK"
getCreationDateFromFilename "$filename"
