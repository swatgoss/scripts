@echo off
:start
cls
echo.
echo DOS Benchmark Pack (PhilsComputerLab)
echo. 
echo 1) 3DBench 1.0 (Slower PCs)        2) 3DBench 1.0c (Faster PCs)
echo 3) Chris's 3D Benchmark            4) Chris's 3D Benchmark 640x480
echo 5) PC Player Benchmark             6) PC Player Benchmark 640x480
echo.
echo a) Doom min. details (Slower PCs)  b) Doom max. details (Faster PCs)
echo c) Quake demo1     320x200 mode  0 d) Quake demo1     320x200 mode  1
echo e) Quake demo1     640x480 mode 11 f) Quake demo1     800x600 mode 14
echo g) Quake demo1    1024x768 mode 20 h) Quake demo1    1280x960 mode 25
echo.
echo k) System Information 8.0          l) Landmark System Speed Test 6.00
echo m) TOPBENCH 3.8                    n) Speedsys 4.78
echo.
echo s) CHKCPU (CPU ID tool)            t) CACHECHK (Cache ID tool)
echo u) MTRRLFBE (VGA boost)            v) FASTVID (VGA boost)
echo.
echo z) Quit back to DOS                ?) Readme / Information
echo.
choice /n /c:123456789abcdefghijklmnopqrstuvwxy?z Please enter option: 

if errorlevel==36 goto end
if errorlevel==35 goto readme
if errorlevel==34 goto start
if errorlevel==33 goto start
if errorlevel==32 goto start
if errorlevel==31 goto fastvid
if errorlevel==30 goto mtrrlfbe
if errorlevel==29 goto cachechk
if errorlevel==28 goto chkcpu
if errorlevel==27 goto start
if errorlevel==26 goto start
if errorlevel==25 goto start
if errorlevel==24 goto start
if errorlevel==23 goto speedsys
if errorlevel==22 goto topbench
if errorlevel==21 goto lm6
if errorlevel==20 goto si8
if errorlevel==19 goto start
if errorlevel==18 goto start
if errorlevel==17 goto quake25
if errorlevel==16 goto quake20
if errorlevel==15 goto quake14
if errorlevel==14 goto quake11
if errorlevel==13 goto quake1
if errorlevel==12 goto quake0
if errorlevel==11 goto doom
if errorlevel==10 goto doommin
if errorlevel==9 goto start
if errorlevel==8 goto start
if errorlevel==7 goto start
if errorlevel==6 goto pcpb2
if errorlevel==5 goto pcpb
if errorlevel==4 goto chrisb2
if errorlevel==3 goto chrisb
if errorlevel==2 goto 3dbench2
if errorlevel==1 goto 3dbench

:readme
cls
more readme.txt
pause
goto start

:fastvid
cd marks
cd fastvid
cls
fastvid
pause
cd..
cd..
goto start

:mtrrlfbe
cd marks
cd mtrrlfbe
cls
mtrrlfbe.exe vga wc
mtrrlfbe.exe lfb wc
pause
cd..
cd..
goto start

:cachechk
cd marks
cd cachechk
cls
cachechk
pause
cd..
cd..
goto start

:chkcpu
cd marks
cd chkcpu
cls
chkcpu
pause
cd..
cd..
goto start

:speedsys
cd marks
cd speedsys
speedsys
cd..
cd..
goto start

:topbench
cls
cd marks
cd topbench
topbench -l
cd..
cd..
goto start
                                      
:lm6
cd marks
cd lm60
lm60
cd..
cd..
goto start

:si8
cd marks
cd si8
sysinfo
cd..
cd..
goto start

:quake25
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode25.cfg -nosound -nocdaudio
cd..
cd..
goto start

:quake20
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode20.cfg -nosound -nocdaudio
cd..
cd..
goto start

:quake14
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode14.cfg -nosound -nocdaudio
cd..
cd..
goto start

:quake11
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode11.cfg -nosound -nocdaudio
cd..
cd..
goto start
                                      
:quake1
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode1.cfg -nosound -nocdaudio
cd..
cd..
goto start

:quake0
cd marks
cd quakes
quake.exe +timedemo demo1 +exec mode0.cfg -nosound -nocdaudio
cd..
cd..
goto start

:doom
cd marks
cd dooms
doom -config max.cfg -timedemo demo3
pause
cd..
cd..
goto start

:doommin
cd marks
cd dooms
doom -config min.cfg -timedemo demo3
pause
cd..
cd..
goto start

:wolf3d
cd marks
cd wolf3d
wolf_286 timedemo
cd..
cd..
goto start

:pcpb2
cd marks
cd pcpbench
pcpbench 101
cd..
cd..
goto start

:pcpb
cd marks
cd pcpbench
pcpbench/vgamode
cd..
cd..
goto start


:chrisb2
cd marks
cd chrisb
svgabnch
pause
cd..
cd..
goto start
     
:chrisb
cd marks
cd chrisb
bench
pause
cd..
cd..
goto start

:3dbench2
cd marks
cd 3dbench2
3dbench2
cd..
cd..
goto start


:3dbench
cd marks
cd 3dbench
3dbench
cd..
cd..
goto start



:end
