transfer() {
    # Check if no arguments are provided and show usage if that's the case
    if [ $# -eq 0 ]; then
        echo "No arguments specified."
        echo "Usage:"
        echo "  transfer <file|directory>"
        echo "  ... | transfer <file_name>" >&2
        return 1
    fi

    # Check if the script is being run in an interactive terminal (tty)
    if tty -s; then
        file="$1"
        file_name=$(basename "$file")

        # Check if the specified file or directory exists
        if [ ! -e "$file" ]; then
            echo "$file: No such file or directory" >&2
            return 1
        fi

        # If it's a directory, create a ZIP archive of it and upload
        if [ -d "$file" ]; then
            file_name="$file_name.zip"
            (cd "$file" && zip -r -q - .) | url=$(curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name") && echo "$url" | tee /dev/null
        else
            # If it's a file, upload it directly
            url=$(cat "$file" | curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name") && echo "$url" | tee /dev/null
        fi
    else
        # If not running in an interactive terminal, upload the file directly
        file_name=$1
        url=$(curl --progress-bar --upload-file "-" "https://transfer.sh/$file_name") && echo "$url" | tee /dev/null
    fi

    # Add a newline after displaying the URL
    echo

    # Copy the URL to clipboard using xclip (X11 clipboard manager)
    echo "$url" | xclip -selection clipboard
}

