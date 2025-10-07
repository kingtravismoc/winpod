This README.md is designed to provide comprehensive documentation for the `winpod` project, which offers a minimal Podman-like experience within a Windows Git Bash environment.

While GitHub Flavored Markdown (GFM) does not natively support "live command editors," "widgets," or dynamic "logic objects" as described, this document simulates a "command constructor" experience by providing a highly organized, configurable, multi-output copy box section. This section offers pre-generated commands for various `winpod` operations, making it easy for users to quickly understand and execute common tasks. Each command is presented in a readily copyable code block, acting as a static, yet highly usable, "widget" for command generation.

---

# `winpod`: Minimal Podman-like Tool for Windows (Git Bash)

`winpod` is a lightweight shell script designed to bring a container-management experience similar to Podman or Docker to Windows users operating within Git Bash. It aims to provide basic functionalities for pulling images, running containers, listing resources, and even managing multi-container applications with `docker-compose` (if available), all without requiring administrative privileges or complex daemon setups.

## 🚀 Features

*   **Image Pulling:** Fetch container images from Docker Hub.
*   **Container Execution:** Run images as isolated "containers" (chroot-based).
*   **Image Management:** List and remove downloaded images.
*   **Container Management:** List and remove active/inactive containers (basic).
*   **Docker Compose Integration:** Leverage `docker-compose` (if installed) for multi-container application management.
*   **No Daemon Required:** Operates directly from Git Bash, offering a simplified setup.
*   **Minimal Dependencies:** Utilizes `skopeo`, `curl`, `jq`, `tar`, and `python`/`docker-compose` for core functionalities.

## 🛠️ Installation

The `winpod_installer.sh` script automates the setup process for `winpod` on your Git Bash environment.

### Prerequisites

*   **Git Bash:** Ensure Git Bash is installed and available on your system.
*   **MSYS2 Pacman:** For installing system-level dependencies (like `skopeo`, `jq`, `python`). You can access `pacman` directly from your Git Bash terminal if MSYS2 is integrated, or by running `C:\msys64\msys2_shell.cmd -use-full-path -no-start -usr-xwin -here` from within Git Bash if you installed MSYS2 separately.

### Dependencies

`winpod` relies on several tools for its full functionality. The installer will check for these and provide guidance.

*   **`skopeo` (Recommended for Image Pulling):**
    *   **Description:** Tool for copying container images between different registries and image formats.
    *   **Installation (MSYS2/Git Bash):**
        ```bash
        pacman -S skopeo
        ```
*   **`jq` (Required for Fallback Image Pulling):**
    *   **Description:** Lightweight and flexible command-line JSON processor. Used by `winpod` if `skopeo` is not available.
    *   **Installation (MSYS2/Git Bash):**
        ```bash
        pacman -S jq
        ```
*   **`python3` & `docker-compose` (Optional for Compose Functionality):**
    *   **Description:** Python is required to run `docker-compose`. `docker-compose` allows you to define and run multi-container Docker applications.
    *   **Installation (Python 3 via MSYS2/Git Bash):**
        ```bash
        pacman -S python
        ```
    *   **Installation (`docker-compose` via pip):**
        ```bash
        pip install docker-compose
        ```

### Installation Steps

1.  **Download the Installer:**
    ```bash
    curl -o winpod_installer.sh https://raw.githubusercontent.com/your-username/your-repo/main/winpod_installer.sh # Replace with actual URL
    chmod +x winpod_installer.sh
    ```
    Alternatively, you can copy the content of `winpod_installer.sh` into a file named `winpod_installer.sh` in your Git Bash environment.

2.  **Run the Installer:**
    ```bash
    ./winpod_installer.sh
    ```
    The installer will:
    *   Check for required dependencies.
    *   Install the `winpod` script into `$HOME/bin`.
    *   Add `$HOME/bin` to your `PATH` in `~/.bashrc` if it's not already there.

3.  **Reload your `bash` environment:**
    ```bash
    source ~/.bashrc
    ```
    Or simply restart your Git Bash terminal.

## 🚀 Usage

Once installed, you can use the `winpod` command from your Git Bash terminal.

### Basic Examples

```bash
# Pull an Ubuntu image
winpod pull ubuntu:latest

# List available images
winpod images

# Run a container from the pulled Ubuntu image
winpod run ubuntu:latest

# List running containers (placeholder for future implementation)
winpod ps
```

## 🎛️ Command Constructor / Example Commands

This section provides a "command constructor" experience, allowing you to quickly copy and paste `winpod` commands for various tasks. Simply click the copy icon or highlight the command you need.

---

### 📦 Image Management Commands

Manage your downloaded container images.

#### Pulling an Image

Downloads a specified image from Docker Hub.
<details>
<summary>Click to view example options</summary>

*   **Pull `ubuntu:latest`:** Get the latest Ubuntu base image.
    ```bash
    winpod pull ubuntu:latest
    ```
*   **Pull `alpine:3.18`:** Download a specific version of Alpine Linux.
    ```bash
    winpod pull alpine:3.18
    ```
*   **Pull `nginx:stable-alpine`:** Fetch a lightweight Nginx server image.
    ```bash
    winpod pull nginx:stable-alpine
    ```
</details>

#### Listing Images

Displays all images currently available in your local `winpod` image store.
<details>
<summary>Click to view example options</summary>

*   **List all images:**
    ```bash
    winpod images
    ```
