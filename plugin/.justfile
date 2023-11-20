export DARKLUA_DEV := "true"

SOURCEMAP := "sourcemap.json"

dev:
    just install-packages
    rojo build default.project.json --watch --plugin HoudiniEngineForRoblox.rbxm & just process-watch

process: sourcemap
    darklua process -c darklua.json src/ dist/

process-watch: sourcemap
    darklua process -c darklua.json -w src/ dist/

sourcemap:
    mkdir -p dist/
    rojo sourcemap sourcemap.project.json -o {{SOURCEMAP}} --include-non-scripts

install-packages:
    wally install
    just sourcemap
    wally-package-types --sourcemap {{SOURCEMAP}} Packages/
