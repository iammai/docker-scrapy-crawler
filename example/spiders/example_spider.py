import scrapy
from scrapy.contrib.spiders import CrawlSpider, Rule
from scrapy.contrib.linkextractors.sgml import SgmlLinkExtractor


from example.items import ExampleItem

class ExampleSpider(CrawlSpider):
    """
    This spider will try to crawl whatever is passed in `start_urls` which
    should be a comma-separated string of fully qualified URIs.

    Example: start_urls=http://localhost,http://example.com
    """
    def __init__(self, name=None, **kwargs):
        if 'start_urls' in kwargs:
            self.start_urls = kwargs.pop('start_urls').split(',')
        super(ExampleSpider, self).__init__(name, **kwargs)

    name = "example"

    """
    The spider will crawl links in the start_url but crawl only one level deep (follow=False) so that we do not go too deep
    with too much data
    """
    rules = (
        Rule(
            SgmlLinkExtractor(allow=()),
            callback='parse_page', follow=False
        ),
    )

    """
    Parse the images from the page grabbing
                - Image src (source url)
                - Page Url where image originated from
    """
    def parse_page(self, response):
        for sel in response.xpath('//img'):
            item = ExampleItem()
            item['img_src'] = sel.xpath('@src').extract()
            item["page_url"] = response.request.url
            yield item