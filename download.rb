#!/usr/bin/ruby

require 'json'
require 'net/http'
require 'fileutils'
require 'uri'

class Downloader
  @@downloadRoot = './download/'
  @@comicId = nil
  @@name_with_index = false

  def download(host, path, filename, referer, dest, index, total)
    uri = URI("#{host}#{path}#{filename}")

    req = Net::HTTP::Get.new(uri)
    req['Referer'] = referer
    req['User-Agent'] = randomUA()

    #start download
    res = Net::HTTP.start(uri.hostname, uri.port) { |http|
      http.request(req)
    }

    #save to file
    #if filename.downcase.end_with? '.png'
    #  filename = filename.split('.')
    #  filename[filename.length-1] = 'jpg'
    #  filename = filename.join('.')
    #end
    filename = "#{(index+1).to_s.rjust(total.to_s.length,'0')}|#{filename}" if @@name_with_index
    filename = URI.unescape filename
    open "#{@@downloadRoot}#{dest}/#{filename}", 'w' do |io|
      io.write res.body
    end if res.is_a?(Net::HTTPSuccess)

    puts "Download error: #{path}#{filename}, referer: #{referer}, dest: #{dest}" if !res.is_a?(Net::HTTPSuccess)
  end

  def randomUA
    useragents = [
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30)',
        'Googlebot/2.1 (http://www.googlebot.com/bot.html)',
        'Opera/9.20 (Windows NT 6.0; U; en)',
        'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.1.1) Gecko/20061205 Iceweasel/2.0.0.1 (Debian-2.0.0.1+dfsg-2)',
        'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 5.1; Trident/4.0; FDM; .NET CLR 2.0.50727; InfoPath.2; .NET CLR 1.1.4322)',
        'Opera/10.00 (X11; Linux i686; U; en) Presto/2.2.0',
        'Mozilla/5.0 (Windows; U; Windows NT 6.0; he-IL) AppleWebKit/528.16 (KHTML, like Gecko) Version/4.0 Safari/528.16',
        'Mozilla/5.0 (compatible; Yahoo! Slurp/3.0; http://help.yahoo.com/help/us/ysearch/slurp)',
        'Mozilla/4.0 (compatible; MSIE 9.0; Windows NT 5.1; Trident/5.0)',
        'Mozilla/5.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
        'Mozilla/4.0 (compatible; MSIE 7.0b; Windows NT 6.0)',
        'Mozilla/5.0 (Windows; U; Windows NT 6.1; ru; rv:1.9.2.3) Gecko/20100401 Firefox/4.0 (.NET CLR 3.5.30729)',
        'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.8) Gecko/20100804 Gentoo Firefox/3.6.8',
        'Mozilla/5.0 (X11; U; Linux x86_64; en-US; rv:1.9.2.7) Gecko/20100809 Fedora/3.6.7-1.fc14 Firefox/3.6.7',
        'Mozilla/5.0 (compatible; Yahoo! Slurp; http://help.yahoo.com/help/us/ysearch/slurp)',
        'YahooSeeker/1.2 (compatible; Mozilla 4.0; MSIE 5.5; yahooseeker at yahoo-inc dot com ; http://help.yahoo.com/help/us/shop/merchant/)'
    ];
    return useragents[Random.rand(0..useragents.length)]
  end


  @@name_with_index = ARGV.length > 0 ? ARGV[0] == '--name-with-index' : false
  comic = JSON.parse(File.read('download/chapters.json'))
  @@comicId = comic['comicId']
  @@downloadRoot += "#{@@comicId}/"

  chapters = comic['chapters']

  chapters.each_with_index { |chapter, index|
    chapter['dest'] = "#{(index+1).to_s.rjust(chapters.length.to_s.length,'0')}|#{chapter['dest']}" if @@name_with_index
    total = chapter['images'].length

    if File.directory?("#{@@downloadRoot}#{chapter['dest']}")
      puts "#{chapter['dest']} downloaded, skip."
      next
    end

    puts "Downloading: #{chapter['dest']}..."

    FileUtils.mkdir_p "#{@@downloadRoot}#{chapter['dest']}"
    chapter['images'].each_with_index { |image, index|
      Downloader.new.download chapter['host'], chapter['path'], image, chapter["referer"], chapter['dest'], index, total
    }
  }
  puts 'Download complete.'

end
