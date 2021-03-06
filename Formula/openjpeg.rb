class Openjpeg < Formula
  desc "Library for JPEG-2000 image manipulation"
  homepage "http://www.openjpeg.org/"
  url "https://github.com/uclouvain/openjpeg/archive/v2.2.0.tar.gz"
  sha256 "6fddbce5a618e910e03ad00d66e7fcd09cc6ee307ce69932666d54c73b7c6e7b"
  head "https://github.com/uclouvain/openjpeg.git"

  bottle do
    cellar :any
    sha256 "437b7f58d8f2e8944adea7481a233bdf7f5c06609bfcf209169e677c93ab621c" => :sierra
    sha256 "ceebb6f74ce06b2a9ea716cd6f72bdbe4590b23819e4d0a980a320ff150760bd" => :el_capitan
    sha256 "bd0c66eb1f759d447a35203a0861698283ee148c97b96ed13922d83adaab4ab7" => :yosemite
    sha256 "8019678399b84b81e65463e3231ef78167895956b991be5874c8d4e8350121a8" => :x86_64_linux
  end

  option "without-doxygen", "Do not build HTML documentation."
  option "with-static", "Build a static library."

  depends_on "cmake" => :build
  depends_on "doxygen" => [:build, :recommended]
  depends_on "little-cms2"
  depends_on "libtiff"
  depends_on "libpng"

  def install
    args = std_cmake_args
    args << "-DBUILD_SHARED_LIBS=OFF" if build.with? "static"
    args << "-DBUILD_DOC=ON" if build.with? "doxygen"
    system "cmake", ".", *args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <openjpeg.h>

      int main () {
        opj_image_cmptparm_t cmptparm;
        const OPJ_COLOR_SPACE color_space = OPJ_CLRSPC_GRAY;

        opj_image_t *image;
        image = opj_image_create(1, &cmptparm, color_space);

        opj_image_destroy(image);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}/openjpeg-2.2",
           testpath/"test.c", "-L#{lib}", "-lopenjp2", "-o", "test"
    system "./test"
  end
end
