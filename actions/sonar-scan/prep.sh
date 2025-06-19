#!/bin/bash

mkdir -p $TEMP_DIR/sonar
echo "PROJECT_KEY=${GIT_REPOSITORY_OWNER}_$(basename $GIT_REPOSITORY)" >> $GITHUB_OUTPUT

if COMPILATION_DATABASE_DIR="$(find $HOME -type d -name 'compilation_database')" && [ -n "${COMPILATION_DATABASE_DIR}" ]; then
    echo "Found compilation database in $COMPILATION_DATABASE_DIR. Merging.";
    # See below link for explanation of why we need to do this
    # https://sonarsource.atlassian.net/browse/CPP-3987
    sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' $COMPILATION_DATABASE_DIR/*.json > $TEMP_DIR/sonar/compile_commands.json
    echo "COMPILE_COMMANDS_FILE=$TEMP_DIR/sonar/compile_commands.json" >> $GITHUB_OUTPUT
fi

if [ "$USES_XCCOV" == "true" ]; then
    RESULT_FOLDER=$(find $HOME -type d -regex ".*\.xcresult")
    echo "Found XCCov coverage files in $RESULT_FOLDER. Converting to SonarQube format..."
    chmod +x $XCCOV_CONVERTER_BINARY
    $XCCOV_CONVERTER_BINARY $RESULT_FOLDER/ > $TEMP_DIR/sonar/sonarqube-generic-coverage.xml
    echo "GENERIC_COVERAGE_FILE=$TEMP_DIR/sonar/sonarqube-generic-coverage.xml" >> $GITHUB_OUTPUT
fi
