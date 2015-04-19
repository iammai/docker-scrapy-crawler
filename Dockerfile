FROM debian:wheezy
MAINTAINER Andrew Huynh <andrew@productbio.com>

# When this Dockerfile was last refreshed
ENV REFRESHED_AT 2014-11-18

ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Install system dependencies
#
#	Python dependencies
#		python-dev python-pip python-setuptools
#
#	Scrapy dependencies
#		libffi-dev libxml2-dev libxslt1-dev
#
#	Pillow (Python Imaging Library) dependencies
#		libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev
# 		liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk
#
RUN apt-get update && apt-get install -y \
			python-dev python-pip python-setuptools \
			libffi-dev libxml2-dev libxslt1-dev \
			libtiff4-dev libjpeg8-dev zlib1g-dev libfreetype6-dev \
			liblcms2-dev libwebp-dev tcl8.5-dev tk8.5-dev python-tk

# Add the dependencies to the container and install the python dependencies
ADD requirements.txt /tmp/requirements.txt
RUN pip install -r /tmp/requirements.txt && rm /tmp/requirements.txt
RUN pip install Pillow

# Expose web GUI
EXPOSE 6800

CMD [ "scrapyd" ]
