#编译.
NGX_MODULE_PATH=
./configure --add-module=$NGX_MODULE_PATH/ngx_http_notetask_module
make
make install

#nginx重启.
cd /usr/local/nginx/sbin
./nginx -s stop ; sleep 1 ; > ../log/error.log ; ./nginx
