##
# Prologue
##
AC_INIT([netroot],
        m4_esyscmd([git describe --always | awk '/.*/ {printf "%s",$1; exit}']))
AC_CONFIG_AUX_DIR([config])
AC_CONFIG_SRCDIR([NEWS])
AC_CANONICAL_SYSTEM
X_AC_EXPAND_INSTALL_DIRS

##
# Automake support
##
AM_INIT_AUTOMAKE([])
AC_CONFIG_HEADERS([config/config.h])
AM_MAINTAINER_MODE

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
