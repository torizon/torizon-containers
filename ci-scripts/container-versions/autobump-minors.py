#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "ruamel-yaml",
# ]
# ///
# This is a small script that may be useful during bump releases, where we
# by definition bump all the minors in the respective yml files in the
# container-versions dir.

# You need `uv` installed to run this program https://docs.astral.sh/uv/
# Then run as `./autobump-minors.py .`

import os
import sys
from ruamel.yaml import YAML


def main():

    yaml = YAML()
    yaml.preserve_quotes = True

    for root, _, files in os.walk(sys.argv[1]):
        for file in files:
            if file.endswith(".yml") or file.endswith(".yaml"):
                file_path = os.path.join(root, file)

                with open(file_path, "r") as yaml_file:
                    data = yaml.load(yaml_file)

                modified = False

                for item in data.keys():
                    if (
                        isinstance(data[item], dict)
                        and "minor" in data[item]
                        and "patch" in data[item]
                    ):
                        current_minor = data[item]["minor"]
                        data[item]["minor"] = current_minor + 1
                        data[item]["patch"] = 0
                        modified = True

                if modified:
                    with open(file_path, "w") as yaml_file:
                        yaml.dump(data, yaml_file)


if __name__ == "__main__":
    main()
