#!env bash

BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'

BOLD_WHITE='\033[1;37m'
BOLD_ULTRA_WHITE='\033[1;97m'

NC='\033[0m' # Reset Color

BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_WHITE='\033[47m'

COUNT_TEST=0
FAILED=0
SUCCESS=0


run_tests () {
    # WRITE HERE YOUR TESTS
    check_status_code "https://www.google.com" 200
    check_status_code "https://www.google.com/not-found" 404
    check_redirect "https://google.com" 301 "https://www.google.com"
}

check_status_code () {
    echo "┌──"
    echo -e "│ ${BOLD_WHITE}Testing $1${NC}"
    echo "└──"

    COUNT_TEST=$((COUNT_TEST+1))
    curl_output=$(curl -k --silent --head $1)
    status_code=$(echo "$curl_output" | grep "HTTP/" | awk '{print $2}')
    if [ $status_code -eq $2 ]; then
        echo -e " ${BOLD_ULTRA_WHITE}${BG_GREEN} [PASS] ${NC} STATUS CODE: $2"
        SUCCESS=$((SUCCESS+1))
    else
        echo -e " ${BOLD_ULTRA_WHITE}${BG_RED} [FAIL] ${NC} EXPECTED STATUS CODE: $2 GOT $status_code"
        FAILED=$((FAILED+1))
    fi

    echo ""
}

check_redirect () {
    echo "┌──"
    echo -e "│ ${BOLD_WHITE}Testing $1${NC}"
    echo "└──"

    COUNT_TEST=$((COUNT_TEST+1))
    curl_output=$(curl -k --silent --head $1)
    status_code=$(echo "$curl_output" | grep "HTTP" | awk '{print $2}')
    test_status="ok"
    if [ $status_code -eq $2 ]; then
        echo -e " ${BOLD_ULTRA_WHITE}${BG_GREEN} [PASS] ${NC} STATUS CODE: $2"
    else
        echo -e " ${BOLD_ULTRA_WHITE}${BG_RED} [FAIL] ${NC} EXPECTED STATUS CODE: $2 GOT $status_code"
        test_status="ko"
    fi

    # using tr to remove newlines and carriage returns
    redirect_url=$(echo "$curl_output" | grep -i "location:" | awk '{print $2}' | tr -d '\r\n')
    if [ "$redirect_url" = "$3" ]; then
        echo -e " ${BOLD_ULTRA_WHITE}${BG_GREEN} [PASS] ${NC} LOCATION: $3"
    else
        echo -e " ${BOLD_ULTRA_WHITE}${BG_RED} [FAIL] ${NC} EXPECTED LOCATION: $3 GOT $redirect_url"
        test_status="ko"
    fi

    if [ $test_status = "ok" ]; then
        SUCCESS=$((SUCCESS+1))
    else
        FAILED=$((FAILED+1))
    fi

    echo ""
}


run_tests

echo -e "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo -e "┃                     ${BOLD_WHITE}Test results${NC}                     ┃"
echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo -e " ${BLACK}${BG_WHITE} $COUNT_TEST ${NC} test(s) run, ${BOLD_ULTRA_WHITE}${BG_GREEN} $SUCCESS ${NC} passed, ${BOLD_ULTRA_WHITE}${BG_RED} $FAILED ${NC} failed\n"

if [ $FAILED -ne 0 ]; then
    exit 1
fi
