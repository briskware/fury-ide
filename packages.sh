#!/usr/bin/env bash
find src -name \*.scala | xargs cat | grep "^package " | xargs -L 1 echo | sort | uniq | \
  grep -v java. | grep -v scala. | sed -e 's/package //g' | \
  grep -v annotation. | grep -v language.


