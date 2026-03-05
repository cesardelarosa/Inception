#!/bin/sh

# CSS injected header for navigation
cat << 'EOF' > /var/www/html/nav.html
<nav style="padding: 10px; background: #f6f8fa; border-bottom: 1px solid #d0d7de; text-align: center;">
    <a href="index.html" style="margin-right: 15px; text-decoration: none; color: #0969da; font-weight: bold;">Readme</a>
    <a href="user_doc.html" style="margin-right: 15px; text-decoration: none; color: #0969da; font-weight: bold;">User Doc</a>
    <a href="dev_doc.html" style="text-decoration: none; color: #0969da; font-weight: bold;">Dev Doc</a>
</nav>
<br>
EOF

# Function to convert markdown to html with navigation prepended
convert_md() {
    INPUT_FILE=$1
    OUTPUT_FILE=$2
    TITLE=$3

    # Generate html body from markdown
    pandoc --standalone --css style.css \
         --metadata pagetitle="$TITLE" \
         -V body-class=markdown-body \
         -f gfm -t html \
         -o /tmp/body.html \
         --wrap=none \
         -c style.css \
         "$INPUT_FILE"

    # Fix markdown links to point to generated html files instead of .md files
    sed -i 's/href="USER_DOC\.md"/href="user_doc.html"/g' /tmp/body.html
    sed -i 's/href="DEV_DOC\.md"/href="dev_doc.html"/g' /tmp/body.html
    sed -i 's/href="README\.md"/href="index.html"/g' /tmp/body.html

    # Quick and dirty way to inject the navigation right after the opening <body> tag using sed
    sed '/<body class="markdown-body">/r /var/www/html/nav.html' /tmp/body.html > "/var/www/html/$OUTPUT_FILE"
}

# Convert all three files
convert_md "/docs/README.md" "index.html" "Inception - README"
convert_md "/docs/USER_DOC.md" "user_doc.html" "Inception - USER DOC"
convert_md "/docs/DEV_DOC.md" "dev_doc.html" "Inception - DEV DOC"

# Start Nginx
echo "Markdown files converted. Starting Nginx..."
exec nginx -g "daemon off;"
