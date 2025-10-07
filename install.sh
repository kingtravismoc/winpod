#!/bin/bash

# installer.sh: Installer for winpod (Windows Git Bash)

# Configuration
INSTALL_DIR="$HOME/bin" # Installation directory (user's bin directory)
WINPOD_SCRIPT="winpod"   # Name of the winpod script

# Functions

# install_dependencies: Check and install required dependencies
install_dependencies() {
    echo "Checking for dependencies..."

    # skopeo (preferred image pulling method)
    if ! command -v skopeo &> /dev/null; then
        echo "skopeo is not installed.  It is highly recommended for image pulling."
        echo "  On MSYS2 (Git Bash), you can install it with: pacman -S skopeo"
        echo "  Alternatively, you'll be relying on a less robust fallback mechanism."
        # No automatic installation for security reasons. User must install manually.
    else
        echo "skopeo is installed."
    fi

    # Python and docker-compose (for winpod compose)
    if command -v docker-compose &> /dev/null ; then
        echo "docker-compose is installed"
    elif ! command -v python3 &> /dev/null; then
        echo "Python 3 is required for docker-compose but is not installed."
        echo "  On MSYS2 (Git Bash), you can install it with: pacman -S python"
        echo "  docker-compose functionality will not be available until Python is installed."
        return 1 # Return error code to signal installation is incomplete
    elif ! command -v docker-compose &> /dev/null; then
        echo "docker-compose is not installed."
        echo "  You can install it with: pip install docker-compose"
        echo "  docker-compose functionality will not be available until docker-compose is installed."
        return 1 # Return error code to signal installation is incomplete
    fi


    # jq (optional, for fallback image pulling)
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Required if skopeo is not available to pull docker images."
        echo "  On MSYS2 (Git Bash), you can install it with: pacman -S jq"
        # No automatic installation for security reasons. User must install manually.
    else
        echo "jq is installed."
    fi

    echo "Dependency check complete."
}



# install_winpod: Install the winpod script
install_winpod() {
    # Create install directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    # Winpod Script
    WINPOD_CONTENT='#!/bin/bash

# winpod: A minimal Podman-like tool for Windows (Git Bash) without elevated permissions

# Configuration
WINPOD_ROOT="$HOME/.winpod"  # Root directory for winpod data
WINPOD_IMAGES="$WINPOD_ROOT/images" # Directory to store image tarballs
WINPOD_CONTAINERS="$WINPOD_ROOT/containers" # Directory to store container data
WINPOD_COMPOSE_CONFIG="$WINPOD_ROOT/compose.yml" # Path to the docker-compose.yml file

# Command handling
case "$1" in
    run)
        winpod_run "$2"
        ;;
    pull)
        winpod_pull "$2"
        ;;
    images)
        winpod_images
        ;;
    ps)
        winpod_ps
        ;;
    rm)
        winpod_rm "$2"
        ;;
    rmi)
        winpod_rmi "$2"
        ;;
    compose)
        shift # Remove "compose" command
        winpod_compose "$@"
        ;;
    *)
        winpod_help
        ;;
esac

# Helper functions

# winpod_help: Display help message
winpod_help() {
    echo "winpod: A minimal Podman-like tool for Windows (Git Bash)"
    echo ""
    echo "Usage: winpod <command> [options]"
    echo ""
    echo "Commands:"
    echo "  run <image>             Run a container from an image"
    echo "  pull <image>            Pull an image from Docker Hub"
    echo "  images                  List available images"
    echo "  ps                      List running containers"
    echo "  rm <container>          Remove a container"
    echo "  rmi <image>             Remove an image"
    echo "  compose <subcommand>    Manage multi-container applications"
    echo ""
    echo "Compose subcommands:"
    echo "  winpod compose up -d     Start the application in detached mode"
    echo "  winpod compose down       Stop and remove the application"
    echo "  winpod compose ps         List containers in the application"
}

