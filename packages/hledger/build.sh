TERMUX_PKG_HOMEPAGE=https://hledger.org/
TERMUX_PKG_DESCRIPTION="Robust, friendly, fast plain text accounting software"
TERMUX_PKG_LICENSE="GPL-3.0-or-later"
TERMUX_PKG_MAINTAINER="@erplsf"
TERMUX_PKG_VERSION=1.43.2
TERMUX_PKG_SRCURL=https://github.com/simonmichael/hledger/archive/refs/tags/${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=60b74c70ddfc6b84ca87debd2ac302aac754da3c0d9089821182e56796cb841e
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_DEPENDS="libffi, libiconv, libgmp, zlib, ncurses"
TERMUX_PKG_BUILD_DEPENDS="aosp-libs"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-c entropy+donotgetentropy"
#
termux_step_post_configure() {
	cabal get splitmix-0.1.3.1 && mv splitmix{-0.1.3.1,}
	cabal get entropy-0.4.1.11 && mv entropy{-0.4.1.11,}

	for f in "$TERMUX_PKG_BUILDER_DIR"/splitmix-patches/*.patch; do
		patch --silent -p1 -d splitmix <"$f"
	done

	sed -i -E 's|(build-type:\s*)Custom|\1Simple|' ./entropy/entropy.cabal

	cat <<-EOF >>cabal.project.local
		packages: splitmix
		          entropy

		package splitmix
			benchmarks: False
			tests: False
	EOF

	if [[ "$TERMUX_ON_DEVICE_BUILD" == false ]]; then # We do not need iserv for on device builds.
		termux_setup_ghc_iserv
		cat <<-EOF >>cabal.project.local
			package *
			    ghc-options: -fexternal-interpreter -pgmi=$(command -v termux-ghc-iserv)
		EOF
	fi
}
