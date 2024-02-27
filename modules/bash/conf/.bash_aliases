#!/bin/bash

# utils functions

## pentest utils

function	printFeedHelp()
{
	printf "Usage: feed EXEC_NAME TITLE COMMAND\n"
	[ ! -z "$1" ] && printf "ERROR: $1\n"
}

function	feed()
{
	[ -z "$1" ] && printFeedHelp "need exec name" && return
	[ -z "$2" ] && printFeedHelp "need title" && return
	[ -z "$3" ] && printFeedHelp "need command" && return

	local	feed_name=$1
	local	feed_title=$2
	local	feed_command=$3
	local	feed_file_path="${HOME}/.backup"

	[ ! -d "${feed_file_path}" ] && mkdir ${feed_file_path}

	feed_file_path="${feed_file_path}/${feed_name}_command.md"

	if [ ! -f "${feed_file_path}" ]; then
		printf "# ${feed_name}\n\n" > ${feed_file_path}
		printf "## ${feed_title}\n" >> ${feed_file_path}
		printf "\`${feed_command}\`\n\n" >> ${feed_file_path}
	else
		printf "## ${feed_title}\n" >> ${feed_file_path}
		printf "\`${feed_command}\`\n\n" >> ${feed_file_path}
	fi
}

## Docker
function	dockc()
{
	docker system prune -af
	docker network prune -f
	docker volume prune -f
}

## bash
: ' debug_bash
${1}    cmd to debug
return  return debug in  in ${PWD}/exec.log. if DEBUG_OUT is set, ouput
        debug in ${PWD}/DEBUG_OUT
'
function	dbash()
{
	local	cmd="${@}"
	local	options="-x"
	if [ -z "${DEBUG_OUT}" ];then
		local debug_file="exec.log"
	else
		local debug_file=${DEBUG_OUT}
	fi

	bash "${options}" ${cmd} 2>${debug_file}
}

# nmap
function	snmap()
{
	local	target="${1:-}"
	local	args=" ${target} -vv -oN ./nmap"
	local	stamp=".$(date +%j.%y-%H.%M.%S-%+3N).${target}"
	local	open_port
	local	port_arg

	if	[ -z "${target}" ]; then
		printf "error: required target $\{1\} missing\n"
		return 0
	fi
	[ ! -d "./nmap/" ] && mkdir "./nmap/"
	[ ${UID} -eq 0 ] && args+=" -sS"
	nmap ${args}/all_port${stamp} -p-
	open_port=($(perl -ne "print if s|^([0-9]{1,5})/.*$|\1|g" "./nmap/all_port${stamp}"))
	for port in ${open_port[@]}; do
		port_arg+="${port},"
	done
	nmap ${args}/advanced_port${stamp} -p"${port_arg/%,}" -A -sV
}

function	clmake()
{
	for makefile in $(find . -type f -name "Makefile"); do
		printf "{${makefile}}\n"
		make --no-print-directory -C ${makefile%/*} fclean
	done
}

function	netar::listen()
{ nc -lvp ${1?} | tar xvf -; }

function	netar::send()
{
	local	target_ip="${1?}"
	local	target_port="${2?}"
	local	folder="${3?}"

	[ ! -d "${folder}" ] && return 1
	tar cvf - "${folder}" | nc "${target_ip}" "${target_port}";
}

function	ffmpeg::to_gif()
{
	local	input_file="${1?}"
	local	output_file="${2:-output.gif}"
	local	height="${3:-320}"
	local	duration="${4:-10}"
	local	skip_time="${5:-0}"

	ffmpeg -i "${input_file}" \
		-ss "${skip_time}" \
		-t "${duration}" \
		-vf "fps=10,scale=${height}:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
		-loop 0 \
		-y "${output_file}"
}

function	ffmpeg::to_mp4()
{
	local	input_file="${1?}"
	local	output_file="${2:-output.mp4}"

	ffmpeg -i "${input_file}" \
		-c:v libx265 \
		-x265-params lossless=1 \
		-c:a libfdk_aac \
		-b:a 128k \
		-y "${output_file}"
}

# Alias

# Enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
	test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	LS_COLOR=y
fi

# Alias

## ENABLE ALIAS FOR SUDO COMMAND
alias sudo="sudo "

## Ip
alias ip="ip --color=auto"

## Ls
export LS_OPTIONS="-vhF"
if [ "${LS_COLOR}" == "y" ]; then
	LS_OPTIONS="--color=auto ${LS_OPTIONS}"
fi
alias ls="ls ${LS_OPTIONS}"
alias ll="ls -oA"
alias la="ls -la"
alias l="ls"

## batcat
function dbat()
{
	git diff --name-only --relative --diff-filter=d | xargs batcat --diff
}

function	man()
{
	local	man="man"
	[ -x $(type -P batman) ] && man="batman"
	/usr/bin/${man} ${@}
}

## John
alias john="/usr/local/bin/john"

TREE_OPT="--metafirst --filesfirst -I .git -apugh -D --timefmt '%x %X'"
# --metafirst	: make metadata appear first, that keep the ascii tree clean :)
# --filesfirst	: make files appear first, more organised tree view
# -I			: ignore dirs (like .git ones)
# -a			: all files
# -p			: print permission
# -u			: print user owner
# -g			: print group owner
# -h			: size in human readable
# -D			: display the last modified
# --timefmt		: print date in format
# %x			: current day padded with zero's
# %X			: current time padded with zero's
alias ttree="tree ${TREE_OPT}"
http_tree='-H . -o ./index.html && sleep 1 && xdg-open ./index.html && read -s -n 1 && rm ./index.html'
# -H			: format output as html
# -o output in file instead of stdout

alias httree="ttree ${http_tree}"
alias htree="tree ${http_tree}"

alias sbashrc="source ~/.bashrc"
alias vbashrc="vim ~/.bashrc"
alias vsbashrc="vbashrc && sbashrc"

alias nc="nc -v"

alias wa="watch --interval 1 --differences --color"

alias lssh="sudo tail -f -n+1 /var/log/auth.log | grep sshd"

alias ntmux="tmux new -s"

export SCRCPY_PUSH_TARGET="/storage/emulated/0/Documents"

if [ -z "${IS_WSL_INSTANCE}" ]; then
	alias sscrcpy="scrcpy \
		--hid-keyboard\
		--push-target=${SCRCPY_PUSH_TARGET} \
		--stay-awake \
		--turn-screen-off \
		--fullscreen \
		"
else
	:
	# TODO
	# alias sscrcpy="scrcpy "
fi
