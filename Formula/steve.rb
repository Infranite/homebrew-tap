class Steve < Formula
  desc "Local workspace for autonomous agents"
  homepage "https://github.com/Infranite/steve"
  version "0.2.82"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://api.github.com/repos/Infranite/steve/releases/assets/726513238",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.2.82/steve-0.2.82-aarch64-apple-darwin-installer.tar.gz"
    sha256 "f8df999dd3bd5d555d20e480f979e9ef7e2af1f9a03710a045e4dc8fd65e9906"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://api.github.com/repos/Infranite/steve/releases/assets/726513239",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.2.82/steve-0.2.82-x86_64-unknown-linux-gnu-installer.tar.gz"
    sha256 "c22feb7c5adb2f5284a77a8881634bcb9688c8c0827f37f9b8c598b102184404"
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
