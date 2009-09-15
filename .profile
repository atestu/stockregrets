for a in local $(ls /opt/ | grep -v local | grep -v gentoo); do
	FULLPATH=/opt/$a
	if [ -x $FULLPATH ]; then
		if [ -x $FULLPATH/bin ]; then
			export PATH="$FULLPATH/bin:$PATH"
		fi
		if [ -x $FULLPATH/sbin ]; then
			export PATH="$FULLPATH/sbin:$PATH"
		fi
		if [ -x $FULLPATH/share/aclocal ]; then
			export ACLOCAL_FLAGS="-I $FULLPATH/share/aclocal $ACLOCAL_FLAGS"
		fi
		if [ -x $FULLPATH/man ]; then
			export MANPATH="$FULLPATH/man:$MANPATH"
		fi
		if [ -x $FULLPATH/share/man ]; then
			export MANPATH="$FULLPATH/share/man:$MANPATH"
		fi
		if [ -x $FULLPATH/lib/pkgconfig ]; then
			export PKG_CONFIG_PATH="$FULLPATH/lib/pkgconfig/:$PKG_CONFIG_PATH"
		fi
	fi
done

