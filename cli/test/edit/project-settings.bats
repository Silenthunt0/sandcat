#!/usr/bin/env bats

setup() {
	load test_helper

	# shellcheck source=../../libexec/edit/project-settings
	source "$SCT_LIBEXECDIR/edit/project-settings"

	mkdir -p "$BATS_TEST_TMPDIR/$SCT_PROJECT_DIR"
	SETTINGS_FILE="$BATS_TEST_TMPDIR/$SCT_PROJECT_DIR/settings.json"
	touch "$SETTINGS_FILE"
}

teardown() {
	unstub_all
}

@test "project-settings opens editor" {
	unset -f open_editor
	stub open_editor \
		"$SETTINGS_FILE : :"

	cd "$BATS_TEST_TMPDIR"
	run project-settings
	assert_success
}

@test "project-settings fails when file missing" {
	rm "$SETTINGS_FILE"

	cd "$BATS_TEST_TMPDIR"
	run project-settings
	assert_failure
	assert_output --partial "No settings file found"
}
