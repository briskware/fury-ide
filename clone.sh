#!/usr/bin/env bash

PROPENSIVE_REPOS="contextual escritoire eucalyptus exoskeleton gastronomy guillotine impromptu kaleidoscope magnolia mercator mitigation optometry probation fury totalitarian"

function cloneRepo() {
  local gitUrl=$1
  local repoName=$2
  local branchOrTag=$3

  if [ -d ./${repoName} ]; then
  	echo "Repo ${gitUrl} is already cloned at $(pwd)/${repoName}, skipping..."
  else
  	echo "Cloning repo: ${gitUrl}"
  	git clone ${gitUrl} || exit $?
  fi
  cd ${repoName} || exit $?
  if [ -z "$(git status --untracked-files=no --porcelain)" ]; then
    # Working directory clean excluding untracked files
    git checkout "${branchOrTag}" && git pull
    branch=$(git status --untracked-files=no --porcelain --branch | head -1) || exit 1
    tag=$(git describe --tag | head -1) || exit 1
    if [[ -z "${tag// }" ]]; then
      tag="*none*"
    fi
    # Uncommitted changes in tracked files
    echo "Repo ${gitUrl} is clean and on branch ${branch} (tag ${tag})..."
  else
    branch=$(git status --untracked-files=no --porcelain --branch | head -1) || exit 1
    tag=$(git describe --tag | head -1) || exit 1
    if [[ -z "${tag// }" ]]; then
      tag="*** none ***"
    fi
    # Uncommitted changes in tracked files
    echo "Repo ${gitUrl} has uncommitted changes on branch ${branch} (tag ${tag})..."
  fi
  cd -
}

function downloadMavenJar() {
  LIB_DIR="$(pwd)/fury-lib"
  mkdir -p ${LIB_DIR}
  local repoUrl="$1"
  local group="$2"
  local artifact="$3"
  local version="$4"
  local fileName="${artifact}-${version}.jar"
  local downloadUrl="${repoUrl}/$(echo ${group} | sed -e 's/\./\//g')/${artifact}/${version}/${fileName}"
  local destination="${LIB_DIR}/${fileName}"
  if [ -f ${destination} ]; then
    echo "Local copy of file ${destination} from ${downloadUrl} already exists, skipping..."
  else
    echo "Downloading ${downloadUrl} to ${destination}"
    echo curl --location --output ${destination} ${downloadUrl}
    curl --location --output ${destination} --silent ${downloadUrl} || exit 1
    if [ ! -f ${destination} ]; then
      echo "Failed to download file"; exit 1
    fi
  fi
}

function makeLinks() {
  root=$(pwd) || exit 1
  linksRoot="${root}/fury-build"
  rootScalaSourceDir="${linksRoot}/src/main/scala"
  rootScalaTestDir="${linksRoot}/src/test/scala"
  echo rm -rv ${linksRoot}
  rm -rv ${linksRoot}
  while read path pack; do
    package=$(echo ${pack} | sed -e "s/\./\//g")
    modulePrefix="$(basename $(dirname ${path}))-"
    if [ -z $(echo "${package}" | grep "test") ]; then
      packageDir=${rootScalaSourceDir}/${package}
    else
      packageDir=${rootScalaTestDir}/${package}
    fi
    #fileName="$(basename "${path}")"
    #linkPath="${packageDir}/${fileName}"
    #if [ -L "${linkPath}" ]; then
    #  echo -n "WARNING: link collision detected ${linkPath} already exists, will use "
      fileName="${modulePrefix}$(basename "${path}")"
      linkPath="${packageDir}/${fileName}"
    #  echo "${linkPath} instead!"
    #fi
    echo "Linking file ${path} to symbolic-link root path ${linkPath}"
    mkdir -p ${packageDir} || exit 1
    ln -s "${path}" "${linkPath}" || exit 1
  done < <(find "${root}" -name \*.scala | xargs grep "package " | grep -v "\/\*\*" | sed -e "s/:package//g" | sort | uniq)
}

function main() {
  for repo in ${PROPENSIVE_REPOS}; do
    local gitRepo="https://github.com/propensive/${repo}.git"
    cloneRepo "${gitRepo}" "${repo}" "fury"
  done
  cloneRepo "https://github.com/facebook/nailgun.git" "nailgun" "nailgun-all-0.9.3"
  downloadMavenJar "http://repo1.maven.org/maven2" "net.java.dev.jna" "jna"          "5.2.0"
  downloadMavenJar "http://repo1.maven.org/maven2" "net.java.dev.jna" "jna-platform" "5.2.0"
  makeLinks
}

main $@
