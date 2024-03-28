#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use egui::TextEdit;

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
    LoggedOut,
    VerifyingAuth,
    LoggedIn,
}

impl AppState {}

struct App {
    auth: Auth,
    state: AppState,
}

impl Default for App {
    fn default() -> Self {
        Self {
            auth: Auth {
                host: String::new(),
                password: String::new(),
            },
            state: AppState::LoggedOut,
        }
    }
}

impl eframe::App for App {
    fn update(&mut self, ctx: &egui::Context, _frame: &mut eframe::Frame) {
        egui::TopBottomPanel::top("auth").show(ctx, |ui| {
            ui.add_space(4.0);

            ui.add_enabled_ui(matches!(self.state, AppState::LoggedOut), |ui| {
                egui::Grid::new("auth_grid")
                    .num_columns(2)
                    .spacing([4.0, 4.0])
                    .show(ui, |ui| {
                        ui.label("Host: ");
                        ui.text_edit_singleline(&mut self.auth.host);
                        ui.end_row();
                        ui.label("Password: ");
                        ui.add(TextEdit::singleline(&mut self.auth.password).password(true));
                        ui.end_row();
                    });
            });

            ui.add_space(4.0);

            if matches!(self.state, AppState::VerifyingAuth) {
                ui.horizontal(|ui| {
                    ui.label("Verifying details...");
                    ui.spinner();
                });
            } else if ui
                .button(match self.state {
                    AppState::LoggedOut => "Login",
                    AppState::LoggedIn => "Logout",
                    AppState::VerifyingAuth => unreachable!(),
                })
                .clicked()
            {
                self.state = match self.state {
                    AppState::LoggedOut => AppState::VerifyingAuth,
                    AppState::VerifyingAuth => AppState::LoggedIn,
                    AppState::LoggedIn => AppState::LoggedOut,
                }
            }

            ui.add_space(4.0);
        });

        egui::CentralPanel::default().show(ctx, |ui| {
            ui.label("Hello World!");
        });
    }
}
