mod engine;
use engine::{Engine, State};
use sdl2::event::Event;
use sdl2::keyboard::Keycode;
use sdl2::rect::Rect;
use sdl2::render::TextureAccess;
use sdl2::video::DisplayMode;
use std::borrow::Borrow;
use std::time::Duration;

pub fn main() {
    let display = DisplayMode::new(sdl2::pixels::PixelFormatEnum::ARGB8888, 640, 480, 60);

    let sdl_context = sdl2::init().unwrap();
    let video_subsystem = sdl_context.video().unwrap();

    let mut window = video_subsystem
        .window(
            "Rust-sdl2_raqote demo for miyoo mini",
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

    let mut engine = Engine::new(display.w, display.h);
    engine.change_state(State::Main);

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

        if engine.require_update() {
            let mut lock_func = |pixels: &mut [u8], pitch: usize| {
                engine.update_screen(pixels, pitch);
                engine.end_update();
            };
            texture.with_lock(rect, &mut lock_func).unwrap();
            //texture.update(rect, &pixels, pitch).unwrap();  // write to framebuffer(on miyoo mini)
            // ---unnecessary on miyoo mini
            canvas.copy(&texture, None, None).unwrap();
            canvas.present();
            // ---
            println!("{}", i);
        }

        ::std::thread::sleep(Duration::new(0, 1_000_000_000u32 / 60)); // 60fps
    }
}
