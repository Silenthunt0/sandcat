#!/usr/bin/env bats
# shellcheck disable=SC2030,SC2031

setup() {
	load test_helper
	# shellcheck source=../../libexec/init/init
	source "$SCT_LIBEXECDIR/init/init"

	export HOME="$BATS_TEST_TMPDIR/home"
	mkdir -p "$HOME"
}

teardown() {
	unstub_all
}

@test "create_user_settings creates file when not present" {
	stub git \
		"config --global user.name : echo 'Test User'" \
		"config --global user.email : echo 'test@example.com'"

	create_user_settings

	[[ -f "$HOME/.config/sandcat/settings.json" ]]
}

@test "create_user_settings derives git identity" {
	stub git \
		"config --global user.name : echo 'Test User'" \
		"config --global user.email : echo 'test@example.com'"

	create_user_settings

	local settings="$HOME/.config/sandcat/settings.json"
	run yq -r '.env.GIT_USER_NAME' "$settings"
	assert_output "Test User"

	run yq -r '.env.GIT_USER_EMAIL' "$settings"
	assert_output "test@example.com"
}

@test "create_user_settings falls back to placeholders when git config missing" {
	stub git \
		"config --global user.name : exit 1" \
		"config --global user.email : exit 1"

	create_user_settings

	local settings="$HOME/.config/sandcat/settings.json"
	run yq -r '.env.GIT_USER_NAME' "$settings"
	assert_output "Your Name"

	run yq -r '.env.GIT_USER_EMAIL' "$settings"
	assert_output "you@example.com"
}

@test "create_user_settings includes ANTHROPIC_API_KEY secret" {
	stub git \
		"config --global user.name : echo ''" \
		"config --global user.email : echo ''"

	create_user_settings

	local settings="$HOME/.config/sandcat/settings.json"
	run yq -r '.secrets.ANTHROPIC_API_KEY.hosts[0]' "$settings"
	assert_output "api.anthropic.com"
}

@test "create_user_settings includes GITHUB_TOKEN secret" {
	stub git \
		"config --global user.name : echo ''" \
		"config --global user.email : echo ''"

	create_user_settings

	local settings="$HOME/.config/sandcat/settings.json"
	run yq -r '.secrets.GITHUB_TOKEN.hosts[0]' "$settings"
	assert_output "github.com"
}

@test "create_user_settings includes network rules" {
	stub git \
		"config --global user.name : echo ''" \
		"config --global user.email : echo ''"

	create_user_settings

	local settings="$HOME/.config/sandcat/settings.json"
	yq -e '.network[] | select(.host == "*.github.com")' "$settings"
	yq -e '.network[] | select(.host == "*.anthropic.com")' "$settings"
	yq -e '.network[] | select(.host == "*.claude.com")' "$settings"
}

@test "create_user_settings skips when file already exists" {
	mkdir -p "$HOME/.config/sandcat"
	echo '{"existing": true}' > "$HOME/.config/sandcat/settings.json"

	create_user_settings

	run yq '.existing' "$HOME/.config/sandcat/settings.json"
	assert_output "true"
}
