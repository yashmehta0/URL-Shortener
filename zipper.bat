del  .\packages 

@echo Zipping URLShortener Lambda handler
cd URLShortenerLambda
"C:\Program Files\7-Zip\7z.exe" a -tzip "..\packages\shortener.zip" ".\handler.py"

@echo Zipping URLShortener Lambda handler
cd ../URLRedirectionLambda
"C:\Program Files\7-Zip\7z.exe" a -tzip "..\packages\redirect.zip" ".\handler.py"