cd $PSScriptRoot

echo "create .cargo/config"
$lfText = "[target.armv7-unknown-linux-gnueabihf]`nlinker = `"arm-unknown-linux-gnueabihf-gcc`"`nrustflags = [`"-C`", `"link-arg=-fuse-ld=gold`", `"--remap-path-prefix`", `"$env:USERPROFILE=~`"]`n`n[target.x86_64-pc-windows-msvc]`nrustflags = [`"-C`", `"target-feature=+crt-static`", `"--remap-path-prefix`", `"$env:USERPROFILE=~`"]`n`n[profile.release]`nstrip = true`n"
$lfText = $lfText.Replace("\","\\")
Set-Content -Path "config" $lfText -NoNewline
#Set-Content -Path "config" "[target.armv7-unknown-linux-gnueabihf]`nlinker = `"arm-unknown-linux-gnueabihf-gcc`"`nrustflags = [`"-C`", `"link-arg=-fuse-ld=gold`", `"--remap-path-prefix`", `"$env:USERPROFILE=~`"]`n`n[target.x86_64-pc-windows-msvc]`nrustflags = [`"-C`", `"target-feature=+crt-static`", `"--remap-path-prefix`", `"$env:USERPROFILE=~`"]`n`n[profile.release]`nstrip = true`n" -NoNewline

echo "download toolchain for Miyoo mini on Windows"
if (!(Test-Path ".\buildroot_gcc8.2.1_armv7_Windows.7z"))
{
	curl.exe -LO https://github.com/bluexe203/crosstool-builder/releases/download/v0.10/buildroot_gcc8.2.1_armv7_Windows.7z
}

echo "download SDL lib for Miyoo mini"
if (!(Test-Path ".\openbor_20220422.zip"))
{
	curl.exe -LO https://github.com/steward-fu/archives/releases/download/miyoo-mini/bin_openbor_20220422.zip
}

echo "download SDL lib for Windows"
if (!(Test-Path ".\SDL2-devel-2.24.0-VC.zip"))
{
	curl.exe -LO https://github.com/libsdl-org/SDL/releases/download/release-2.24.0/SDL2-devel-2.24.0-VC.zip
}

echo "download parasyte"
if (!(Test-Path ".\parasyte_20220125.zip"))
{
	curl.exe -LO https://github.com/steward-fu/archives/releases/download/miyoo-mini/bin_parasyte_20220125.zip
}

echo "extract lib"
if (!(Test-Path ".\openbor"))
{
	Expand-Archive -Path .\openbor_20220422.zip -DestinationPath .\
}
if (!(Test-Path ".\SDL2-2.24.0"))
{
	Expand-Archive -Path .\SDL2-devel-2.24.0-VC.zip -DestinationPath .\
}

echo "extract toolchain"
if (!(Test-Path "C:\buildroot"))
{
	$7zipPath = &{$env:ProgramFiles}
	$7zipPath += "\7-Zip\7z.exe"
	& $7zipPath x .\buildroot_gcc8.2.1_armv7_Windows.7z "-oC:\\" -y
}

echo "setup path"
$tmpUserPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
if (!($tmpUserPath.IndexOf(";C:\buildroot\bin", 0) -ge 0))
{
	echo "add path"
	$tmpUserPath += ";C:\buildroot\bin"
	[System.Environment]::SetEnvironmentVariable("Path", $tmpUserPath, "User")
}

echo "copy library to .rustup"
Copy-Item -Path .\openbor\lib\libSDL2-2.0.so.0 -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\armv7-unknown-linux-gnueabihf\lib\libSDL2.so -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2.dll -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\lib\SDL2.dll -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2.dll -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\bin\SDL2.dll -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2.dll -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\bin\SDL2.dll -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2.lib -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\lib\SDL2.lib -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2main.lib -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\lib\SDL2main.lib -Force
Copy-Item -Path .\SDL2-2.24.0\lib\x64\SDL2test.lib -Destination $env:USERPROFILE\.rustup\toolchains\stable-x86_64-pc-windows-msvc\lib\rustlib\x86_64-pc-windows-msvc\lib\SDL2test.lib -Force

echo "copy config to .cargo"
Copy-Item -Path $env:USERPROFILE\.cargo\config -Destination $env:USERPROFILE\.cargo\config.bak
Copy-Item -Path .\config -Destination $env:USERPROFILE\.cargo\config -Force
