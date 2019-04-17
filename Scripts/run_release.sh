#!/usr/bin/env bash

set -e

MYREPO=${HOME}/workdir/${TRAVIS_REPO_SLUG}

mkdir -p ${MYREPO}
git clone -b ${TRAVIS_BRANCH} https://${GITHUB_TOKEN}@github.com/${TRAVIS_REPO_SLUG} ${MYREPO}
cd ${MYREPO}
git tag "v${VERSION}"
git push --tags
echo "do cocoapods stuff"
