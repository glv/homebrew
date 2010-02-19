require 'formula'

class Icon <Formula
  url 'http://www.cs.arizona.edu/icon/ftp/packages/unix/icon.v943src.tgz'
  homepage 'http://www.cs.arizona.edu/icon/'
  md5 '4740b1fc5caf2fe7409367923dffe607'
  version '9.4.3'

  def install
    system "make", "X-Configure", "name=macintosh"
    system "make"
    system "make", "Install", "dest=#{prefix}"
  end
  
  def caveats
    return <<EOD
To keep #{HOMEBREW_PREFIX}/lib reasonably clean, the Icon Program Library (ipl)
has been installed in #{HOMEBREW_PREFIX}/lib/icon rather than directly in 
#{HOMEBREW_PREFIX}/lib as in a typical Icon installation.  The tools know
about this, but if you run into problems you may want to set the IPATH
environment variable to include #{HOMEBREW_PREFIX}/lib/icon.
EOD
  end
  
  # These patches serve two purposes:
  # 
  # 1. To redirect the nearly 800 ipl files into HOMEBREW_PREFIX/lib/icon
  #    rather than just dropping them into HOMEBREW_PREFIX/lib
  # 2. To force make to build certain dependencies sequentially.  For 
  #    reasons I don't understand, Snow Leopard's make was building
  #    certain targets in parallel, resulting in build failures due to
  #    race conditions.
  def patches; DATA; end
end

__END__
diff --git a/Makefile b/Makefile
index 0fc9ce7..6dc6f73 100644
--- a/Makefile
+++ b/Makefile
@@ -59,7 +59,8 @@ Status:
 
 # The interpreter: icont and iconx.
 
-Icont bin/icont: Common
+bin/icont: Icont
+Icont: Common
 		cd src/icont;		$(MAKE)
 		cd src/runtime;		$(MAKE) 
 
@@ -84,7 +85,7 @@ Common:		src/h/define.h
 Ilib:		bin/icont
 		cd ipl;			$(MAKE) Ilib
 
-Ibin:		bin/icont
+Ibin:		bin/icont Ilib
 		cd ipl;			$(MAKE) Ibin
 
 
@@ -97,14 +98,14 @@ Ibin:		bin/icont
 
 D=$(dest)
 Install:
-		mkdir $D
-		mkdir $D/bin $D/lib $D/doc $D/man $D/man/man1
+		mkdir -p $D
+		mkdir -p $D/bin $D/lib $D/lib/icon $D/doc $D/man $D/man/man1
 		cp README $D
 		cp bin/[cflpvwx]* $D/bin
 		cp bin/icon[tx]* $D/bin
 		rm -f $D/bin/libI*
 		(cd $D/bin; ln -s icont icon)
-		cp lib/*.* $D/lib
+		cp lib/*.* $D/lib/icon
 		cp doc/*.* $D/doc
 		cp man/man1/*.* $D/man/man1
 
diff --git a/ipl/Makefile b/ipl/Makefile
index a438946..b4d6bea 100644
--- a/ipl/Makefile
+++ b/ipl/Makefile
@@ -1,7 +1,7 @@
 #  Makefile for the Icon Program Library
 
 
-All:	Ilib Ibin
+All:	Ibin
 
 
 #  Make a library distribution (portable ucode and include files).
@@ -27,7 +27,7 @@ Cfunctions:
 #  for ../bin, given that ../lib is ready
 
 Ibin:	gpacks/vib/vib
-gpacks/vib/vib:  ../bin/icont
+gpacks/vib/vib:  ../bin/icont Ilib
 	MAKE=$(MAKE) ./BuildBin
 
 
diff --git a/src/icont/tunix.c b/src/icont/tunix.c
index 9478403..e51fe71 100644
--- a/src/icont/tunix.c
+++ b/src/icont/tunix.c
@@ -301,6 +301,8 @@ static char *libpath(char *prog, char *envname) {
    else
       strcpy(buf, ".");
    strcat(buf, ":");
+   strcat(buf, relfile(prog, "/../../lib/icon"));
+   strcat(buf, ":");
    strcat(buf, relfile(prog, "/../../lib"));
    return salloc(buf);
    }
