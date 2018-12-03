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
When you ran the above command to start Basic browser, it created two volumes mongodb and mysql. You can see the volumes using the command `docker volume ls`. For the data to persist between sessions and between containers, make sure you dont delete these volumes. If you need to delete the volumes for various reasons, please run 'docker volume rm mysql mongodb'.

## To delete the basic browser container
```
docker rm -f $(docker ps --filter name=basic-browser -q)
```

## To stop the basic browser container
Stopping the container will remove the container, as we are running the container with "--rm" option
```
docker stop basic-browser
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

## Genome Installation File Download Links

(1) Genome Annotation File: http://genome.ucsc.edu/cgi-bin/hgTables

(2) Go Term File: http://www.geneontology.org/doc/GO.terms_alt_ids

(3) Gene Association File: 

human: ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/HUMAN/goa_human.gaf.gz

fly: ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/FLY/goa_fly.gaf.gz


## Install Genome Assembly on Basic Browser
(1)Make sure Basic Browser is running at localhost:8000, and you are able to login using your username and password, and a TTY terminal is opened in the container.

(2)Make sure your files to upload are accessible within the basic browser session. To mount the files in ~/Documents/BasicBrowser/
```
docker run  -d --rm --name basic-browser -p 8000:8000 \
-v ~/Documents/BasicBrowser/:/Documents -v mongodb:/data/db \
-v mysql:/var/lib/mysql \
basic-browser
```
The files in ~/Documents/BasicBrowser/ will be accessible in /Documents inside basic browser docker

(3)To create a folder to save gene annotation, go to admin page -> Librarys -> Add library -> Create a library name (for example, "annotation") -> save

(4)Install the genome assembly
```
source /opt/basic/_py/bin/activate
_py/bin/python console/table_util.py create hg19 "UCSC Known Genes (hg19)"
ID=1
_py/bin/python console/table_util.py load_genes ${ID} -i /Documents/data/hg19_known_genes.txt --assoc /Documents/data/gene_association.goa_human --terms /Documents/data/GO.terms_alt_ids
_py/bin/python console/track_util.py gen_genes hg19
```

## Upload Tracks to Basic Browser
(1)Make sure your files to upload are accessible within the basic browser session. To mount the files in ~/Documents/BasicBrowser/
```
docker run  -d --rm --name basic-browser -p 8000:8000 \
-v ~/Documents/BasicBrowser/:/Documents -v mongodb:/data/db \
-v mysql:/var/lib/mysql \
basic-browser
```
The files in ~/Documents/BasicBrowser/ will be accessible in /Documents inside basic browser docker

(2)To create a folder to organize tracks, go to admin page -> Librarys -> Add library -> Create a library name (for example, "test_upload") -> save

# Upload Coverage Track 
(1) To upload the coverage track, first create a table for coverage, select a folder ("test_upload"), and give the name of the track ("GM12878_RNAPII_coverage")
```
alias TABLE="/opt/basic/_py/bin/python /opt/basic/console/table_util.py" 
alias TRACK="/opt/basic/_py/bin/python /opt/basic/console/track_util.py"
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_coverage"
```
(2) Then you will get a TABLE ID for this track, and save the ID to the corresponding variable:
```
COV=2
```
(3) Upload coverage track:
```
TRACK gen_cov max ${COV} /Documents/GM12878_RNAPII_insitu.for.BROWSER.bedgraph
```
# Upload Peak Track 
(1) To upload the peak track, first create a table for peak, select a folder ("test_upload"), and give the name of the track ("GM12878_RNAPII_peak")
```
alias TABLE="/opt/basic/_py/bin/python /opt/basic/console/table_util.py" 
alias TRACK="/opt/basic/_py/bin/python /opt/basic/console/track_util.py"
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_peak"
```
(2) Then you will get a TABLE ID for this track, and save the ID to the corresponding variable:
```
BED=4
```
(3) Upload peak track:
```
TABLE load ${BED} 1:chrom 2:start 3:end -i /Documents/GM12878_RNAPII_insitu.for.BROWSER.spp.z6.broadPeak
TRACK new ${BED} scls
```
# Upload Loop Track 
```
alias TABLE="/opt/basic/_py/bin/python /opt/basic/console/table_util.py" 
alias TRACK="/opt/basic/_py/bin/python /opt/basic/console/track_util.py"
TABLE create hg19 -l "test_upload" "GM12878_RNAPII_loop"
CLU=3
TABLE load ${CLU} 1:chrom 2:start 3:end 4:chrom2 5:start2 6:end2 7:score -i /Documents/GM12878_RNAPII_insitu.e500.clusters.cis.BE3
TRACK new ${CLU} curv
```
# Configure Loop Track
Go to Tracks in Admin page and select the loop track you just uploaded, under Metadatas "Key" and "Value", set: 

Key="options",
Value=
{
  "opacity": 0.02,
  "outbound": {
    "show": false
  },
"yaxis": {
"log": 10.0 }
}

Go to the next row,

Key="series",
Value= [{"color": "red"}]

