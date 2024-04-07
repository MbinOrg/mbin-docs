#!/bin/bash

# Define variables
local_dir="./mbin-repo"
post_command="echo 1"
new_tag_exists=false
latest_tag=""
branch_name="documentation-hosting"

# Change directory to the local repository
cd "$local_dir" || exit

# Fetch old tags
old_tags=$(git tag -l)

# Fetch changes from the remote repository
git fetch origin

# Check if there are any changes
if [[ $(git rev-list HEAD...origin/"$branch_name" --count) -gt 0 ]]; then
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

    # Copy files
    cd "../"
    rm -r ./docs/*
    # copy all .md files and folders from the source repo
    rsync --mkpath -f'+ */' -f'+ *.md' -f'- *' -r ./mbin-repo/docs ./
    cp ./mbin-repo/docs/images -r ./docs/
    cp ./mbin-repo/CONTRIBUTING.md ./docs/contributing/README.md
    cp ./mbin-repo/C4.md ./mbin-repo/LICENSE ./docs/contributing/
    npm run build

    # Set post command
    if $new_tag_exists; then
        echo "Executing post command: $post_command"
        $post_command
    fi
else
    echo "No changes found."
fi