</details>

#### Removing an Image

Deletes a previously pulled image from your local store.
<details>
<summary>Click to view example options</summary>

*   **Remove `ubuntu:latest`:**
    ```bash
    winpod rmi ubuntu:latest
    ```
*   **Remove `alpine:3.18`:**
    ```bash
    winpod rmi alpine:3.18
    ```
</details>

---

### 🏃 Container Management Commands

Interact with running and stopped containers.

#### Running a Container

Starts a new container from a specified image.
<details>
<summary>Click to view example options</summary>

*   **Run `ubuntu:latest` and get a bash shell:**
    ```bash
    winpod run ubuntu:latest
    ```
*   **Run `alpine:latest` and get a shell:**
    ```bash
    winpod run alpine:latest
    ```
</details>

#### Listing Containers

(Placeholder) Intended to list currently active containers.
<details>
<summary>Click to view example options</summary>

*   **List all containers:**
    ```bash
    winpod ps
    ```
</details>

#### Removing a Container

Deletes a stopped container.
<details>
<summary>Click to view example options</summary>

*   **Remove a container named `my-web-app`:** (Note: `winpod` currently derives container names from images.)
    ```bash
    winpod rm ubuntu-latest # Based on winpod run ubuntu:latest
    ```
</details>

---

### 🔗 Compose Commands

Integrate with `docker-compose` for multi-container application management. Requires `python3` and `docker-compose` to be installed. Ensure your `docker-compose.yml` is located at `$HOME/.winpod/compose.yml`.

#### Starting Compose Services

Brings up all services defined in your `docker-compose.yml`.
<details>
<summary>Click to view example options</summary>

*   **Start compose services in foreground:**
    ```bash
    winpod compose up
    ```
*   **Start compose services in detached mode:**
    ```bash
    winpod compose up -d
    ```
</details>

#### Stopping Compose Services

Shuts down and removes all services defined in your `docker-compose.yml`.
<details>
<summary>Click to view example options</summary>

*   **Stop and remove compose services:**
    ```bash
    winpod compose down
    ```
</details>

#### Listing Compose Services

Displays the status of services defined in your `docker-compose.yml`.
<details>
<summary>Click to view example options</summary>

*   **List compose services status:**
    ```bash
    winpod compose ps
    ```
</details>

---

## 📖 Command Reference

This section provides a detailed overview of each `winpod` command and its usage.

### `winpod help`

Display the main help message, listing available commands and compose subcommands.

```bash
winpod help
```

### `winpod run <image>`

Run a container from a specified image.

#### Arguments:
*   `image`: The name of the image to run (e.g., `ubuntu:latest`).

#### Example:
```bash
winpod run myimage:1.0
```

### `winpod pull <image>`

Pull a container image from Docker Hub.

#### Arguments:
*   `image`: The name of the image to pull (e.g., `alpine:3.18`).

#### Example:
```bash
winpod pull nginx:latest
```

### `winpod images`

List all available images that have been pulled and stored locally.

#### Example:
```bash
winpod images
```

### `winpod ps`

List running containers (currently a placeholder for future, more robust implementation).

#### Example:
```bash
winpod ps
```

### `winpod rm <container>`

Remove a container by its name.
*Note: `winpod` currently names containers by transforming the image name (e.g., `ubuntu:latest` becomes `ubuntu-latest`).*

#### Arguments:
*   `container`: The name of the container to remove.

#### Example:
```bash
winpod rm mycontainer-name
```

### `winpod rmi <image>`

Remove a stored image by its name.

#### Arguments:
*   `image`: The name of the image to remove.

#### Example:
```bash
winpod rmi unwanted-image:tag
```

### `winpod compose <subcommand>`

Manage multi-container applications using `docker-compose`. This command requires `python3` and `docker-compose` to be installed and assumes a `docker-compose.yml` file is located at `$HOME/.winpod/compose.yml`.

#### Subcommands:

#### `winpod compose up [-d]`
Start the services defined in your `docker-compose.yml`.

*   **Options:**
    *   `-d`: Run services in detached (background) mode.

#### `winpod compose down`
Stop and remove the services and associated networks defined in your `docker-compose.yml`.

#### `winpod compose ps`
List the containers and their status for your `docker-compose` application.

#### Examples:
```bash
# Start compose services in detached mode
winpod compose up -d

# Stop and remove compose services
winpod compose down

# List compose services status
winpod compose ps
```

## 🤝 Contributing

Contributions are welcome! If you have suggestions for improvements, new features, or bug fixes, please follow these steps:

1.  **Fork** the repository.
2.  **Create** a new branch (`git checkout -b feature/your-feature`).
3.  **Implement** your changes.
4.  **Test** your changes thoroughly.
5.  **Commit** your changes (`git commit -am 'Add new feature'`).
6.  **Push** to the branch (`git push origin feature/your-feature`).
7.  **Open** a Pull Request.

### To-Do List

*   [ ] Implement more robust container lifecycle management (start, stop, pause, restart).
*   [ ] Improve image pulling for non-skopeo fallbacks (proper tar extraction, manifest handling).
*   [ ] Enhance `winpod ps` to show actual running processes.
*   [ ] Add volume mounting capabilities.
*   [ ] Support custom container names on `winpod run`.
*   [ ] Improve error handling and user feedback.
*   [ ] Write unit tests for the installer and `winpod` script.

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
