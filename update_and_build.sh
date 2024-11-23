#!/usr/bin/env bash

# Get the directory where the script is located
SCRIPT_DIR=$(dirname "$(realpath "$0")")

# Define variables
force_update=false
skip_build=false
local_dir="./mbin"
new_tag_exists=false
latest_tag=""
branch_name="main"

# Function to display usage information
usage() {
    echo "Usage: $0 [-f] [-d LOCAL_DIR] [-b BRANCH_NAME]" 1>&2
    echo "    -f          Force update even if there are no changes" 1>&2
    echo "    -s          Skip the build (eg. when you want to execute npm start)" 1>&2
    echo "    -d LOCAL_DIR   Specify the local directory of the repository (default: ./mbin)" 1>&2
    echo "    -b BRANCH_NAME   Specify the branch name to pull changes from (default: main)" 1>&2
    exit 1
}

# Parse options
while getopts ":fsd:b:" opt; do
    case ${opt} in
        f )
            force_update=true
            ;;
        s )
            skip_build=true
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

if [ ! -d "$local_dir" ]; then
    echo "Error: Directory $local_dir does not exist. Exiting"
    exit 1
fi    

# Change directory to the local repository
cd "$local_dir"

# Fetch old tags
old_tags=$(git tag -l)

# Fetch changes from the remote repository
git fetch origin

# Check if there are any changes
if $force_update || [[ $(git rev-list HEAD...origin/"$branch_name" --count) -gt 0 ]]; then
    # Switch to the branch (or it will pull changes in to the currently checked out branch)
    git checkout "$branch_name"

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

    composer install --no-scripts --no-progress --no-autoloader --no-interaction
    php bin/console nelmio:apidoc:dump --format=json --no-pretty > "$SCRIPT_DIR/docs/mbin-api.json" 2>/dev/null

    if [ "$skip_build" = "false" ]; then
        # Go back to the directory where the script is located
        cd "$SCRIPT_DIR" || exit

        npm run build
    fi
else
    echo "No changes found."
fi
