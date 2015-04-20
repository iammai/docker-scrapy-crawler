# Docker Scrapyd Scrapy Crawler - Mailan-Spider App

This repository is a spider Python application that can be "Dockerized".
It comes with a step-by-step guide on "Dockerizing" a Python application in Mac OS X. You will learn about Scrapy, Scrapd, Docker, and Boot2Docker.
The mailan-spider app will be distributed as a docker image.

The mailan-spider docker image (built from this guide) is hosted at Docker Hub
https://registry.hub.docker.com/u/iammai/mailan-spider/

## Quick Start

Assuming you have docker installed and configured, run this command to download the image and launch a new container running the spider crawler.
```bash
$ docker run -it -p 6800:6800 iammai/mailan-spider
```

Once the image is downloaded and your container is running, run this command to schedule a spider crawl job
* This API call on the spider server will return a jobid
* Make sure to replace the ip address with the IP address of your Docker Daemon (e.g. boot2docker ip)
* You can pass in multiple URIs to the start_urls in this string format (comma separated): start_urls="http://www.docker.com,http://www.google.com"
```bash
$ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com,http://www.google.com"
{"status": "ok", "jobid": "f0bda666e72111e4b7290242ac110002"}
```

Once the job is complete, to see the list of crawled images, run this command:
```bash
$ curl http://192.168.59.103:6800/items/mailan/mailan/f0bda666e72111e4b7290242ac110002.jl
```

* Replace f0bda666e72111e4b7290242ac110002 with the "jobid" that is returned form the curl
* You can also to your web browser for the web ui for monitoring
   * Go to http://192.168.59.103:6800/
   * Go to http://192.168.59.103:6800/jobs
   * Make sure to replace the ip address with the IP address of your Docker Daemon (e.g. boot2docker ip)


## Basic Terminology

What is ... ?

* Scrapy
 * a framework that allows you to easily crawl web pages and extract desired information.
* Scrapyd
 * an application that allows you to manage your spiders.
 * Because Scrapyd lets you deploy your spider projects via a JSON api, you can run scrapy on a different machine than the one you are running.
 * Lets you schedule your crawls, and even comes with a web UI to see all crawls and data responses.
* Docker
 * provides a way for almost any application to run securely in an isolated container.
 The isolation of a container allows you to run many instances of your application simultaneously and on many different platforms easily.
  * Main Docker Parts
    * docker daemon: used to manage docker containers on the host it runs
    * docker CLI: used to command and communicate with the docker daemon
    * docker image index: a repository (public or private) for docker images
  * Main Docker Elements
    * docker containers: directories containing EVERYTHING (OS, server daemons, your application)
    * docker images: snapshots of containers or base OS images - images are just templates for docker containers!
    * Dockerfiles: scripts automating the building process of images
* Boot2Docker
 * a lightweight Linux distribution made specifically to run Docker containers
 * Like many developers, I am on Mac OS X. Since Docker uses features only available to Linux, the machine must be running on a Linux kernel. Hence, Boot2docker VM (Virtual Machine) for Mac OS X solves our problem!

## Scrapyd

This mailan-spider will try to crawl whatever is passed in `start_urls` which should be a comma-separated string of fully qualified URIs.
The output will be a list of image names from the URIs and also crawl one page link deep in JSON; we will also get the image's page source in the JSON output

After the application is fully "Dockerized", we can schedule a mailan-spider crawl with the follow command:

example: to schedule a crawl for http://www.docker.com and http://www.google.com:
```bash

$ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com,http://www.google.com"
```

Be wary that some sites block crawlers

Besides the command line tools, one can also access Scrapyd's web interface, which shows jobs, their logs, and their output:

http://192.168.59.103:6800/jobs


## Guide

This guide will walk you step-by-step on how to dockerize the mailan-spider application.
You will learn
* how to run your a mailan-spider crawl using Scrapy
* how to use Boot2Docker on your Mac OS X
* how to use Scrapyd to schedule crawls and manage them
* how to deploy your DockerHub

1. Clone this repository

  ```bash
  $ git clone git@github.com:iammai/docker-scrapy-crawler.git
  ```
