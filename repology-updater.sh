#!/bin/sh

set -x

[ ! -f ./main.zip ] && curl -#Lo main.zip "https://github.com/ivan-hc/AM/archive/main.zip" && unzip -qq main.zip
if wget -q --tries=10 --timeout=20 --spider https://repology.org; then
	rm -f ./versions-list
	for arg in AM-main/programs/x86_64/*; do
		if grep -q "repology" "$arg"; then
			appname=$(echo "$arg" | sed -- 's:.*/::')
			purearg=$(echo "$appname" | sed -- 's/-electron$//g; s/-host$//g; s/-appimage$//g; s/-app$//g; s/inkscape-next$/inkscape-dev/g; s/^nfctools$/nfcutils/g')
			version=$(wget -q -O - "https://repology.org/project/$purearg/versions" | grep -i "version" | grep -i "new" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			if [ -z "$version" ]; then
				version=$(wget -q -O - "https://repology.org/project/$purearg/versions" | grep -i "version" | grep -i "uniq" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			fi
			if [ -z "$version" ]; then
				version=$(wget -q -O - "https://repology.org/project/$purearg-client/versions" | grep -i "version" | grep -i "new" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			fi
			if [ -z "$version" ]; then
				version=$(wget -q -O - "https://repology.org/project/$purearg-client/versions" | grep -i "version" | grep -i "uniq" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			fi
			if [ -z "$version" ]; then
				version=$(wget -q -O - "https://repology.org/project/$purearg-desktop/versions" | grep -i "version" | grep -i "new" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
			fi
			if [ -z "$version" ]; then
				version=$(wget -q -O - "https://repology.org/project/$purearg-desktop/versions" | grep -i "version" | grep -i "uniq" | head -1 | tr '><' '\n' | grep "^[0-9]") || version=""
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
