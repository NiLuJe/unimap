all: tables.lua
tables.lua: gen.lua Scripts.txt script_names.lua fc-lang Makefile
	lua gen.lua Scripts.txt fc-lang fc-lang/*.orth > tables.lua
Scripts.txt:
	wget -c http://www.unicode.org/Public/15.0.0/ucd/Scripts.txt
	touch Scripts.txt
script_names.lua: Scripts.txt
	echo "return {" > script_names.lua
	grep -Eo "; [[:alpha:]_]+ #" Scripts.txt | awk '{print "\""$$2}' ORS='",\n' | uniq >> script_names.lua
	echo "}" >> script_names.lua
clean:
	rm -f tables.lua Scripts.txt script_names.lua fontconfig.tar.gz
	rm -rf fc-lang

fontconfig.tar.gz:
	wget -c https://github.com/freedesktop/fontconfig/archive/master.tar.gz -O fontconfig.tar.gz

fc-lang: fontconfig.tar.gz
	tar -xzf fontconfig.tar.gz --strip=1 --wildcards */fc-lang
	touch fc-lang

