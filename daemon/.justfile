hfs_path := "/Applications/Houdini/Current/Frameworks/Houdini.framework/Versions/Current/Resources"

check:
    HFS={{hfs_path}} cargo check

build:
    HFS={{hfs_path}} cargo build --release

run:
    HFS={{hfs_path}} RUST_LOG=debug cargo run -- test
