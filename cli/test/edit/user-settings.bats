#!/usr/bin/env bats

setup() {
	load test_helper

	# shellcheck source=../../libexec/edit/user-settings
	source "$SCT_LIBEXECDIR/edit/user-settings"

	export HOME="$BATS_TEST_TMPDIR/home"
	mkdir -p "$HOME/.config/sandcat"
	USER_SETTINGS="$HOME/.config/sandcat/settings.json"
	touch "$USER_SETTINGS"
}

teardown() {
	unstub_all
}

@test "user-settings opens editor" {
	unset -f open_editor
	stub open_editor \
		"$USER_SETTINGS : :"

	run user-settings
	assert_success
}

@test "user-settings fails when file missing" {
	rm "$USER_SETTINGS"

	run user-settings
	assert_failure
	assert_output --partial "No user settings file found"
}
