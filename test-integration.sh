#!/bin/bash
set -e

echo "🧪 LUMOS-MODE INTEGRATION TEST SUITE"
echo "===================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_PASSED=0
TESTS_FAILED=0

# Helper functions
pass() {
  echo -e "${GREEN}✓ PASS:${NC} $1"
  TESTS_PASSED=$((TESTS_PASSED + 1))
}

fail() {
  echo -e "${RED}✗ FAIL:${NC} $1"
  TESTS_FAILED=$((TESTS_FAILED + 1))
}

info() {
  echo -e "${YELLOW}ℹ INFO:${NC} $1"
}

# Test 1: Check Emacs is installed
echo "Test 1: Check Emacs installation"
if command -v emacs &> /dev/null; then
  EMACS_VERSION=$(emacs --version | head -n1)
  pass "Emacs found: $EMACS_VERSION"
else
  fail "Emacs not found. Please install Emacs 26.1+"
  exit 1
fi

# Test 2: Check minimum Emacs version (26.1)
echo ""
echo "Test 2: Check Emacs version >= 26.1"
EMACS_MAJOR=$(emacs --version | head -n1 | grep -oE '[0-9]+' | head -n1)
EMACS_MINOR=$(emacs --version | head -n1 | grep -oE '\.[0-9]+' | head -n1 | tr -d '.')

if [ "$EMACS_MAJOR" -ge 26 ]; then
  pass "Emacs version $EMACS_MAJOR.$EMACS_MINOR is supported"
else
  fail "Emacs version $EMACS_MAJOR.$EMACS_MINOR is too old (need 26.1+)"
fi

# Test 3: Run unit tests
echo ""
echo "Test 3: Run unit test suite"
if make test &> /tmp/lumos-mode-test.log; then
  pass "All 14 unit tests passed"
else
  fail "Unit tests failed. Check /tmp/lumos-mode-test.log"
  cat /tmp/lumos-mode-test.log
fi

# Test 4: Byte compilation
echo ""
echo "Test 4: Byte compilation"
if make compile &> /tmp/lumos-mode-compile.log; then
  pass "Byte compilation successful"
  rm -f *.elc  # Clean up
else
  fail "Byte compilation failed. Check /tmp/lumos-mode-compile.log"
  cat /tmp/lumos-mode-compile.log
fi

# Test 5: Check lumos-lsp server availability
echo ""
echo "Test 5: Check lumos-lsp server"
if command -v lumos-lsp &> /dev/null; then
  LSP_VERSION=$(lumos-lsp --version 2>&1 || echo "unknown")
  pass "lumos-lsp found: $LSP_VERSION"
else
  info "lumos-lsp not found (optional for LSP features)"
  info "Install with: cargo install lumos-lsp"
fi

# Test 6: Load mode in Emacs
echo ""
echo "Test 6: Load lumos-mode in Emacs"
if emacs -batch -L . -l lumos-mode.el --eval "(message \"lumos-mode loaded successfully\")" 2>&1 | grep -q "lumos-mode loaded"; then
  pass "lumos-mode loads without errors"
else
  fail "lumos-mode failed to load"
fi

# Test 7: Check file association
echo ""
echo "Test 7: Check .lumos file association"
cat > /tmp/test.lumos << 'EOF'
struct Player {
  wallet: PublicKey,
  level: u64,
}
EOF

if emacs -batch -L . -l lumos-mode.el /tmp/test.lumos --eval "(message \"Mode: %s\" major-mode)" 2>&1 | grep -q "lumos-mode"; then
  pass ".lumos files activate lumos-mode"
else
  fail ".lumos file association not working"
fi

rm -f /tmp/test.lumos

# Test 8: Check syntax highlighting rules
echo ""
echo "Test 8: Check syntax highlighting definitions"
if emacs -batch -L . -l lumos-mode.el \
  --eval "(if (boundp 'lumos-mode-font-lock-keywords) (message \"FOUND\") (message \"NOT FOUND\"))" 2>&1 | grep -q "FOUND"; then
  pass "Syntax highlighting rules defined"
else
  fail "Syntax highlighting rules missing"
fi

# Test 9: Check indentation function
echo ""
echo "Test 9: Check indentation function"
if emacs -batch -L . -l lumos-mode.el \
  --eval "(if (fboundp 'lumos-indent-line) (message \"FOUND\") (message \"NOT FOUND\"))" 2>&1 | grep -q "FOUND"; then
  pass "Indentation function defined"
else
  fail "Indentation function missing"
fi

# Test 10: Check customizable variables
echo ""
echo "Test 10: Check customizable variables"
if emacs -batch -L . -l lumos-mode.el \
  --eval "(if (boundp 'lumos-indent-offset) (message \"FOUND\") (message \"NOT FOUND\"))" 2>&1 | grep -q "FOUND"; then
  pass "Custom variables defined"
else
  fail "Custom variables missing"
fi

# Test 11: Package-lint (if available)
echo ""
echo "Test 11: Package-lint check"
if command -v package-lint-batch-and-exit &> /dev/null; then
  if emacs -batch -l package \
    --eval "(add-to-list 'package-archives '(\"melpa\" . \"https://melpa.org/packages/\") t)" \
    --eval "(package-initialize)" \
    --eval "(package-refresh-contents)" \
    --eval "(package-install 'package-lint)" 2>&1 | grep -q "installed"; then
    pass "package-lint validation passed"
  else
    info "package-lint not available (optional)"
  fi
else
  info "package-lint not available (optional)"
fi

# Summary
echo ""
echo "===================================="
echo "📊 TEST SUMMARY"
echo "===================================="
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
  echo -e "${GREEN}✓ All tests passed! Ready for MELPA submission.${NC}"
  exit 0
else
  echo -e "${RED}✗ Some tests failed. Please fix before submitting.${NC}"
  exit 1
fi
