##
# Prologue
##
AC_INIT([netroot],
        m4_esyscmd([git describe --always | awk '/.*/ {printf "%s",$1; exit}']))
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_MACRO_DIR([config])
AC_CONFIG_SRCDIR([NEWS])
AC_CANONICAL_SYSTEM
X_AC_EXPAND_INSTALL_DIRS

##
# Automake support
##
AM_INIT_AUTOMAKE([subdir-objects])
AM_SILENT_RULES([yes])
AM_CONFIG_HEADER([config/config.h])
AM_MAINTAINER_MODE

##
# Specialized install directories
##
AC_ARG_WITH([bootdir],
  [AS_HELP_STRING([--with-bootdir=DIR], [directory where kernel images live])],
  [with_bootdir="$withval"], [with_bootdir="$libdir/boot"])
adl_RECURSIVE_EVAL(["$with_bootdir"], [bootdir])
AC_SUBST([bootdir])

adl_RECURSIVE_EVAL(["$sysconfdir/kernel/postinst.d"], [postinstdir])
AC_SUBST([postinstdir])

adl_RECURSIVE_EVAL(["$sysconfdir/kernel/prerm.d"], [prermdir])
AC_SUBST([prermdir])

adl_RECURSIVE_EVAL(["$libdir/dracut/modules.d"], [dracutmoddir])
AC_SUBST([dracutmoddir])

##
# Epilogue
##
AC_CONFIG_FILES( \
  netroot.spec \
  Makefile \
  boot/Makefile \
  configpxe/Makefile \
  configpxe/configpxe.8 \
  freedos/Makefile \
  dracut.nbd9/Makefile \
)

AC_OUTPUT
