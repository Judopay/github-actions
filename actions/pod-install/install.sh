#!/bin/bash

# By this point in the job, `ruby/setup-ruby` has already installed gems for
# the repo's pinned Ruby version via `bundle install`. Its PATH update
# (pointing `bundle`/`ruby` at that install) doesn't reliably survive into
# this composite action's own step on hosted macOS runners, where a
# Homebrew-provided Ruby can still be first on PATH. If `bundle exec` below
# runs under that wrong Ruby, it looks for gems under a different
# `vendor/bundle/ruby/<abi>` subdirectory than the one they were installed
# into, and fails with Bundler::GemNotFound even though install succeeded.
# Re-derive the pinned Ruby's bin dir from RUNNER_TOOL_CACHE (always set by
# Actions, independent of PATH) and put it first, so bundle resolves to the
# same Ruby that installed the gems.
if [[ -f .ruby-version && -n "${RUNNER_TOOL_CACHE:-}" ]]; then
  RUBY_VERSION=$(tr -d '[:space:]' < .ruby-version)
  RUBY_VERSION=${RUBY_VERSION#ruby-}
  RUBY_BIN_DIR="$RUNNER_TOOL_CACHE/Ruby/$RUBY_VERSION/$(uname -m | sed 's/x86_64/x64/')"
  if [[ -d "$RUBY_BIN_DIR/bin" ]]; then
    export PATH="$RUBY_BIN_DIR/bin:$PATH"
    echo "Using Ruby from $RUBY_BIN_DIR"
  else
    echo "::warning::Ruby $RUBY_VERSION not found in $RUNNER_TOOL_CACHE/Ruby"
  fi
else
  echo "::warning::Skipping Ruby PATH fix (pwd=$PWD, .ruby-version present: $([[ -f .ruby-version ]] && echo yes || echo no))"
fi
echo "ruby: $(command -v ruby) ($(ruby -v))"

while IFS= read -r -d '' FILE; do
  CURR_DIR=$(pwd)
  echo "Installing pods for $FILE"
  cd "$(dirname "$FILE")"
  bundle exec pod install --repo-update || exit 1
  cd "$CURR_DIR"
done < <(find . -name Podfile.lock -not -path './Carthage/*' -type f -print0)
