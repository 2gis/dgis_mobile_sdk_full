#!/bin/bash
#
# Fetches PlatformCDart.xcframework for a DGIS Flutter plugin.
#
# CocoaPods invokes this through the podspec's `prepare_command`, which runs
# with the working directory set to this pod's root (the plugin's `ios/` dir)
# both for `:path` (Flutter `.symlinks/plugins/...`) and for published pods.
#
# Contract:
#   * idempotent - a second `pod install` for the same pin costs a few stat()s
#   * pin keyed - the cache never mixes SDK builds, flavors or re-uploads
#   * atomic - downloads and extractions land in temp siblings, then rename
#   * verified - the artifact sha1 (published in the podspec) is enforced
#
# Inputs (exported by the podspec, which reads them from dgis_artifact.json):
#   DGIS_ARTIFACT_NAME, DGIS_ARTIFACT_URL, DGIS_ARTIFACT_SHA1,
#   DGIS_ARTIFACT_VERSION
#
# Optional inputs for offline / proxy / air-gapped builds:
#   DGIS_FLUTTER_SDK_CACHE   cache root (default: ~/Library/Caches/dgis_mobile_sdk)
#   DGIS_PLATFORM_CDART_DIR  directory that already contains PlatformCDart.xcframework;
#                            skips the download entirely
#   DGIS_ARTIFACT_ZIP        path to a pre-downloaded zip; still sha1 verified
#
# Exit codes: 0 ok, 1 failure (message on stderr, prefixed "error: ").

set -euo pipefail

FRAMEWORK="PlatformCDart.xcframework"

ios_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
plugin="$(basename "$ios_dir")"

die() {
  echo "error: [$plugin] $*" >&2
  exit 1
}

# verify <file> <description>: returns non-zero unless the file matches the
# sha1 published in the podspec. Leaves the message to the caller, so it can
# clean up temporary files first.
verify() {
  local file="$1" what="$2" actual
  actual="$(shasum -a 1 "$file" | cut -d' ' -f1)"
  if [ "$actual" != "$DGIS_ARTIFACT_SHA1" ]; then
    echo "error: [$plugin] checksum mismatch for $what
       expected sha1 $DGIS_ARTIFACT_SHA1
       actual   sha1 $actual" >&2
    return 1
  fi
}

: "${DGIS_ARTIFACT_NAME:?DGIS_ARTIFACT_NAME must be set by the podspec}"
: "${DGIS_ARTIFACT_URL:?DGIS_ARTIFACT_URL must be set by the podspec}"
: "${DGIS_ARTIFACT_SHA1:?DGIS_ARTIFACT_SHA1 must be set by the podspec}"
: "${DGIS_ARTIFACT_VERSION:?DGIS_ARTIFACT_VERSION must be set by the podspec}"

link_dir="$ios_dir/Frameworks"
link="$link_dir/$FRAMEWORK"

# 1. Resolve where the pinned PlatformCDart.xcframework lives.
if [ -n "${DGIS_PLATFORM_CDART_DIR:-}" ]; then
  source_dir="$DGIS_PLATFORM_CDART_DIR/$FRAMEWORK"
else
  cache_root="${DGIS_FLUTTER_SDK_CACHE:-$HOME/Library/Caches/dgis_mobile_sdk}"
  # Keyed by artifact name, version and sha1: the full and map flavors ship
  # different binaries under the same SDK version, and artifactory may serve a
  # re-uploaded zip under an unchanged version URL.
  artifact_dir="$cache_root/$DGIS_ARTIFACT_NAME/$DGIS_ARTIFACT_VERSION-$DGIS_ARTIFACT_SHA1"
  zip="$artifact_dir/$DGIS_ARTIFACT_NAME-$DGIS_ARTIFACT_VERSION.zip"
  source_dir="$artifact_dir/$FRAMEWORK"
fi

# 2. Already integrated: the link points at exactly this pin, nothing to do.
#    A link to another version (pin bump) or another override is replaced below.
if [ -L "$link" ] && [ "$(readlink "$link")" = "$source_dir" ] && [ -f "$link/Info.plist" ]; then
  exit 0
fi

