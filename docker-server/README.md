Set up the VPS server with docker compose
----

To setup the VPS server using nginx and certbot you can use `docker-compose`.

## Install docker on the server
Check how to install `docker-compose` in the server [here](https://docs.docker.com/compose/install/)
```sh
ssh root@server
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
```

## Prepare server
Move all needed files in the VPS server. First you need to create a folder in the VPS:

```sh
ssh root@server
mkdir /root/stupid-projects.com
```

From your host in the repo folder run this:
```sh
scp docker-compose.yml root@server:/root/stupid-projects.com
scp init-letsencrypt.sh root@server:/root/stupid-projects.com
scp -r data root@server:/root/stupid-projects.com
scp web-server.service root@server:/etc/systemd/system/
```

## Create and run the server service
Now that all the files are in the server you need to ssh back to the server.
```sh
ssh root@server
cd /root/stupid-projects.com
```

The folder content should be like this:
```sh
drwxr-xr-x 3 root root 4096 Jan  8 13:57 ./
drwx------ 7 root root 4096 Jan  8 14:03 ../
drwxr-xr-x 4 root root 4096 Jan  8 13:19 data/
-rw-r--r-- 1 root root  685 Jan  8 13:57 docker-compose.yml
-rwxr-xr-x 1 root root 2524 Jan  8 13:25 init-letsencrypt.sh*
```

And also the service file should be in `/etc/systemd/system/web-server.service`.

Now you need to run:
```sh
./init-letsencrypt.sh
```

After that you can try that everything works properly:
```sh
docker-compose up

# Check that server works properly, then
docker-compose down
```

Finally, enable the service and run it:
```sh
systemctl enable web-server
systemctl start web-server
```