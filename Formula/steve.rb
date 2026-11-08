class Steve < Formula
  desc "Local workspace for autonomous agents"
  homepage "https://github.com/Infranite/steve"
  version "0.2.77"
  license "MIT"

  on_macos do
    depends_on arch: :arm64
    depends_on macos: :sonoma
    url "https://api.github.com/repos/Infranite/steve/releases/assets/723501542",
        headers: ["Accept: application/octet-stream"]
    sha256 "0a1e6687d6eb8b079635b751c51afb7cd904d546ef0a1f4d468605f67642b36e"
  end

  on_linux do
    depends_on arch: :x86_64
    url "https://api.github.com/repos/Infranite/steve/releases/assets/723501536",
        headers: ["Accept: application/octet-stream"]
    sha256 "9f6f312c959e69cade51de42ded5778438deb2243c6e06ac79e9f9d6c4a8643a"
  end

  depends_on "python@3.13"

  def install
    if OS.linux?
      glibc = Utils.safe_popen_read("getconf", "GNU_LIBC_VERSION").split.last
      odie "Steve requires glibc 2.35 or newer" if glibc.nil? || Version.new(glibc) < Version.new("2.35")
    end
    libexec.install "bin", "ops", "web", "release.json", "LICENSE"
    (bin/"steve").write <<~SH
      #!/bin/sh
      exec "#{Formula["python@3.13"].opt_bin}/python3.13" "#{libexec}/ops/steve.py" "$@"
    SH
    (bin/"steve").chmod 0755
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
