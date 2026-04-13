# 生成: set > env.txt
include env.txt 
#export PATH=$(Path)

DD    = ddisasm
gtirb = gtirb-pprinter
link  = link
ml    = ml
cc    = cl


libs = kernel32.lib user32.lib gdi32.lib advapi32.lib ole32.lib winmm.lib ddraw.lib dsound.lib msacm32.lib imm32.lib ucrt.lib vcruntime.lib
libpath = C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22000.0\um\x86
SRCS := $(wildcard src/*.S)
C_SRC = $(wildcard src/*.c)
C_OBJECTS = $(patsubst src/%.c, %.obj, $(C_SRC))

first_target: build copygame


bio2.gtirb: bio2.exe
	$(DD) bio2.exe --ir bio2.gtirb --debug-dir ./bio2-dd-info/
	
bio2.S: bio2.gtirb
	$(gtirb) bio2.gtirb --asm bio2.S

# To avoid accidental overwriting, it must be renamed.
asm: bio2.S


main.obj: main.S $(SRCS) 
	$(ml) //c //coff main.S //Fo main.obj //Zi //Zd
	
bio2re.exe: main.obj $(C_OBJECTS)
	$(link) //SUBSYSTEM:WINDOWS //ENTRY:_EntryPoint $(libs) $^ //OUT:bio2re.exe //LIBPATH:"$(libpath)"  //DEBUG
	
build: bio2re.exe


%.obj: src/%.c
	$(cc) //c //Zi //Od $<



copygame: bio2re.exe
	cp -f bio2re.exe bio2re.pdb bio2game\
	
run: first_target
	bio2game/bio2re.exe
  
test:
	echo $(PATH)
  
check_tool:
	$(DD)    --version
	$(gtirb) --version
	$(link)  //help | findstr 'Microsoft (R) Incremental Linker Version'
	$(ml)    //help | findstr 'Microsoft (R) Macro Assembler Version'
  
create_env: check_tool
	echo Not implement...

.PHONY: clean build asm first_target copygame test check_tool create_env