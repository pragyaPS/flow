#!/bin/sh
FLOW=$1

IMPL_FILES="
  A.js
  node_modules/test/Test.js
"
DECL_FILES="$(echo "$IMPL_FILES" | sed -e "s/\.js/.js.flow/g")"

ignore_files() {
  for file in $1; do
    mv "$file" "$file.ignored" 2>&1
  done
}

use_files() {
  for file in $1; do
    mv "$file.ignored" "$file" 2>&1
  done
}

printf "======Start off with the .js files but without the .flow file======\n"
"$FLOW" status --no-auto-start --strip-root .
use_files "$DECL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .
ignore_files "$DECL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .

printf "\n\n======Start off with the .js files and the .flow file======\n"
"$FLOW" stop .
use_files "$DECL_FILES"
"$FLOW" start . --all --wait

"$FLOW" status --no-auto-start --strip-root .
ignore_files "$DECL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .
use_files "$DECL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .

printf "\n\n======Start off without the .js files and with the .flow file======\n"
"$FLOW" stop .
ignore_files "$IMPL_FILES"
"$FLOW" start . --all --wait

"$FLOW" status --no-auto-start --strip-root .
use_files "$IMPL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .
ignore_files "$IMPL_FILES"
"$FLOW" force-recheck --no-auto-start $IMPL_FILES $DECL_FILES
"$FLOW" status --no-auto-start --strip-root .

# reset
use_files "$IMPL_FILES"
ignore_files "$DECL_FILES"