# 3. Make sure the source directory holds a verified PlatformCDart.xcframework.
if [ -n "${DGIS_PLATFORM_CDART_DIR:-}" ]; then
  [ -f "$source_dir/Info.plist" ] ||
    die "DGIS_PLATFORM_CDART_DIR=$DGIS_PLATFORM_CDART_DIR does not contain $FRAMEWORK"
else
  if [ ! -f "$source_dir/Info.plist" ]; then
    mkdir -p "$artifact_dir" ||
      die "cannot create cache directory $artifact_dir"

    # A caller-supplied zip is read-only input: never write to it, never fall
    # back to the network when it fails verification.
    if [ -n "${DGIS_ARTIFACT_ZIP:-}" ]; then
      zip="$DGIS_ARTIFACT_ZIP"
      [ -f "$zip" ] || die "DGIS_ARTIFACT_ZIP=$zip does not exist"
      verify "$zip" "DGIS_ARTIFACT_ZIP" || exit 1
    else
      if [ -f "$zip" ]; then
        # A cached zip that no longer verifies (truncated copy, disk error) is
        # discarded and re-downloaded.
        file_sha1="$(shasum -a 1 "$zip" | cut -d' ' -f1)"
        [ "$file_sha1" = "$DGIS_ARTIFACT_SHA1" ] || rm -f "$zip"
      fi
      if [ ! -f "$zip" ]; then
        command -v curl >/dev/null 2>&1 ||
          die "curl is required to download $DGIS_ARTIFACT_URL"
        echo "[$plugin] downloading $FRAMEWORK $DGIS_ARTIFACT_VERSION" >&2
        tmp_zip="$(mktemp "$artifact_dir/.download.XXXXXX")"
        if ! curl --fail --silent --show-error --location \
                  --retry 3 --retry-delay 2 --connect-timeout 30 \
                  --output "$tmp_zip" "$DGIS_ARTIFACT_URL"; then
          rm -f "$tmp_zip"
          die "download failed: $DGIS_ARTIFACT_URL
       If this machine has no direct access to artifactory.2gis.dev, configure a
       proxy (curl honours http_proxy/https_proxy/all_proxy) or pre-seed the
       artifact:
         DGIS_ARTIFACT_ZIP=/path/to/$DGIS_ARTIFACT_NAME-$DGIS_ARTIFACT_VERSION.zip
         DGIS_PLATFORM_CDART_DIR=/path/to/unpacked"
        fi
        if ! verify "$tmp_zip" "downloaded $DGIS_ARTIFACT_URL"; then
          rm -f "$tmp_zip"
          exit 1
        fi
        mv -f "$tmp_zip" "$zip"
      fi
    fi

    staging="$(mktemp -d "$artifact_dir/.unzip.XXXXXX")"
    trap 'rm -rf "$staging"' EXIT
    unzip -q -o "$zip" -d "$staging" >/dev/null ||
      die "cannot unzip $zip"
    [ -f "$staging/$FRAMEWORK/Info.plist" ] ||
      die "$zip does not contain $FRAMEWORK"
    rm -rf "$source_dir"
    mv "$staging/$FRAMEWORK" "$source_dir"
    rm -rf "$staging"
    trap - EXIT
  fi
fi

# 4. Expose it inside the pod directory. CocoaPods' PathList only matches paths
#    relative to the pod root, so an out-of-tree absolute path cannot be
#    declared directly; a symlink keeps one copy of the ~190 MB framework on
#    disk and keeps the pod dir free of build artifacts.
#
#    This directory is deliberately outside the Swift package directory
#    (`ios/<plugin>/`), so in Swift Package Manager mode nothing here is ever
#    picked up by the package -- SwiftPM gets its copy from the binaryTarget.
#
#    A real bundle at the link path is a stale copy from an older layout, and
#    `ln -sfn` would nest a link inside it rather than replace it.
mkdir -p "$link_dir" 2>/dev/null || true
if [ -e "$link" ] && [ ! -L "$link" ]; then
  rm -rf "$link" 2>/dev/null || true
fi
ln -sfn "$source_dir" "$link" 2>/dev/null || true
if [ ! -f "$link/Info.plist" ]; then
  die "cannot write to $link_dir
       The plugin checkout appears to be read-only, and CocoaPods only resolves
       vendored frameworks that live inside the pod directory.
       Remedies:
         * make the plugin's ios/ directory writable and re-run pod install, or
         * point the build at a writable plugin checkout (path dependency)."
fi
