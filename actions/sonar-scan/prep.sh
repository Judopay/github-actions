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

if JACOCO_COVERAGE_FILE="$(find $HOME -type f -name 'jacocoTestReport.xml')" && [ -n "${JACOCO_COVERAGE_FILE}" ]; then
    echo "Found JaCoCo coverage file at $JACOCO_COVERAGE_FILE. Adding to SonarQube parameters."
    PARAMS+=(-Dsonar.coverage.jacoco.xmlReportPaths="$JACOCO_COVERAGE_FILE")
fi

if [ -d "$HOME/.gradle/caches" ]; then
    echo "Found Gradle cache in $HOME/.gradle/caches. Adding to SonarQube parameters."
    PARAMS+=(-Dsonar.java.libraries="$HOME/.gradle/caches/**/*.jar")
fi

if TEST_LOCATIONS="$(find $SONAR_SOURCES -not -path './node_modules/*' -wholename '*/src/test' | tr '\n' ',')" && [ -n "${TEST_LOCATIONS}" ]; then
    echo "Found test locations: $TEST_LOCATIONS. Adding to SonarQube parameters."
    PARAMS+=(-Dsonar.tests="$TEST_LOCATIONS")
    TEST_EXCLUSIONS=$(echo "$TEST_LOCATIONS" | sed 's/,/\/**\/*,/g')
    PARAMS+=(-Dsonar.exclusions="$TEST_EXCLUSIONS")
fi

if ANDROID_LINT_FILE="$(find $HOME -name lint-results-debug.xml)" && [ -n "${ANDROID_LINT_FILE}" ]; then
    echo "Found Android lint results file at $ANDROID_LINT_FILE. Adding to SonarQube parameters."
    PARAMS+=(-Dsonar.androidLint.reportPaths="$ANDROID_LINT_FILE")
fi

echo "SONAR_ARGS=${PARAMS[@]}" >> $GITHUB_OUTPUT
