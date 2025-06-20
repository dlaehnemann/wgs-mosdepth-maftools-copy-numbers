# import basic packages
import pandas as pd
from snakemake.utils import validate


# read sample sheet
samples = (
    pd.read_csv(config["samplesheet"], sep="\t", dtype={"sample": str})
    .set_index("sample", drop=False)
    .sort_index()
)

# validate sample sheet and config file
validate(samples, schema="../../config/schemas/samples.schema.yml")
validate(config, schema="../../config/schemas/config.schema.yml")

def final_results(wildcards):
    final_results = []
    background_alias = lookup(within=config, dpath="background_alias", default="")
    if background_alias:
        for g in lookup(within=samples, cols="group"):
            final_results.extend(
                expand(
                    "results/maftools/{group}.{alias}.cbs.seg",
                    group=g,
                    alias=lookup(within=samples, query="group == '{group}' & alias != '{background_alias}'", cols=alias),
                )
            )
    else:
        final_results.extend(
            expand(
                "results/maftools/{sample}.cbs.seg",
                sample=lookup(within=samples, cols="sample_name"),
            )
        )
    return final_results
