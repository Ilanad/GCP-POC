#!/bin/bash
sudo mv -f /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
sudo mkdir -p /etc/nginx/www
echo "<html><head><style>body {font-family: Helvetica, sans-serif;}</style></head><body><br><br><br><br><br><br><br><br><center><img src='https://mk0getcloudify4yiua1.kinstacdn.com/wp-content/uploads/2017/01/Cloudify_Logo_horizontal.png' width='500' height='162'><br><h1>${message}</h1></body></html>" | sudo tee /etc/nginx/www/index.html
sudo chmod 0755 /etc/nginx/www
sudo chmod 644 /etc/nginx/www/index.html
ctx logger info "app: index webpage created"

sudo touch /etc/nginx/nginx.conf
sudo touch /etc/nginx/conf.d/app.conf
sudo chmod -R 777 /etc/nginx/nginx.conf /etc/nginx/conf.d/app.conf
cat > /etc/nginx/nginx.conf <<'EOF' 
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log;
pid /run/nginx.pid;

include /usr/share/nginx/modules/*.conf;
events {
    worker_connections 1024;
}

http {
  log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
  '$status $body_bytes_sent "$http_referer" '
  '"$http_user_agent" "$http_x_forwarded_for"';
  access_log  /var/log/nginx/access.log  main;
  sendfile            on;
  tcp_nopush          on;
  tcp_nodelay         on;
  keepalive_timeout   65;
  types_hash_max_size 2048;
  include /etc/nginx/mime.types;
  default_type        application/octet-stream;
  include /etc/nginx/conf.d/*.conf;
}
EOF

cat > /etc/nginx/conf.d/app.conf <<'EOF'
server {
    listen 80;
    server_name localhost;
    root /etc/nginx/www;
    error_log /var/log/nginx/app-server-error.log notice;
    index demo-index.html index.html;
    expires -1;

    access_log  /var/log/nginx/app.access.log;

    sub_filter_once off;
    sub_filter 'server_hostname' '$hostname';
    sub_filter 'server_address'  '$server_addr:$server_port';
    sub_filter 'server_url'      '$request_uri';
    sub_filter 'remote_addr'     '$remote_addr:$remote_port';
    sub_filter 'server_date'     '$time_local';
    sub_filter 'client_browser'  '$http_user_agent';
    sub_filter 'request_id'      '$request_id';
    sub_filter 'nginx_version'   '$nginx_version';
    sub_filter 'document_root'   '$document_root';
    sub_filter 'proxied_for_ip'  '$http_x_forwarded_for';

    location / {
      index index.html;
    }
}
EOF
sudo chmod -R 644 /etc/nginx/nginx.conf /etc/nginx/conf.d/app.conf
ctx logger info "app: nginx configuration done"

sudo yum -y install firewalld
sudo systemctl unmask firewalld
sudo systemctl restart firewalld
sudo firewall-cmd --zone=public --permanent --add-service=http
sudo firewall-cmd --reload
sudo systemctl enable firewalld
sudo systemctl restart firewalld
ctx logger info "app: firewall installed and configured"

sudo systemctl enable nginx
sudo systemctl restart nginx
ctx logger info "app: nginx restarted"
