#!/bin/bash
set -euo pipefail

command -v faketorio >/dev/null 2>&1 || {
    echo "faketorio is required to package the mod" >&2
    exit 1
}

faketorio package
