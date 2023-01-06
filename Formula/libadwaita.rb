class Libadwaita < Formula
  desc "Building blocks for modern adaptive GNOME applications"
  homepage "https://gnome.pages.gitlab.gnome.org/libadwaita/"
  url "https://download.gnome.org/sources/libadwaita/1.2/libadwaita-1.2.1.tar.xz"
  sha256 "326f142a4f0f3de5a63f0d5e7a9de66ea85348a4726cbfd13930dcf666d22779"
  license "LGPL-2.1-or-later"

  # libadwaita doesn't use GNOME's "even-numbered minor is stable" version
  # scheme. This regex is the same as the one generated by the `Gnome` strategy
  # but it's necessary to avoid the related version scheme logic.
  livecheck do
    url :stable
    regex(/libadwaita-(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_ventura:  "84bd7cb9a13af48ae0ff68568e26e85b2bbe69fbd4c5964c246711b8226c1bea"
    sha256 arm64_monterey: "0792a3db924c5a33c1b6849ccc2f3cac1b168e4267025084001af8a532bc40bf"
    sha256 arm64_big_sur:  "25c1f762056fc685c92eaf58e51237973d5afa96047997aac1ec867fc1fac33e"
    sha256 ventura:        "dd18b3b331d34f114f783f818ab534b3fcd129e2803cc347cfa8365e3260eea1"
    sha256 monterey:       "c0e552e7f8bb80a296e8064daf7951fcd427ee4eb2dd3a69d9f97ddd322e665b"
    sha256 big_sur:        "558aabf74bf246f77c325ddc0d50012f4b5006873612929d56724805cc434c7a"
    sha256 catalina:       "61c581548b0093b670535f7cd41c52a3addadafb810683897235d7eebd4ce8c3"
    sha256 x86_64_linux:   "ab32954b42d20ceeaa2444477146842a4b67731a30030c2b18e42e7b83530680"
  end

  depends_on "gobject-introspection" => :build
  depends_on "meson" => :build
  depends_on "ninja" => :build
  depends_on "pkg-config" => [:build, :test]
  depends_on "sassc" => :build
  depends_on "vala" => :build
  depends_on "gtk4"

  def install
    system "meson", "setup", "build", *std_meson_args, "-Dtests=false"
    system "meson", "compile", "-C", "build"
    system "meson", "install", "-C", "build"
  end

  test do
    # Remove when `jpeg-turbo` is no longer keg-only.
    ENV.prepend_path "PKG_CONFIG_PATH", Formula["jpeg-turbo"].opt_lib/"pkgconfig"

    (testpath/"test.c").write <<~EOS
      #include <adwaita.h>

      int main(int argc, char *argv[]) {
        g_autoptr (AdwApplication) app = NULL;
        app = adw_application_new ("org.example.Hello", G_APPLICATION_FLAGS_NONE);
        return g_application_run (G_APPLICATION (app), argc, argv);
      }
    EOS
    flags = shell_output("#{Formula["pkg-config"].opt_bin}/pkg-config --cflags --libs libadwaita-1").strip.split
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test", "--help"

    # include a version check for the pkg-config files
    assert_match version.to_s, (lib/"pkgconfig/libadwaita-1.pc").read
  end
end
