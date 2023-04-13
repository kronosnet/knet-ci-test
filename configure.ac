#
# Copyright (C) 2023 Red Hat, Inc.  All rights reserved.
#
# Authors: Fabio M. Di Nitto <fabbione@kronosnet.org>
#
# This software licensed under GPL-2.0+
#

#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
#

AC_PREREQ([2.63])
AC_INIT([knet-ci-test],
	m4_esyscmd([build-aux/git-version-gen .tarball-version .gitarchivever]),
	[devel@lists.kronosnet.org])
# Don't let AC_PROC_CC (invoked by AC_USE_SYSTEM_EXTENSIONS) replace
# undefined CFLAGS with -g -O2, overriding our special OPT_CFLAGS.
: ${CFLAGS=""}
AC_USE_SYSTEM_EXTENSIONS
AM_INIT_AUTOMAKE([1.13 dist-bzip2 dist-xz color-tests -Wno-portability subdir-objects])

LT_PREREQ([2.2.6])
# --enable-new-dtags: Use RUNPATH instead of RPATH.
# It is necessary to have this done before libtool does linker detection.
# See also: https://github.com/kronosnet/kronosnet/issues/107
# --as-needed: Modern systems have builtin ceil() making -lm superfluous but
# AC_SEARCH_LIBS can't detect this because it tests with a false prototype
AX_CHECK_LINK_FLAG([-Wl,--enable-new-dtags],
		   [AM_LDFLAGS=-Wl,--enable-new-dtags],
		   [AC_MSG_ERROR(["Linker support for --enable-new-dtags is required"])])
AX_CHECK_LINK_FLAG([-Wl,--as-needed], [AM_LDFLAGS="$AM_LDFLAGS -Wl,--as-needed"])

saved_LDFLAGS="$LDFLAGS"
LDFLAGS="$AM_LDFLAGS $LDFLAGS"
LT_INIT
LDFLAGS="$saved_LDFLAGS"

AC_CONFIG_MACRO_DIR([m4])
AC_CONFIG_SRCDIR([main.c])
AC_CONFIG_HEADERS([config.h])

AC_CANONICAL_HOST

AC_LANG([C])

if test "$prefix" = "NONE"; then
	prefix="/usr"
	if test "$localstatedir" = "\${prefix}/var"; then
		localstatedir="/var"
	fi
	if test "$libdir" = "\${exec_prefix}/lib"; then
		if test -e /usr/lib64; then
			libdir="/usr/lib64"
		else
			libdir="/usr/lib"
		fi
	fi
fi

AC_PROG_AWK
AC_PROG_GREP
AC_PROG_SED
AC_PROG_CPP
AC_PROG_CC
m4_version_prereq([2.70], [:], [AC_PROG_CC_C99])
if test "x$ac_cv_prog_cc_c99" = "xno"; then
	AC_MSG_ERROR(["C99 support is required"])
fi
AC_PROG_LN_S
AC_PROG_INSTALL
AC_PROG_MAKE_SET
PKG_PROG_PKG_CONFIG

## local helper functions
# this function checks if CC support options passed as
# args. Global CPPFLAGS are ignored during this test.
cc_supports_flag() {
	saveCPPFLAGS="$CPPFLAGS"
	CPPFLAGS="-Werror $@"
	AC_MSG_CHECKING([whether $CC supports "$@"])
	AC_COMPILE_IFELSE([AC_LANG_PROGRAM([])],
			  [RC=0; AC_MSG_RESULT([yes])],
			  [RC=1; AC_MSG_RESULT([no])])
	CPPFLAGS="$saveCPPFLAGS"
	return $RC
}

PKG_CHECK_MODULES([knet], [libknet])

AC_MSG_NOTICE([knet found $knet_CFLAGS / $knet_LIBS])

OPT_CFLAGS="-O2"

# gdb flags
if test "x${GCC}" = xyes; then
	GDB_CFLAGS="-ggdb3"
