#!/usr/bin/env bash
# run_rocm.sh — recommended launcher for AMD ROCm users
#
# The MIOpen "IsEnoughWorkspace" warnings you may see on AMD GPUs are a known,
# currently-open upstream PyTorch/ROCm issue affecting Conv1d-heavy TTS/vocoder
# models on RDNA3 (not a kvoicewalk bug). This script quiets that log noise by
# default. It does not change performance on its own.
#
# Usage:
#   ./run_rocm.sh gui
#   ./run_rocm.sh main --target_text "..." --target_audio ./example/target.wav --device cuda
#   ./run_rocm.sh tune --target_text "..." --target_audio ./example/target.wav --device cuda
#
# "tune" runs a one-off MIOpen performance-database tuning pass. That single
# run will be slower (it's benchmarking solvers), but results are cached to
# ~/.config/miopen and ~/.cache/miopen, so subsequent normal runs should be
# faster and quieter.

set -euo pipefail

# 3 = errors only (still surfaces real problems). Use 1 for total silence,
# or override by exporting MIOPEN_LOG_LEVEL yourself before calling this script.
export MIOPEN_LOG_LEVEL="${MIOPEN_LOG_LEVEL:-3}"

MODE="${1:-main}"
shift || true

case "$MODE" in
  gui)
    uv run gui.py
    ;;
  main)
    uv run main.py "$@"
    ;;
  tune)
    echo "Running a one-off MIOpen tuning pass — this run will be slower than usual." >&2
    echo "Subsequent normal runs (./run_rocm.sh main ...) should be faster afterward." >&2
    MIOPEN_FIND_ENFORCE=3 uv run main.py "$@"
    ;;
  *)
    echo "Usage: $0 {gui|main|tune} [args...]" >&2
    exit 1
    ;;
esac
