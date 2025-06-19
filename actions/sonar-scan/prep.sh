#!/bin/bash

mkdir -p ${{ runner.temp }}/sonar
echo "PROJECT_KEY=${{ github.repository_owner }}_$(basename ${{ github.repository }})" >> $GITHUB_OUTPUT

if COMPILATION_DATABASE_DIR="$(find $HOME -type d -name 'compilation_database')" && [ -n "${COMPILATION_DATABASE_DIR}" ]; then
    echo "Found compilation database in $COMPILATION_DATABASE_DIR. Merging.";
    # See below link for explanation of why we need to do this
    # https://sonarsource.atlassian.net/browse/CPP-3987
    sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' $COMPILATION_DATABASE_DIR/*.json > ${{ runner.temp }}/sonar/compile_commands.json
    echo "COMPILE_COMMANDS_FILE=${{ runner.temp }}/sonar/compile_commands.json" >> $GITHUB_OUTPUT
fi

if [ "${{ inputs.uses-xccov }}" == "true" ]; then
    RESULT_FOLDER=$(find $HOME -type d -regex ".*\.xcresult")
    echo "Found XCCov coverage files in $RESULT_FOLDER. Converting to SonarQube format..."
    chmod +x ${{ steps.install-xccov-converter.outputs.destination }}
    ${{ steps.install-xccov-converter.outputs.destination }} $RESULT_FOLDER/ > ${{ runner.temp }}/sonar/sonarqube-generic-coverage.xml
    echo "GENERIC_COVERAGE_FILE=${{ runner.temp }}/sonar/sonarqube-generic-coverage.xml" >> $GITHUB_OUTPUT
fi