else
	GDB_CFLAGS="-g"
fi

DEFAULT_CFLAGS="-Werror -Wall -Wextra"

# manual overrides
# generates too much noise for stub APIs
UNWANTED_CFLAGS="-Wno-unused-parameter"

AC_SUBST([AM_CFLAGS],["$OPT_CFLAGS $GDB_CFLAGS $DEFAULT_CFLAGS $UNWANTED_CFLAGS"])
AC_SUBST([AM_LDFLAGS])

AX_PROG_DATE
AS_IF([test "$ax_cv_prog_date_gnu_date:$ax_cv_prog_date_gnu_utc" = yes:yes],
	[UTC_DATE_AT="date -u -d@"],
	[AS_IF([test "x$ax_cv_prog_date_bsd_date" = xyes],
		[UTC_DATE_AT="date -u -r"],
		[AC_MSG_ERROR([date utility unable to convert epoch to UTC])])])
AC_SUBST([UTC_DATE_AT])

AC_ARG_VAR([SOURCE_EPOCH],[last modification date of the source])
AC_MSG_NOTICE([trying to determine source epoch])
AC_MSG_CHECKING([for source epoch in \$SOURCE_EPOCH])
AS_IF([test -n "$SOURCE_EPOCH"],
	[AC_MSG_RESULT([yes])],
	[AC_MSG_RESULT([no])
	 AC_MSG_CHECKING([for source epoch in source_epoch file])
	 AS_IF([test -e "$srcdir/source_epoch"],
		[read SOURCE_EPOCH <"$srcdir/source_epoch"
		 AC_MSG_RESULT([yes])],
		[AC_MSG_RESULT([no])
		 AC_MSG_CHECKING([for source epoch baked in by gitattributes export-subst])
		 SOURCE_EPOCH='$Format:%at$' # template for rewriting by git-archive
		 AS_CASE([$SOURCE_EPOCH],
			[?Format:*], # was not rewritten
				[AC_MSG_RESULT([no])
				 AC_MSG_CHECKING([for source epoch in \$SOURCE_DATE_EPOCH])
				 AS_IF([test "x$SOURCE_DATE_EPOCH" != x],
					[SOURCE_EPOCH="$SOURCE_DATE_EPOCH"
					 AC_MSG_RESULT([yes])],
					[AC_MSG_RESULT([no])
					 AC_MSG_CHECKING([whether git log can provide a source epoch])
					 SOURCE_EPOCH=f${SOURCE_EPOCH#\$F} # convert into git log --pretty format
					 SOURCE_EPOCH=$(cd "$srcdir" && git log -1 --pretty=${SOURCE_EPOCH%$} 2>/dev/null)
					 AS_IF([test -n "$SOURCE_EPOCH"],
						[AC_MSG_RESULT([yes])],
						[AC_MSG_RESULT([no, using current time and breaking reproducibility])
						 SOURCE_EPOCH=$(date +%s)])])],
			[AC_MSG_RESULT([yes])]
		 )])
	])
AC_MSG_NOTICE([using source epoch $($UTC_DATE_AT$SOURCE_EPOCH +'%F %T %Z')])

AC_CONFIG_FILES([
		Makefile
		])

if test "x$VERSION" = "xUNKNOWN"; then
	AC_MSG_ERROR([m4_text_wrap([
  configure was unable to determine the source tree's current version. This
  generally happens when using git archive (or the github download button)
  generated tarball/zip file. In order to workaround this issue, either use git
  clone https://github.com/kronosnet/kronosnet.git or use an official release
  tarball, available at https://kronosnet.org/releases/.  Alternatively you
  can add a compatible version in a .tarball-version file at the top of the
  source tree, wipe your autom4te.cache dir and generated configure, and rerun
  autogen.sh.
  ], [  ], [   ], [76])])
fi

AC_OUTPUT
