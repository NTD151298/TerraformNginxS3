# ssh to vm box ansible1
ssh -p 2001 duongtn1512@127.0.0.1 

# ansible install
sudo apt update 
sudo apt install software-properties-common 
sudo add-apt-repository --yes --update ppa:ansible/ansible 
sudo apt -y install ansible
ansible --version
cd /etc/ansible

# install terraform
sudo apt update && sudo apt -y upgrade 
sudo apt install curl software-properties-common 

wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg 

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list 

sudo apt update && sudo apt install terraform 
terraform version 

# hosts file store addr of taraget machine we want to connect
[localhost] 
127.0.0.1 
[lap_app]
3.84.93.131 ansible_ssh_user=ec2-user ansible_ssh_private_key_file=Key_AWS_1.pem

# connect to taraget machine
ssh -i key/key5.pem ubuntu@3.84.93.131

# ping to check connection, taraget machine must turn on sg allow to get ping
wsl ansible lap_app -m ping 

# mount file from vmbox machine to host machine
winscp bro !

# Aws cli
aws sts get-caller-identity
aws configure list
aws configure 

# Teraform
terraform init
terraform apply --auto-approve
terraform destroy --auto-approve
terraform plan
terraform validate

# Command pass time 5h in vm box ubuntu
cat ansible/inventory/lap
ssh -i key/key5.pem ubuntu@18.142.120.242
terraform apply --auto-approve
terraform destroy --auto-approve
rm ansible/playbook/install-jenkins-container.yml
nano ansible/playbook/install-jenkins-container.yml
history

# Git config user
git config --global user.name "NTD1512"
git config --global user.email "duongtn1512@gmail.com"

# Fire wall ubuntu
sudo apt-get install ufw
sudo ufw allow ssh
sudp ufw allow https
sudo ufw allow http
sudo reboot

# Nginx systemctl
sudo systemctl restart nginx
sudo systemctl status nginx
sudo ss -tuln 

# All S3 object url could be use for lab
http://lap-final-bucket-125777342244.s3.amazonaws.com.s3.amazonaws.com/index.html
http://lap-final-bucket-125777342244.s3-ap-southeast-1.amazonaws.com/index.html
http://lap-final-bucket-125777342244.s3.amazonaws.com/index.html
http://s3.amazonaws.com/lap-final-bucket-125777342244/index.html

# Sulostion on going .. for nginx proxy pass s3 index.html
http://webcache.googleusercontent.com/search?q=cache:bnLASzMs9aYJ:https://thucnc.medium.com/how-to-use-nginx-to-proxy-your-s3-files-760acc869e8&sca_esv=572530057&hl=vi&gl=vn&strip=1&vwsrc=0

# Nginx config at sites-enabled
cd /etc/nginx/sites-enabled/ 
sudo rm default
sudo nano default
sudo rm /etc/nginx/sites-enabled/default
sudo nano /etc/nginx/sites-enabled/default
cat /etc/nginx/sites-enabled/default

# Config file follow chat gpt
server {
    listen 80;
    server_name _;

    location / {
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_pass http://lap-final-bucket-125777342244.s3.amazonaws.com/index.html;
    }
}

# On solution
server {
  listen 80;
  listen 443 ssl;
  server_name  statics.yourside.com;
  access_log  /var/log/nginx/statics.access.log  combined;
  error_log   /var/log/nginx/statics.error.log;
  set $bucket "ucodevn.s3-ap-southeast-1.amazonaws.com";
  sendfile on;location / {
    resolver 8.8.8.8;
    proxy_http_version     1.1;
    proxy_redirect off;
    proxy_set_header       Connection "";
    proxy_set_header       Authorization '';
    proxy_set_header       Host $bucket;
    proxy_set_header       X-Real-IP $remote_addr;
    proxy_set_header       X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_hide_header      x-amz-id-2;
    proxy_hide_header      x-amz-request-id;
    proxy_hide_header      x-amz-meta-server-side-encryption;
    proxy_hide_header      x-amz-server-side-encryption;
    proxy_hide_header      Set-Cookie;
    proxy_ignore_headers   Set-Cookie;
    proxy_intercept_errors on;
    add_header             Cache-Control max-age=31536000;
    proxy_pass             https://$bucket; # without trailing slash
  }
}

# Another way on VIBLO website cd /etc/nginx/conf.d
server {
        listen 80;
        server_name _;
 
        location / {
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Host $http_host;
                proxy_pass http://lap-final-bucket-125777342244.s3-ap-southeast-1.amazonaws.com/index.html;  
                proxy_redirect off;
        }
}

# last from solustion
proxy_cache_path   /tmp/ levels=1:2 keys_zone=s3_cache:10m max_size=500m inactive=60m use_temp_path=off;
server {
  listen 80;
  listen 443 ssl;
  server_name  cdn.ucode.vn;
  access_log   /var/log/nginx/ucode-cdn.access.log  combined;
  error_log   /var/log/nginx/ucode-cdn.error.log;
  set $bucket "ucodevn.s3-ap-southeast-1.amazonaws.com";
  sendfile        on;
  # This configuration uses a 60 minute cache for files requested:
  location ^~ /cached/ {
    rewrite           /cached(.*) $1 break;
    resolver 8.8.8.8;
    proxy_cache            s3_cache;
    proxy_http_version     1.1;
    proxy_redirect off;
    proxy_set_header       Connection "";
    proxy_set_header       Authorization '';
    proxy_set_header       Host $bucket;
    proxy_set_header       X-Real-IP $remote_addr;
    proxy_set_header       X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_hide_header      x-amz-id-2;
    proxy_hide_header      x-amz-request-id;
    proxy_hide_header      x-amz-meta-server-side-encryption;
    proxy_hide_header      x-amz-server-side-encryption;
    proxy_hide_header      Set-Cookie;
    proxy_ignore_headers   Set-Cookie;
    proxy_cache_revalidate on;
    proxy_intercept_errors on;
    proxy_cache_use_stale  error timeout updating http_500 http_502 http_503 http_504;
    proxy_cache_lock       on;
    proxy_cache_valid      200 304 60m;
    add_header             Cache-Control max-age=31536000;
    add_header             X-Cache-Status $upstream_cache_status;
    proxy_pass             https://$bucket; 
    # without trailing slash
  }
  # This configuration provides direct access to the Object Storage bucket:
  location / {
    resolver 8.8.8.8;
    proxy_http_version     1.1;
    proxy_redirect off;
    proxy_set_header       Connection "";
    proxy_set_header       Authorization '';
    proxy_set_header       Host $bucket;
    proxy_set_header       X-Real-IP $remote_addr;
    proxy_set_header       X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_hide_header      x-amz-id-2;
    proxy_hide_header      x-amz-request-id;
    proxy_hide_header      x-amz-meta-server-side-encryption;
    proxy_hide_header      x-amz-server-side-encryption;
    proxy_hide_header      Set-Cookie;
    proxy_ignore_headers   Set-Cookie;
    proxy_intercept_errors on;
    add_header             Cache-Control max-age=31536000;
    proxy_pass             https://$bucket;
  }
}
# Final solustions
# Only proxy pass though HTTPS get a SSL 