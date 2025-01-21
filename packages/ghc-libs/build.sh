TERMUX_PKG_HOMEPAGE=https://www.haskell.org/ghc/
TERMUX_PKG_DESCRIPTION="The Glasgow Haskell Compiler libraries"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_MAINTAINER="Aditya Alok <alok@termux.dev>"
TERMUX_PKG_VERSION=9.12.1
TERMUX_PKG_SRCURL="https://downloads.haskell.org/~ghc/$TERMUX_PKG_VERSION/ghc-$TERMUX_PKG_VERSION-src.tar.xz"
TERMUX_PKG_SHA256=4a7410bdeec70f75717087b8f94bf5a6598fd61b3a0e1f8501d8f10be1492754
TERMUX_PKG_DEPENDS="libiconv, libffi, libgmp, libandroid-posix-semaphore"
TERMUX_PKG_BUILD_DEPENDS="dnsutils"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--host=$TERMUX_BUILD_TUPLE
--with-system-libffi"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_REPLACES="ghc-libs-static"

termux_step_post_get_source() {
	termux_setup_ghc && termux_setup_cabal
	cabal update
}

termux_step_pre_configure() {
	export CONF_CC_OPTS_STAGE1="$CFLAGS $CPPFLAGS" CONF_GCC_LINKER_OPTS_STAGE1="$LDFLAGS"
	export CONF_CC_OPTS_STAGE2="$CFLAGS $CPPFLAGS" CONF_GCC_LINKER_OPTS_STAGE2="$LDFLAGS"
	# export CONF_GCC_SUPPORTS_NO_PIE=NO # Linker says it does, but Android > 5.0 cannot run them.

	export target="$TERMUX_HOST_PLATFORM"
	if [ "$TERMUX_ARCH" = "arm" ]; then
		target="armv7a-linux-androideabi"
	fi
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --target=$target"

	./boot.source
}

termux_step_make() {
	termux_setup_ghc && termux_setup_cabal
	(
		# XXX: Temporary

		unset CFLAGS CPPFLAGS LDFLAGS # For stage0 compilation.

		./hadrian/build binary-dist-dir -j --flavour=quickest+no_profiled_libs --docs=none \
			"stage1.*.ghc.*.opts += -optl-landroid-posix-semaphore" \
			"stage2.*.ghc.*.opts += -optl-landroid-posix-semaphore"
	)
}

termux_step_make_install() {
	# XXX: Temporary
	export target="$TERMUX_HOST_PLATFORM"
	if [ "$TERMUX_ARCH" = "arm" ]; then
		target="armv7a-linux-androideabi"
	fi
	# patch -p1 <"$TERMUX_PKG_BUILDER_DIR"/use-stage1-ghc-on-host.patch

	(
		cd _build/bindist/ghc-"$TERMUX_PKG_VERSION"-"$target" || exit 1
		CXX_STD_LIB_LIBS="c++ c++abi" ./configure --prefix="$TERMUX_PREFIX" --host="$target"
		HOST_GHC_PKG="$(realpath ../../stage1/bin/"$target"-ghc-pkg)" make install
	)

	# We may build GHC with `llc-9` etc., but only `llc` is present in Termux
	sed -i 's/"LLVM llc command", "llc.*"/"LLVM llc command", "llc"/' \
		"$TERMUX_PREFIX/lib/$target-ghc-$TERMUX_PKG_VERSION/lib/settings" || :
	sed -i 's/"LLVM opt command", "opt.*"/"LLVM opt command", "opt"/' \
		"$TERMUX_PREFIX/lib/$target-ghc-$TERMUX_PKG_VERSION/lib/settings" || :

	# `configure` script was ment to be run on device but since we are running on CI we need to remove cross compiler flag.
	sed -i 's|"cross compiling", "YES"|"cross compiling", "NO"|' \
		"$TERMUX_PREFIX/lib/$target-ghc-$TERMUX_PKG_VERSION/lib/settings" || :

}

termux_step_install_license() {
	install -Dm600 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" \
		"$TERMUX_PKG_SRCDIR/LICENSE"
}
