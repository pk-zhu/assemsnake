# This rule uses hifiasm to assemble the genome from the hifi reads
# 产物形态由 scaffold_sets 反推 (下游挂载链数):
#   collapsed = 只要 bp.p_ctg → asm.primary.fa (optional_params 里的 --n-hap K 仅为坍缩调参)
#   haplotype = 额外产 hap1/hap2 两套单倍型 fasta (自动补 --n-hap, 供下游双链)
# hifiasm 各模式均产 bp.p_ctg, 差别只在是否额外出单倍型/alternate

params_hifiasm = " ".join(
    f"{k} {v}" if v else f"{k}"
    for k, v in config["hifiasm"]["optional_params"].items() if v is not False
)

if scaffold_sets == "haplotype":
    # 自动补 --n-hap (缺省 2), 保证产单倍型 fasta
    if "--n-hap" not in config["hifiasm"]["optional_params"]:
        params_hifiasm += " --n-hap 2"

    rule hifiasm:
        input:
            reads = "results/reads/hifi/hifi.fastq.gz",
        output:
            gfa="results/hifiasm/asm.primary.gfa",
            fasta="results/hifiasm/asm.primary.fa",
            link="results/assemblies/asm_primary.fa",
            gfa_h1="results/hifiasm/asm.hap1.gfa",
            fasta_h1="results/hifiasm/asm.hap1.fa",
            link_h1="results/assemblies/asm_hap1.fa",
            gfa_h2="results/hifiasm/asm.hap2.gfa",
            fasta_h2="results/hifiasm/asm.hap2.fa",
            link_h2="results/assemblies/asm_hap2.fa",
        threads: config["high"]["t"]
        log:
            "logs/hifiasm.log",
        resources:
            mem_mb=config["high"]["mem_mb"],
        conda:
            "../envs/hifiasm.yaml"
        params:
            optional_params=params_hifiasm,
        shell:
            r"""
            rm -f results/hifiasm/asm.*.gfa results/hifiasm/asm.*.bed
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm {params.optional_params} >> {log} 2>&1
            echo "=== hifiasm 产出的 gfa 文件 ===" >> {log}
            ls -la results/hifiasm/asm.*.gfa >> {log} 2>&1
            # 坍缩 primary = bp.p_ctg, 对齐下游命名; hapN = 单倍型副本
            ln -srn results/hifiasm/asm.bp.p_ctg.gfa {output.gfa}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa} > {output.fasta}
            ln -srn {output.fasta} {output.link}
            ln -srn results/hifiasm/asm.bp.hap1.p_ctg.gfa {output.gfa_h1}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_h1} > {output.fasta_h1}
            ln -srn {output.fasta_h1} {output.link_h1}
            ln -srn results/hifiasm/asm.bp.hap2.p_ctg.gfa {output.gfa_h2}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_h2} > {output.fasta_h2}
            ln -srn {output.fasta_h2} {output.link_h2}
            """

else:

    rule hifiasm:
        input:
            reads = "results/reads/hifi/hifi.fastq.gz",
        output:
            gfa="results/hifiasm/asm.primary.gfa",
            fasta="results/hifiasm/asm.primary.fa",
            link="results/assemblies/asm_primary.fa",
        threads: config["high"]["t"]
        log:
            "logs/hifiasm.log",
        resources:
            mem_mb=config["high"]["mem_mb"],
        conda:
            "../envs/hifiasm.yaml"
        params:
            optional_params=params_hifiasm,
        shell:
            r"""
            rm -f results/hifiasm/asm.*.gfa results/hifiasm/asm.*.bed
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm {params.optional_params} >> {log} 2>&1
            echo "=== hifiasm 产出的 gfa 文件 ===" >> {log}
            ls -la results/hifiasm/asm.*.gfa >> {log} 2>&1
            # 坍缩 primary = bp.p_ctg, 对齐下游 purge_dups/bwa/yahs 的 asm.primary 命名
            ln -srn results/hifiasm/asm.bp.p_ctg.gfa {output.gfa}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa} > {output.fasta}
            ln -srn {output.fasta} {output.link}
            """
