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


addNewNoteFromMailFile "$1"
