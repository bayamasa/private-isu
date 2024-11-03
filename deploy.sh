#!/bin/sh
# referenced from https://github.com/tatsuru/isucon13/blob/main/scripts/deploy

set -v

now=$(date +%Y%m%d-%H%M%S)
branch=${1-main}


update="cd /home/isucon/private_isu && git remote update && git checkout $branch && git pull"
update_mysqld_config="sudo cp /home/isucon/private_isu/mysql/mysql.conf.d/mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf"
update_nginx_config="sudo cp /home/isucon/private_isu/nginx/nginx.conf /etc/nginx/nginx.conf"
# update_nginx_config2="sudo cp /home/isucon/private_isu/nginx/sites-available/isucon.conf /etc/nginx/sites-available/isucon.conf"

clear_images="cd /home/isucon/private_isu/webapp/public/img && ls | grep -E '[0-9]{5,}' | xargs --no-run-if-empty rm"
restart="cd /home/isucon/private_isu/webapp/golang && /home/isucon/.local/go/bin/go build -o app && sudo systemctl restart isu-go"
rotate_mysql="sudo mv -v /var/log/mysql/mysql-slow.log /var/log/mysql/mysql-slow.log.$now && mysqladmin -uisuconp -pisuconp flush-logs && sudo systemctl restart mysql"
rotate_nginx="sudo mv -v /var/log/nginx/access.log /var/log/nginx/access.log.$now && sudo systemctl reload nginx"

# ssh -A isucon@52.196.250.55 "$update && $clear_images && $restart && $rotate_mysql && $rotate_nginx"
ssh isu-server "$update && $update_mysqld_config && $update_nginx_config && $clear_images && $restart && $rotate_mysql && $rotate_nginx"