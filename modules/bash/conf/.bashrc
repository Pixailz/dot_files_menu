# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
	*i*) ;;
	*) return;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

HAVE_MONO_FONT=1

# load lib_bash, making all my function available to other script and even
LIBBASH_CONFIG="${HOME}/.local/lib/lib_bash/.config"

[ -f "${LIBBASH_CONFIG}" ] && . "${LIBBASH_CONFIG}"

[ -f ~/.bash_aliases ] && . ~/.bash_aliases

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
	if [ -f /usr/share/bash-completion/bash_completion ]; then
		. /usr/share/bash-completion/bash_completion
	elif [ -f /etc/bash_completion ]; then
		. /etc/bash_completion
	fi
fi

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
	xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
	if [ ! -z $(type -t tput) ] && tput setaf 1 >&/dev/null; then
		# We have color support; assume it's compliant with Ecma-48
		# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
		# a case would tend to support setf rather than setaf.)
		color_prompt=yes
	else
		color_prompt=
	fi
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# CUSTOM

# Function to generate PS1 after CMDs
PROMPT_COMMAND=prompt::PS1

tabs 4

if [ "${color_prompt}" = yes ]; then
	P_ESC="\[\e"
	P_END="\]"
	RST="${P_ESC}[0m${P_END}"

	P_RED="${P_ESC}${ANSI["RED"]}${P_END}"
	P_GREEN="${P_ESC}${ANSI["GRE"]}${P_END}"
	P_YELLOW="${P_ESC}${ANSI["YEL"]}${P_END}"
	P_ORANGE="${P_ESC}${ANSI["ORA"]}${P_END}"
	P_BLUE="${P_ESC}${ANSI["BLU"]}${P_END}"
	P_PURPLE="${P_ESC}${ANSI["PUR"]}${P_END}"
	P_PINK="${P_ESC}${ANSI["PIN"]}${P_END}"
	P_CYAN="${P_ESC}${ANSI["CYA"]}${P_END}"
	P_WHITE="${P_ESC}${ANSI["WHI"]}${P_END}"
	P_BLACK="${P_ESC}${ANSI["BLA"]}${P_END}"
	P_GRAY="${P_ESC}${ANSI["GRA"]}${P_END}"
	P_BOLD="${P_ESC}${ANSI["BOL"]}${P_END}"
	P_DFL_BLUE="${P_ESC}[38;5;25m${P_END}"

	WORK_DIR_COLOR="${P_BOLD}${P_DFL_BLUE}"
	USER_COLOR="${P_BOLD}${P_ORANGE}"
	COMMAND_COLOR=""
	PS0="${RST}"
fi

if [ "${SSH_CLIENT}" ]; then
	P_SSH="[${P_BOLD}${P_RED}${LOGO_SSH}${SSH_CLIENT/ */}${RST}]"
fi

# set shebang because \$ don't work :'(
[ $(id -u) -eq 0 ] && SHEBANG="#" || SHEBANG="$"

PROMPT_DIRTRIM=4

# set modified PROMPT_VARIABLE according to which os we are
case ${OS_ID} in
	termux)
		OS_EMOJI="${LOGO_TERMUX:-@}"
		OS_COLOR="${P_CYAN}"
		USER_COLOR="${P_BOLD}${P_GREEN}"
		PROMPT_DIRTRIM=2
	;;
	ubuntu)
		OS_EMOJI="${LOGO_UBUNTU:-@}"
		OS_COLOR="${P_YELLOW}"
		USER_COLOR="${P_BOLD}${P_ORANGE}"
		;;
	debian)
		OS_EMOJI="${LOGO_DEBIAN:-@}"
		OS_COLOR="${P_RED}"
		USER_COLOR="${P_BOLD}${P_PURPLE}"
		;;
	kali)
		OS_EMOJI="${LOGO_KALI:-@}"
		OS_COLOR="${P_GREEN}"
		USER_COLOR="${P_BOLD}${P_RED}"
		;;
	alpine)
		OS_EMOJI="${LOGO_ALPINE:-@}"
		OS_COLOR="${P_CYAN}"
		USER_COLOR="${P_BOLD}${P_BLUE}"
		;;
	arch)
		OS_EMOJI="${LOGO_ARCH:-@}"
		OS_COLOR="${P_GRAY}"
		USER_COLOR="${P_BOLD}${P_CYAN}"
		WORK_DIR_COLOR="${P_BOLD}${P_ORANGE}"
		;;
	None)
		OS_EMOJI="@"
		OS_COLOR=""
		USER_COLOR=""
		;;
esac

export OS_EMOJI

P_EMOJI="${OS_COLOR}${OS_EMOJI}${RST}"
P_USER="${USER_COLOR}\u${RST}"
P_AT="${USER_COLOR}@${RST}"
P_HOST="${USER_COLOR}\h${RST}"
P_UAH="${P_USER}${P_AT}${P_HOST}"

if [ -f /.dockerenv ]; then
	P_DOCKER="[${P_CYAN}${LOGO_DOCKER}${RST}]"
else
	P_DOCKER=""
fi

if [ -z "${IS_WSL_INSTANCE}" ]; then
	P_WSL=""
else
	P_WSL="[${P_GREEN}${LOGO_WINDOWS}${RST}]"
fi

GIT_UNTRACKED="!"
GIT_UNSTAGED="?"
GIT_STAGED="+"
GIT_COMMIT_AHEAD="⇡"
GIT_COMMIT_BEHIND="⇣"
GIT_ALL_GOOD="✓"

