import os
import shutil
import argparse
import subprocess
import json

"""
DEMO_GALLERY_VERSION is required: it replaces the "${RELEASE_TAG}-rc" image tags
in the generated composes, so it has to be passed in the command.

To run locally:

    DEMO_GALLERY_VERSION=<series> python ./ci-scripts/demo-gallery/demo-gallerizator.py tests/demo-gallery-composes

To use the same value CI does, which is the "major:" from
ci-scripts/container-versions/*.yml:

    . ./ci-scripts/release-tag.sh
    . ./ci-scripts/release/release-version.sh
    DEMO_GALLERY_VERSION="$RELEASE_SERIES" python ./ci-scripts/demo-gallery/demo-gallerizator.py tests/demo-gallery-composes
"""
DEMO_GALLERY_VERSION = os.environ.get("DEMO_GALLERY_VERSION")

_PLATFORMS_ENV = os.environ.get("PLATFORMS", "").replace(",", " ").split()

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
    "am67a": [
        "beagley-ai",
    ],
    "am69": [
        "aquila-am69",
    ],
    "am62p": [
        "verdin-am62p",
        "sk-am62p",
    ],
    "imx93": [
        "frdm-imx93",
    ],
    "imx95": [
        "verdin-imx95",
        "smarc-imx95",
        "aquila-imx95",
    ],
    "sl1680": [
        "astra-sl1680",
        "luna-sl1680",
    ],
    "orin": [
        "jetson-orin-nano-devkit",
        "jetson-orin-nano-devkit-nvme",
    ],
    "thor": [
        "jetson-agx-thor-devkit",
        "jetson-agx-thor-t4000",
    ],
    "upstream": [
        "apalis-imx6",
        "colibri-imx6",
        "colibri-imx6ull",
        "colibri-imx7",
    ],
}

DISABLED_MARKER = ".disabled"

SELECTED_PLATFORMS = (
    [p for p in platforms if p in _PLATFORMS_ENV] if _PLATFORMS_ENV else list(platforms)
)
SELECTED_MEMBERS = {m for p in SELECTED_PLATFORMS for m in platforms[p]}


def member_of(compose_filename):
    """docker-compose-verdin-imx8mm.yml -> verdin-imx8mm"""
    return compose_filename[len("docker-compose-") : -len(".yml")]


def app_dirs(root):
    if not os.path.isdir(root):
        return []
    return [
        d
        for d in sorted(os.listdir(root))
        if os.path.isdir(os.path.join(root, d)) and not d.startswith(".")
    ]


def compose_files(app_dir):
    return [
        f
        for f in sorted(os.listdir(app_dir))
        if f.startswith("docker-compose-") and f.endswith(".yml")
    ]


def merge_into_gallery(temp_dir, gallery_dir):
    """Overlay the generated composes onto an existing gallery checkout.

    Only files belonging to the selected platforms are touched. Everything else
    the gallery already publishes is left exactly as it is.
    """
    for app in app_dirs(gallery_dir):
        app_path = os.path.join(gallery_dir, app)
        for fname in compose_files(app_path):
            if member_of(fname) in SELECTED_MEMBERS:
                os.remove(os.path.join(app_path, fname))
                desc = os.path.join(app_path, fname + ".description")
                if os.path.exists(desc):
                    os.remove(desc)

    for app in app_dirs(temp_dir):
        src, dst = os.path.join(temp_dir, app), os.path.join(gallery_dir, app)
        os.makedirs(dst, exist_ok=True)
        for fname in os.listdir(src):
            if fname == "app.json":
                continue
            shutil.copyfile(os.path.join(src, fname), os.path.join(dst, fname))

    for app in app_dirs(gallery_dir):
        app_path = os.path.join(gallery_dir, app)
        remaining = compose_files(app_path)
        if not remaining:
            shutil.rmtree(app_path)
            print(f"Removed now-empty app: {app}")
            continue

        generated = {}
        gen_json = os.path.join(temp_dir, app, "app.json")
        if os.path.exists(gen_json):
            with open(gen_json, encoding="utf-8") as f:
                generated = {p["name"]: p for p in json.load(f)["packages"]}

        kept = {}
        old_json = os.path.join(app_path, "app.json")
        if os.path.exists(old_json):
            with open(old_json, encoding="utf-8") as f:
                for pkg in json.load(f)["packages"]:
                    if member_of(pkg["filename"]) not in SELECTED_MEMBERS:
                        kept[pkg["name"]] = pkg

        merged = {**kept, **generated}
        merged = {
            n: p for n, p in merged.items() if p["filename"] in remaining
        }
        with open(old_json, "w", encoding="utf-8") as f:
            json.dump({"packages": [merged[n] for n in sorted(merged)]}, f, indent=4)
        print(f"Merged app.json for {app}: {len(merged)} packages")


def is_app_disabled(app_dir):
    """An app is kept out of the published feed if it contains a `.disabled` marker file."""
    return os.path.exists(os.path.join(app_dir, DISABLED_MARKER))


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
                    "version": DEMO_GALLERY_VERSION,
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


def main(composes_dir, merge_into=None):
    # tcb doesn't support canonicalizing compose files with a fully qualified image
    # ie, an `image:` specifying the registry such as `docker.io/torizon/weston:stable-rc`
    recursively_replace_contents("$REGISTRY/", "", composes_dir)
    # FIXME: we should only do this on torizon-containers releases, ie, tags
    recursively_replace_contents("${RELEASE_TAG}-rc", DEMO_GALLERY_VERSION, composes_dir)

    temp_dir = "./temp"

    if not os.path.exists(temp_dir):
        os.makedirs(temp_dir)

    disabled_apps = {
        app
        for app in os.listdir(composes_dir)
        if os.path.isdir(os.path.join(composes_dir, app))
        and is_app_disabled(os.path.join(composes_dir, app))
    }
    for app in sorted(disabled_apps):
        print(f"Skipping disabled app: {app}")

    # For each platform
    for platform, members in platforms.items():
        if platform not in SELECTED_PLATFORMS:
            print(f"Skipping platform not in $PLATFORMS: {platform}")
            continue
        # For each app in ./composes
        for app in os.listdir(composes_dir):
            app_path = os.path.join(composes_dir, app)
            if not os.path.isdir(app_path):
                continue
            if app in disabled_apps:
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

    if merge_into:
        print(f"Selected platforms: {' '.join(SELECTED_PLATFORMS)}")
        merge_into_gallery(temp_dir, merge_into)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("composes_dir", help="Path to the composes directory")
    parser.add_argument(
        "--merge-into",
        metavar="GALLERY_DIR",
        help="Overlay the result onto an existing gallery checkout, touching only "
        "the platforms in $PLATFORMS instead of replacing the whole tree.",
    )
    args = parser.parse_args()
    main(args.composes_dir, args.merge_into)
