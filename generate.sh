#!/usr/bin/env bash
set -euo pipefail

version="${1:-${GITIGNORE_IN_VERSION:-}}"
if [ -z "${version}" ]; then
  version="$(curl -fsSL https://api.github.com/repos/gitignore-in/gitignore-in/releases/latest | jq -r .tag_name)"
fi
homepage='https://github.com/gitignore-in/gitignore-in'

gethash() {
  curl -fsSL "${homepage}/releases/download/${version}/$1" 2>/dev/null \
  | shasum -a 256 \
  | awk '{print $1}'
}

arm64_file="gitignore-in-aarch64-apple-darwin-${version}.tar.gz"
amd64_file="gitignore-in-x86_64-apple-darwin-${version}.tar.gz"
sha256_arm64=$(gethash "$arm64_file")
sha256_amd64=$(gethash "$amd64_file")

cd "${0%/*}"
cat <<EOF > gitignore-in.rb
require "formula"

class GitignoreIn < Formula
  homepage "${homepage}"
  head "${homepage}.git"
  version "${version}"

  if Hardware::CPU.arm? and Hardware::CPU.is_64_bit?
    url "https://github.com/gitignore-in/gitignore-in/releases/download/${version}/${arm64_file}"
    sha256 "${sha256_arm64}"
  elsif Hardware::CPU.intel? and Hardware::CPU.is_64_bit?
    url "https://github.com/gitignore-in/gitignore-in/releases/download/${version}/${amd64_file}"
    sha256 "${sha256_amd64}"
  end

  def install
    bin.install "gitignore.in" => "gitignore.in"
  end
end
EOF
