# Docker Scrapyd Scrapy Crawler - Mailan-Spider App

This repository is a spider Python application that can be "Dockerized".
It comes with a step-by-step guide on "Dockerizing" a Python application in Mac OS X. You will learn about Scrapy, Scrapd, Docker, and Boot2Docker.
The mailan-spider app will be distributed as a docker container and can have more than one version of the same container running in parallel.


## Basic Terminology

What is ... :

* Scrapy
* * a framework that allows you to easily crawl web pages and extract desired information.
* ScrapyD
** an application that allows you to manage your spiders.
** Because Scrapyd lets you deploy your spider projects via a JSON api, you can run scrapy on a different machine than the one you are running.
** Lets you schedule your crawls, and even comes with a web UI to see all crawls and data responses.
* Docker provides a way for almost any application to run securely in an isolated container.
The isolation of a container allows you to run many instances of your application simultaneously and on many different platforms easily.
**Main Docker Parts
*** docker daemon: used to manage docker (LXC) containers on the host it runs
*** docker CLI: used to command and communicate with the docker daemon
*** docker image index: a repository (public or private) for docker images
**Main Docker Elements
***docker containers: directories containing everything-your-application
***docker images: snapshots of containers or base OS (e.g. Ubuntu) images
***Dockerfiles: scripts automating the building process of images
* Boot2Docker
**a lightweight Linux distribution made specifically to run Docker containers
**Like many developers, I am on Mac OS X. Since Docker uses features only available to Linux, the machine must be running a Linux kernel. Hence, Boot2docker for Mac OS X solves our problem!

## Guide

1. Clone this repository and installs all dependencies for Scrapy
**list dependencies here
2.

**


## Usage

This spider will try to crawl whatever is passed in `start_urls` which should be a comma-separated string of fully qualified URIs.

To schedule a mailan-spider crawl:


to schedule a crawl for http://www.docker.com:

curl http://192.168.59.103:6800/schedule.json -d project=test -d spider=mailan -d start_urls="http://www.docker.com"

to schedule a crawl for http://www.docker.com and http://www.cnn.com:

curl http://192.168.59.103:6800/schedule.json -d project=test -d spider=mailan -d start_urls="http://www.docker.com,http://www.cnn.com"

Message: be wary that some sites block crawlers

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request

## History

I've heard a lot about Docker and wanted to try it out.
As a developer, there wasn't a straight-forward guide to "dockerizing" my particular application that I wrote.
I wanted to put forth a clear step-by-step guide and put forth code for developers
that would ease the process for developers trying out Docker for the first time.

## Credits
Influenced and inspired by

Scrapyd Playground - https://github.com/a5huynh/scrapyd-playground
Scrapy Tutorial - http://doc.scrapy.org/en/latest/intro/tutorial.html
Boot2Docker - https://docs.docker.com/installation/mac/
Understanding Docker - https://docs.docker.com/introduction/understanding-docker/
Docker Getting Started Guide - https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-getting-started
How to Use Docker on OS X - http://viget.com/extend/how-to-use-docker-on-os-x-the-missing-guide


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
