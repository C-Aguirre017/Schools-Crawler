from lxml import html
import requests

#Region, Numero, Comunas
#values = [[ 1, 'Tarapaca', [1101,1107,1401,1402,1403,1404,1405]],
#          [ 2, 'Antofagasta', [2101,2102,2103,2104,2201,2202,2203,2301,2302]],
#          [ 3, 'Atacama', [3101,3102,3103,3201,3202,3301,3302,3303,3304]],
#          [ 4, 'Coquimbo', [1,6,1,4,1,5]],
#          [ 5, 'Valparaiso',
#          [ 6, "Libertador Bernardo O'Higgins", []],
#          [ 7, 'Maule'],
#          [ 8, 'BioBio'],
#          [ 9, 'La Araucanía'],
#          [ 10, 'Los lagos'],
#          [ 12, 'Magallanes y la Antartcia Chilena',
#          [ 13, 'Metropoloitana de Stgo.'],
#          [ 14, 'De los Rios'],
#          [ 15, 'De Arica y Parinacota']]

payload = {'region': '1', 'comuna': '1107', 'dependencia': '0', 'tipoEns': '0' }
url = "http://www.mime.mineduc.cl/mime-web/mvc/mime/busqueda_avanzada/"
res = requests.post(url, data = payload)

page = html.fromstring(res.content)
results = page.xpath('//*[@id="busqueda_avanzada"]/tbody/tr')

counter = 0
with open('salida.txt', 'a') as f:
    f.write(" Nombre del establecimiento | Mensualidad | Dependencia | Direccion | Comuna | Telefono | Email | Pagina Web | Director \n")
    for node in results:
        specialNumber = node.xpath('./td[2]/text()')[1].strip()
        specialNumber = specialNumber.replace("[","")
        specialNumber = specialNumber.replace("]","")

        name = node.xpath('./td[2]/a/text()')
        mensuality = node.xpath('./td[3]/text()')
        dependence = node.xpath('./td[4]/text()')

        print ("[+] " + str(counter) +") Nombre: " + str(name[0]) )

        if counter < 1 :
            #Going Deeper
            url = "http://www.mime.mineduc.cl/mime-web/mvc/mime/ficha"
            #payload = {'rbd' : '12605' }

            payload = "-----011000010111000001101001\r\nContent-Disposition: form-data; name=\"rbd\"\r\n\r\n"+ specialNumber +"\r\n-----011000010111000001101001--"
            headers = {
                'content-type': "multipart/form-data; boundary=---011000010111000001101001",
                'cache-control': "no-cache",
                }

            new_res = requests.request("POST", url, data=payload, headers=headers)

            print ("\n\n\n\n\n")
            print (new_res.text.encode('utf-8'))
            print ("\n\n\n\n\n")
            aux_page = html.fromstring(new_res.content)

            #new_results = aux_page.xpath('//html/body/div[1]/div/div[1]/div[3]/div[2]/div[1]/table/tbody/tr')
            new_results = aux_page.xpath('*//tr')

            print ("[+] Escribiendo Parametros ")

            adress = new_results[0].xpath('./td[0]/text()')
            comuna = new_results[0].xpath('./td[2]/text()')
            telephone = new_results[0].xpath('./td[3]/text()')
            email_contact = new_results[0].xpath('./td[4]/a/text()')
            web_page = new_results[0].xpath('./td[5]/a/text()')
            director = new_results[0].xpath('./td[6]/text()')

            print(name[0])
            #print(str(mensuality[0]))
            #print(str(dependence[0]))
            #print(str(adress[0]))
            #print(str(comuna[0]))
            print(str(telephone))
            print(str(email_contact))
            #print(str(web_page))
            print(str(director))

                #f.write( name[0] + '|' + mensuality[0] + '|' + dependence[0] + '|' +
                #         adress[0] + '|' + comuna[0] + '|' + telephone[0] + '|' +
                #         email_contact[0] + '|'  + web_page[0] + '|' + director[0] + "\n")

        counter = counter + 1

print ("Finish")
