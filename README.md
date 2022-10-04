# Develop rust applications for Miyoo Mini on Windows

## Setup Rust

https://www.rust-lang.org/tools/install

Install

[Visual Studio C++ Build tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)

[Download rustup-init.exe (64-bit)](https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe)

※You need installed Rust in %USERPROFILE%/.rustup

rustup for armv7(for Miyoo mini)

```powershell
rustup target add armv7-unknown-linux-gnueabihf
```

## Setup Toolchain for Miyoo Mini

Download setup.ps1

Start powershell with admin

```powershell
.\setup.ps1
```

setup.ps1 executes the following

- Install and set the path to the Miyoo Mini toolchain for Windows

- Setup SDL for Rust (Windows and Miyoo Mini)

- Configuration of cargo config
  
  ```toml
  [target.armv7-unknown-linux-gnueabihf]
  linker = "arm-unknown-linux-gnueabihf-gcc"
  rustflags = ["-C", "link-arg=-fuse-ld=gold", "--remap-path-prefix", "C:\\Users\\user=~"]
  
  [target.x86_64-pc-windows-msvc]
  rustflags = ["-C", "target-feature=+crt-static", "--remap-path-prefix", "C:\\Users\\user=~"]
  
  [profile.release]
  strip = true
  ```

- Download libraries required for Miiyoo Mini. (Parasyte and Openbor/lib)
  
  - This library created by Steward-Fu(SDL2, Parasyte, Openbor)

## Build sample project

git clone or downLoad this project.

build command is this

```powershellag-0-1geb7fiurag-1-1geb7fiur
cd sdl_test
# for Windows target sdl_test.exe
cargo build --release
# for Miyoo Mini target sdl_test
# cargo build --target armv7-unknown-linux-gnueabihf --release
build.bat
```

This code works Windows and Miyoo Mini.

main.rs

```rust
use sdl2::event::Event;
use sdl2::keyboard::Keycode;
use sdl2::rect::Rect;
use sdl2::render::TextureAccess;
use sdl2::video::DisplayMode;
use std::time::Duration;

pub fn main() {
    let display = DisplayMode::new(sdl2::pixels::PixelFormatEnum::ARGB8888, 640, 480, 60);

    let sdl_context = sdl2::init().unwrap();
    let video_subsystem = sdl_context.video().unwrap();

    let mut window = video_subsystem
        .window(
            "Rust-sdl2 demo for miyoo mini",
            display.w as u32,
            display.h as u32,
        )
        .position_centered()
        .build()
        .unwrap();

    window.set_display_mode(display).unwrap();

    let mut canvas = window
        .into_canvas()
        .present_vsync()
        .accelerated()
        .build()
        .unwrap();

    let texture_creater = canvas.texture_creator();

    let mut texture = texture_creater
        .create_texture(
            display.format,
            TextureAccess::Streaming,
            display.w as u32,
            display.h as u32,
        )
        .unwrap();

    let rect = Some(Rect::new(0, 0, display.w as u32, display.h as u32));
    let pitch = (display.w * 4) as usize;

    let mut event_pump = sdl_context.event_pump().unwrap();
    let mut i = 0;

    'running: loop {
        i = (i + 1) % 255;
        for event in event_pump.poll_iter() {
            match event {
                Event::Quit { .. }
                | Event::KeyDown {
                    keycode: Some(Keycode::Escape), // if menu key down exit app
                    ..
                } => break 'running,
                _ => {}
            }
        }

        texture.with_lock(rect, lock_func).unwrap();
        //texture.update(rect, &pixels, pitch).unwrap();  // write to framebuffer(on miyoo mini)

        // ---unnecessary on miyoo mini
        canvas.copy(&texture, None, None).unwrap();
        canvas.present();
        // ---

        ::std::thread::sleep(Duration::new(0, 1_000_000_000u32 / 60)); // 60fps
    }
}

fn lock_func(pixels : &mut [u8], pitch : usize) {
    static mut COUNT: i32 = 0;
    unsafe
    {
        // set color to pixels (only blue)
        for index in 0..=(pixels.len() / 4) - 1 {
            pixels[index * 4] = (255 - COUNT).clamp(0, 255) as u8;
            // pixels[i*4 + 1] = 0;
            // pixels[i*4 + 2] = 0;
        }
        COUNT = (COUNT + 1) % 256;
    }
}
```

### Run Windows

```powershell
cargo run
```

### Run Miyoo Mini

#### [On Windows PC]

- Format SDCard with fat32

- Setup Runcher
  
  - MiniUI (Reccomended )
    
    [GitHub - shauninman/MiniUI: A custom launcher for the Miyoo Mini](https://github.com/shauninman/MiniUI)
    
    - If your sd drive is D:\
    
    - MiniUI-20220910-0-base.zip extract D:\
      
      e.g.
      D:\Bios
      D:\miyoo
      D:\Roms
      D:\Saves

- Install Parasyte
  
  - Copy parasyte directory in parasyte_20220125.zip to D:\App
    
    e.g. D:\App\parasyte\rootfs

- Copy project
  
  - Copy porject to D:\Tools\xxxx.pak
    
    e.g. D:\Tools\sdl_test.pak
    
    D:\Tools\sdl_test.pak\sdl_test
    
    D:\Tools\sdl_test.pak\launch.sh
  
  - Copy required lib
    
    Copy openbor\lib to D:\Tools\sdl_test.pak\lib

#### [On Miyoo Mini]

- Run MiniUI (Once)

- Run app
  
  - Select Tools > sdl_test
    
    Screen shows blue color.
    
    ![sdl_test](https://user-images.githubusercontent.com/87966746/193721152-8901191c-eafa-403a-a1ab-c094c3f5a7b7.png)
  
  - Select Tools > sdl_raqote
    
    ![sdl_raqote](https://user-images.githubusercontent.com/87966746/193721320-7ad6ae74-d2a1-4592-9b7d-ad844641f8bd.png)