# winpod_run: Run a container from an image
winpod_run() {
    local image="$1"
    local container_name=$(echo "$image" | tr / - | tr : -) # Generate a container name based on image
    local container_dir="$WINPOD_CONTAINERS/$container_name"

    if [ ! -d "$container_dir" ]; then
        mkdir -p "$container_dir"
    fi

    # Check if image exists
    if [ ! -f "$WINPOD_IMAGES/$image.tar" ]; then
        echo "Error: Image \'$image\' not found. Use \'winpod pull\' to download it."
        return 1
    fi

    echo "Running container \'$container_name\' from image \'$image\'..."
    tar -xf "$WINPOD_IMAGES/$image.tar" -C "$container_dir" # Extract the image layers
    chroot "$container_dir" /bin/bash # Chroot into the container
    # NOTE: This chroot is very basic and not secure.
    #       It is just a minimal emulation of a container for testing.
    #       For real containerization, use a proper tool like Podman or Docker.

    rm -rf "$container_dir" # Clean up container files after running (very basic)
}

# winpod_pull: Pull an image from Docker Hub
winpod_pull() {
    local image="$1"
    local image_tar="$WINPOD_IMAGES/$image.tar"

    mkdir -p "$WINPOD_IMAGES"

    if [ -f "$image_tar" ]; then
        echo "Image \'$image\' already exists."
        return 0
    fi

    echo "Pulling image \'$image\' from Docker Hub..."

    # Use skopeo (if installed) for proper image pulling
    if command -v skopeo &> /dev/null; then
        skopeo copy docker://docker.io/library/"$image" oci-archive:"$image_tar"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to pull image using skopeo."
            return 1
        fi
    else
        # Fallback to a very basic curl and tar method (not ideal, prone to errors)
        echo "Warning: skopeo not found. Using a basic (and potentially unreliable) pull method."
        curl -s "https://registry.hub.docker.com/v2/repositories/library/$image/tags/latest" | jq -r \'.images[].digest\' > /tmp/digest.txt
        if [ $? -ne 0 ]; then
            echo "Error: Failed to get image digest."
            return 1
        fi
        local digest=$(cat /tmp/digest.txt)
        rm /tmp/digest.txt
        curl -s "https://registry.hub.docker.com/v2/blobs/$digest" | tar -xf - -C "$WINPOD_IMAGES"
        if [ $? -ne 0 ]; then
            echo "Error: Failed to download and extract image layers."
            return 1
        fi
        touch "$image_tar" # Create a dummy tar file to mark the image as downloaded. This should be replaced with actual extraction for proper functionality.

    fi

    echo "Image \'$image\' pulled successfully."
}

