server {
  listen 80;

  server_name www.runner.sh;

  return 301 $scheme://runner.sh$request_uri;
}

server {
  listen 80;

  server_name runner.sh;

  root /srv/http/runner.sh;

  charset utf-8;

  # Custom 404 page
  error_page 404 /404.html;

  # Include the basic h5bp config set
  include h5bp/basic.conf;
}
