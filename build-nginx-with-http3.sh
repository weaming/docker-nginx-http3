#!/bin/bash
# https://gist.github.com/weaming/e1ca9bc8203ed5f4e2f107813b68efbe

set -e

export PATH=$PATH:$HOME/.cargo/bin

curl --version
git --version
cmake --version
perl --version
go version
cargo --version

mkdir http3; cd http3;
curl -O https://nginx.org/download/nginx-1.16.1.tar.gz
tar xvzf nginx-1.16.1.tar.gz
git clone https://github.com/cloudflare/quiche --recursive

# google proxy
export pcre_name='pcre-8.43'
export zlib_name='zlib-1.2.11'
wget https://ftp.pcre.org/pub/pcre/$pcre_name.tar.gz && tar -zxf $pcre_name.tar.gz
wget http://zlib.net/$zlib_name.tar.gz && tar -zxf $zlib_name.tar.gz
git clone https://github.com/cuber/ngx_http_google_filter_module
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module
# more_set_headers
git clone https://github.com/openresty/headers-more-nginx-module.git

cd nginx-1.16.1 || exit
patch -p01 < ../quiche/extras/nginx/nginx-1.16.patch

./configure                                 \
   	--with-http_ssl_module              	\
   	--with-http_v2_module               	\
   	--with-http_v3_module               	\
   	--with-openssl=../quiche/deps/boringssl \
   	--with-quiche=../quiche                 \
    --prefix=/usr/local/nginx \
    --sbin-path=/usr/local/nginx/nginx \
    --conf-path=/usr/local/nginx/nginx.conf \
    --pid-path=/usr/local/nginx/nginx.pid \
    --user=nginx \
    --group=nginx \
    --with-cc-opt="-D FD_SETSIZE=2048" \
    --with-stream \
    --with-stream_ssl_module \
    --with-http_realip_module \
    --with-http_sub_module \
    --with-http_addition_module \
    --with-threads \
    --with-http_stub_status_module \
    --with-pcre=../$pcre_name \
    --with-zlib=../$zlib_name \
    --add-module=../ngx_http_google_filter_module \
    --add-module=../ngx_http_substitutions_filter_module \
    --add-module=../headers-more-nginx-module

make
make install  && cd ../.. && rm -rf http3/