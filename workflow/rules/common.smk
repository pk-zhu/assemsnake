# Define function for the inputs to rule_all
# this rule just defines the inputs to the final rule

import os

wildcard_constraints:
    hap = "primary|hap1|hap2",

# phased 双链不支持 purge (上游 colora 同约定); 坍缩 primary 允许单次 purge (本 fork)
if diploid_mode and config.get("include_purge_dups", False):
    sys.exit("You set `phased_assembly: True` — phased assembly must skip purge_dups, please set `include_purge_dups: False` in config.yaml.")

def get_all_inputs(wc=None):
    hap = downstream_haps
    if not sample:
        # Show the user a meaningful error message
        logger.error(f"No files matching {samples_in_pattern} were found in"
                     f" {config.get('hic_path')}. Please check your config file.")
        logger.error(f"Exiting.")
        sys.exit(1)
    # 单次 purge_dups 作用于 primary, 与 phased 模式兼容 (本项目异源四倍体坍缩一次即可)

    inputs = [
        "results/nanoplot/NanoPlot-report.html",  # nanoplot report
        "results/kmc/out.hist",  # output of kmc rule
        "results/genomescope",  # output directory of genomescope
        "results/quast", # output directory of quast
        "results/busco", # output directory of busco
    ]

    inputs.extend(expand(
            "results/yahs_{hap}/asm_yahs_scaffolds_final.fa", hap=hap
        ))  # final scaffolded assembly (yahs)

    # AutoHiC (3D-DNA) scaffold 修正 (include_autohic)
    if config.get("include_autohic", False):
        inputs.extend(expand(
            "results/autohic_{hap}/error_summary.json",
            hap=hap))

    if pltd:
        inputs.append("results/bandage_pltd/pltd.jpg")
        inputs.append("results/bandage_pltd/mito.jpg")
        inputs.append("results/gfastats_pltd/pltd.stats")
        inputs.append("results/gfastats_pltd/mito.stats")

    if not pltd:
        inputs.append("results/bandage/mito.jpg")
        inputs.append("results/gfastats/mito.stats")

    return inputs


# create a function to read the inputs of purge_dups rule dynamically
def get_purge_dups_inputs():
    if config["include_fcsgx"] == True:
        return "results/ncbi_fcsgx_primary/asm_clean.fa"
    else:
        return "results/hifiasm/asm.primary.fa"


# create a function to read the inputs of bwa_index rule dynamically
# This will affect the "REF" input in the following rules:
# bwa_index
# bwa_mem
# two_read_bam_combiner
# yahs

def get_bwa_index_inputs(wildcards):
    hap = wildcards.hap
    if config["include_purge_dups"] == True:
        return "results/purge_dups/asm.{hap}_purged.fa"
    elif config["include_fcsgx"] == True:
        return f"results/ncbi_fcsgx_{hap}/asm_clean.fa"
    else:
        return f"results/hifiasm/asm.{hap}.fa"


def get_assemblies_QC(wildcards=None):
    results = {}
    for hap in downstream_haps:
        results[f"asm_{hap}"] = f"results/assemblies/asm_{hap}.fa"
        results[f"yahs_{hap}"] = f"results/assemblies/yahs_{hap}.fa"
        if config["include_purge_dups"]:
            results[f"purged_{hap}"] = f"results/assemblies/purged_{hap}.fa"  
        if config["include_fcsgx"]:
            results[f"fcsgx_{hap}"] = f"results/assemblies/fcsgx_{hap}.fa"
    return results