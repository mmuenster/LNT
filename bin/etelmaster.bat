%~d0
cd \lnt\bin
set path=%~d0\LNT\lib\phantomjs;%~d0\LNT\lib\python\app
%~d0\LNT\lib\casperjs\bin\casperjs.exe %~d0\LNT\bin\firebase_casper.js %1 %2
pause
