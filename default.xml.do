redo-ifchange "$2.yml"

if [ -e "$2.yml" ]; then
	mustache "$2.yml" rss.mustache
fi
