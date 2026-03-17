#!/usr/bin/env bats

setup() {
	load test_helper

	# shellcheck source=../../libexec/edit/dockerfile
	source "$SCT_LIBEXECDIR/edit/dockerfile"

	mkdir -p "$BATS_TEST_TMPDIR/.devcontainer"
	DOCKERFILE="$BATS_TEST_TMPDIR/.devcontainer/Dockerfile.app"
	touch "$DOCKERFILE"
}

teardown() {
	unstub_all
}

@test "dockerfile opens editor" {
	unset -f open_editor
	stub open_editor \
		"$DOCKERFILE : :"

	cd "$BATS_TEST_TMPDIR"
	run dockerfile
	assert_success
}

@test "dockerfile fails when file missing" {
	rm "$DOCKERFILE"

	cd "$BATS_TEST_TMPDIR"
	run dockerfile
	assert_failure
	assert_output --partial "No Dockerfile found"
}
