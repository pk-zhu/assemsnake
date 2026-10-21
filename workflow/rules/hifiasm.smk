# This rule uses hifiasm to assemble the genome from the hifi reads
# phased_assembly=True: 分相组装 (--n-hap), 下游用坍缩 primary (bp.p_ctg) 单链;
# phased_assembly=False: 原版 primary/alternate 双组装 (见 hifiasm 规则).
# 两种模式互斥定义, 避免 asm.primary.fa 双生产者歧义.

params_hifiasm = " ".join(
    f"{k} {v}" if v else f"{k}"
    for k, v in config["hifiasm"]["optional_params"].items() if v is not False
)

if diploid_mode:

    rule hifiasm_phased:
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
            """
            rm -f results/hifiasm/asm.*.gfa results/hifiasm/asm.*.bed
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm {params.optional_params} >> {log} 2>&1
            echo "=== hifiasm 产出的 gfa 文件 ===" >> {log}
            ls -la results/hifiasm/asm.*.gfa >> {log} 2>&1
            # 坍缩 primary = bp.p_ctg, 对齐下游 purge_dups/bwa/yahs 的 asm.primary 命名
            ln -srn results/hifiasm/asm.bp.p_ctg.gfa {output.gfa}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa} > {output.fasta}
            ln -srn {output.fasta} {output.link}
            """

else:

    rule hifiasm:
        input:
            reads = "results/reads/hifi/hifi.fastq.gz",
        output:
            gfa="results/hifiasm/asm.primary.gfa",
            gfa_alt="results/hifiasm/asm.alternate.gfa",
            fasta="results/hifiasm/asm.primary.fa",
            fasta_alt="results/hifiasm/asm.alternate.fa",
            link_primary = "results/assemblies/asm_primary.fa",
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
            """
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm --primary {params.optional_params} >> {log} 2>&1
            mv results/hifiasm/asm.p_ctg.gfa {output.gfa}
            mv results/hifiasm/asm.a_ctg.gfa {output.gfa_alt}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa} > {output.fasta}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_alt} > {output.fasta_alt}

            # all the assemblies produced by the workflow will be symlinked to results/assemblies

            ln -srn {output.fasta} {output.link_primary}
            """