function	prompt::get_git_status()
{
	: "
	master  current branch
	   ⇣42  local branch is 42 commits behind the remote
	   ⇡42  local branch is 42 commits ahead of the remote
	 merge  merge in progress
	   ~42  42 merge conflicts
	   +42  42 staged changes
	   !42  42 unstaged changes
	   ?42  42 untracked files
	"
	local	git_status=$(git status --porcelain --branch)
	local	branch_name
	local	untracked		# !
	local	unstaged		# ?
	local	staged			# +
	local	commit_ahead	# ⇡

	branch_name=$(perl -ne "print if s|## (.*?)\..*|\1|g" <<<"${git_status}")
	branch_name="${P_GREEN}${LOGO_GIT} ${branch_name}${RST}"

	untracked=$(git ls-files --others --exclude-standard | wc -l)
	if [ "${untracked}" -ne 0 ]; then
		untracked="${P_ORANGE}${GIT_UNTRACKED}${untracked}${RST}"
	else untracked="" ; fi
	unstaged=$(grep -E "^( D| M| A)" <<<"${git_status}" | wc -l)
	if [ "${unstaged}" -ne 0 ]; then
		unstaged="${P_CYAN}${GIT_UNSTAGED}${unstaged}${RST}"
	else unstaged="" ; fi
	staged=$(grep -E "^(D |M |A )" <<<"${git_status}" | wc -l)
	if [ "${staged}" -ne 0 ]; then
		staged="${P_GREEN}${GIT_STAGED}${staged}${RST}"
	else staged="" ; fi

	commit_ahead=$(perl -ne "print if s|^##.*\[ahead ([0-9]*)]|\1|g" <<<"${git_status}")
	if [ "${commit_ahead:-0}" -ne 0 ]; then
		commit_ahead="${P_PURPLE}${GIT_COMMIT_AHEAD}${commit_ahead}${RST}"
	else commit_ahead="" ; fi

	if [ -z "${commit_ahead}" -a -z "${staged}" -a -z "${untracked}" -a -z "${unstaged}" ]; then
		P_GIT="[ ${branch_name} ${P_GREEN}${GIT_ALL_GOOD}${RST} ]"
	else
		P_GIT="[ ${branch_name} ${commit_ahead}${staged}${untracked}${unstaged} ]"
	fi
}

function	prompt::PS1() {
	local	EXIT=${?}
	local	status_color
	local	is_a_git_dir

	PS1=""

	case ${EXIT} in
		0)		status_color="${P_GREEN}" ;;
		130)	status_color="${P_ORANGE}" ;;
		*)		status_color="${P_RED}" ;;
	esac
	case ${#EXIT} in
		1)	EXIT=" ${EXIT} " ;;
		2)	EXIT=" ${EXIT}" ;;
		*)	EXIT="${EXIT}" ;;
	esac

	P_CWD="${WORK_DIR_COLOR}\w${RST}"
	P_RET="${status_color}${EXIT}${RST}"
	P_TIME="$(date +%T)"
	TERM_WIDTH=$(tput cols)

	is_a_git_dir=$(git rev-parse --is-inside-work-tree 2>/dev/null)
	[ "${is_a_git_dir}" == "true" ] && prompt::get_git_status

	FL_L="[ ${P_EMOJI} ]${P_GIT}[${P_CWD}]"
	FL_R="${P_SSH}[${P_TIME}]"
	SL_L="[${P_RET}]${P_DOCKER}${P_WSL}[${P_UAH}]"

	if [ ! -z "${FL_R}" ]; then
		FL_R_LEN=$(printf "%b" "${FL_R}" | perl -pe 's|\\\[\x1b\[.*?\]||g' | wc -m)
		FL_R_POS=$(printf "\x1b[$((${TERM_WIDTH} - ${FL_R_LEN} + 1))G")
	fi
	FIRST_LINE="${FL_L}${FL_R_POS}${FL_R}\n"
	SECOND_LINE="${SL_L}"

	PS1="${FIRST_LINE}${SECOND_LINE} ${SHEBANG}${COMMAND_COLOR} "

	unset P_GIT
	unset P_CWD
	unset P_RET
	unset P_TIME
	unset TERM_WIDTH
	unset FL_L
	unset FL_R
	unset FL_R_LEN
	unset FL_R_POS
	unset SL_L
	unset FIRST_LINE
	unset SECOND_LINE
}

unset color_prompt force_color_prompt

# set tab on bash debug
PS4="    "

# set cursor shape
printf "\x1b[5 q"

export LANGUAGE="en_US:en"
export LC_ALL="en_US.UTF-8"
export LC_ADDRESS="fr_FR.UTF-8",
export LC_NAME="fr_FR.UTF-8",
export LC_MONETARY="fr_FR.UTF-8",
export LC_PAPER="fr_FR.UTF-8",
export LC_IDENTIFICATION="fr_FR.UTF-8",
export LC_TELEPHONE="fr_FR.UTF-8",
export LC_MEASUREMENT="fr_FR.UTF-8",
export LC_TIME="fr_FR.UTF-8",
export LC_NUMERIC="fr_FR.UTF-8",
export LANG="en_US.UTF-8"

export GIT_SSH_COMMAND="ssh -i ${HOME}/.ssh/git"
export PATH="${HOME}/.local/bin:${PATH}"

export PIP_BREAK_SYSTEM_PACKAGES=1

# Display previous command as title of the GUI terminal
trap 'echo -ne "\x1b]2;[$?] $(history 1 | sed "s/^[ ]*[0-9]*[ ]*//g")\007"' DEBUG

export DEBUGINFOD_URLS=https://debuginfod.archlinux.org/
