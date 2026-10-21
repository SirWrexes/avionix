{
  lib,
  writeShellApplication,

  fd,
  gawk,
}:
let
  inherit (lib) escapeShellArg;

  name = "dupes";
  usage = ''
    Usage: ${name} [DIR] [FD_ARGS...]

    Finds and lists files with duplicate names (basenames) recursively.

    Arguments:
      DIR              Directory to search inside. (default: \$PWD)
      FD_ARGS          Any extra arguments passed directly to 'fd'.
                       More info at `man fd`

    Options:
      -h, --help       Display this help message and exit

    Examples:
      ${name}                    Search current directory
      ${name} /var/log           Search a specific directory
      ${name} ~/.config -e txt   Search only for text files in configs
      ${name} -H                 Include hidden files/directories
  '';
in
writeShellApplication {
  inherit name;

  runtimeInputs = [
    fd
    gawk
  ];

  text = ''
    show_help() {
      # shellcheck disable=SC2016
      echo ${escapeShellArg usage}
    }

    for arg in "$@"; do
      if [[ "$arg" == "-h" || "$arg" == "--help" ]]; then
        show_help
        exit 0
      fi
    done

    if (( "''${#@}" < 2)); then
      SEARCH_ROOT="$PWD"
    elif [[ -n "$1" && -d "$1" ]]; then
      SEARCH_ROOT="$1"
      shift
    else
      echo "Invalid root: $1" >&2
      exit 1
    fi

    fd "$SEARCH_ROOT" --type f "$@" | awk -F'/' ${escapeShellArg ''
      {
        name=$NF
        paths[name] = paths[name] ? paths[name] "\n  " $0 : $0
        count[name]++
      } END {
        for (n in count) if (count[n] > 1) {
          print "Duplicate name: " n
          print " " path[n]
          print ""
        }
      }
    ''}

    exit "''${PIPESTATUS[0]}"
  '';
}
