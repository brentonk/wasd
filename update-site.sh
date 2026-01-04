#!/bin/bash
# Updates the reading guides and slides tables in index.qmd by scanning directories

cd "$(dirname "$0")"

# Generate reading guides table rows sorted by date
guides_table=""
for qmd in guides/*.qmd; do
    [ -f "$qmd" ] || continue

    # Extract title and date from YAML front matter
    title=$(grep -m1 "^title:" "$qmd" | sed 's/^title: *//' | tr -d '"')
    date=$(grep -m1 "^date:" "$qmd" | sed 's/^date: *//')

    # Get the HTML path (same name as qmd but .html)
    html_path="${qmd%.qmd}.html"

    # Format date for display (YYYY-MM-DD -> Day, Month D, YYYY)
    formatted_date=$(date -d "$date" "+%A, %B %-d, %Y" 2>/dev/null || echo "$date")

    # Store with sortable date prefix for sorting
    guides_table+="$date|$formatted_date|$title|$html_path\n"
done

# Generate slides table rows sorted by date
slides_table=""
for qmd in slides/*/*.qmd; do
    [ -f "$qmd" ] || continue

    # Extract title and date from YAML front matter
    title=$(grep -m1 "^title:" "$qmd" | sed 's/^title: *//' | tr -d '"')
    date=$(grep -m1 "^date:" "$qmd" | sed 's/^date: *//')

    # Get the HTML path (same name as qmd but .html)
    html_path="${qmd%.qmd}.html"

    # Format date for display (YYYY-MM-DD -> Day, Month D, YYYY)
    formatted_date=$(date -d "$date" "+%A, %B %-d, %Y" 2>/dev/null || echo "$date")

    # Store with sortable date prefix for sorting
    slides_table+="$date|$formatted_date|$title|$html_path\n"
done

# Build sorted guides rows
sorted_guides=""
while IFS='|' read -r sort_date formatted_date title html_path; do
    [ -z "$sort_date" ] && continue
    sorted_guides+="| $formatted_date | [$title]($html_path) |\n"
done < <(echo -e "$guides_table" | sort)

# Build sorted slides rows (with target="_blank")
sorted_slides=""
while IFS='|' read -r sort_date formatted_date title html_path; do
    [ -z "$sort_date" ] && continue
    sorted_slides+="| $formatted_date | [$title]($html_path){target=\"_blank\"} |\n"
done < <(echo -e "$slides_table" | sort)

# Write updated index.qmd
cat > index.qmd << 'HEADER'
---
title: "War and State Development"
subtitle: "PSCI 2227, Spring 2026<br>Prof. Brenton Kenkel, Vanderbilt University"
---

## Reading Guides

| Date | Reading |
|------|---------|
HEADER

echo -e "$sorted_guides" >> index.qmd

cat >> index.qmd << 'MIDDLE'
: {tbl-colwidths="[30, 70]"}

## Lecture Slides

| Date | Topic |
|------|-------|
MIDDLE

echo -e "$sorted_slides" >> index.qmd

echo ': {tbl-colwidths="[30, 70]"}' >> index.qmd

echo "Updated index.qmd with $(echo -e "$guides_table" | grep -c .) reading guides and $(echo -e "$slides_table" | grep -c .) slide decks"
