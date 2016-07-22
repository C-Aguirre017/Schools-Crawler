require 'nokogiri'
require 'rest-client'

require_relative 'methods.rb'

class School < Methods

  $host = "http://www.mime.mineduc.cl/"
  $xpath = "//*[@id='busqueda_avanzada']/tbody/tr"
  $directory = './results'

  def start_crawler(region,comuna,file_name)
    begin

      #Iniciar para Obtener Cookies
      params = {'region': region.to_s, 'comuna': comuna.to_s, 'dependencia': '0', 'tipoEns': '0' }
      res = Post($host + 'mime-web/mvc/mime/busqueda_avanzada/','', 'Primera', params , 1)

      return get_table(res,2,file_name)

    rescue Exception => e
      puts "[!] Error al intentar hacer consulta: " + e.to_s
      puts "[*] Reintentando"
      start_crawler(region,comuna,file_name)
    end

  end

  def get_table(res,count,file_name)
    tab = ""
    count.times { tab += "\t " }

    doc = Nokogiri::HTML(res)
    tr = doc.xpath($xpath)

    f = File.new($directory + file_name, "w")
    if tr.size > 0
      tr[0..-1].each do |school|
        get_school_info(school,f,4)
        puts ""
      end
    end

    f.close()
    return true
  end

  def get_school_info(school,f,count)
    tab = ""
    count.times { tab += "\t " }

    name = ''
    money = ''
    type = ''

    begin
      rows = "\t\t"
      special_number = -1

      school.xpath('td').each_with_index do |td,i|
          rows += td.content.strip + "\t"
          if i == 1
            special_number = td.content.strip.match(/\[.*\]/)[0].sub!('[', '').sub!(']', '')
            name = td.content.strip.match(/.*\[/)[0].sub!('[', '').strip
          elsif i == 2
            money = td.content.strip
          else i == 3
            type = td.content.strip
          end
      end
      puts rows

      res2 = Post($host + 'mime-web/mvc/mime/ficha',
                        $host+ 'mime-web/mvc/mime/busqueda_avanzada/', 'Segunda',
                       {"rbd" => special_number.to_s}, 3)

      doc2 = Nokogiri::HTML(res2)
      data = doc2.xpath('//td[text()="Mapa:"]/../../tr')


      if data.size > 0
        address = data[0].xpath('td')[1].content.strip
        comuna = data[2].xpath('td')[1].content.strip
        telephone = data[3].xpath('td')[1].content.strip
        email = data[4].xpath('td')[1].content.strip
        web_page = data[5].xpath('td')[1].content.strip
        director = data[6].xpath('td')[1].content.strip

        f.puts(name + '|' + type + '|' + director + '|' + telephone + '|' + email + '|' + money + '|' + address + '|' + comuna + '|' + web_page)
        puts tab + "[+] Centro Añadido "
      end

    rescue Exception => e
      puts tab + '[!] Error: ' + e.to_s
      puts tab + '[*] Reintentando!'
      get_school_info(school,f,count)
    end
  end

  def join_files
    file_name = './all_schools.txt'
    puts "[+] Creating " + file_name.to_s

    f = File.new(file_name, 'w')
    f.puts('Name|Type|Director|Telephone|Email|Money|Address|Comuna|Web Page')
    Dir.foreach($directory) do |file|
      next if file == '.' or file == '..'

      aux_file = File.open($directory + '/' + file.to_s, 'r')
      f.puts(aux_file.read)
      aux_file.close
    end
    f.close()

    puts '[!] File ' + file_name + ' Created Succesfully'
  end
end

#Region, Numero, Comunas
regions = [[ 1, 'Tarapaca', [1101,1107,1401,1402,1403,1404,1405]],
          [ 2, 'Antofagasta', [2101,2102,2103,2104,2201,2202,2203,2301,2302]],
          [ 3, 'Atacama', [3101,3102,3103,3201,3202,3301,3302,3303,3304]],
          [ 4, 'Coquimbo', [*4101..4106,*4201..4204,*4301..4305]],
          [ 5, 'Valparaiso', [*5101..5109,5201,*5301..5304,*5401..5405,*5501..5506,*5601..5606,*5701..5706,*5801..5804]],
          [ 6, "Libertador Bernardo OHiggins", [*6101..6117,*6201..6206,*6301..6310]],
          [ 7, 'Maule', [*7101..7110,*7201..7203,*7301..7309,*7401..7408]],
          [ 8, 'BioBio',[*8101..8112,*8201..8207,*8301..8314,*8401..8421]],
          [ 9, 'La Araucania', [*9101..9121,*9201..9211]],
          [ 10, 'Los lagos', [*10101..10109,*10201..10210,*10301..10307,*10401..10404] ],
          [ 11, 'Aysen del General Carlos Ibanez del Campo', [11101,11102,*11201..11203,*11301..11303,11401,11402]],
          [ 12, 'Magallanes y la Antartica Chilena', [*12101..12104,*12201..12202,*12301..12303,12401,12402]],
          [ 13, 'Metropolitana de Stgo.', [*13101..13132,*13201..13203,*13301..13303,*13401..13404,*13501..13505,*13601..13605]],
          [ 14, 'De los Rios', [*14101..14108,*14201..14204]],
          [ 15, 'De Arica y Parinacota', [15101,15102,15201,15202]]]


puts '[+] Realizando Busqueda Emails Colegios de Stgo'
crawler = School.new

puts '[?] Which region you want to select for the crawler'
puts '-1 => To Join all the files'
regions.each_with_index do |region,i|
  puts i.to_s + ' => ' + region[1].to_s
end
puts 'Please submit your answer'
region_chosen = gets.chomp

begin

  if region_chosen.to_i == -1
    crawler.join_files

  else
    regions[region_chosen.to_i][2].each do |comuna|
      puts '[+] Buscando en ' + regions[region_chosen.to_i][1].to_s + ' => ' + comuna.to_s
      crawler.start_crawler(regions[region_chosen.to_i][0],comuna,"/" + regions[region_chosen.to_i][1].to_s + '_' + comuna.to_s + '.txt')
    end
  end

rescue Exception => e
  puts "[!] Error: " + e.to_s
end
#end
