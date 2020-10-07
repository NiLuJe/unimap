package = "unimap"
version = "0.1-0"

source = {
  url = "git://github.com/ezdiy/unimap.git",
}

description = {
    summary = "Check coverage of for a language or a script",
    detailed = [[This is a ghetto fontconfig to determine whether a
given font face is suitable to display specific language. ]],
    license = "Public Domain",
    maintainer = "ezdiy@outlook.com"
}

build = {
    type = "builtin",
    modules = {
        ["unimap.init"] = "init.lua",
        ["unimap.unimaps"] = "unimaps.lua",
    }
}
