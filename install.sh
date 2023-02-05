#!/usr/bin/env bash

# folder.sh
function folder() {
  #statements
  local file=$1
  local new_folder=`head -n 1 $file/README.md | sed 's/# //g'`

  mv $file $new_folder
}
# readme.sh
# 1. change word sbt to bloop-sbt
# 2. add description
# 3. change docker image name
function replace_readme_str() {
  #statements
  local file=$1/README.md
  local old=$2
  local new=$3

  perl -pi.bak -e "s/${old}/${new}/" $file
  rm -f $1/README.md.bak
}
function replace_readme_first() {
  #statements
  local file=$1/README.md
  local old=$2
  local new=$3

  perl -pi.bak -0 -e "s/${old}/${new}/" $file
  rm -f $1/README.md.bak
}
function readme() {
  #statements
  local file=$1
  read -r -d '' DESCRIPTION <<EOF
Uses self-sign ssl.

## Tech stack
EOF

read -r -d '' DOCKER_STACK <<EOF
## Docker stack
- alpine:edge
EOF

  replace_readme_first $file "postgres" "ssl-postgres"

  replace_readme_str $file "## Tech stack" "$DESCRIPTION"

  replace_readme_str $file "## Docker stack" "$DOCKER_STACK"
}
# build.sh
# 1. remove Dockerfile
function chg_dockerfile() {
  #statements
  local file=$1/db

  mkdir -p $file && cp ./.src/Dockerfile "$_"
}
function build() {
  local file=$1

  sed -i 's/image: postgres:alpine/build: db/g' $file/docker-compose.yml

  sed -i 's/POSTGRES_HOST_AUTH_METHOD=trust/POSTGRES_PASSWORD=pass/g' $file/docker-compose.yml

  chg_dockerfile $file
}

# install.sh
function install() {
  #statements
  local file=$1

  build $file

  readme $file

  cp -R ./.src/openssl-srv $file

  rm -f $file/install.sh

  cp ./.src/install.sh $file

  folder $file
}
for d in `ls -la | grep ^d | awk '{print $NF}' | egrep -v '^\.'`; do
  install $d
done
