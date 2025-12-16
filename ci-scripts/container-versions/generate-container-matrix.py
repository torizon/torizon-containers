#!/usr/bin/env -S uv run
# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "ruamel-yaml",
# ]
# ///

# You need `uv` installed to run this program https://docs.astral.sh/uv/
# Then run as `./generate-container-matrix.py .`

import os
import glob
import re
from collections import defaultdict
from ruamel.yaml import YAML
from collections import OrderedDict

FOLDER = '.'

PLATFORM_SUFFIXES = ['am62', 'am62p', 'am67a', 'am69', 'sl1680', 'imx8', 'imx93', 'imx95']

def detect_platform(key):
    for platform in PLATFORM_SUFFIXES:
        if key.endswith("-" + platform) or key.endswith("_" + platform):
            return platform
    return "upstream"

def collect_yaml_files(folder):
    return glob.glob(os.path.join(folder, "*.yml")) + glob.glob(os.path.join(folder, "*.yaml"))

def parse_yaml_file(filename):
    yaml = YAML(typ='safe')
    with open(filename, 'r') as f:
        return yaml.load(f)

def collect_all_by_platform(folder):
    platform_bins = defaultdict(OrderedDict)
    files = collect_yaml_files(folder)
    for filename in sorted(files):
        data = parse_yaml_file(filename)
        if not data:
            continue
        for key, value in data.items():
            platform = detect_platform(key)
            platform_bins[platform][key] = value
    return platform_bins

def print_markdown_tables(platform_bins):
    for platform in PLATFORM_SUFFIXES + ['upstream']:
        if platform not in platform_bins:
            continue
        items = platform_bins[platform]
        if not items:
            continue
        print(f"\n### Platform: `{platform}`\n")
        print("| Name" + " " * 36 + "| Major | Minor | Patch |")
        print("|" + "-"*41 + "|-------|-------|-------|")
        maxlen = max(len(name) for name in items)
        for name, version in items.items():
            pad = ' ' * (40 - len(name)) if maxlen < 40 else ' '
            major = version.get('major', '')
            minor = version.get('minor', '')
            patch = version.get('patch', '')
            print(f"| {name}{' ' * (40 - len(name))}|  {major:<5}|  {minor:<5}|  {patch:<5}|")
        print()

def main():
    platform_bins = collect_all_by_platform(FOLDER)
    if not any(platform_bins.values()):
        print("No YAML files or no valid data.")
        return
    print("# Container Version Matrix\n")
    print_markdown_tables(platform_bins)

if __name__ == "__main__":
    main()
