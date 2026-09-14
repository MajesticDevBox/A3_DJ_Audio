// Keep the existing launcher-ready folder refreshed alongside both archives.
let target = HEMTT_RFS.join("releases/@edj");
target.create_dir_all();
fn copy_runtime(source, destination) {
    if source.is_dir() {
        destination.create_dir_all();
        for child in source.list() { copy_runtime(child, destination.join(child.file_name())); }
    } else {
        if destination.is_file() { destination.remove_file(); }
        if !source.copy(destination) { fatal("Cannot refresh launcher runtime: " + source.file_name()); }
    }
}
for entry in HEMTT_OUT.list() {
    copy_runtime(entry, target.join(entry.file_name()));
}
