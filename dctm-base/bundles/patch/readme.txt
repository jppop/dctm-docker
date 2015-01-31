Run patch installer with the command below:

Windows: patch.exe LAX_VM <full_path_to_java_executable>
Linux  : patch.bin LAX_VM <full_path_to_java_executable>

Replace <full_path_to_java_executable> with the java executable location. The java used must be of version 1.6+.
Double quote the full name of the java if it contains space in the directory path. You can use a 32 or 64 bit java to run patch installer.

Example: 
For Content Server:
patch.exe LAX_VM "C:\Documentum\java64\1.7.0.17\jre\bin\java.exe"
For xPlore:
patch.exe LAX_VM C:\xPlore\jdk\jre\bin\java.exe

Note: Ensure that you do not rename patch.bin (exe) to run the patch installer.
