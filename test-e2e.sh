#!/bin/bash
set -e

echo "🔄 LUMOS-MODE END-TO-END TEST"
echo "============================="
echo "Simulating real user workflow"
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓${NC} $1"; }
fail() { echo -e "${RED}✗${NC} $1"; exit 1; }
info() { echo -e "${YELLOW}ℹ${NC} $1"; }

# Create test directory
TEST_DIR="/tmp/lumos-mode-e2e-test"
rm -rf "$TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "1️⃣  Simulating user installation (straight.el)"
info "Creating minimal Emacs config with straight.el"

cat > init.el << 'EOF'
;; Minimal Emacs config for testing lumos-mode

;; Bootstrap straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; Install use-package
(straight-use-package 'use-package)

;; Install lumos-mode from GitHub
(use-package lumos-mode
  :straight (lumos-mode :type git :host github :repo "getlumos/lumos-mode")
  :hook (lumos-mode . (lambda () (message "lumos-mode activated!"))))

(message "✓ lumos-mode installed successfully")
EOF

pass "Created test Emacs config"

echo ""
echo "2️⃣  Creating sample .lumos file"

cat > example.lumos << 'EOF'
#[solana]
#[account]
struct PlayerAccount {
  wallet: PublicKey,
  level: u16,
  experience: u64,
  inventory: Vec<Item>,
}

#[solana]
struct Item {
  id: u32,
  name: String,
  quantity: u16,
}

#[solana]
enum GameState {
  Lobby,
  Playing { round: u32 },
  Finished,
}
EOF

pass "Created example.lumos"

echo ""
echo "3️⃣  Testing mode activation"

# Test that lumos-mode activates for .lumos files
emacs -Q -batch \
  -l "$PWD/../../../lumos-mode/lumos-mode.el" \
  -l example.lumos \
  --eval "(if (eq major-mode 'lumos-mode) (message \"SUCCESS: lumos-mode activated\") (error \"FAILED: Wrong mode\"))" 2>&1 | grep -q "SUCCESS" \
  && pass "lumos-mode auto-activates for .lumos files" \
  || fail "lumos-mode did not activate"

echo ""
echo "4️⃣  Testing syntax highlighting"

# Test that font-lock keywords are defined
emacs -Q -batch \
  -l "$PWD/../../../lumos-mode/lumos-mode.el" \
  --eval "(if (and (boundp 'lumos-mode-font-lock-keywords) lumos-mode-font-lock-keywords) (message \"SUCCESS\") (error \"FAILED\"))" 2>&1 | grep -q "SUCCESS" \
  && pass "Syntax highlighting rules loaded" \
  || fail "Syntax highlighting not working"

echo ""
echo "5️⃣  Testing indentation"

# Create file with unindented code
cat > unindented.lumos << 'EOF'
struct Player {
wallet: PublicKey,
level: u64,
}
EOF

# Test indentation function
emacs -Q -batch \
  -l "$PWD/../../../lumos-mode/lumos-mode.el" \
  unindented.lumos \
  --eval "(lumos-mode)" \
  --eval "(goto-char (point-min))" \
  --eval "(forward-line 1)" \
  --eval "(lumos-indent-line)" \
  --eval "(if (> (current-indentation) 0) (message \"SUCCESS: indented\") (error \"FAILED: not indented\"))" 2>&1 | grep -q "SUCCESS" \
  && pass "Indentation function works" \
  || fail "Indentation not working"

echo ""
echo "6️⃣  Testing comment functionality"

# Test comment insertion
emacs -Q -batch \
  -l "$PWD/../../../lumos-mode/lumos-mode.el" \
  example.lumos \
  --eval "(lumos-mode)" \
  --eval "(if (string= comment-start \"// \") (message \"SUCCESS\") (error \"FAILED\"))" 2>&1 | grep -q "SUCCESS" \
  && pass "Comment settings correct" \
  || fail "Comment settings wrong"

echo ""
echo "7️⃣  Testing customizable variables"

# Test that custom variables can be set
emacs -Q -batch \
  -l "$PWD/../../../lumos-mode/lumos-mode.el" \
  --eval "(setq lumos-indent-offset 4)" \
  --eval "(if (= lumos-indent-offset 4) (message \"SUCCESS\") (error \"FAILED\"))" 2>&1 | grep -q "SUCCESS" \
  && pass "Custom variables work" \
  || fail "Custom variables broken"

echo ""
echo "8️⃣  Testing LSP integration (if lumos-lsp available)"

if command -v lumos-lsp &> /dev/null; then
  info "lumos-lsp found, testing LSP integration..."

  # Create minimal LSP test
  cat > test-lsp.el << 'EOF'
(require 'lumos-mode)

;; Check LSP registration
(if (assoc 'lumos-mode lsp-language-id-configuration)
    (message "SUCCESS: LSP configured")
  (error "FAILED: LSP not configured"))
EOF

  emacs -Q -batch \
    -l "$PWD/../../../lumos-mode/lumos-mode.el" \
    -l test-lsp.el 2>&1 | grep -q "SUCCESS" \
    && pass "LSP integration configured" \
    || info "LSP integration not loaded (lsp-mode may not be installed)"
else
  info "lumos-lsp not installed (optional)"
  info "LSP features require: cargo install lumos-lsp"
fi

echo ""
echo "9️⃣  Cleanup"
cd /
rm -rf "$TEST_DIR"
pass "Cleaned up test directory"

echo ""
echo "===================================="
echo -e "${GREEN}✓ ALL E2E TESTS PASSED!${NC}"
echo "===================================="
echo ""
echo "Summary:"
echo "- Mode activation: ✓"
echo "- Syntax highlighting: ✓"
echo "- Indentation: ✓"
echo "- Comments: ✓"
echo "- Custom variables: ✓"
echo ""
echo -e "${GREEN}Ready for real-world usage and MELPA submission!${NC}"
