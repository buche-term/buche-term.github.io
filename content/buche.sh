#!/bin/sh
# Install (or upgrade) buche from its GitHub releases:
#
#   curl -fsSL https://buche.sh/buche.sh | sh
#
# macOS (Apple Silicon): Buche.app in /Applications (~/Applications if that
# is not writable). Downloaded with curl, the app is not quarantined:
# Gatekeeper lets it open without a warning.
# Linux (x86-64): the app in ~/.local/share/buche/app, a menu entry.
# Both: a `buche` command in ~/.local/bin.
#
# Environment:
#   BUCHE_VERSION      the release to install (a tag, e.g. v0.1.0; default: the latest)
#   BUCHE_APP_DIR      where the app goes (macOS: the folder for Buche.app;
#                      Linux: the app's own directory)
#   BUCHE_BIN_DIR      where the `buche` command goes (default: ~/.local/bin)
#
# The whole script is a function, called on its last line: a download cut
# short runs nothing.

set -eu

REPO="buche-term/buche"

say() { printf 'buche: %s\n' "$*"; }
die() { printf 'buche: error: %s\n' "$*" >&2; exit 1; }
need() { command -v "$1" >/dev/null 2>&1 || die "needs $1"; }

sha256() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | cut -d' ' -f1
    else
        shasum -a 256 "$1" | cut -d' ' -f1
    fi
}

# The tag of the latest release (from the redirect: no API, no rate limit).
latest_tag() {
    url=$(curl -fsSLI -o /dev/null -w '%{url_effective}' "https://github.com/$REPO/releases/latest") ||
        die "could not reach github.com"
    case "$url" in
        */tag/*) printf '%s\n' "${url##*/tag/}" ;;
        *) die "no release found for $REPO" ;;
    esac
}

# Download a release asset into $tmp, and check it against sha256.sum.
fetch() {
    say "downloading $1"
    curl -fL --progress-bar -o "$tmp/$1" "https://github.com/$REPO/releases/download/$tag/$1" ||
        die "could not download $1 (is there a build for this platform in $tag?)"
    expected=$(grep "  $1\$" "$tmp/sha256.sum" | cut -d' ' -f1 || true)
    [ -n "$expected" ] || die "$1 is not in sha256.sum"
    [ "$(sha256 "$tmp/$1")" = "$expected" ] || die "$1: checksum mismatch"
}

# The `buche` command: the app's executable, with the command line's arguments.
install_command() {
    bin_dir="${BUCHE_BIN_DIR:-$HOME/.local/bin}"
    mkdir -p "$bin_dir"
    cat >"$bin_dir/buche" <<EOF
#!/bin/sh
exec "$1" "\$@"
EOF
    chmod +x "$bin_dir/buche"
    case ":$PATH:" in
        *":$bin_dir:"*) say "installed the buche command in $bin_dir" ;;
        *) say "installed the buche command in $bin_dir (not on your PATH: add it to use \`buche\` from a terminal)" ;;
    esac
}

install_mac() {
    asset="Buche-$version-arm64-mac.zip"
    fetch "$asset"
    app_dir="${BUCHE_APP_DIR:-}"
    if [ -z "$app_dir" ]; then
        if [ -w /Applications ]; then app_dir=/Applications; else app_dir="$HOME/Applications"; fi
    fi
    mkdir -p "$app_dir"
    if pgrep -xq Buche 2>/dev/null; then
        say "note: Buche is running; the new version is used from its next launch"
    fi
    # ditto keeps the bundle as it was signed (symlinks, attributes).
    ditto -x -k "$tmp/$asset" "$tmp/unpacked"
    rm -rf "$app_dir/Buche.app"
    mv "$tmp/unpacked/Buche.app" "$app_dir/Buche.app"
    say "installed Buche $version in $app_dir/Buche.app"
    install_command "$app_dir/Buche.app/Contents/MacOS/Buche"
}

install_linux() {
    asset="buche-$version.tar.gz"
    fetch "$asset"
    app_dir="${BUCHE_APP_DIR:-$HOME/.local/share/buche/app}"
    mkdir -p "$tmp/unpacked"
    tar -xzf "$tmp/$asset" -C "$tmp/unpacked"
    rm -rf "$app_dir"
    mkdir -p "$(dirname "$app_dir")"
    mv "$tmp/unpacked/buche-$version" "$app_dir"
    say "installed buche $version in $app_dir"
    install_command "$app_dir/buche"

    # A menu entry, with the icon from the release's sources.
    data="${XDG_DATA_HOME:-$HOME/.local/share}"
    icon="$data/icons/hicolor/512x512/apps/buche.png"
    mkdir -p "$(dirname "$icon")" "$data/applications"
    curl -fsSL -o "$icon" "https://raw.githubusercontent.com/$REPO/$tag/assets/buche.png" || true
    cat >"$data/applications/buche.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Buche
Comment=A terminal for interactive HTML views
Exec="$app_dir/buche" %U
Icon=buche
Terminal=false
Categories=Development;
StartupWMClass=Buche
EOF
    command -v update-desktop-database >/dev/null 2>&1 &&
        update-desktop-database "$data/applications" >/dev/null 2>&1 || true

    # Electron's sandbox: where unprivileged user namespaces are restricted
    # (Ubuntu 24.04 and later), it needs its setuid helper.
    restrict=/proc/sys/kernel/apparmor_restrict_unprivileged_userns
    if [ -r "$restrict" ] && [ "$(cat "$restrict")" = 1 ]; then
        say "note: this system restricts user namespaces; if buche does not start, run:"
        say "  sudo chown root:root '$app_dir/chrome-sandbox' && sudo chmod 4755 '$app_dir/chrome-sandbox'"
    fi
}

main() {
    need curl
    case "$(uname -s)/$(uname -m)" in
        Darwin/arm64) platform=mac ;;
        Linux/x86_64 | Linux/amd64) platform=linux; need tar ;;
        *) die "no build for $(uname -s) $(uname -m) (macOS arm64 and Linux x86-64 only, for now)" ;;
    esac

    tag="${BUCHE_VERSION:-$(latest_tag)}"
    version="${tag#v}"
    say "installing $tag"

    tmp=$(mktemp -d)
    trap 'rm -rf "$tmp"' EXIT INT TERM
    curl -fsSL -o "$tmp/sha256.sum" "https://github.com/$REPO/releases/download/$tag/sha256.sum" ||
        die "no release $tag (or it has no sha256.sum)"

    "install_$platform"
}

main "$@"
