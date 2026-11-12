class Steve < Formula
  desc "Local workspace for autonomous agents"
  homepage "https://github.com/Infranite/steve"
  version "0.2.108"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://api.github.com/repos/Infranite/steve/releases/assets/740568440",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.2.108/steve-0.2.108-aarch64-apple-darwin-installer.tar.gz"
    sha256 "06e2440b98c16b24d261dfdcc6a6b36352edee6d6c7a4da96ffcba73d090233a"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://api.github.com/repos/Infranite/steve/releases/assets/740568442",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.2.108/steve-0.2.108-x86_64-unknown-linux-gnu-installer.tar.gz"
    sha256 "617d790e8d4741d3ab1d1a7e882b24934e3c761fb30cbf92fafc1a17fbf9f868"
  end

  def install
    if OS.linux?
      glibc = Utils.safe_popen_read("getconf", "GNU_LIBC_VERSION").split.last
      odie "Steve requires glibc 2.35 or newer" if glibc.nil? || Version.new(glibc) < Version.new("2.35")
    end
    libexec.install "bin", "ops", "web", "release.json", "LICENSE"
    bin.install_symlink libexec/"bin/steve"
  end

  def caveats
    <<~EOS
      Set up a Hub with `steve setup`, then start it with `steve hub start`.
      For a remote Node, use `steve setup node --hub https://your-hub.example`.
      `steve hub doctor` and `steve node doctor` work without a reachable Hub.
      Homebrew installs the launcher and a verified bundle. Steve manages its
      running release, data and service independently of Homebrew cleanup.
    EOS
  end

  test do
    assert_equal "steve CLI/package #{version}", shell_output("#{bin}/steve --version").strip
    assert_match "setup", shell_output("#{bin}/steve --help")
    refute_path_exists testpath/".steve"
    refute_path_exists testpath/".steve-node"
  end
end
