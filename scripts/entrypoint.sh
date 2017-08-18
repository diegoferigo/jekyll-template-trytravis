#!/bin/bash
set -e

# Use the local folder for ruby gems
BUNDLER_FOLDER="$WWW_DIR/_vendor/bundle"
if [ -d "$BUNDLER_FOLDER" ] ; then
    BUNDLER_FOLDERS_BIN=($BUNDLER_FOLDER/ruby/*/bin)
    for folder in $BUNDLER_FOLDERS_BIN ; do
        export PATH=$folder:$PATH
    done
fi

cd $JEKYLL_DIR

case "$@" in
    new)
        echo "Generate a new website in $JEKYLL_DIR? [y/N]"
        read generate_jekyll
        case $generate_jekyll in
            y)
                # If the folder is not empty, ask if the environment should be initizialized
                if [ -n "$(ls -A $WWW_DIR)" ] ; then
                    echo "The folder $WWW_DIR is not empty"
                    if [ -e "$WWW_DIR/Gemfile" ] ; then
                        echo "Do you want to set the environment up with bundler? [y/N]"
                        read bundler_env
                        case $bundler_env in
                            y)
                                cd "$WWW_DIR"
                                bundler install --path $BUNDLER_FOLDER
                                cd -
                                ;;
                            *) ;;
                        esac
                        exit 0
                    else
                        exit 1
                    fi
                fi
                # Otherwise, generate the default website
                jekyll new --force $WWW_DIR || exit 1
                cd $WWW_DIR
                bundle install
                echo
                #
                install_gems
                cd -
                ;;
            *)
                echo "Exiting"
                ;;
        esac
        ;;
    serve) ;;
    build) ;;
    *)
        # Execute command from CMD
        $@
        ;;
esac