2. Install Scrapy onto your local machine
   * I recommend installing everything in a virtual environment (http://docs.python-guide.org/en/latest/dev/virtualenvs/)

    * To install  virtualenv
    ```bash
     $ pip install virtualenv
    ```
    * Create a virtualenvironment folder for this project
    ```bash
    $ cd my_project_folder
    $ virtualenv venv
    ```

    Each time you want to use virtualenv in a new terminal, you must activate it
    ```bash
    $ cd my_project_folder
    $ source venv/bin/activate
    ```

    * Installing Scrapy in your virtual environment
    ```bash
     (venv)$ pip install scrapy

             * Wait for the installation to finish. Upon successful installation, you may see the following line

              ```
              Successfully installed Twisted-15.1.0 cffi-0.9.2 cryptography-0.8.2 cssselect-0.9.1 enum34-1.0.4 lxml-3.4.3 pyOpenSSL-0.15.1 pyasn1-0.1.7 pycparser-2.10 queuelib-1.2.2 scrapy-0.24.5 six-1.9.0 w3lib-1.11.0 zope.interface-4.1.2
             ```
    ```

    * Check your scrapy version

    ```bash
    (venv)$ pip install scrapyscrapy version
     ```
    Your output should be the following.
    ```bash
    Scrapy 0.24.5
     ```

    You may see the below warning when you check for the version
    ```bash
    (venv) $ scrapy version
    :0: UserWarning: You do not have a working installation of the service_identity module: 'No module named service_identity'.  Please install it from <https://pypi.python.org/pypi/service_identity> and make sure all of its dependencies are satisfied.  Without the service_identity module and a recent enough pyOpenSSL to support it, Twisted can perform only rudimentary TLS client hostname verification.  Many valid certificate/hostname mappings may be rejected.
    Scrapy 0.24.5
     ```

    * Make sure you have all dependencies installed.
      * If you see the Warning message, you will need to install the service_identity module
          ```bash
            (venv) $ pip install service_identity
          ```


2. You can test that your Scrapy installation works with the mailan-spider by running the crawler locally on your machine.
   Make sure you are on the level with scrapy.cfg.
   - This particular mailan-spider will go to http://www.docker.com and http://www.google.com and crawl for images on the page and one page link below the page
    * Installing Scrapy in your virtual environment
    ```bash
     (venv)$ cd docker-scrapy-crawler
     (venv)$ scrapy crawl mailan -o items.json -a start_urls=http://www.docker.com,http://www.google.com

    ```


    * Once the mailan-spider crawl is done, you should be left with a items.json output file in your docker-scrapy-crawler folder
      with a JSON file that is a list of image names and the page source of the image.
      Your JSON output items.json should be similar to the following (a sample is stored in sample-item-output/items.json]:

       ```JSON
        [{"img_src": ["//www.google.com/images/logos/google_logo_41.png"], "page_url": "http://www.google.com/intl/en/policies/terms/"},
        {"img_src": ["//www.google.com/images/logos/google_logo_41.png"], "page_url": "http://www.google.com/intl/en/ads/"},
        {"img_src": ["images/testimonial/advertiser.jpg"], "page_url": "http://www.google.com/intl/en/ads/"},
        {"img_src": ["images/testimonial/publisher.jpg"], "page_url": "http://www.google.com/intl/en/ads/"}]
       ```

        We've successfully ran our first crawl!

        Now we want to be able to schedule these crawls and so that we can makes multiple crawls in parallel!
        We also want to manage these crawls and be able to save their logs and JSON output.
        We can manage run multiple different spiders as well with Scrapyd but I decided to omit adding multiple spiders for the sake of simplicity.

3. Install Boot2Docker onto your local machine and use it to create docker containers

    * Get the latest version and install
        * Go to the : [boot2docker/osx-installer](https://github.com/boot2docker/osx-installer/releases/) release page.

        * Download Boot2Docker by clicking Boot2Docker-x.x.x.pkg in the "Downloads" section.

        * Install Boot2Docker by double-clicking the package.

        * The installer places Boot2Docker in your "Applications" folder.

        * The installation places the docker and boot2docker binaries in your /usr/local/bin directory.

    * LAUNCH the application

        * You can launch Boot2Docker by simply directly clicking on the Boot2Docker App in your Applications folder
        * or via the command line

            * To initialize and run boot2docker from the command line, do the following:

                 * Create a new Boot2Docker VM (Virtual Machine).
                 ```bash
                 $ boot2docker init
                 ```

                 This creates a new virtual machine. You only need to run this command once.

                 Start the boot2docker VM.
                 ```bash
                 $ boot2docker start
                 ```

                 Display the environment variables for the Docker client.
                 ```bash
                 $ boot2docker shellinit
                 Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/ca.pem
                 Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/cert.pem
                 Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/key.pem
                     export DOCKER_HOST=tcp://192.168.59.103:2376
                     export DOCKER_CERT_PATH=/Users/mary/.boot2docker/certs/boot2docker-vm
                     export DOCKER_TLS_VERIFY=1
                  ```
                 The specific paths and address on your machine will be different.

                 To set the environment variables in your shell do the following:
                  ```bash
                 $ eval "$(boot2docker shellinit)"
                 You can also set them manually by using the export commands boot2docker returns.
                 ```

    * Once the launch completes, you can run docker commands. A good way to verify your setup succeeded is to run the hello-world container.

                ```bash
                    bash-3.2$ docker run hello-world
                    Hello from Docker.
                    This message shows that your installation appears to be working correctly.

                    To generate this message, Docker took the following steps:
                     1. The Docker client contacted the Docker daemon.
                     2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
                        (Assuming it was not already locally available.)
                     3. The Docker daemon created a new container from that image which runs the
                        executable that produces the output you are currently reading.
                     4. The Docker daemon streamed that output to the Docker client, which sent it
                        to your terminal.

                    To try something more ambitious, you can run an Ubuntu container with:
                     $ docker run -it ubuntu bash

                    For more examples and ideas, visit:
                     http://docs.docker.com/userguide/
                    bash-3.2$

                ```

                * To check what images you have on your boot2docker VM
                 ```bash
                        bash-3.2$ docker images
                 ```

                * You should see in return at this point
                     ```bash
                        REPOSITORY          TAG                 IMAGE ID            CREATED              VIRTUAL SIZE
                        scrapyd             latest              9db96efb336a        About a minute ago   561.1 MB
                        hello-world         latest              91c95931e552        2 days ago           910 B
                     ```


                * I recommend review docker's commands and functionalitybefore you procees (Docker Command Lines)[https://docs.docker.com/reference/commandline/cli/]
                      ```bash
                            bash-3.2$ docker
                       ```

    * To create a docker container we need a Dockerfile which automates our build. Fortunately, There is one written already in this repository for you! (written by Andrew Huynh <andrew@productbio.com>)
        * Mount a volume on the container
          * When you start boot2docker, it automatically shares your /Users directory with the VM. You can use this share point to mount directories onto your container. The next exercise demonstrates how to do this.
            *Change to your user $HOME directory and go to your docker-scrapy-crawler folder (your path may vary)
        ```bash
        bash-3.2$ cd $HOME
        bash-3.2$ cd docker-scrapy-crawler
        ```

        * Build a scrapyd container
        ```bash
        bash-3.2$ docker build -t scrapyd .
        ```

           * Once finished building you should see a successfully build confirmation similar to below
           ```
           Successfully built 9db96efb336a
           ```

          * Check on the docker images

            * You should see
             ```

            REPOSITORY          TAG                 IMAGE ID            CREATED              VIRTUAL SIZE
            scrapyd             latest              9db96efb336a        About a minute ago   561.1 MB
            hello-world         latest              91c95931e552        2 days ago           910 B
            debian              wheezy              1265e16d0c28        2 weeks ago          84.98 MB
            ```


        * Take a moment to understand how the ports are mapped in Boot2docker to the docker containers
            * Because we are on a VM, all ports in boot2docker must map to the the desired port in your docker container

            * Type in a command to find your boot2docker's ip address

                ```bash
                boot2docker ip
                ```
                * You should get a similar response
                 ```bash
                    192.168.59.103
                 ```

        * Try running the scrapd container
           ```bash
                    bash-3.2$ docker run -it -p 6800:6800 scrapyd
           ```
        * Open another terminal and launch into boot2docker.
            *Either double click to launch the application again
            * or follow the steps to export the shellinit parameters in the terminal again.
              You will have to do this for each terminal that you open that you want to run docker commands on.
              * Display the environment variables for the Docker client.
                               ```bash
                               $ boot2docker shellinit
                               Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/ca.pem
                               Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/cert.pem
                               Writing /Users/iammai/.boot2docker/certs/boot2docker-vm/key.pem
                                   export DOCKER_HOST=tcp://192.168.59.103:2376
                                   export DOCKER_CERT_PATH=/Users/mary/.boot2docker/certs/boot2docker-vm
                                   export DOCKER_TLS_VERIFY=1
                                ```
                               The specific paths and address on your machine will be different.

              * To set the environment variables in your shell do the following:
                                ```bash
                               $ eval "$(boot2docker shellinit)"
                               You can also set them manually by using the export commands boot2docker returns.
                               ```

       * Type in a command to see your current running container, this will help you see how the ports are set up
         ```bash
         bash-3.2$ docker ps
         ```

       * The response should be similar to below
        ```
        CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
        fcd2afbc1cf0        scrapyd:latest      "scrapyd"           3 minutes ago       Up 3 minutes        0.0.0.0:6800->6800/tcp   elegant_kirch
        ```

            * note PORT: every ip address on port 6800 on your boot2docker are routed to the container's port 6800.

        * Open up your web browser and point to your boot2docker's ip address with port 6800: http://192.168.59.103:6800/
            * You should see a web interface that lets you see jobs, items, and logs of your spider crawls
            ```

            Scrapyd

            Available projects:

            Jobs
            Items
            Logs
            Documentation
            How to schedule a spider?

            To schedule a spider you need to use the API (this web UI is only for monitoring)

            Example using curl:

            curl http://localhost:6800/schedule.json -d project=default -d spider=somespider

            For more information about the API, see the Scrapyd documentation

            ```


        * We have a fully working scrapd container, but we have no spiders yet to be able to crawl!
          In the next steps, you will learn how to deploy (upload) the mailan-spider) to your scrapd container

4. Open up another terminal on your local machine and install Scrapyd in your virtual environment
    ```bash
     (venv)$ pip install scrapyd

    ```

5. Deploy your mailan-spider (which is on your local machine) to the scrapd container (which exists on your boot2docker VM)
   We will do this via scrapd, which "eggify" our mailan-spider and uploads the egg to our docker container
    ```

   Make sure the IP address to the container is correct in the scrapy.cfg file.
   In the previous steps, we had checked in our boot2docker VM's address. You can recheck it in the boot2docker terminal with:
    ```bash
    boot2docker ip
    ```
    * You should get a similar response
     ```bash
        192.168.59.103
     ```

    our scrapy.cfg file should have this same ip address set for uploading our egg
    ```
    [deploy:docker]
    url = http://192.168.59.103:6800/
    project = mailan
    version = GIT
    ```

    * Go to your docker-scrapy-crawler folder

    ```bash
      (venv)$ cd docker-scrapy-crawler

   * Once inside the folder, we can deploy the mailan-spider to the scrapyd container on your boot2docker using the below command line

   ```bash
   (venv)$ scrapyd-deploy docker -p mailan
   ```

     * If the deployment of your mailan-spider egg is successful, you will see a similar output
     ```
     (venv)$ scrapyd-deploy docker -p mailan
     Packing version 46b43ae-master
     Deploying to project "mailan" in http://192.168.59.103:6800/addversion.json
     Server response (200):
     {"status": "ok", "project": "mailan", "version": "46b43ae-master", "spiders": 1}
     ```

     * Note: If we have more spiders that we wrote, we can deploy as many spiders as we want! I didn't do this in this guide for simplicity.


     * Check that our docker container was uploaded.
       * Go back to our second terminal window with boot2docker
       * Check on all docker containers that are running in our boot2docker VM.
       ```bash
       bash-3.2$ docker ps
       CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS                    NAMES
       66e404162fcf        scrapyd:latest      "scrapyd"           3 minutes ago       Up 3 minutes        0.0.0.0:6800->6800/tcp   cocky_perlman
       ```
        * We should be able to see that the CONTAINER ID has been updated after our deployment!

        * Check on the versioning differences with docker diff [containerID]
        ```
        bash-3.2$ docker diff --help

        Usage: docker diff [OPTIONS] CONTAINER

        Inspect changes on a container's filesystem

          --help=false       Print usage
        bash-3.2$ docker diff 66e404162fcf
        A /dbs
        A /dbs/mailan.db
        A /eggs
        A /eggs/mailan
        A /eggs/mailan/46b43ae-master.egg
        C /tmp
        A /twistd.pid
        ```
            * We can see that the eggs are in the file diff!

6. Now that we have our mailan-spider uploaded to our scrapd container we should be able to do many crawls

   To schedule a mailan-spider crawl, go to any terminal window and enter:
   ```bash
   $ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com"
   ```

   Schedule another a mailan-spider crawl with two website urls, go to any terminal window and enter:
      ```bash
      $ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com,http://www.google.com"
      ```

   We can schedule as many crawls as you want. If we had more spiders, we can schedule different types of spiders!
   For mailan-spider, we can also change the start_urls so that you can crawl different sites.

   We should get a similar response with unique jobids for each crawl:
   ```
   $ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com"
   {"status": "ok", "jobid": "1546dc9ae71911e4b7290242ac110016"}
   $ curl http://192.168.59.103:6800/schedule.json -d project=mailan -d spider=mailan -d start_urls="http://www.docker.com,http://www.google.com"
   {"status": "ok", "jobid": "894e3b56e71911e4b7290242ac110016"}
   ```

7. We can monitor the jobs, items, and logs of our scheduled crawls via the command line or the web browser interface

   * Go to http://192.168.59.103:6800/ (or whatever your boot2docker IP address:6800 port is)

     * We should see a webpage with:
     ```
     Scrapyd

     Available projects: mailan

     Jobs
     Items
     Logs
     Documentation
     How to schedule a spider?

     To schedule a spider you need to use the API (this web UI is only for monitoring)

     Example using curl:

     curl http://localhost:6800/schedule.json -d project=default -d spider=somespider

     For more information about the API, see the Scrapyd documentation
     ```

   * Go to http://192.168.59.103:6800/jobs

    * We should see a webpage with:
    ```
    Jobs

    Go back

    Project	Spider	Job	PID	Runtime	Log	Items
    Pending
    Running
    Finished
    mailan	mailan	1546dc9ae71911e4b7290242ac110016		0:00:13.675644	Log	Items
    mailan	mailan	894e3b56e71911e4b7290242ac110016		0:00:09.515443	Log	Items
    ```

    * We should be able to see the log of the crawl and the items (.jl format)
        * I've saved some output samples in the sample-item-output/scrapd/ folder of this repository]

8. Now that we have this functional container that with our mailan-spider egg and scrapyd working, we should save it!

   * Save our new scrapd container with the mailan-spider egg and save rename to be a mailan-spider image
      * We'll be using using docker commit <container-id> <image-name>, but first we must do the following steps:

      * In the terminal with the running scrapd container, you can terminate the server by pressing Control + C
          You should see the following upon successful shutdown
          ```
          ^C2015-04-20 04:17:45+0000 [-] Received SIGINT, shutting down.
          2015-04-20 04:17:45+0000 [-] (TCP Port 6800 Closed)
          ...
          2015-04-20 04:31:59+0000 [-] Server Shut Down.
      *  Pull up info of the recently shut down container
      ```bash
      bash-3.2$ docker ps -ls
      CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES               SIZE
      66e404162fcf        scrapyd:latest      "scrapyd"           25 minutes ago      Exited (0) 6 seconds ago                       cocky_perlman       1.637 MB
      ```

        * NOTE: If you haven't already done so, in a web browse, create a DockerHub account (https://hub.docker.com/)
            * Click on "Add Repository' and add a repo with your desired name, in my case 'mailan-spider'

      * Go back to your boot2docker terminal and commit your docker container to a new name
       * (the required format to upload to your account is dockerhub-account-name/repository-name
      ```bash
      bash-3.2$ docker commit 66e404162fcf iammai/mailan-spider
      688cc34903b0746774e629c73e843a83ab9b78c2dd0f431a0315745bedec219c
      ```

        * To see your all your containers
        ```bash
        bash-3.2$ docker ps --all
        CONTAINER ID        IMAGE                COMMAND             CREATED             STATUS                         PORTS               NAMES
        66e404162fcf        scrapyd:latest       "scrapyd"           38 minutes ago      Exited (0) 13 minutes ago                          cocky_perlman
        39eafe6f234c        scrapyd:latest       "scrapyd"           56 minutes ago      Exited (0) 49 minutes ago                          hungry_carson
        fcd2afbc1cf0        scrapyd:latest       "scrapyd"           About an hour ago   Exited (0) About an hour ago                       elegant_kirch
        da97dccd7aaf        hello-world:latest   "/hello"            About an hour ago   Exited (0) About an hour ago                       fervent_poincare
        ```

        *bash-3.2$ docker images
         REPOSITORY             TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
         iammai/mailan-spider   latest              688cc34903b0        10 minutes ago      562.7 MB
         scrapyd                latest              9db96efb336a        About an hour ago   561.1 MB
         hello-world            latest              91c95931e552        2 days ago          910 B
         debian                 wheezy              1265e16d0c28        2 weeks ago         84.98 MB
        *

9. Upload the container to your Dockerhub account. In your boot2docker terminal:

        * connect your boot2docker to your dockerhub account
          ```
         bash-3.2$ sudo docker login
          ```

       * push your docker container to the hub
       ```bash
       bash-3.2$ docker push iammai/mailan-spider
       The push refers to a repository [iammai/mailan-spider] (len: 1)
       688cc34903b0: Image already exists
       9db96efb336a: Image successfully pushed
       a6026c9e4e9d: Image successfully pushed
       b5082d48c7ec: Image successfully pushed
       3a648bcc9d13: Image successfully pushed
       5a00fb0319f3: Image successfully pushed
       e5d9ad50134e: Image successfully pushed
       ad3d6b4cefde: Image successfully pushed
       78d35f240215: Image successfully pushed
       f057f57e23b0: Image successfully pushed
       e702657f40a5: Image successfully pushed
       1265e16d0c28: Image successfully pushed
       4f903438061c: Image successfully pushed
       511136ea3c5a: Image successfully pushed
       Digest: sha256:69e575c1735babfec90cc01cad2fc7dcca33c502a7ec17ce0a280656053ca7f2
       ```

        * Mine is hosted on https://registry.hub.docker.com/u/iammai/mailan-spider/


        * You can also save your image file to a tar file to save it locally
        ```
        bash-3.2$ sudo docker save iammai/mailan-spider > mailan-spider.tar
        ```


### Summany of docker images and docker containers flow in a nutshell

        * The image is a template for docker containers. It has all of the files (OS, configuration) including your application.
        * A container is an instance of an image.
        * You can make changes to a container, but these changes will not affect the image.
            * However, you can create a new image from a container (and all it changes) using docker commit <container-id> <image-name>.
        * When you create a new container, you build it from an image or by using a Dockerfile.
        * You can then go modify the container, which changes the contents of the container.
        * Based on the modified container, you can create or update an image based on your changes to your container.
        * You can upload your image to DockerHub.
        * Others can download your image and recreate new containers that will be exact copies of your container.

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## History

I've heard a lot about Docker and wanted to try it out.
As a developer, there wasn't a straight-forward guide to "dockerizing" my particular application that I wrote.
I wanted to put forth a clear step-by-step guide and put forth code for developers
that would ease the process for developers trying out Docker for the first time.

## Credits
Influenced and inspired by

* Scrapyd Playground - https://github.com/a5huynh/scrapyd-playground
* Scrapy Tutorial - http://doc.scrapy.org/en/latest/intro/tutorial.html
* Boot2Docker - https://docs.docker.com/installation/mac/
* Understanding Docker - https://docs.docker.com/introduction/understanding-docker/
* Docker Getting Started Guide - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started
* How to Use Docker on OS X - http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide


## License

The MIT License (MIT)

Copyright (c) 2015 Mailan Reiser

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
