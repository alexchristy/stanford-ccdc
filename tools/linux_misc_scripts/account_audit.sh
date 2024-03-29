#!/bin/bash

get_human_users() {
    awk -F: '($3 >= 1000 || $3 == 0) && $1 != "nobody" {print $1}' /etc/passwd
}

user_is_admin() {
    test "$(id -u "$1")" == 0
}

print_user() {
    local user="$1"
    local successful_logins="$2"
    local failed_logins="$3"

    user_is_admin "$user" && user+=" (Admin)"
    printf "%-24s %10d %10d\n" "$user" "$successful_logins" "$failed_logins"
}

count_logins_file() {
    local user files file total_logins file_logins

    lookup_pattern="$1"
    shift
    files=("$@")

    total_logins=0
    for file in "${files[@]}"; do
        file_logins="$(grep -c -E "$lookup_pattern" "$file")"
        total_logins=$(( total_logins + file_logins ))
    done

    echo "$total_logins"
}

file_audit() {
    local file_pattern users auth_files user successful_logins failed_logins

    file_prefix="$1"
    users=( $(get_human_users) )
    files=( $(find "/var/log/$file_prefix"* -maxdepth 0 2>/dev/null) )
    
    for user in "${users[@]}"; do
        successful_logins="$(count_logins_file "sshd.* session opened for user $user" "${files[@]}")"
        failed_logins="$(count_logins_file "sshd.* authentication failure.*user=$user" "${files[@]}")"
        print_user "$user" "$successful_logins" "$failed_logins"
    done
}

secure_audit() {
    file_audit "secure"
    echo "Used method 'secure' on $(hostname)"
}

auth_audit() {
    file_audit "auth.log"
    echo "Used method 'auth.log' on $(hostname)"
}

journalctl_count_logins() {
    journalctl --quiet -D logs/journal -u sshd --grep "$1" | wc -l
}

journalctl_audit() {
    local users user successful_logins failed_logins

    users=( $(get_human_users) )
    for user in "${users[@]}"; do
        successful_logins="$(journalctl_count_logins "sshd.* session opened for user $user")"
        failed_logins="$(journalctl_count_logins "sshd.* authentication failure.*user=$user")"
        print_user "$user" "$successful_logins" "$failed_logins"
    done
    echo "Used method 'journalctl' on $(hostname)"
}

last_count_logins() {
    local user files file total_logins file_logins

    user="$1"
    shift
    files=("$@")

    total_logins=0
    for file in "${files[@]}"; do
        file_logins="$(last --file "$file" "$user" | grep -c "^$user")"
        total_logins=$(( total_logins + file_logins ))
    done

    echo "$total_logins"
}

last_audit() {
    local users wtmp_files btmp_files user successful_logins failed_logins

    users=( $(get_human_users) )
    wtmp_files=( $(find /var/log/wtmp* -maxdepth 0 2>/dev/null) )
    btmp_files=( $(find /var/log/btmp* -maxdepth 0 2>/dev/null) )
    
    for user in "${users[@]}"; do
        successful_logins="$(last_count_logins "$user" "${wtmp_files[@]}")"
        failed_logins="$(last_count_logins "$user" "${btmp_files[@]}")"
        print_user "$user" "$successful_logins" "$failed_logins"
    done
    echo "Used method 'last' on $(hostname)"
}

audit_logins() {
    if [[ -f /var/log/secure ]]; then
        secure_audit
    elif find /var/log/auth.log* -maxdepth 0 >/dev/null 2>&1; then
        auth_audit
    elif [[ $(journalctl --quiet -u sshd | wc -l) -gt 0 ]]; then
        journalctl_audit
    else
        last_audit
    fi
}

printf "%-24s %10s %10s\n" "User" "Successful" "Failed"
echo "----------------------------------------------"
audit_logins
