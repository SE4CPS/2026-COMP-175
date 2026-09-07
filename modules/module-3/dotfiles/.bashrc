# ~/.bashrc -- University Library server, sample admin welcome banner
#
# Companion file for COMP-175 Module 3 (File Systems & Storage). This is
# NOT a full replacement .bashrc -- append the block below to your own
# ~/.bashrc (or `source` this file from it) to get a short admin-facing
# status report on every new interactive shell login.
#
# Deliberately built only from commands Module 3 itself teaches: df,
# mount, id, groups, stat -- so it doubles as a real-world example of
# why those commands matter, not just syntax to memorize.

# Only run for interactive shells -- a script piping through bash
# shouldn't get a banner dumped into its output.
case $- in
    *i*) ;;
      *) return ;;
esac

welcome_banner() {
    local user host now root_fs

    user="$(whoami)"
    host="$(hostname)"
    now="$(date '+%A, %B %d %Y  %H:%M %Z')"

    echo "-------------------------------------------------------------"
    echo " Welcome, ${user}! You are logged in to: ${host}"
    echo " ${now}"
    echo "-------------------------------------------------------------"

    # Module 3, "Ownership: Owner & Group" -- id/groups. Useful the
    # instant you're unsure whether a command needs sudo.
    echo " Your identity:  $(id)"
    echo " Your groups:    $(groups)"
    echo

    # Module 3, "What Is a File System?" -- mount. Shows what kind of
    # filesystem root is actually running on (ext4, xfs, overlay in a
    # container, etc.) -- the very first fact that slide asks about.
    root_fs="$(mount | grep ' on / ' | awk '{print $5}')"
    echo " Root filesystem type: ${root_fs:-unknown}"
    echo

    # Same slide's other half -- df. Free space on the mounts an admin
    # actually cares about: root and the library's own /srv share.
    echo " Disk space (df -h):"
    df -h / /srv 2>/dev/null | awk 'NR==1{print "   "$0} NR>1{print "   "$0}'
    echo

    # A quick reminder of where FHS says the changing data lives --
    # ties back to the "/var: Where the Changes Go" slide.
    if [ -d /var/log ]; then
        var_pct="$(df -h /var 2>/dev/null | awk 'NR==2{print $5}')"
        echo " /var usage: ${var_pct:-n/a} -- if this climbs fast, check /var/log first."
        echo
    fi

    echo " Admin reminders:"
    echo "   - New here? Read /etc/motd and this dept's onboarding doc."
    echo "   - /etc config files are always plain text -- diff them freely."
    echo "   - /usr should be read-only in production; don't write to it."
    echo "-------------------------------------------------------------"
}

welcome_banner
unset -f welcome_banner
