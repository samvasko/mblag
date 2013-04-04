require 'redcarpet'
require 'rainbow'
# Samuel Vasko 2013 (I should be learinig Dynamics right now)

# Generate index file if there is one use that
# just place $content where stuff will be dumped
$faux = "<!DOCTYPE html>\n<html>\n<head>\n    <meta charset=\"utf-8\">\n    <title></title>\n</head>\n<body>\n    $content\n</body>\n</html>"

unless File.exists?('template_index.html')
	# Generate like the most simple html template
	index = File.new('template_index.html', 'w')
	index.write($faux)
	index.close

	puts 'Index created, you are ready to write stuff'.color(:green)
end

unless File.exists?('template_post.html')
	template = File.new('template_post.html', 'w')
	template.write($faux)
	template.close()

	puts "Template file created".color(:green)
end

#dirs && stuff
$posts = 'posts'			# Freshly baked htmls will go here
$markdowns = 'markdown'		# The files that will used to generate shit
$home = Dir.pwd
headings = []				# When generating index
$content_regex = /^\s*\$content\s*$/

$template_index = File.read("template_index.html")
$template_post = File.read("template_post.html")


Dir.mkdir($posts) unless Dir.exists?($posts)
# Filenames will be used to generate urls
Dir.mkdir($markdowns) unless Dir.exists?($markdowns)

# Ok now when we have boring stuff out the way, lets look into generating actual content

# Look into the markdown folder
files = Dir.entries($markdowns);
files = files.drop(2);

if files.empty?
	puts 'No files... at all? cmon I will make a sample for you'
	hello = File.new($markdowns+'/hello_human.md', 'w');
	hello.write("# Hello world is such a oboxious phrase \n some other stuff")
	hello.close()
	files.push('hello_human.md')
end

# Set up our awesome markdown converter
$convert = Redcarpet::Markdown.new(
	Redcarpet::Render::HTML,
	:autolink => true,
	:space_after_headers => true,
	:no_intra_emphasis => true,
	:superscript => true,
	:tables => true,
	:hard_wrap => true
)

# convert MD to HTML using template
def generate md
	html = $convert.render(md)
	return html
end

def writeHtml html, name
	Dir.chdir('posts')
	filename = name+'.html'
	html = $template_post.sub($content_regex, html)
	if File.exists?(filename)
		if File.read(filename) == html
			puts 'Not updating: '+name
			return false
		else
			File.unlink(filename)
		end
	end
	file = File.new(filename, 'w')
	file.write(html)
	file.close()
	Dir.chdir($home)
	puts 'Created html: '+name.color(:green)
end

puts "Checking files for changes \n \n"

files.each do |file|
	filename = file
	file = file.split('.')
	if /(?:^md$)|(?:^markdown$)|(?:^txt$)/ =~ file[1]
		Dir.chdir($home)
		md = File.read($markdowns+'/'+filename)
		md.scan(/^#\s?(.+)$/) { |match| headings.push([match[0], file[0]]) }
		# easy one, file is no existent just create it
		writeHtml(generate(md), file[0])
	end
end

# make links
insert = ''
headings.each do |head|
	insert += '<a href="'+$posts+'/'+head[1]+'.html">'+head[0]+"</a>\n"
end

# Now create index
Dir.chdir($home)
ind = $template_index.sub($content_regex, insert);

if File.exists?('index.html')
	File.unlink('index.html')
	File.open('index.html', 'w') { |f| f.puts ind }
end