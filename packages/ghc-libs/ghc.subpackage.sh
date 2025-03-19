# shellcheck shell=bash
TERMUX_SUBPKG_DESCRIPTION="The Glasgow Haskell Compiler"
TERMUX_SUBPKG_DEPENDS="clang"

TERMUX_SUBPKG_INCLUDE="
lib/ghc-$TERMUX_PKG_VERSION/lib/*-linux-ghc-$TERMUX_PKG_VERSION-inplace/ghc-$TERMUX_PKG_VERSION
lib/ghc-$TERMUX_PKG_VERSION/lib/*-linux-ghc-$TERMUX_PKG_VERSION-inplace/libHSghc-$TERMUX_PKG_VERSION-inplace-ghc$TERMUX_PKG_VERSION.so
$(find lib/ghc-"$TERMUX_PKG_VERSION"/bin -type f -or -type l -not -name "ghc-pkg*" -print)
$(find bin -type f -or -type l -not -name "ghc-pkg*" -print)
"
#
# while read -r file; do
# 	TERMUX_SUBPKG_INCLUDE+=" $file"
# done < <(find lib/ghc-"$TERMUX_PKG_VERSION"/bin -type f -or -type l -not -name "ghc-pkg*" -print)
#
# while read -r file; do
# 	TERMUX_SUBPKG_INCLUDE+=" $file"
# done < <(find bin -type f -or -type l -not -name "ghc-pkg*" -print)
