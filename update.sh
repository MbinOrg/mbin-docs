#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define variables
force_update=false
local_dir="./mbin-repo"
post_command="echo 1"
new_tag_exists=false
latest_tag=""
branch_name="main"

# Function to display usage information
usage() {
    echo "Usage: $0 [-f] [-d LOCAL_DIR] [-b BRANCH_NAME]" 1>&2
    echo "    -f          Force update even if there are no changes" 1>&2
    echo "    -d LOCAL_DIR   Specify the local directory of the repository (default: ./mbin-repo)" 1>&2
    echo "    -b BRANCH_NAME   Specify the branch name to pull changes from (default: main)" 1>&2
    exit 1
}

# Parse options
while getopts ":fd:b:" opt; do
    case ${opt} in
        f )
            force_update=true
            ;;
        d )
            local_dir=$OPTARG
            ;;
        b )
            branch_name=$OPTARG
            ;;
        \? )
            usage
            ;;
    esac
done
shift $((OPTIND -1))

# Change directory to the local repository
cd "$local_dir" || exit

# Fetch old tags
old_tags=$(git tag -l)

# Fetch changes from the remote repository
git fetch origin

# Check if there are any changes
if $force_update || [[ $(git rev-list HEAD...origin/"$branch_name" --count) -gt 0 ]]; then
    # Pull changes if there are any
    git pull origin "$branch_name"

    new_tags=$(git tag -l)

    # Identify new tags
    diff_tags=$(comm -13 <(echo "$old_tags" | sort) <(echo "$new_tags" | sort))

    if [[ ! -z "$diff_tags" ]]; then
        echo "New tags found:"
        echo "$diff_tags"
        
        # Set flag to indicate new tags exist
        new_tag_exists=true
        
        # Get the latest tag
        latest_tag=$(echo "$diff_tags" | sort -V | tail -n 1)
    else
        echo "No new tags found."
    fi

    # Go back to the directory where the script is located
    cd "$SCRIPT_DIR" || exit

    rm -r ./docs/*
    # copy all .md files and folders from the source repo
    rsync --mkpath -f'+ */' -f'+ *.md' -f'- *' -r "$local_dir/docs" ./
    cp "$local_dir/docs/images" -r ./docs/
    cp "$local_dir/CONTRIBUTING.md" ./docs/04-contributing/README.md
    cp "$local_dir/C4.md" ./docs/04-contributing/

    cd "$local_dir" || exit

    composer install
    touch "$SCRIPT_DIR/docs/mbin-api.json"
    php bin/console nelmio:apidoc:dump --format=json --no-pretty > "$SCRIPT_DIR/docs/mbin-api.json"

    # Go back to the directory where the script is located
    cd "$SCRIPT_DIR" || exit

    npm run build

    # Set post command
    if $new_tag_exists; then
        echo "Executing post command: $post_command"
        $post_command
    fi
else
    echo "No changes found."
fi
