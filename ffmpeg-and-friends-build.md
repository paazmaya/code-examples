# FFMpeg and friend build commands in 2013-05-07

## general
```sh
mkdir sources
cd sources
```

## libvpx
```sh
git clone http://git.chromium.org/webm/libvpx.git
cd libvpx
./configure --prefix=/usr/local/encoding \
--enable-vp8 \
--enable-vp9
make -j4
sudo make install
make clean
cd ..
```

## x264
```sh
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix=/usr/local/encoding \
--enable-visualize \
--enable-shared \
--extra-cflags="-I/usr/local/encoding/include" \
--extra-ldflags="-L/usr/local/encoding/lib"
make -j4
sudo make install
make distclean
cd ..
```

## ffmpeg
```sh
git clone git://git.videolan.org/ffmpeg.git
cd ffmpeg
./configure --prefix=/usr/local/encoding \
--enable-frei0r \
--enable-gpl \
--enable-libdc1394 \
--enable-libfaac \
--enable-libfreetype \
--enable-libgsm \
--enable-libmp3lame \
--enable-libopencore-amrnb \
--enable-libopencore-amrwb \
--enable-libopenjpeg \
--enable-librtmp \
--enable-libschroedinger \
--enable-libspeex \
--enable-libtheora \
--enable-libvo-aacenc \
--enable-libvo-amrwbenc \
--enable-libvorbis \
--enable-libvpx \
--enable-libx264 \
--enable-libxvid \
--enable-nonfree \
--enable-openal \
--enable-postproc \
--enable-pthreads \
--enable-shared \
--enable-version3 \
--extra-cflags="-I/usr/local/encoding/include" \
--extra-libs="-L/usr/local/encoding/lib"
make -j4
sudo make install
make distclean
cd ..
```




no
```sh
--enable-libnut \
--enable-libopencv \
--enable-mlib \

--enable-avisynth \
--enable-libcelt \
--enable-libxavs \
--enable-w32threads \
--enable-x11grab \
```

## mplayer
```sh
wget http://mplayerhq.hu/MPlayer/releases/codecs/all-20110131.tar.bz2
tar jxf all-20110131.tar.bz2
sudo mv all-20110131 /usr/local/encoding/lib/codecs
git clone git://git.mplayerhq.hu/mplayer
cd mplayer
./configure --prefix=/usr/local/encoding \
--enable-dynamic-plugins \
--extra-cflags="-I/usr/local/encoding/include" \
--extra-libs="-L/usr/local/encoding/lib"
make -j4
sudo make install
make distclean
cd ..
```

## gpac
```sh
svn co https://gpac.svn.sourceforge.net/svnroot/gpac/trunk/gpac gpac
cd gpac
./configure --prefix=/usr/local/encoding \
--extra-cflags="-I/usr/local/encoding/include" \
--extra-libs="-L/usr/local/encoding/lib" \
--enable-amr \
--enable-static-bin \
--use-png=local \
--static-mp4box
make -j4
sudo make install
make distclean
"/usr/local/encoding/lib" >> /etc/ld.so.conf
cd ..
```


## encoding format
Audio:
	HE-AAC (ISO) - http://en.wikipedia.org/wiki/HE-AAC

Video:
	MPEG-4/AVC (ISO) - http://en.wikipedia.org/wiki/H.264/MPEG-4_AVC
	http://www.adobe.com/devnet/flashmediaserver/articles/h264_primer/h264_primer.pdf
	http://www.adobe.com/devnet/flashmediaserver/articles/h264_encoding_02.html
	Baseline profile

Container:
	MP4
