# Nexus Repo Cleaner | Tasks Runner/Checker
<img src="https://www.addteq.com/blog/files/115220009/115220010/1/1464974290000/sonatype-nexus_logo-stacked_whiteBG.png" width="400">

This script was created to help you run and check out tasks in turn to solve / automate the Nexus OOS problem of cleaning up the Docker repository.
## Environment Variables 

| Name | Default Value | Description
| ------ | ----------- | ------------- |
| `NEXUS_IP`   | localhost | Nexus OOS IP address or hostname  |
| `NEXUS_PORT`   | 8081 | Nexus OOS Port |
| `NEXUS_USER`   | admin | Nexus OOS Username |
| `NEXUS_PASS`   | admin123 | Nexus OOS Password |
| `NEXUS_BLOB`   | default | Nexus OOS Blob Store |

## Preparation
1. Login to your Nexus UI
2. Create the - "Admin - Compact blob store" task
3. Create the - "Docker - Delete unused manifests and images" task
4. Create new directory under `/root/`
```bash
$ mkdir /root/nexus_scripts/
```
5. Copy `DailyCleanup.sh` script to `/root/nexus_scripts/`
6. Give the executable permission to run it
```bash
$ chmod +x /root/nexus_scripts/DailyCleanup.sh
```
## Quick start
### Crontab (Automation) Method
1. Edit `/root/nexus_scripts/DailyCleanup.sh` script and change the global variable's values for your environment
2. Execute `crontab -e` and write the following line down
```bash
$ 0 0 * * * /root/nexus_scripts/DailyCleanup.sh
```
### Manual Method
1. Set the all environment variables (You can also set them inside the script) shown above,like:
```bash
$ export NEXUS_IP=192.168.55.10
$ export NEXUS_PORT=8081
$ export NEXUS_USER=admin
$ export NEXUS_PASS='MySuperStrongPass'
$ export NEXUS_BLOB=myblob
```
1. Execute the script
```bash
$ bash /root/nexus_scripts/DailyCleanup.sh
```