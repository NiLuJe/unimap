all: tables.lua
tables.lua: gen.lua Scripts.txt fc-lang Makefile
	lua gen.lua Scripts.txt fc-lang fc-lang/*.orth > tables.lua
Scripts.txt:
	wget -c http://www.unicode.org/Public/5.2.0/ucd/Scripts.txt
	touch Scripts.txt
clean:
	rm -f tables.lua Scripts.txt fontconfig.tar.gz
	rm -rf fc-lang

fontconfig.tar.gz:
	wget -c https://github.com/freedesktop/fontconfig/archive/master.tar.gz -O fontconfig.tar.gz

fc-lang: fontconfig.tar.gz
	tar -xzf fontconfig.tar.gz --strip=1 --wildcards */fc-lang
	touch fc-lang

