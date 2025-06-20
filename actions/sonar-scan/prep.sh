#!/bin/bash

mkdir -p $OUTPUT_DIR

PARAMS=(-Dsonar.organization=judopay)
PARAMS+=(-Dproject.settings=.sonarscan)
PARAMS+=(-Dsonar.sources=$SONAR_SOURCES)

PROJECT_KEY="${GIT_REPOSITORY_OWNER}_$(basename $GIT_REPOSITORY)"
PARAMS+=(-Dsonar.projectKey=$PROJECT_KEY)

if COMPILATION_DATABASE_DIR="$(find $HOME -type d -name 'compilation_database')" && [ -n "${COMPILATION_DATABASE_DIR}" ]; then
    COMPILE_COMMANDS_FILE="$OUTPUT_DIR/compile_commands.json"
    echo "Found compilation database in $COMPILATION_DATABASE_DIR. Merging into $COMPILE_COMMANDS_FILE.";
    # See below link for explanation of why we need to do this
    # https://sonarsource.atlassian.net/browse/CPP-3987
    sed -e '1s/^/[\'$'\n''/' -e '$s/,$/\'$'\n'']/' $COMPILATION_DATABASE_DIR/*.json > $COMPILE_COMMANDS_FILE
    
    PARAMS+=(-Dsonar.cfamily.cache.enabled=false)
    PARAMS+=(-Dsonar.cfamily.compile-commands=$COMPILE_COMMANDS_FILE)
fi

if XCCOV_RESULTS_DIR="$(find $HOME -type d -regex ".*\.xcresult")" && [ -n "${XCCOV_RESULTS_DIR}" ]; then
    GENERIC_COVERAGE_FILE="$OUTPUT_DIR/sonarqube-generic-coverage.xml"
    echo "Found XCCov coverage files in $XCCOV_RESULTS_DIR. Converting to SonarQube format and saving to $GENERIC_COVERAGE_FILE."
    chmod +x $XCCOV_CONVERTER_BINARY
    $XCCOV_CONVERTER_BINARY $XCCOV_RESULTS_DIR/ > $GENERIC_COVERAGE_FILE
    PARAMS+=(-Dsonar.coverageReportPaths=$GENERIC_COVERAGE_FILE)
fi

echo "SONAR_ARGS=${PARAMS[@]}" >> $GITHUB_OUTPUT
