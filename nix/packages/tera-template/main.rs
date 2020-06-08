//! Small utility for rendering a template from a directory of templates with some context.

#![deny(
    warnings,
    missing_debug_implementations,
    missing_copy_implementations,
    trivial_casts,
    trivial_numeric_casts,
    unstable_features,
    unused_import_braces,
    unused_qualifications,
    missing_docs,
    unused_extern_crates,
    unused_qualifications,
    unused_results
)]

use std::fs::File;
use std::io::BufReader;

use anyhow::Result;
use serde_json::Value;
use structopt::StructOpt;
use tera::{Context, Tera};

/// Template rendering utility for use within Nix-based static site generator.
#[derive(StructOpt, Debug)]
#[structopt(name = "tera-template")]
struct Cli {
    /// Directory containing templates.
    #[structopt(short, long)]
    path: String,

    /// Template to be rendered, must be a path (relative to the templates path).
    #[structopt(short, long)]
    template: String,

    /// JSON file containing the context to be provided to the template while rendering.
    #[structopt(short, long)]
    context: String,
}

fn main() -> Result<()> {
    let cli = Cli::from_args();

    let file = File::open(&cli.context)?;
    let reader = BufReader::new(file);
    let context: Value = serde_json::from_reader(reader)?;

    let rendered = Tera::new(&format!("{}/**/*", cli.path))
        .and_then(|mut tera| {
            tera.autoescape_on(vec![]);
            tera.render(&cli.template, &Context::from_value(context)?)
        })
        .unwrap();

    println!("{}", rendered);
    Ok(())
}
