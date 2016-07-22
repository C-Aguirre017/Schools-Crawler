require 'nokogiri'
require 'rest-client'

class Methods
  $cookies = {}

  def save_cookies(response)
    response.cookies.each { |k, v|
      $cookies[k] = v
    }
  end

  def print_cookies(tab)
    puts tab + "\t [-] Cookies: " + $cookies.to_s
  end

  def Get(url, iteracion, counter)

    #Mensaje
    tab = ""
    counter.times { tab += "\t " }

    if url.size > 118
      puts tab + '[+] ' + iteracion +' -> ' + url[56..118].to_s + " ..."
    else
      puts tab + '[+] ' + iteracion +' -> ' + url
    end

    response = RestClient.get(url, {:cookies => $cookies})

    if (response.code == 200)
      print_cookies(tab)
      save_cookies(response)
      response.to_s
    else
      puts 'Error'
    end
  end

  def Post(url, referer, iteracion, params, counter)
    #Mensaje
    tab = ""
    counter.times { tab += "\t " }

    if url.size > 118
      puts tab + '[+] ' + iteracion +' -> ' + url[56..118].to_s + " ..."
    else
      puts tab + '[+] ' + iteracion +' -> ' + url
    end

    response = RestClient::Request.execute(:method => :post,
                                           :url => url,
                                           :headers => {
                                               'Referer' => referer,
                                               'User-Agent' => 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/51.0.2704.103 Safari/537.36'
                                           },
                                           :payload => params,
                                           :cookies => $cookies,
                                           :timeout => 30
    )

    if (response.code == 200)
      print_cookies(tab)
      save_cookies(response)
      response.to_s
    else
      puts 'No Entro'
    end
  end



end
