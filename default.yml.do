# Uses ruby for date math and URI escaping
strftime() {
	ruby -e "print (Time.mktime(ARGV[0].to_i) + (ARGV[1].to_i - 1)*60*60*24).strftime(ARGV[2])" $(basename "$1" | cut -c1-4) $(basename "$1" | cut -c5-7) "$2"
}

# Bail out if there is no input
if ! ls audio/"$2"*.* > /dev/null 2>&1; then
	exit 0
fi

# Start YAML
echo "---"

# Current timezone at time of building
# Not ideal, but I don't want to use CGI
export TZ="America/Toronto"
printf 'tz: "%s"\n' "$(date +%:z)"

next="$(( $2 + 1 ))"
redo-ifchange "$next".html
if [ -e "$next".html ]; then
	printf 'next: {"uri": "%s.html", "fn": "%s"}\n' "$next" "$next"
fi

prev="$(( $2 - 1 ))"
#redo-ifchange "$prev".html
if ls audio/"$prev"*.* > /dev/null 2>&1; then
#if [ -e "$prev".html ]; then
	printf 'prev: {"uri": "%s.html", "fn": "%s"}\n' "$prev" "$prev"
fi

echo "episodes: ["
first=1
ls -r audio/"$2"*.* | while read -r FILE; do
	redo-ifchange "$FILE"

	if [ $first -ne 1 ]; then
		printf ', '
	else
		first=0
	fi

	printf '{'
	printf '"published": '
	strftime "$FILE" "%Y-%m-%d"
	printf ', "rssPublished": "%s"' "$(strftime "$FILE" "%a, %d %b %Y %H:%M:%S %z")"
	printf ', "fileSize": %s' "$(wc -c "$FILE" | cut -d' ' -f1)"
	printf ', "title": "%s"' "$(basename "$(basename "$FILE" .spx)" .opus | cut -c9-)"
	printf ', "file": "/%s"' "$(ruby -ruri -e 'print ARGV[0].split(/\//).map { |s| URI.escape(s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")) }.join("/")' "$FILE")"

	echo '}'
done
echo "]"
echo "---"
