class Librevenge < Formula
  desc "Base library for writing document import filters"
  homepage "https://sourceforge.net/p/libwpd/wiki/librevenge/"
  url "https://dev-www.libreoffice.org/src/librevenge-0.0.4.tar.bz2"
  mirror "https://downloads.sourceforge.net/project/libwpd/librevenge/librevenge-0.0.4/librevenge-0.0.4.tar.bz2"
  sha256 "c51601cd08320b75702812c64aae0653409164da7825fd0f451ac2c5dbe77cbf"

  bottle do
    cellar :any
    sha256 "2f8a2a371c35b578d181d1ce8d45084a2f699bbed95cabd10f5cd75977249542" => :sierra
    sha256 "827a37488cc92f16ba8f4d7343e7944c7faed4b8cf9d930f49d93e4104784c94" => :el_capitan
    sha256 "a95c4fc2b7832e226d21a209811a2f149b8fde4962d07d354e3a6cb80b7f0a01" => :yosemite
    sha256 "45c4df842b9cf38554efeb4d04f2c2abf2ed8341e0fb4bc0d80830e02e1fbfeb" => :mavericks
    sha256 "fdcd310449d3db5bf6b6f0c0acfe2669a2f1a285ddd35ff37821574a932769f3" => :x86_64_linux
  end

  depends_on "pkg-config" => :build
  depends_on "boost"

  def install
    system "./configure", "--without-docs",
                          "--disable-dependency-tracking",
                          "--enable-static=no",
                          "--disable-werror",
                          "--disable-tests",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS.undent
      #include <librevenge/librevenge.h>
      int main() {
        librevenge::RVNGString str;
        return 0;
      }
    EOS
    system ENV.cc, "test.cpp", "-lrevenge-0.0",
                   "-I#{include}/librevenge-0.0", "-L#{lib}"
  end
end
