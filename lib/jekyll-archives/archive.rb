module Jekyll
  class Archive
    include Convertible

    attr_accessor :posts, :type, :name, :slug
    attr_accessor :data, :content, :output
    attr_accessor :path, :ext
    attr_accessor :site

    # Attributes for Liquid templates
    ATTRIBUTES_FOR_LIQUID = %w[
      posts
      type
      name
    ]

    # Initialize a new Archive page
    #
    # site  - The Site object.
    # name  - The name of the tag/category or a Hash of the year/month/day in case of date.
    #           e.g. { :year => 2014, :month => 08 } or "my-category" or "my-tag".
    # type  - The type of archive. Can be one of "year", "month", "day", "category", or "tag"
    # posts - The array of posts that belong in this archive.
    def initialize(site, name, type, posts)
      @site   = site
      @posts  = posts
      @type   = type
      @name   = name
      @config = site.config['jekyll-archives']

      # Generate slug if tag or category (taken from jekyll/jekyll/features/support/env.rb)
      if name.is_a? String
        @slug = name.split(" ").map { |w|
          w.downcase.gsub(/[^\w]/, '')
        }.join("-")
      end

      # Use ".html" for file extension and url for path
      @ext  = ".html"
      @path = url

      @data = {
        "layout" => layout
      }
      @content = ""
    end

    # The template of the permalink.
    #
    # Returns the template String.
    def template
      @config['permalinks'][type]
    end

    # The layout to use for rendering
    #
    # Returns the layout as a String
    def layout
      if @config['layouts'] && @config['layouts'][type]
        @config['layouts'][type]
      else
        @config['layout']
      end
    end

    # Returns a hash of URL placeholder names (as symbols) mapping to the
    # desired placeholder replacements. For details see "url.rb".
    def url_placeholders
      if @name.is_a? Hash
        @name.merge({ :type => @type })
      else
        { :name => @slug, :type => @type }
      end
    end

    # The generated relative url of this page. e.g. /about.html.
    #
    # Returns the String url.
    def url
      @url ||= URL.new({
        :template => template,
        :placeholders => url_placeholders,
        :permalink => nil
      }).to_s
    rescue ArgumentError
      raise ArgumentError.new "Template \"#{template}\" provided is invalid."
    end

    # Add any necessary layouts to this post
    #
    # layouts      - The Hash of {"name" => "layout"}.
    # site_payload - The site payload Hash.
    #
    # Returns nothing.
    def render(layouts, site_payload)
      payload = Utils.deep_merge_hashes({
        "page" => to_liquid
      }, site_payload)

      do_layout(payload, layouts)
    end

    # Convert this Convertible's data to a Hash suitable for use by Liquid.
    #
    # Returns the Hash representation of this Convertible.
    def to_liquid(attrs = nil)
      further_data = Hash[(attrs || self.class::ATTRIBUTES_FOR_LIQUID).map { |attribute|
        [attribute, send(attribute)]
      }]

      Utils.deep_merge_hashes(data, further_data)
    end

    # Obtain destination path.
    #
    # dest - The String path to the destination dir.
    #
    # Returns the destination file path String.
    def destination(dest)
      @dest ||= dest
      path = Jekyll.sanitized_path(dest, URL.unescape_path(url))
      path = File.join(path, "index.html") if url =~ /\/$/
      path
    end

    # Obtain the write path relative to the destination directory
    #
    # Returns the destination relative path String.
    def relative_path
      path = Pathname.new(destination(@dest)).relative_path_from Pathname.new(@dest)
      path
    end

    # Returns the object as a debug String.
    def inspect
      "#<Jekyll:Archive @type=#{@type.to_s} @name=#{@name}>"
    end

    # Returns the Boolean of whether this Page is HTML or not.
    def html?
      true
    end
  end
end
