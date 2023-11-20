export DARKLUA_DEV := "true"

SOURCEMAP := "sourcemap.json"

dev:
    just install-packages
    rojo build default.project.json --watch --plugin HoudiniEngineForRoblox.rbxm & just process-watch

process: sourcemap
    darklua process -c darklua.jsonc src/ dist/

process-watch: sourcemap
    darklua process -c darklua.jsonc -w src/ dist/

sourcemap:
    mkdir -p dist/
    rojo sourcemap default.project.json -o {{SOURCEMAP}}

install-packages:
    wally install
    just sourcemap
    wally-package-types --sourcemap {{SOURCEMAP}} Packages/
