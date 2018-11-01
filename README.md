# Basic Browser


## Running Basic Browser
Below are the instructions to run Basic Browser docker image.

## Install Docker
 - [Install Docker for Mac](https://docs.docker.com/v17.09/docker-for-mac/install/)
 - [Install Docker for Windows](https://docs.docker.com/v17.09/docker-for-windows/install/)
 - [Install Docker for Ubuntu](https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/#extra-steps-for-aufs)

## How to build the Basic Browser Docker image
```sh
git clone https://github.com/TheJacksonLaboratory/basic-browser.git
cd basic-browser
docker build -t basic-browser .
cd ..
```

## How to run Basic Browser
This creates a mongodb and mysql Docker volumes, which is useful for data persistence
```sh
docker run  -d --rm --name basic-browser \
       -p 8000:8000 \
       -v mongodb:/data/db \
       -v mysql:/var/lib/mysql \
       basic-browser
```
The basic browser should be running at localhost:8000. To upload track and data into the Basic Browser, a new TTY terminal must be opened in the container.
```sh
docker exec -ti basic-browser bash
```

## Create a username and password through the terminal the first time
```sh
# this should create the superuser 'root'
cd /opt/basic/
$BASIC_DIR/_py/bin/python manage.py createsuperuser
```

## About Data persistence
When you ran the above command to start Basic browser, it created two volumes mongodb and mysql. You can see the volumes using the command `docker volume ls`. For the data to persist between sessions and between containers, make sure you dont delete these volumes.

## To delete the basic browser container
```
docker rm -f $(docker ps --filter name=basic-browser -q)
```

## To restart Basic Browser
```sh
docker restart basic-browser
```

## To make sure mysql, mongod, and basic browser are running
```sh
supervisorctl status all
```

# A note about passwords
The mysql root password is not set. If you would like to set the root password, follow these steps
```sh
# Login to the machine
docker exec -ti basic-browser bash

# Update the mysql password
mysql -u root -p
mysql> use mysql;
mysql> update user set password=PASSWORD('your_new_password') where User='root';
mysql> flush privileges;
```
## Install Genome Assembly on Basic Browser
Make sure Basic Browser is running at localhost:8000, and you are able to login using your username and password, and a TTY terminal is opened in the container.


```
source /opt/basic/_py/bin/activate
_py/bin/python console/table_util.py create hg19 "UCSC Known Genes (hg19)"
ID=1
_py/bin/python console/table_util.py load_genes ${ID} -i /Documents/data/hg19_known_genes.txt --assoc /Documents/data/gene_association.goa_human --terms /Documents/data/GO.terms_alt_ids
_py/bin/python console/track_util.py gen_genes hg19
```

## Upload Tracks to Basic Browser

```
alias TABLE="/opt/basic/_py/bin/python /opt/basic/console/table_util.py" 
alias TRACK="/opt/basic/_py/bin/python /opt/basic/console/track_util.py"
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_coverage"
COV=10
TRACK gen_cov max ${COV} /Documents/
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_peak"
BED=7
TABLE load ${BED} 1:chrom 2:start 3:end -i /Documents/GM12878_RNAPII_insitu.for.BROWSER.spp.z6.broadPeak
TRACK new ${BED} scls #set options
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_loop"
CLU=6
TABLE load ${CLU} 1:chrom 2:start 3:end 4:chrom2 5:start2 6:end2 7:score -i /Documents/GM12878_RNAPII_insitu.e500.clusters.cis.BE3
TRACK new ${CLU} pcls
TRACK new ${CLU} curv
```
