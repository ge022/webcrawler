############################################################
#
#  Name:        William Grishko
#  Assignment:  Web Crawler
#  Date:        05/22/2017
#  Class:       CIS 283
#  Description: A program that crawls a website, capturing links
#
############################################################

class LinkChecker

  attr_accessor :links, :base_url

  def initialize(base_url)
    @@base_url, @base_url = base_url, base_url
    @links = []
  end

  def add_link(link)
    @links << link
  end

  def check_links
    @links.each do |link|
      link.check_link
    end
  end

  def get_sorted_links_by_code(code)
    arr = []
    @links.each { |link|
      arr << link if code === link.code.to_i
    }
    return arr.sort_by { |link| link.code }
  end

end


class Link < LinkChecker

  attr_accessor :link, :click_value, :link_type, :code, :hyperlink

  def initialize(link, click_value)
    @link = link
    @click_value = click_value
    @link_type = ''
    @code = '400'
    @hyperlink = '' # Save a click-able hyperlink to print to the pdf
  end

  def check_link
    # Set link type
    if link =~ /(\A\/?\/)|(\A#)|(\A(https?:\/\/)?#{@@base_url})/
      @link_type = 'Internal'
      # Set response code if link is internal and is valid
      if @link !~ /\A#\z/ # exclude '#' links
        if @link !~ /(\A\/?\/?https?:\/\/)|(\A\/\/#{@@base_url})/
          if @link =~ /\A\//
            @code = Net::HTTP.get_response(@@base_url, @link).code
            @hyperlink = URI.parse(@@base_url + @link)
          end
        else
          @code = Net::HTTP.get_response(URI.parse(@link.sub(/\A\/\//, 'https://'))).code # Replace the '//' in front of the url with a valid protocol
          @hyperlink = URI.parse(@link.sub(/\A\/\//, 'https://'))
        end
      else
        @hyperlink = URI.parse(@@base_url + '/' + @link)
      end
    else
      @hyperlink = @link
      @link_type = 'External'
    end
  end

  def full_tag # I could not use this with :inline_format => true, because it stripped all <'s in the click_value
    return "<a href='#{@link}'>#{@click_value}</a>"
  end

  def to_s
    return "Code: #{@code}  #{@link_type}"
  end

end