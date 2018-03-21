############################################################
#
#  Name:        William Grishko
#  Assignment:  Web Crawler
#  Date:        05/22/2017
#  Class:       CIS 283
#  Description: A program that crawls a website, capturing links
#
############################################################

require 'net/https'
require 'prawn'
require_relative 'linkchecker.rb'

def pdf_print_header(website, link_count)
  move_down 20
  font 'Helvetica', :size => 12
  text "Website: #{website}", :align => :center, :size => 28
  text "Number of Links: #{link_count}", :align => :center, :size => 22
  move_down 15
end

def pdf_print_sites(heading, link_source_and_code)
  text heading, :size => 14, :style => :bold
  move_down 5
  counter = 1
  link_source_and_code.each do |link|
    formatted_text([{:text => "#{counter}. "}, {:text => "#{link.click_value.encode("Windows-1252", "UTF-8", invalid: :replace, undef: :replace)}".strip, :styles => [:underline], :color => rgb='0645AD', :link => "#{link.hyperlink}"}, {:text => "  #{link.to_s}"}])
    counter += 1
  end
  move_down 15
end


link_checker = LinkChecker.new(website = ARGV[0])

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

Net::HTTP.get_response(website, '/').body.scan(/<a.*?href=["'](.*?)["'].*?>(.*?)<\/a>/m).each { |link, text|
  link_checker.add_link(Link.new(link, text))
}
link_checker.check_links


Prawn::Font::AFM.hide_m17n_warning = true
# Create PDF to display all links
Prawn::Document.generate("#{link_checker.base_url}.pdf") do

  pdf_print_header(link_checker.base_url, link_checker.links.count)

  # Print valid urls
  pdf_print_sites("Valid URL's", link_checker.get_sorted_links_by_code(200..299))

  # Print redirected urls
  pdf_print_sites("Redirected URL's", link_checker.get_sorted_links_by_code(300..399))

  # Print invalid urls
  pdf_print_sites("Invalid URL's", link_checker.get_sorted_links_by_code(400..599))

end


# Create PDF to display 404 links
Prawn::Document.generate("#{link_checker.base_url}-404s.pdf") do

  pdf_print_header(link_checker.base_url, link_checker.get_sorted_links_by_code(404).count)

  # Print 404 links
  pdf_print_sites("404 URLS's", link_checker.get_sorted_links_by_code(404))

end