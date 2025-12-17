#!/bin/bash

echo "=========================================="
echo "Logseq Data Resolution Testing Suite"
echo "=========================================="
echo

# Run all test scripts
./test_block_content.sh | tee test_block_content_results.txt
echo

./test_status_resolution.sh | tee test_status_resolution_results.txt
echo

./test_tag_resolution.sh | tee test_tag_resolution_results.txt
echo

echo "=========================================="
echo "All tests completed!"
echo "Results saved to:"
echo "  - test_block_content_results.txt"
echo "  - test_status_resolution_results.txt"
echo "  - test_tag_resolution_results.txt"
echo "=========================================="
