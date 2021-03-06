class Flann < Formula
  desc "Fast Library for Approximate Nearest Neighbors"
  homepage "https://www.cs.ubc.ca/~mariusm/index.php/FLANN/FLANN"
  url "https://github.com/mariusmuja/flann/archive/1.9.1.tar.gz"
  sha256 "b23b5f4e71139faa3bcb39e6bbcc76967fbaf308c4ee9d4f5bfbeceaa76cc5d3"
  revision 3

  bottle do
    cellar :any_skip_relocation
    sha256 "8d8aab39b18401195d3bb31129f8500bd108d3560123e251b61677b86283f9a8" => :x86_64_linux
  end

  depends_on "cmake" => :build
  depends_on "hdf5"
  depends_on "python" => :optional
  depends_on "numpy" if build.with? "python"

  resource("dataset.dat") do
    url "https://www.cs.ubc.ca/~mariusm/uploads/FLANN/datasets/dataset.dat"
    sha256 "dcbf0268a7ff9acd7c3972623e9da722a8788f5e474ae478b888c255ff73d981"
  end

  resource("testset.dat") do
    url "https://www.cs.ubc.ca/~mariusm/uploads/FLANN/datasets/testset.dat"
    sha256 "d9ff91195bf2ad8ced78842fa138b3cd4e226d714edbb4cb776369af04dda81b"
  end

  resource("dataset.hdf5") do
    url "https://www.cs.ubc.ca/~mariusm/uploads/FLANN/datasets/dataset.hdf5"
    sha256 "64ae599f3182a44806f611fdb3c77f837705fcaef96321fb613190a6eabb4860"
  end

  def install
    if build.with? "python"
      pyarg = "-DBUILD_PYTHON_BINDINGS:BOOL=ON"
    else
      pyarg = "-DBUILD_PYTHON_BINDINGS:BOOL=OFF"
    end

    system "cmake", ".", *std_cmake_args, pyarg
    system "make", "install"
  end

  test do
    resource("dataset.dat").stage testpath
    resource("testset.dat").stage testpath
    resource("dataset.hdf5").stage testpath
    system "#{bin}/flann_example_c"
    system "#{bin}/flann_example_cpp"
  end
end
