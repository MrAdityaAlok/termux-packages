TERMUX_PKG_HOMEPAGE=https://www.haskell.org/ghc/
TERMUX_PKG_DESCRIPTION="The Glasgow Haskell Compiler libraries"
TERMUX_PKG_LICENSE="custom"
TERMUX_PKG_MAINTAINER="Aditya Alok <alok@termux.dev>"
TERMUX_PKG_VERSION=9.8.1
TERMUX_PKG_SRCURL="https://downloads.haskell.org/~ghc/$TERMUX_PKG_VERSION/ghc-$TERMUX_PKG_VERSION-src.tar.xz"
TERMUX_PKG_SHA256=b2f8ed6b7f733797a92436f4ff6e088a520913149c9a9be90465b40ad1f20751
TERMUX_PKG_DEPENDS="libiconv, libffi, libgmp, libandroid-posix-semaphore"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--host=$TERMUX_BUILD_TUPLE
--with-system-libffi"
TERMUX_PKG_NO_STATICSPLIT=true
TERMUX_PKG_REPLACES="ghc-libs-static"

termux_step_post_get_source() {
	local version=3.8.1.0 #Note: As of 27-01-2024 both lib had same versioning. Review before updating.

	termux_setup_ghc && termux_setup_cabal

	local index_state
	index_state="$(grep -oP '^index-state: \K(.*)' ./hadrian/cabal.project)"
	[ -z "$index_state" ] && termux_error_exit "Unable to find index_state from ./hadrian/cabal.project"

	cabal update
	for pkg in Cabal Cabal-syntax; do
		cabal get "$pkg"-"$version" --index-state="$index_state"
		mkdir ./"$pkg"-patched
		mv "$pkg"-"$version"/* ./"$pkg"-patched
	done
}

termux_step_pre_configure() {
	export CONF_CC_OPTS_STAGE1="$CFLAGS $CPPFLAGS" CONF_GCC_LINKER_OPTS_STAGE1="$LDFLAGS"
	export CONF_CC_OPTS_STAGE2="$CFLAGS $CPPFLAGS" CONF_GCC_LINKER_OPTS_STAGE2="$LDFLAGS"

	export target="$TERMUX_HOST_PLATFORM"
	if [ "$TERMUX_ARCH" = "arm" ]; then
		target="armv7a-linux-androideabi"
	fi
	TERMUX_PKG_EXTRA_CONFIGURE_ARGS+=" --target=$target"

	./boot.source
}

termux_step_make() {
	unset CFLAGS CPPFLAGS LDFLAGS # For stage0 compilation.

	./hadrian/build binary-dist-dir --flavour=perf+llvm --docs=none \
		"stage1.rts.ghc.c.opts += -optc-Wno-error" \
		"stage1.*.ghc.*.opts += -optl-landroid-posix-semaphore" \
		"stage2.*.ghc.*.opts += -optl-landroid-posix-semaphore"
}

termux_step_make_install() {
	cd ./_build/bindist/ghc-*

	./configure --prefix="$TERMUX_PREFIX" --host="$target"
	make install

	# We may build GHC with `llc-9` etc., but only `llc` is present in Termux
	sed -i 's/"LLVM llc command", "llc.*"/"LLVM llc command", "llc"/' \
		"$TERMUX_PREFIX/lib/$target-ghc-$TERMUX_PKG_VERSION/lib/settings" || :
	sed -i 's/"LLVM opt command", "opt.*"/"LLVM opt command", "opt"/' \
		"$TERMUX_PREFIX/lib/$target-ghc-$TERMUX_PKG_VERSION/lib/settings" || :
}

termux_step_install_license() {
	install -Dm600 -t "$TERMUX_PREFIX/share/doc/$TERMUX_PKG_NAME" \
		"$TERMUX_PKG_SRCDIR/LICENSE"
}
