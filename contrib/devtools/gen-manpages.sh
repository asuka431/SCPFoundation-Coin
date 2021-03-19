#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

SCPFOUNDATIOND=${SCPFOUNDATIOND:-$SRCDIR/scpfoundationd}
SCPFOUNDATIONCLI=${SCPFOUNDATIONCLI:-$SRCDIR/scpfoundation-cli}
SCPFOUNDATIONTX=${SCPFOUNDATIONTX:-$SRCDIR/scpfoundation-tx}
SCPFOUNDATIONQT=${SCPFOUNDATIONQT:-$SRCDIR/qt/scpfoundation-qt}

[ ! -x $SCPFOUNDATIOND ] && echo "$SCPFOUNDATIOND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
SCP-FVER=($($SCPFOUNDATIONCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$SCPFOUNDATIOND --version | sed -n '1!p' >> footer.h2m

for cmd in $SCPFOUNDATIOND $SCPFOUNDATIONCLI $SCPFOUNDATIONTX $SCPFOUNDATIONQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${SCP-FVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${SCP-FVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
