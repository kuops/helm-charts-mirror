#!/bin/bash
set -ex 
# variables
URL="https://kubernetes-charts.storage.googleapis.com"

# change directory
cd $(dirname $0)

today(){
   date +%F
}

set_git(){
  git config --global user.name "kuops"
  git config --global user.email opshsy@gmail.com
}

checkout_branch(){
    git remote add origin git@github.com:kuops/helm-charts-mirror.git
    git checkout -b gh-pages
    git branch --set-upstream-to=origin/gh-pages gh-pages
}

git_commit(){
     local COMMIT_FILES_COUNT=$(git status -s|wc -l)
     local TODAY=$(today)
     if [ $COMMIT_FILES_COUNT -ne 0 ];then
        git add -A
        git commit -m "Synchronizing completion at $TODAY"
        git push -u origin gh-pages
     fi
}

get_new_index() {
  curl -SLO https://kubernetes-charts.storage.googleapis.com/index.yaml
}

get_digest(){
  cat index.yaml |yq '.entries[]| {name: .[].name, digest: .[].digest, version: .[].version , url: .[].urls[]}' > chart-list.json
}

get_new_tgz_file() {
  grep "${URL}/.*.tgz" index.yaml > /tmp/chart-tgz-list.log
  ls docs/*.tgz|sed "s@.*@${URL}/&@g" > /tmp/chart-install-tgz.log
  awk 'NR==FNR{a[$0];next}NR!=FNR{if(!($0 in a))print $0}' /tmp/chart-install-tgz.log /tmp/chart-install-tgz.log > /tmp/chart-installed.log
  while read line;do
    CHART_DIGEST=$(cat chart-list.json|jq -r ".|select(.url==\"$line\")|.digest")
    until [[ ${CHART_DIGEST} == ${DOWN_DIGEST} ]];do
      curl -SLo docs/${line##*/} $line && DOWN_DIGEST=$(md5sum ${line##*/})
    done
    echo $line > last_install
  done < /tmp/chart-installed.log
}

clean_temp() {
  rm /tmp/chart*
}


main() {
  set_git
  checkout_branch
  get_new_index
  get_digest
  get_new_tgz_file
  clean_temp
}
