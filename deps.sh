#!/usr/bin/env bash
find src -name \*.scala | xargs cat | grep "import " | xargs -L 1 echo | sort | uniq | \
  grep "^import " | \
  grep -v java. | grep -v scala. | sed -e 's/import //g' | \
  grep -v annotation. | grep -v language.


