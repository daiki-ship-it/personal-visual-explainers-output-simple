#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git log --date=iso-strict --pretty=format:'%C(yellow)%h%Creset  %C(dim white)%ad%Creset  %C(cyan)%an%Creset  %C(white)%s%Creset' --name-status \
  | awk '
    BEGIN { print "" }
    /^[0-9a-f]{7,}/ {
      print $0
      next
    }
    /^[AMD]\t/ {
      printf("    %s\n", $0)
      next
    }
    /^$/ { next }
    { printf("    %s\n", $0) }
  '

