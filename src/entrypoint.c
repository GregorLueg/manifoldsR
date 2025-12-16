// We need to forward routine registration from C to Rust
// to avoid the linker removing the static library.

void R_init_manifoldsR_extendr(void *dll);

void R_init_manifoldsR(void *dll) {
    R_init_manifoldsR_extendr(dll);
}
