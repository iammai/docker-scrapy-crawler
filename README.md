# Docker Scrapyd Scrapy Crawler - Mailan-Spider App

This repository is a spider Python application that can be "Dockerized".
It comes with a step-by-step guide on "Dockerizing" a Python application in Mac OS X. You will learn about Scrapy, Scrapd, Docker, and Boot2Docker.
The mailan-spider app will be distributed as a docker container and can have more than one version of the same container running in parallel.

The mailan-spider docker container is hosted at Docker Hub, but you can also get a copy in the containers folder of this repository (saved in mailan-spider.tar).
https://registry.hub.docker.com/u/iammai/mailan-spider/

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
    * docker containers: directories containing EVERYTHING and your application
    * docker images: snapshots of containers or base OS images
    * Dockerfiles: scripts automating the building process of images
* Boot2Docker
 * a lightweight Linux distribution made specifically to run Docker containers
 * Like many developers, I am on Mac OS X. Since Docker uses features only available to Linux, the machine must be running a Linux kernel. Hence, Boot2docker for Mac OS X solves our problem!

## Usage

This mailan-spider will try to crawl whatever is passed in `start_urls` which should be a comma-separated string of fully qualified URIs.
The output will be a list of image names from the URIs and also crawl one page link deep in JSON; we will also get the image's page source in the JSON output

After the application is fully "Dockerized", we can schedule a mailan-spider crawl with the follow commands:

to schedule a crawl for http://www.docker.com:
```bash

$ curl http://192.168.59.103:6800/schedule.json -d project=test -d spider=mailan -d start_urls="http://www.docker.com"
```


to schedule a crawl for http://www.docker.com and http://www.google.com:
```bash

$ curl http://192.168.59.103:6800/schedule.json -d project=test -d spider=mailan -d start_urls="http://www.docker.com,http://www.google.com"
```

Be wary that some sites block crawlers

Besides the command line tools, one can also access Scrapyd's web interface, which shows jobs, their logs, and their output:

http://192.168.59.103:6800/jobs


## Guide

This guide will walk you step-by-step on how to dockerize the mailan-spider application
You will learn
* how to run your a crawl using Scrapy
* how to use Boot2Docker on your Mac OS X
* how to use Scrapyd to schedule crawls and manage them
* how to deploy your docker

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

3. Install Boot2Docker onto your machine and use it to create docker containers

    * Get the latest version and install
        * Go to the : [boot2docker/osx-installer](https://github.com/boot2docker/osx-installer/releases/) release page.

        * Download Boot2Docker by clicking Boot2Docker-x.x.x.pkg in the "Downloads" section.

        * Install Boot2Docker by double-clicking the package.

        * The installer places Boot2Docker in your "Applications" folder.

        * The installation places the docker and boot2docker binaries in your /usr/local/bin directory.

    * Run the application

        * You can launch Boot2Docker by simply directly clicking on the Boot2Docker App in your Applications folder
        * or via the command line

            * To initialize and run boot2docker from the command line, do the following:

                 * Create a new Boot2Docker VM.
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

4. Install Scrapyd in your virtual environment
    ```bash
     (virtualenvspider)$ pip install scrapyd

    ```

5. Deploy your application


**




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
