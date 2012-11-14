require 'formula'

class Chicken < Formula
  url 'http://code.call-cc.org/releases/4.8.0/chicken-4.8.0.tar.gz'
  sha1 '5068929f02d8a4fcb8fde13e4ddefb0bcb7142a6'
  homepage 'http://www.call-cc.org/'
  head 'git://code.call-cc.org/chicken-core'

  def install
    ENV.deparallelize
    args = ["PREFIX=#{prefix}", "PLATFORM=macosx", "C_COMPILER=#{ENV.cc}"] # Chicken uses a non-standard var. for this
    args << "ARCH=x86-64" if MacOS.prefer_64_bit?
    system "make", *args
    system "make", "install", *args
  end
end
