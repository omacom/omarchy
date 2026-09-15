fn main() {
  #[cfg(feature = "qt-bridge")]
  {
    cxx_build::bridge("src/qt.rs")
      .std("c++17")
      .compile("ward-qt");
    println!("cargo:rerun-if-changed=src/qt.rs");
  }
}
