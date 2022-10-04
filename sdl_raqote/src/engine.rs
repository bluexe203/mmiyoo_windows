use raqote::*;
pub struct Engine {
    screen_w: i32,
    screen_h: i32,
    target: DrawTarget,
    require_update: bool,
}

pub enum State {
    None,
    Main,
}

impl Engine {
    pub fn new(w: i32, h: i32) -> Self {
        Self {
            screen_w: w,
            screen_h: h,
            target: DrawTarget::new(w, h),
            require_update: false,
        }
    }

    pub fn change_state(&mut self, state: State) {
        match state {
            State::None => {},
            State::Main => {
                let mut pb = PathBuilder::new();
                pb.move_to(100., 10.);
                pb.cubic_to(150., 40., 175., 0., 200., 10.);
                pb.quad_to(120., 100., 80., 200.);
                pb.quad_to(150., 180., 300., 300.);
                pb.close();
                let path = pb.finish();

                let gradient = Source::new_radial_gradient(
                    Gradient {
                        stops: vec![
                            GradientStop {
                                position: 0.2,
                                color: Color::new(0xff, 0, 0xff, 0),
                            },
                            GradientStop {
                                position: 0.8,
                                color: Color::new(0xff, 0xff, 0xff, 0xff),
                            },
                            GradientStop {
                                position: 1.,
                                color: Color::new(0xff, 0xff, 0, 0xff),
                            },
                        ],
                    },
                    Point::new(150., 150.),
                    128.,
                    Spread::Pad,
                );
                self.target.fill(&path, &gradient, &DrawOptions::new());

                let mut pb = PathBuilder::new();
                pb.move_to(100., 100.);
                pb.line_to(300., 300.);
                pb.line_to(200., 300.);
                let path = pb.finish();

                self.target.stroke(
                    &path,
                    &Source::Solid(SolidSource {
                        r: 0x0,
                        g: 0x0,
                        b: 0x80,
                        a: 0x80,
                    }),
                    &StrokeStyle {
                        cap: LineCap::Round,
                        join: LineJoin::Round,
                        width: 10.,
                        miter_limit: 2.,
                        dash_array: vec![10., 18.],
                        dash_offset: 16.,
                    },
                    &DrawOptions::new(),
                );

                self.require_update = true;
            }
        }
    }
    pub fn update_screen(&self, pixels: &mut [u8], pitch: usize) {
        // copy to texture
        pixels.copy_from_slice(self.target.get_data_u8());
    }

    pub fn require_update(&self) -> bool {
        self.require_update
    }

    pub fn end_update(&mut self) {
        self.require_update = false;
    }
}
