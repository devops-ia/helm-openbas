#!/bin/bash

DEFAULT_BASE_URL="https://github.com/bitnami/charts/releases/tag"

awk -v default_base_url="$DEFAULT_BASE_URL" '
/^[a-zA-Z]/ {
    if (name && show && current_version && new_version && current_version != new_version) {
        print name "\n" dashes "\n\n* **Current**: `" current_version "`\n* **Upgrade**: `" new_version "`"
        if (name != "caldera") {
            print "* **Changelog**: " default_base_url "/" name "/" new_version "\n"
        }
    }
    name = $0;
    getline; dashes = $0;
    show = 1;  # Reset show flag
    current_version = "";  # Reset current_version
    new_version = "";  # Reset new_version
}
/change detected:/ {
    getline;
    if (match($0, /updated from "([^"]+)" to "([^"]+)"/, versions)) {
        current_version = versions[1];
        new_version = versions[2];
    }
}
/no change detected:/ {
    show = 0;  # Do not show this section
}
END {
    if (name && show && current_version && new_version && current_version != new_version) {
        print name "\n" dashes "\n\n* **Current**: `" current_version "`\n* **Upgrade**: `" new_version "`"
        if (name != "caldera") {
            print "* **Changelog**: " default_base_url "/" name "/" new_version "\n"
        }
    }
}' "$1"
