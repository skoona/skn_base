# views/sitemap.builder

xml.instruct!

xml.urlset(
    :"xmlns:xsi"          => "http://www.w3.org/2001/XMLSchema-instance",
    :"xsi:schemaLocation" => "http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd",
    :xmlns                => "http://www.sitemaps.org/schemas/sitemap/0.9"
) do
  xml.url do
    xml.loc "http://localhost:9292/"
    xml.changefreq "daily"
    xml.priority "1"
  end

  xml.url do
    xml.loc "http://localhost:9292/about"
    xml.changefreq "monthly"
    xml.priority "0.5"
  end

  # @posts.each do |post|
  #   xml.url do
  #     xml.loc "http://localhost:9292/posts/#{post.id}"
  #     xml.lastmod post.updated_at.iso8601
  #     xml.changefreq "weekly"
  #     xml.priority "0.7"
  #   end
  # end
end
