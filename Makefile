
DD = D:/GAME/bio2/ddisasm/bin/ddisasm
gtirb = D:/GAME/bio2/ddisasm/bin/gtirb-pprinter


bio2.gtirb: bio2.exe
  $(DD) bio2.exe --ir bio2.gtirb --debug-dir ./bio2-dd-info/
  
bio2.S