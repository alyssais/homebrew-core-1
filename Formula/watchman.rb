# watchman: Build a bottle for Linuxbrew
class Watchman < Formula
  desc "Watch files and take action when they change"
  homepage "https://github.com/facebook/watchman"
  url "https://github.com/facebook/watchman/archive/v4.7.0.tar.gz"
  sha256 "77c7174c59d6be5e17382e414db4907a298ca187747c7fcb2ceb44da3962c6bf"
  revision 1
  head "https://github.com/facebook/watchman.git"

  bottle do
    # Bottle hard-codes statedir. See https://github.com/Linuxbrew/homebrew-core/issues/956
    cellar :any if OS.mac?
    sha256 "07e826368e27cc7401366d820cc8109fec8bd815143ec75b30a81cc0b84d766f" => :sierra
    sha256 "bcea4d625e7c30ecc6f728e257f5de81125c7f14680cac684bc7c878655e167c" => :el_capitan
    sha256 "c8374abbad804b919c372d6883302654b44b8d4b190e06b6e4dad172e038bf51" => :yosemite
    sha256 "4f5fa73acad96e9e2650d75ff7e0382bf1a5636be52759289453a08d38c66114" => :x86_64_linux
  end

  depends_on :python if MacOS.version <= :snow_leopard
  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pcre"

  def install
    system "./autogen.sh"
    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--with-pcre",
                          # we'll do the homebrew specific python
                          # installation below
                          "--without-python",
                          "--enable-statedir=#{var}/run/watchman"
    system "make"
    system "make", "install"

    # Homebrew specific python application installation
    ENV.prepend_create_path "PYTHONPATH", libexec/"lib/python2.7/site-packages"
    cd "python" do
      system "python", *Language::Python.setup_install_args(libexec)
    end
    bin.install Dir[libexec/"bin/*"]
    bin.env_script_all_files(libexec/"bin", :PYTHONPATH => ENV["PYTHONPATH"])
  end

  def post_install
    (var/"run/watchman").mkpath
    chmod 042777, var/"run/watchman"
    # Older versions would use socket activation in the launchd.plist, and since
    # the homebrew paths are versioned, this meant that launchd would continue
    # to reference the old version of the binary after upgrading.
    # https://github.com/facebook/watchman/issues/358
    # To help swing folks from an older version to newer versions, force unloading
    # the plist here.  This is needed even if someone wanted to add brew services
    # support; while there are still folks with watchman <4.8 this is still an
    # upgrade concern.
    home = ENV["HOME"]
    system "launchctl", "unload",
           "-F", "#{home}/Library/LaunchAgents/com.github.facebook.watchman.plist" if OS.mac?
  end

  test do
    assert_equal /(\d+\.\d+\.\d+)/.match(version)[0], shell_output("#{bin}/watchman -v").chomp
  end
end
