#!/bin/sh

if [ "$#" -gt 0 ]; then
	RELEASE="${1}"
else
	RELEASE=$(uname -r)
fi

if [ "$#" -gt 1 ]; then
	DIR="${2}"
else
	DIR='snapshots'
fi

DATE=$(date "+%Y%m%d")
ARCH=$(uname -m)

echo "Updating to latest ${RELEASE} (${ARCH}) on ${DATE}"

OVERWRITE_FILES="/etc/devd/hyperv.conf /etc/devd/usb.conf /etc/devd/zfs.conf /etc/ntp/leap-seconds /etc/crontab /etc/inetd.conf /etc/periodic/security/100.chksetuid /etc/periodic/security/110.neggrpperm /etc/periodic/security/security.functions /etc/periodic/daily/200.backup-passwd /etc/periodic/daily/480.leapfile-ntpd /etc/periodic/daily/800.scrub-zfs /etc/netstart /etc/motd /etc/spwd.db /etc/security/audit_event /etc/services /etc/pwd.db /etc/rc /etc/printcap /etc/devd.conf /etc/newsyslog.conf /etc/rc.subr /etc/portsnap.conf /etc/rc.initdiskless /etc/ssh/moduli /etc/ssh/sshd_config /etc/ssh/ssh_config /etc/network.subr /etc/syslog.conf /etc/pf.os /etc/autofs/include_nis /etc/mail/mailer.conf /etc/autofs/special_media /etc/regdomain.xml/etc /etc/rc.firewall /etc/ttys /etc/devd/devmatch.conf /etc/ntp.conf /etc/ftpusers /etc/auto_master /etc/ssl/openssl.cnf /etc/ppp/ppp.conf /etc/rc.resume /etc/newsyslog.conf.d/opensm.conf /etc/periodic/daily/440.status-mailq /etc/periodic/weekly/340.noid /etc/csh.login /etc/profile /etc/mail/Makefile /etc/snmpd.config /etc/rc.shutdown /etc/login.conf /etc/periodic/daily/310.accounting /etc/ddb.conf /etc/periodic/security/520.pfdenied /etc/libalias.conf /etc/mail/freebsd.cf /etc/mail/submit.cf /etc/mail/sendmail.cf /etc/mail/freebsd.submit.cf /etc/mail/freebsd.mc /etc/mail/freebsd.submit.mc /etc/motd.template"

EXCLUDE_FILES="/etc/shells /etc/sysctl.conf /etc/passwd /etc/master.passwd /etc/group"

/sbin/bectl create "${RELEASE}-${DATE}"

$HOME/scripts/3rdparty/mondieu/mondieu -w "${OVERWRITE_FILES}" -x "${EXCLUDE_FILES}" -p base,kernel -y -U ftp://ftp.FreeBSD.org/pub/FreeBSD/${DIR}/${ARCH}/${ARCH}/${RELEASE} ${RELEASE}

echo "Host upgraded, please reboot"
