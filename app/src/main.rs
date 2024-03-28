#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use replace_with::replace_with_or_abort;

fn main() -> Result<(), eframe::Error> {
    env_logger::init();
    eframe::run_native(
        "Soundboard",
        eframe::NativeOptions {
            viewport: egui::ViewportBuilder::default().with_inner_size([320.0, 240.0]),
            ..Default::default()
        },
        Box::new(|_| Box::<App>::default()),
    )
}

struct Auth {
    pub host: String,
    pub password: String,
}

enum AppState {
    LoggedOut { auth: Auth },
    LoggedIn { auth: Auth },
}

impl AppState {
    pub fn auth(&mut self) -> &mut Auth {
        match self {
            AppState::LoggedOut { auth } => auth,
            AppState::LoggedIn { auth } => auth,
        }
    }

    pub fn logged_in(&self) -> bool {
        match self {
            AppState::LoggedOut { .. } => false,
            AppState::LoggedIn { .. } => true,
        }
    }

    pub fn toggle(&mut self) {
        replace_with_or_abort(self, |state| match state {
            AppState::LoggedOut { auth } => AppState::LoggedIn { auth },
            AppState::LoggedIn { auth } => AppState::LoggedOut { auth },
        });
    }
}

struct App {
    state: AppState,
}

impl Default for App {
    fn default() -> Self {
        Self {
            state: AppState::LoggedOut {
                auth: Auth {
                    host: String::new(),
                    password: String::new(),
                },
            },
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::TopBottomPanel::top("auth").show(ctx, |ui| {
            let logged_out = !self.state.logged_in();
            ui.add_enabled_ui(logged_out, |ui| {
                egui::Grid::new("auth_grid")
                    .num_columns(2)
                    .spacing([40.0, 4.0])
                    .show(ui, |ui| {
                        ui.label("Host: ");
                        ui.text_edit_singleline(&mut self.state.auth().host);
                        ui.end_row();
                        ui.label("Password: ");
                        ui.text_edit_singleline(&mut self.state.auth().password);
                        ui.end_row();
                    });
            });

            if ui
                .button(match self.state {
                    AppState::LoggedOut { .. } => "Login",
                    AppState::LoggedIn { .. } => "Logout",
                })
                .clicked()
            {
                self.state.toggle();
            };
        });

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.label("Hello World!");
        });
        // egui::CentralPanel::default().show(ctx, |ui| {
        //     ui.heading("My egui Application");
        //     ui.horizontal(|ui| {
        //         let name_label = ui.label("Your name: ");
        //         ui.text_edit_singleline(&mut self.name)
        //             .labelled_by(name_label.id);
        //     });
        //     ui.add(egui::Slider::new(&mut self.age, 0..=120).text("age"));
        //     if ui.button("Increment").clicked() {
        //         self.age += 1;
        //     }
        //     ui.label(format!("Hello '{}', age {}", self.name, self.age));

        //     // ui.image(egui::include_image!(
        //     //     "../../../crates/egui/assets/ferris.png"
        //     // ));
        // });
    }
}