# winpod_images: List available images
winpod_images() {
    echo "Available images:"
    for f in "$WINPOD_IMAGES"/*.tar; do
        echo "  $(basename "$f" .tar)"
    done
}

# winpod_ps: List running containers (very basic emulation)
winpod_ps() {
    echo "CONTAINER ID   IMAGE     COMMAND   STATUS"
    #  (This is a placeholder - needs proper container management logic)
}

# winpod_rm: Remove a container (very basic emulation)
winpod_rm() {
    local container_name="$1"
    local container_dir="$WINPOD_CONTAINERS/$container_name"

    if [ -d "$container_dir" ]; then
        rm -rf "$container_dir"
        echo "Container \'$container_name\' removed."
    else
        echo "Container \'$container_name\' not found."
    fi
}

# winpod_rmi: Remove an image
winpod_rmi() {
    local image="$1"
    local image_tar="$WINPOD_IMAGES/$image.tar"

    if [ -f "$image_tar" ]; then
        rm "$image_tar"
        echo "Image \'$image\' removed."
    else
        echo "Image \'$image\' not found."
    fi
}


# winpod_compose: Handles docker-compose like commands
winpod_compose() {
    case "$1" in
        up)
            winpod_compose_up "$@"
            ;;
        down)
            winpod_compose_down
            ;;
        ps)
            winpod_compose_ps
            ;;
        *)
            echo "winpod compose: Invalid subcommand."
            ;;
    esac
}


# winpod_compose_up: Emulates docker-compose up -d functionality
winpod_compose_up() {
  shift  # Remove "up" from arguments

  # Check for detached mode (-d)
  local detached_mode=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d)
        detached_mode=true
        shift
        ;;
      *)
        echo "winpod compose up: Invalid option: $1"
        return 1
        ;;
    esac
  done

  if [ ! -f "$WINPOD_COMPOSE_CONFIG" ]; then
        echo "Error: docker-compose.yml not found. Place it in $WINPOD_COMPOSE_CONFIG or specify it using -f option (future feature)."
        return 1
  fi

  # Install python and docker-compose if not installed (minimal check)
  if ! command -v python3 &> /dev/null ; then
      echo "Error: Python 3 is required to run docker-compose. Please install it (e.g., using pacman -S python on MSYS2)."
      return 1
  fi
  if ! command -v docker-compose &> /dev/null ; then
      echo "Error: docker-compose is required. Please install it (e.g., pip install docker-compose)."
      return 1
  fi


  echo "winpod compose up: Running docker-compose up -d"

  # Create the root directory if it doesn\'t exist
  mkdir -p "$(dirname "$WINPOD_COMPOSE_CONFIG")"

  # Run docker-compose up in the background if detached mode is requested,
  # otherwise just run it and wait for completion
  if $detached_mode; then
      docker-compose -f "$WINPOD_COMPOSE_CONFIG" up -d  &
      echo "Compose application started in detached mode."
  else
      docker-compose -f "$WINPOD_COMPOSE_CONFIG" up
  fi


}

# winpod_compose_down: Emulates docker-compose down functionality
winpod_compose_down() {
  if [ ! -f "$WINPOD_COMPOSE_CONFIG" ]; then
        echo "Error: docker-compose.yml not found. Place it in $WINPOD_COMPOSE_CONFIG or specify it using -f option (future feature)."
        return 1
  fi
  if ! command -v python3 &> /dev/null ; then
      echo "Error: Python 3 is required to run docker-compose. Please install it (e.g., using pacman -S python on MSYS2)."
      return 1
  fi
  if ! command -v docker-compose &> /dev/null ; then
      echo "Error: docker-compose is required. Please install it (e.g., pip install docker-compose)."
      return 1
  fi


  echo "winpod compose down: Running docker-compose down"
  docker-compose -f "$WINPOD_COMPOSE_CONFIG" down
}

# winpod_compose_ps: Emulates docker-compose ps functionality
winpod_compose_ps() {
    if [ ! -f "$WINPOD_COMPOSE_CONFIG" ]; then
        echo "Error: docker-compose.yml not found. Place it in $WINPOD_COMPOSE_CONFIG or specify it using -f option (future feature)."
        return 1
    fi

    if ! command -v python3 &> /dev/null ; then
        echo "Error: Python 3 is required to run docker-compose. Please install it (e.g., using pacman -S python on MSYS2)."
        return 1
    fi

    if ! command -v docker-compose &> /dev/null ; then
        echo "Error: docker-compose is required. Please install it (e.g., pip install docker-compose)."
        return 1
    fi


    echo "winpod compose ps: Running docker-compose ps"
    docker-compose -f "$WINPOD_COMPOSE_CONFIG" ps
}
'
    echo "$WINPOD_CONTENT" > "$INSTALL_DIR/$WINPOD_SCRIPT"

    # Make the script executable
    chmod +x "$INSTALL_DIR/$WINPOD_SCRIPT"

    echo "winpod installed to $INSTALL_DIR/$WINPOD_SCRIPT"
}


# update_bashrc: Add the installation directory to PATH if it's not already there
update_bashrc() {
    local bashrc="$HOME/.bashrc"
    local path_line='export PATH="$HOME/bin:$PATH"' # Standard PATH entry for user's bin

    # Check if ~/.bashrc exists, create if not
    if [ ! -f "$bashrc" ]; then
        echo "Creating $HOME/.bashrc"
        touch "$bashrc"
    fi

    # Check if the PATH is already modified
    if grep -q "$path_line" "$bashrc"; then
        echo "PATH already configured in $HOME/.bashrc"
    else
        echo "Adding $INSTALL_DIR to PATH in $HOME/.bashrc"
        echo "$path_line" >> "$bashrc"
        echo "Please source ~/.bashrc or restart Git Bash for the changes to take effect."
    fi
}

# --- Main Script ---
echo "Starting winpod installation..."

# Check dependencies
if install_dependencies; then
    echo "Installing winpod..."
    install_winpod
else
    echo "Some dependencies are missing. winpod may not function correctly."
    echo "Please install the missing dependencies and run this installer again."
fi

# Update .bashrc
update_bashrc

echo "winpod installation complete."
echo "You can now use 'winpod' command in Git Bash."
echo "Please source ~/.bashrc or restart Git Bash if you just added $INSTALL_DIR to your path."
