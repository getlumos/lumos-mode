#!/bin/bash
set -e

echo "🚀 LUMOS-MODE COMPREHENSIVE TEST SUITE"
echo "======================================"
echo "Running all tests before MELPA submission"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Track overall success
OVERALL_SUCCESS=true

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 1: UNIT TESTS                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if make test; then
  echo -e "${GREEN}✓ Unit tests passed (14/14)${NC}"
else
  echo -e "${RED}✗ Unit tests failed${NC}"
  OVERALL_SUCCESS=false
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 2: INTEGRATION TESTS            ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if ./test-integration.sh; then
  echo -e "${GREEN}✓ Integration tests passed${NC}"
else
  echo -e "${RED}✗ Integration tests failed${NC}"
  OVERALL_SUCCESS=false
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  PHASE 3: END-TO-END TESTS             ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

if ./test-e2e.sh; then
  echo -e "${GREEN}✓ End-to-end tests passed${NC}"
else
  echo -e "${RED}✗ End-to-end tests failed${NC}"
  OVERALL_SUCCESS=false
fi

echo ""
echo "======================================"
echo "📊 FINAL SUMMARY"
echo "======================================"

if [ "$OVERALL_SUCCESS" = true ]; then
  echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║  ✓ ALL TESTS PASSED!                        ║${NC}"
  echo -e "${GREEN}║                                              ║${NC}"
  echo -e "${GREEN}║  Ready for:                                  ║${NC}"
  echo -e "${GREEN}║  • MELPA submission                          ║${NC}"
  echo -e "${GREEN}║  • Production use                            ║${NC}"
  echo -e "${GREEN}║  • End-user distribution                     ║${NC}"
  echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  exit 0
else
  echo -e "${RED}╔══════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║  ✗ SOME TESTS FAILED                        ║${NC}"
  echo -e "${RED}║                                              ║${NC}"
  echo -e "${RED}║  Please fix failing tests before:           ║${NC}"
  echo -e "${RED}║  • MELPA submission                          ║${NC}"
  echo -e "${RED}║  • Public release                            ║${NC}"
  echo -e "${RED}╚══════════════════════════════════════════════╝${NC}"
  echo ""
  exit 1
fi
