# encoding: utf-8
class Helpers
  def initialize(context, path)
    @context = context
    @depth = path.scan('/').count
    @regions_hash={}
  end

  attr_reader :context

  def content_for(region, &blk)  
    @regions_hash[region] = blk.call
  end
  
  def relative(link)
    '../'*@depth+link
  end

  def partial(template, options = {})
    context.haml("_#{template}").render(self, Mash.new(options))
  end

  def to_filename(text)
    context.make_filename(text)
  end

  def [](region)
    @regions_hash[region]
  end

  def userpic_path(userid)
    relative(context.path_("images/userpics/#{userid}.jpg"))
  end

  def thumbnail_path(url)
    local_img?(url) ?
      relative(context.path_("images/media/thumbnails/#{url.sub(%r{.+/}, '')}.jpg")) :
      url
  end

  def image_path(url)
    if local_img?(url)
      @image_map ||= File.read(context.json_path('images.tsv')).split("\n").
                  map{|ln| ln.split("\t")}.to_h

      fname = @image_map[url] or
        fail("Картинка #{url} не скачана!")

      relative(context.path_("images/media/#{fname}"))
    else
      url
    end
  end

  private

  def local_img?(url)
    url.include?('http://m.friendfeed-media.com/') ||
        url.include?('http://i.friendfeed.com/')
  end
end