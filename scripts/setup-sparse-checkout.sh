#!/bin/bash
# Set up sparse checkout for vendor/typst submodule.
# Only includes the crates needed by folio_nif.
#
# Run from project root: ./scripts/setup-sparse-checkout.sh

set -e

MODULES_DIR=".git/modules/vendor/typst"
SPARSE_FILE="$MODULES_DIR/info/sparse-checkout"

if [ ! -d "$MODULES_DIR" ]; then
    echo "Error: vendor/typst submodule not initialized."
    echo "Run: git submodule update --init vendor/typst"
    exit 1
fi

cd vendor/typst

git sparse-checkout init --cone
git sparse-checkout set \
    crates/typst \
    crates/typst-eval \
    crates/typst-html \
    crates/typst-layout \
    crates/typst-library \
    crates/typst-macros \
    crates/typst-pdf \
    crates/typst-realize \
    crates/typst-render \
    crates/typst-svg \
    crates/typst-syntax \
    crates/typst-timing \
    crates/typst-utils

echo "Sparse checkout configured. vendor/typst reduced from ~17M to ~5M."
