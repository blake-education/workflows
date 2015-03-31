#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

rm log/*.log || true

echo --- env
env|sort

echo '--- bundling'

rm -f Gemfile.lock
time bundle install --clean --path=$CI_TMP/bundled_gems

echo '--- running specs'

bundle exec rake
