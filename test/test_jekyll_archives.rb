require 'helper'

class TestJekyllArchives < Minitest::Test
  context "the jekyll-archives plugin" do
    setup do
      @site = fixture_site
      @site.read
      @archives = Jekyll::Archives.new(@site.config)
    end

    should "generate archive pages by year" do
      @archives.generate(@site)
      assert archive_exists? @site, "/2014/"
      assert archive_exists? @site, "/2013/"
    end

    should "generate archive pages by month" do
      @archives.generate(@site)
      assert archive_exists? @site, "/2014/08/"
      assert archive_exists? @site, "/2014/03/"
    end

    should "generate archive pages by day" do
      @archives.generate(@site)
      assert archive_exists? @site, "/2014/08/17/"
      assert archive_exists? @site, "/2013/08/16/"
    end

    should "generate archive pages by tag" do
      @archives.generate(@site)
      assert archive_exists? @site, "/tag/test-tag/"
      assert archive_exists? @site, "/tag/tagged/"
      assert archive_exists? @site, "/tag/new/"
    end

    should "generate archive pages by category" do
      @archives.generate(@site)
      assert archive_exists? @site, "/category/plugins/"
    end

    should "generate archive pages with a layout" do
      @site.process
      assert_equal "Test", read_file("/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives plugin with custom layout path" do
    setup do
      @site = fixture_site({
        "jekyll-archives" => {
          "layout" => "archive-too"
        }
      })
      @site.process
    end

    should "use custom layout" do
      assert_equal "Test too", read_file("/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives plugin with type-specific layout" do
    setup do
      @site = fixture_site({
        "jekyll-archives" => {
          "layouts" => {
            "year" => "archive-too"
          }
        }
      })
      @site.process
    end

    should "use custom layout for specific type only" do
      assert_equal "Test too", read_file("/2014/index.html")
      assert_equal "Test too", read_file("/2013/index.html")
      assert_equal "Test", read_file("/tag/test-tag/index.html")
    end
  end

  context "the jekyll-archives plugin with custom permalinks" do
    setup do
      @site = fixture_site({
        "jekyll-archives" => {
          "permalinks" => {
            "year" => "/year/:year/",
            "tag" => "/tag-:name.html",
            "category" => "/category-:name.html"
          }
        }
      })
      @site.process
    end

    should "use the right permalink" do
      assert archive_exists? @site, "/year/2014/"
      assert archive_exists? @site, "/year/2013/"
      assert archive_exists? @site, "/tag-test-tag.html"
      assert archive_exists? @site, "/tag-new.html"
      assert archive_exists? @site, "/category-plugins.html"
    end
  end

  context "the archives" do
    setup do
      @site = fixture_site
      @site.process
    end

    should "populate the {{ site.archives }} tag in Liquid" do
      assert_equal 12, read_file("/length.html").to_i
    end
  end
end
