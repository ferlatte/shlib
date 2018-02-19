#!/bin/sh
# vim:et:ft=sh:sts=2:sw=2
#
# Unit tests for shlib_ansi.
#
# Copyright 2018 Kate Ward. All Rights Reserved.
# Released under the Apache 2.0 license.
#
# Author: kate.ward@forestent.com (Kate Ward)
# https://github.com/kward/shlib
#
# $() are not fully portable (POSIX != portable).
#   shellcheck disable=SC2006

# Treat unset variables as an error.
set -u

testANSIInit() {
  while read -r mode none ok; do
    [ "${none}" = "''" ] && none=''

    (
      # shellcheck disable=SC2034
      tput='mock_tput'
      shlib_ansi_init "${mode}" >"${stdoutF}" 2>"${stderrF}"
      echo $? >"${returnF}"
      # shellcheck disable=SC2154
      echo "${shlib_ansi_none}" >"${gotF}"
    )

    got=`cat "${returnF}"`
    want="${ok}"
    test "${got}" = "${want}"
    assertTrue "${mode} ok: ansi_init exited with '${got}', want '${want}'" $?

    [ "${ok}" -eq "${SHLIB_TRUE}" ] || continue

    echo "${none}" >"${wantF}"
    diff -u "${gotF}" "${wantF}"
    rtrn=$?
    assertTrue "${mode} got and want differ" ${rtrn}
    if [ "${rtrn}" -ne "${SHLIB_TRUE}" ]; then
      echo '-- got --'; hexdump "${gotF}"
      echo '-- want --'; hexdump "${wantF}"
    fi
  done <<EOF
always  ${SHLIB_ANSI_NONE} ${SHLIB_TRUE}
auto    ${SHLIB_ANSI_NONE} ${SHLIB_TRUE}
none    ''                 ${SHLIB_TRUE}
invalid ''                 ${SHLIB_FALSE}
EOF
}

# tput overrides the OS tput command.
mock_tput() {
  echo 256
}

oneTimeSetUp() {
  # Load the function.
  # shellcheck disable=SC1090
  . "$(echo "$0" |sed 's/_test.sh$//')"

  stdoutF="${SHUNIT_TMPDIR}/stdout"
  stderrF="${SHUNIT_TMPDIR}/stderr"
  returnF="${SHUNIT_TMPDIR}/return"
  gotF="${SHUNIT_TMPDIR}/got"
  wantF="${SHUNIT_TMPDIR}/want"
  export stdoutF stderrF returnF gotF wantF

  # shellcheck disable=SC2034
  SHLIB_DEBUG=${SHLIB_TRUE}
}

# Run shUnit2.
# shellcheck disable=SC1090,SC1091
. "${SHLIB_LIBDIR:-../lib}/shunit2"
