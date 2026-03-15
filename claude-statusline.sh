#!/bin/bash
# Claude Code status line script
# Reads JSON session data from stdin, outputs formatted status line

input=$(cat)

host=$(hostname -s)

raw_cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd')
cwd="${raw_cwd#$HOME/}"

branch=$(git -C "$raw_cwd" symbolic-ref --short HEAD 2>/dev/null)
[ -n "$branch" ] && cwd="$cwd ($branch)"

name=$(echo "$input" | jq -r '.session_name // empty')

in_tok=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
out_tok=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
cost=$(echo "scale=2; ($in_tok * 0.003 + $out_tok * 0.015) / 1000" | bc -l 2>/dev/null || echo "0.00")

remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // "N/A"')
if [ "$remaining" != "N/A" ]; then
  ctx_display=$(printf "%.0f%%" "$remaining")
else
  ctx_display="N/A"
fi

prefix=""
[ -n "$name" ] && prefix="$name | "

printf "%s%s | %s | \$%s | free ctx: %s" "$prefix" "$host" "$cwd" "$cost" "$ctx_display"
