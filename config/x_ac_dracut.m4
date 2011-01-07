AC_DEFUN([X_AC_DRACUT],
[
  AC_MSG_CHECKING([for whether to build with dracut])
  AC_ARG_WITH([dracut],
    AC_HELP_STRING([--with-dracut], [Build with dracut]),
    [ case "$withval" in
        no)  ac_dracut_test=no ;;
        yes) ac_dracut_test=yes ;;
        *)   AC_MSG_ERROR([bad value "$withval" for --with-dracut]) ;;
      esac
    ]
  )
  AC_MSG_RESULT([${ac_dracut_test=no}])
  if test "$ac_dracut_test" = "yes"; then
     ac_with_dracut=yes
     AC_SUBST([WITH_DRACUT],0)
  else
     ac_with_dracut=no
     AC_SUBST([WITH_DRACUT],1)
  fi
])

