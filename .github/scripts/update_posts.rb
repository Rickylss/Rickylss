require 'httparty'
require 'nokogiri'
require 'octokit'

# Scrape blog posts from the website
url = "https://www.rickylss.site/"
response = HTTParty.get(url)
parsed_page = Nokogiri::HTML(response.body)
posts = parsed_page.css('article.post.post-type-')

# Generate the updated blog posts list (top 5)
posts_list = ["\n### Recent Blog Posts\n\n"]
posts.first(5).each do |post|
  title = post.css('h1.post-title').text.strip
  link = "https://www.rickylss.site#{post.at_css('a')[:href]}"
  posts_list << "* [#{title}](#{link})"
end

# puts posts_list

# Update the README.md file
client = Octokit::Client.new(access_token: ENV['GITHUB_TOKEN'])
repo = ENV['GITHUB_REPOSITORY']
readme = client.readme(repo)
readme_content = Base64.decode64(readme[:content]).force_encoding('UTF-8')

# readme = File.read('README.md')
# readme_content = readme.force_encoding('UTF-8')

# Replace the existing blog posts section
posts_regex = /### Recent Blog Posts\n\n[\s\S]*?(?=<\!\-\- placeholder \-\->)/m
updated_content = readme_content.sub(posts_regex, "#{posts_list.join("\n")}\n")

# puts updated_content

client.update_contents(repo, 'README.md', 'Update recent blog posts', readme[:sha], updated_content)