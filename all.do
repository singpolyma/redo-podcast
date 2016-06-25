redo "`date +%Y`.yml"
(
	for FILE in audio/*; do
		echo "$(basename "$FILE" | cut -c1-4)".html
		echo "$(basename "$FILE" | cut -c1-4)".xml
	done
#	echo "index.html"
	echo "index.xml"
) | xargs redo-ifchange
