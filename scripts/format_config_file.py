#!/usr/bin/env python3

from jinja2 import Environment, FileSystemLoader
import yaml
import argparse

# pull in the arguments needed for the script
parser = argparse.ArgumentParser()
parser.add_argument("--config", required=True)
parser.add_argument("--long_reads", required=True)
parser.add_argument("--hic_reads", default=None)

args = parser.parse_args()

# load config file
with open(args.config) as f:
    config = yaml.safe_load(f)

# reformat the long reads so they're being parsed as file paths
long_reads = args.long_reads.split(",")

# do the same to the hic reads if there are any
if args.hic_reads is not None:
    hic_reads = args.hic_reads.split(",")
else:
    hic_reads = None

# determine whether we're using PacBio or ONT assemblies
if "PACBIO_SMRT" in config.get("reads", {}):
    platform = "pacbio"
else:
    platform = "ont"

# merge config file with the CLI args 
context = {
    **config,                     # everything from config file
    "platform": platform,         # override / add CLI values    
    "long_reads": long_reads,
    "hic_reads": hic_reads,
}

# render template
env = Environment(loader=FileSystemLoader("assets"))

template = env.get_template("config_template.yaml.j2")

rendered = template.render(context)

# write config file
with open(f"sanger_config.yaml", "w") as f:
    f.write(rendered)
