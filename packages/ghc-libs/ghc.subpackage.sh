# shellcheck shell=bash
TERMUX_SUBPKG_DESCRIPTION="The Glasgow Haskell Compiler"
TERMUX_SUBPKG_DEPENDS="clang"

TERMUX_SUBPKG_INCLUDE="
lib/*-linux-ghc-$TERMUX_PKG_VERSION-inplace/ghc-$TERMUX_PKG_VERSION
lib/*-linux-ghc-$TERMUX_PKG_VERSION-inplace/libHSghc-$TERMUX_PKG_VERSION-inplace-ghc$TERMUX_PKG_VERSION.so
"

while read -r file; do
	TERMUX_SUBPKG_INCLUDE+=" ${file/$TERMUX_PREFIX\//}"
done < <(find "$TERMUX_PREFIX"/lib/ghc-"$TERMUX_PKG_VERSION"/bin -type f -or -type l -not -name "ghc-pkg*" -print)

while read -r file; do
	TERMUX_SUBPKG_INCLUDE+=" ${file/$TERMUX_PREFIX\//}"
done < <(find "$TERMUX_PREFIX"/bin -type f -or -type l -not -name "ghc-pkg*" -print)
