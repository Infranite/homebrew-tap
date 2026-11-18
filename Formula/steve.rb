class Steve < Formula
  desc "Local workspace for autonomous agents"
  homepage "https://github.com/Infranite/steve"
  version "0.3.3"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://api.github.com/repos/Infranite/steve/releases/assets/761828081",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.3.3/steve-0.3.3-aarch64-apple-darwin-installer.tar.gz"
    sha256 "a3c85deca8c9f0e81e5877fbd50ab766667bc605586c1c12a73a02cc72c5b92e"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://api.github.com/repos/Infranite/steve/releases/assets/761828073",
        headers: ["Accept: application/octet-stream"]
    mirror "https://github.com/Infranite/steve/releases/download/v0.3.3/steve-0.3.3-x86_64-unknown-linux-gnu-installer.tar.gz"
    sha256 "7c834dc88d31e11d21467c987d3caaa20e79f80e390dabb79be9e25fa7d93f5a"
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
