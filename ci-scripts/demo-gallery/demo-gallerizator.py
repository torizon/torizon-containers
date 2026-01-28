import os
import shutil
import argparse
import subprocess
import json

"""
To run locally: python ./ci-scripts/demo-gallery/demo-gallerizator.py tests/composes
"""
platforms = {
    "imx8": [
        "apalis-imx8",
        "colibri-imx8x",
        "verdin-imx8mm",
        "verdin-imx8mp",
        "smarc-imx8mp",
    ],
    "am62": [
        "verdin-am62",
        "sk-am62",
        "sk-am62l",
    ],
    "am69": ["aquila-am69"],
    "am62p": [
        "verdin-am62p",
        "sk-am62p",
    ],
    "imx95": [
        "verdin-imx95",
        "smarc-imx95",
    ],
    "sl1680": [
        "astra-sl1680",
        "luna-sl1680",
    ],
    "upstream": [
        "apalis-imx6",
        "colibri-imx6",
        "colibri-imx6ull",
        "colibri-imx7",
        "frdm-imx93",
    ],
}

apps_deny_list = ["chromium-tests"]


def recursively_replace_contents(target_content, replace_with, target_dir):
    for root, _, files in os.walk(target_dir):
        for file in files:
            file_path = os.path.join(root, file)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            new_content = content.replace(target_content, replace_with)
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(new_content)


def generate_app_json(composes_dir):
    print("Finding apps...")
    for app in os.listdir(composes_dir):
        print(f"Found {app}")
        app_dir = os.path.join(composes_dir, app)
        if not os.path.isdir(app_dir):
            continue

        platform = None
        packages = []
        for fname in os.listdir(app_dir):
            if fname.startswith("docker-compose-") and fname.endswith(".yml"):
                description = None
                # Try to read description from separate .description file
                description_file_path = os.path.join(app_dir, fname + ".description")
                if os.path.exists(description_file_path):
                    try:
                        with open(description_file_path, "r", encoding="utf-8") as f:
                            description = f.read().strip()
                    except Exception as e:
                        print(
                            f"Warning: Could not read description file {description_file_path}: {e}"
                        )
                        description = None

                # Parse platform from filename
                # Format: docker-compose-<platform>.yml
                platform = fname[len("docker-compose-") : -len(".yml")]
                package = {
                    "name": f"{app}-{platform}",
                    "filename": fname,
                    # FIXME: hardcoded!
                    "version": "4",
                    "description": description if description else "",
                }
                packages.append(package)

        if packages:
            app_json = {"packages": packages}
            with open(os.path.join(app_dir, "app.json"), "w", encoding="utf-8") as f:
                json.dump(app_json, f, indent=4)
            print(f"Generated app.json for {app}: {platform}")


def extract_description_from_file(file_path):
    """Extract description from the first line of a docker-compose file."""
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            first_line = f.readline()
            if first_line.startswith("# description: "):
                return first_line.replace("# description: ", "").rstrip().capitalize()
    except Exception as e:
        print(f"Warning: Could not extract description from {file_path}: {e}")
    return None


def main(composes_dir):
    # tcb doesn't support canonicalizing compose files with a fully qualified image
    # ie, an `image:` specifying the registry such as `docker.io/torizon/weston:stable-rc`
    recursively_replace_contents("$REGISTRY/", "", composes_dir)
    # FIXME: we should only do this on torizon-containers releases, ie, tags
    recursively_replace_contents("stable-rc", "4", composes_dir)

    temp_dir = "./temp"

    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)

    platform_app_deny_dict = {
        "upstream": ["chromium", "chromium-tests"],
        "imx8": ["chromium-tests"],
        "am62": ["chromium-tests"],
        "am69": ["chromium-tests"],
        "imx95": ["chromium-tests"],
        "am62p": ["chromium-tests"],
        "sl1680": ["chromium-tests"],
    }

    # For each platform
    for platform, members in platforms.items():
        # For each app in ./composes
        for app in os.listdir(composes_dir):
            if app in platform_app_deny_dict[platform]:
                print(
                    f"Not demo-gallelirizing {app} on {platform} because it's on the deny list"
                )
                continue
            app_path = os.path.join(composes_dir, app)
            if not os.path.isdir(app_path):
                continue
            compose_pattern = f"{app}-{platform}-compose.yml"
            compose_file_path = os.path.join(app_path, compose_pattern)
            if not os.path.isfile(compose_file_path):
                continue

            # Extract description from original file before copying
            description = extract_description_from_file(compose_file_path)

            # For each member of platform
            for member in members:
                dest_dir = os.path.join(temp_dir, app)
                os.makedirs(dest_dir, exist_ok=True)
                dest_file = os.path.join(dest_dir, f"docker-compose-{member}.yml")
                shutil.copyfile(compose_file_path, dest_file)
                print(f"Created: {dest_file}")

                # Save description to a separate file if it exists
                if description:
                    description_file = dest_file + ".description"
                    with open(description_file, "w", encoding="utf-8") as f:
                        f.write(description)
                    print(f"Saved description: {description_file}")

    temp_dir = "./temp"

    base_cmd = [
        "docker",
        "run",
        "--platform",
        "linux/amd64",
        "--rm",
        "-v",
        "/deploy",
        "-v",
        f"{os.getcwd()}:/workdir",
        "-v",
        "storage:/storage",
        "--net=host",
        "-v",
        "/var/run/docker.sock:/var/run/docker.sock",
        "torizon/torizoncore-builder:3",
    ]

    for root, dirs, files in os.walk(temp_dir):
        for file in files:
            if (
                file.startswith("docker-compose-")
                and not file.endswith(".lock.yml")
                and not file.endswith(".description")
            ):
                compose_file_path = os.path.join(root, file)

                # Canonicalize each compose file (ie, generate a .lock file with torizoncore-builder)
                cmd = base_cmd + [
                    "platform",
                    "push",
                    "--canonicalize-only",
                    "--force",
                    compose_file_path,
                ]

                try:
                    subprocess.run(cmd, capture_output=True, text=True, check=True)
                    print(f"Canonicalized: {compose_file_path}")
                except subprocess.CalledProcessError as e:
                    print(f"Error canonicalizing {compose_file_path}:\n{e.stderr}")
                    continue

                # Replace the original docker-compose with the canonicalized version
                lock_file_path = compose_file_path.replace(".yml", ".lock.yml")
                if os.path.exists(lock_file_path):
                    with open(lock_file_path, "r", encoding="utf-8") as lock_file:
                        lock_content = lock_file.read()
                    with open(compose_file_path, "w", encoding="utf-8") as orig_file:
                        orig_file.write(lock_content)
                    os.remove(lock_file_path)
                    print(f"Replaced and removed lock file: {compose_file_path}")
                else:
                    print(f"Lock file not found for: {compose_file_path}")

    generate_app_json(temp_dir)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("composes_dir", help="Path to the composes directory")
    args = parser.parse_args()
    main(args.composes_dir)
