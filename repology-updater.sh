#!/bin/sh

set -x

[ ! -f ./main.zip ] && curl -#Lo main.zip "https://github.com/ivan-hc/AM/archive/main.zip" && unzip -qq main.zip
if wget -q --tries=10 --timeout=20 --spider https://repology.org; then
	rm -f ./versions-list
	for arg in AM-main/programs/x86_64/*; do
		if grep -q "repology" "$arg"; then
			appname=$(echo "$arg" | sed -- 's:.*/::')
			purearg=$(echo "$appname" | sed -- 's/^teamviewer-host$/teamviewer/g; s/^infra-app$/infra/g; s/^nfctools$/nfcutils/g; s/wiznote/wiznote-desktop/g')
			page=$(wget -q -O - "https://repology.org/project/$purearg/versions" | grep -i "version")
			[ -z "$page" ] && page=$(wget -q -O - "https://repology.org/project/$purearg-client/versions" | grep -i "version")
			[ -z "$page" ] && page=$(wget -q -O - "https://repology.org/project/$purearg-desktop/versions" | grep -i "version")
			version=$(echo "$page" | grep -i "new" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			if [ -z "$version" ]; then
				version=$(echo "$page" | grep -i "uniq" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			fi
			if [ -z "$version" ]; then
				version="unknown"
			fi
			echo "◆ $appname $version" >> ./versions-list
		fi
	done
fi
if ! wget -q --tries=10 --timeout=20 --spider https://repology.org; then
	exit 1
fi
