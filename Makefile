# 生成: set > env.txt
include env.txt 

DD    = ddisasm
gtirb = gtirb-pprinter
link  = link
ml    = ml


libs = kernel32.lib user32.lib gdi32.lib advapi32.lib ole32.lib winmm.lib ddraw.lib dsound.lib msacm32.lib imm32.lib
libpath = C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86

first_target: build mv


bio2.gtirb: bio2.exe
	$(DD) bio2.exe --ir bio2.gtirb --debug-dir ./bio2-dd-info/
	
bio2.S: bio2.gtirb
	$(gtirb) bio2.gtirb --asm bio2.S
	
asm: bio2.S


bio2.fixed.obj: bio2.fixed.S
	$(ml) //c //coff bio2.fixed.S //Fo bio2.fixed.obj //Zi
	
bio2.fixed.exe: bio2.fixed.obj
	$(link) //SUBSYSTEM:WINDOWS //ENTRY:_EntryPoint $(libs) bio2.fixed.obj //OUT:bio2.fixed.exe //LIBPATH:"$(libpath)"  //DEBUG
	
build: bio2.fixed.exe


mv: bio2.fixed.exe
	cp -f bio2.fixed.exe bio2game\
	
run: first_target
	bio2game/bio2.fixed.exe


.PHONY: clean build asm first_target mv