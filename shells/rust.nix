# This file contains a development shell for working on rustc. To use, symlink it into the
# directory where Rust is being worked on.

let
  pkgs = import (import ../nix/sources.nix).nixpkgs {
    overlays = [
      (_: super: { workman = super.callPackage ../packages/workman.nix {}; })
    ];
  };
  # Build configuration for rust-lang/rust. Based on `config.toml.example` from
  # `1bd30ce2aac40c7698aa4a1b9520aa649ff2d1c5`.
  config = pkgs.writeText "rust-config" ''
    # =============================================================================
    # Tweaking how LLVM is compiled
    # =============================================================================
    [llvm]

    # Indicates whether the LLVM build is a Release or Debug build
    optimize = false

    # Indicates whether the LLVM assertions are enabled or not
    assertions = true

    # Indicates whether ccache is used when building LLVM
    ccache = true

    # Tell the LLVM build system to use Ninja instead of the platform default for
    # the generated build system. This can sometimes be faster than make, for
    # example.
    ninja = true

    # LLVM targets to build support for.
    # Note: this is NOT related to Rust compilation targets. However, as Rust is
    # dependent on LLVM for code generation, turning targets off here WILL lead to
    # the resulting rustc being unable to compile for the disabled architectures.
    # Also worth pointing out is that, in case support for new targets are added to
    # LLVM, enabling them here doesn't mean Rust is automatically gaining said
    # support. You'll need to write a target specification at least, and most
    # likely, teach rustc about the C ABI of the target. Get in touch with the
    # Rust team and file an issue if you need assistance in porting!
    targets = "AArch64;ARM;Hexagon;MSP430;Mips;NVPTX;PowerPC;RISCV;Sparc;SystemZ;WebAssembly;X86"

    # =============================================================================
    # General build configuration options
    # =============================================================================
    [build]

    # Indicate whether the compiler should be documented in addition to the standard
    # library and facade crates.
    compiler-docs = true

    # Indicate whether git submodules are managed and updated automatically.
    submodules = true

    # Update git submodules only when the checked out commit in the submodules differs
    # from what is committed in the main rustc repo.
    fast-submodules = true

    # The path to (or name of) the GDB executable to use. This is only used for
    # executing the debuginfo test suite.
    gdb = "${pkgs.gdb}/bin/gdb"

    # Python interpreter to use for various tasks throughout the build, notably
    # rustdoc tests, the lldb python interpreter, and some dist bits and pieces.
    # Note that Python 2 is currently required.
    #
    # Defaults to python2.7, then python2. If neither executable can be found, then
    # it defaults to the Python interpreter used to execute x.py.
    python = "${pkgs.python2Full}/bin/python"

    # =============================================================================
    # Options for compiling Rust code itself
    # =============================================================================
    [rust]

    # Whether or not to optimize the compiler and standard library.
    # WARNING: Building with optimize = false is NOT SUPPORTED. Due to bootstrapping,
    # building without optimizations takes much longer than optimizing. Further, some platforms
    # fail to build without this optimization (c.f. #65352).
    optimize = true

    # Whether or not debug assertions are enabled for the compiler and standard
    # library.
    debug-assertions = true

    # Debuginfo level for most of Rust code, corresponds to the `-C debuginfo=N` option of `rustc`.
    # `0` - no debug info
    # `1` - line tables only
    # `2` - full debug info with variable and type information
    # Can be overriden for specific subsets of Rust code (rustc, std or tools).
    # Debuginfo for tests run with compiletest is not controlled by this option
    # and needs to be enabled separately with `debuginfo-level-tests`.
    debuginfo-level = 2

    # Whether or not `panic!`s generate backtraces (RUST_BACKTRACE)
    backtrace = true

    # Whether to always use incremental compilation when building rustc
    incremental = true

    # Indicates whether LLD will be compiled and made available in the sysroot for
    # rustc to execute.
    lld = true

    # Indicates whether some LLVM tools, like llvm-objdump, will be made available in the
    # sysroot.
    llvm-tools = true

    # Indicates whether LLDB will be made available in the sysroot.
    # This is only built if LLVM is also being built.
    lldb = true

    # Whether to deny warnings in crates
    deny-warnings = true

    # Print backtrace on internal compiler errors during bootstrap
    backtrace-on-ice = true

    # Run tests in various test suites with the "nll compare mode" in addition to
    # running the tests in normal mode. Largely only used on CI and during local
    # development of NLL
    test-compare-mode = false
  '';
  # Custom Vim configuration to disable ctags on directories we never want to look at.
  lvimrc = pkgs.writeText "rust-lvimrc" ''
    let g:gutentags_ctags_exclude = [
    \   "src/llvm-project",
    \   "src/librustdoc/html",
    \   "src/doc",
    \   "src/ci",
    \   "src/bootstrap",
    \   "*.md"
    \ ]

    " Don't format automatically.
    let g:ale_fix_on_save_ignore['rust'] = [ 'rustfmt' ]

    " Same configuration as `x.py fmt`.
    let g:ale_rust_rustfmt_options = '--edition 2018 --unstable-features --skip-children'
    let g:ale_rust_rustfmt_executable = './build/x86_64-unknown-linux-gnu/stage0/bin/rustfmt'
  '';
  # Files that are ignored by ripgrep when searching.
  rgignore = pkgs.writeText "rust-rgignore" ''
    configure
    config.toml.example
    x.py
    LICENSE-MIT
    LICENSE-APACHE
    COPYRIGHT
    **/*.txt
    **/*.toml
    **/*.yml
    **/*.nix
    *.md
    src/bootstrap
    src/ci
    src/doc/
    src/etc/
    src/llvm-emscripten/
    src/llvm-project/
    src/rtstartup/
    src/rustllvm/
    src/stdsimd/
    src/tools/rls/rls-analysis/test_data/
  '';
  workmanConfig = pkgs.writeText "rust-workman_config" ''
    # Directory where working directories are kept.
    WORKDIR_PATH="."
    # Name of stamp file placed in active working directories.
    ACTIVE_STAMP_NAME=".workman_active_working_directory"
    # Name of stamp file placed in working directories that are updated but not assigned.
    DO_NOT_ASSIGN_STAMP_NAME=".workman_do_not_assign"

    # Use git worktrees.
    USE_GIT_WORKTREE="YES"

    # Name of project, used in working directory names.
    PROJECT_NAME="rust"
    # Default branch to check out and update.
    DEFAULT_BRANCH="master"

    # Name of upstream remote to create and update from.
    UPSTREAM_NAME="upstream"
    # Url of upstream remote to create and update from.
    UPSTREAM_URL="git@github.com:rust-lang/rust.git"

    # Name of origin remote to clone from.
    ORIGIN_NAME="origin"
    # Url of origin remote to clone from.
    ORIGIN_URL="git@github.com:davidtwco/rust.git"

    # Command to run before creating a new working directory.
    BEFORE_COMMAND="
    ln -s ${config} ./config.toml &&
    ln -s ${rgignore} ./.rgignore &&
    ln -s ${lvimrc} ./.lvimrc
    "
    # Command to run to clean a working directory.
    CLEAN_COMMAND="python2 x.py clean"
    # Command to run to build in a working directory.
    BUILD_COMMAND="python2 x.py build"
    # Command to run after creating a new working directory.
    AFTER_COMMAND="
    rustup toolchain link $(basename $(pwd))-stage1 ./build/x86_64-unknown-linux-gnu/stage1 &&
    rustup toolchain link $(basename $(pwd))-stage2 ./build/x86_64-unknown-linux-gnu/stage2
    "
  '';
in
pkgs.mkShell rec {
  name = "rust";
  buildInputs = with pkgs; [
    git
    pythonFull
    gnumake
    cmake
    curl
    clang

    libxml2
    ncurses
    swig

    # If `llvm.ninja` is `true` in `config.toml`.
    ninja
    # If `llvm.ccache` is `true` in `config.toml`.
    ccache
    # Used by debuginfo tests.
    gdb
    # Used with emscripten target.
    nodejs

    # Local toolchain is added to rustup to avoid needing to set up
    # environment variables.
    rustup

    # Working directory management.
    workman
  ];

  # Environment variable used by `workman` to find configuration.
  WORKMAN_CONFIG_FILE = workmanConfig;
  # Environment variable for local use.
  RUSTC_CONFIG = config;
  RGIGNORE = rgignore;
  LVIMRC = lvimrc;
  # Always show backtraces.
  RUST_BACKTRACE = 1;

  # Disable compiler hardening for formatting - required for LLVM.
  hardeningDisable = [ "format" ];
}
