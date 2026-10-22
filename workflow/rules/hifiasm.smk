# This rule uses hifiasm to assemble the genome from the hifi reads
# 三条规则按 DAG 选用:
#   hifiasm_collapsed  = 默认, 坍缩 primary 链。任何 hifiasm 模式都产 bp.p_ctg
#                        (bubble-popped), 取它作 primary; --n-hap K 仅为坍缩调参,
#                        允许单次 purge_dups
#   hifiasm_primary    = include_alternate: True, 上游 --primary 双产物模式:
#                        p_ctg → primary + a_ctg → alternate, 下游两链各挂一条;
#                        purge_dups + purge_dups2 各清一遍
#   hifiasm_phased     = phased_assembly: True, 上游 Hi-C 分相 (--h1/--h2),
#                        产 hap1/hap2 双链, 不支持 purge_dups
# 上游原版 hifiasm 规则与 hifiasm_primary 的差别仅在日志与产物软链命名

params_hifiasm = " ".join(
    f"{k} {v}" if v else f"{k}"
    for k, v in config["hifiasm"]["optional_params"].items() if v is not False
)

if include_alternate:

    rule hifiasm_primary:
        input:
            reads = "results/reads/hifi/hifi.fastq.gz",
        output:
            gfa="results/hifiasm/asm.primary.gfa",
            gfa_alt="results/hifiasm/asm.alternate.gfa",
            fasta="results/hifiasm/asm.primary.fa",
            fasta_alt="results/hifiasm/asm.alternate.fa",
            link="results/assemblies/asm_primary.fa",
            link_alt="results/assemblies/asm_alternate.fa",
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
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm --primary {params.optional_params} >> {log} 2>&1
            echo "=== hifiasm 产出的 gfa 文件 ===" >> {log}
            ls -la results/hifiasm/asm.*.gfa >> {log} 2>&1
            mv results/hifiasm/asm.p_ctg.gfa {output.gfa}
            mv results/hifiasm/asm.a_ctg.gfa {output.gfa_alt}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa} > {output.fasta}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_alt} > {output.fasta_alt}
            ln -srn {output.fasta} {output.link}
            ln -srn {output.fasta_alt} {output.link_alt}
            """

elif diploid_mode:

    rule hifiasm_phased:
        input:
            reads = "results/reads/hifi/hifi.fastq.gz",
            hic_forward = "results/fastp/hic_trim_1.fastq.gz",
            hic_reverse = "results/fastp/hic_trim_2.fastq.gz"
        output:
            gfa_hap1="results/hifiasm/asm.hap1.gfa",
            gfa_hap2="results/hifiasm/asm.hap2.gfa",
            fasta_hap1="results/hifiasm/asm.hap1.fa",
            fasta_hap2="results/hifiasm/asm.hap2.fa",
            link_hap1="results/assemblies/asm_hap1.fa",
            link_hap2="results/assemblies/asm_hap2.fa"
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
            hifiasm {input.reads} -t {threads} -o results/hifiasm/asm --h1 {input.hic_forward} --h2 {input.hic_reverse} {params.optional_params} >> {log} 2>&1
            echo "=== hifiasm 产出的 gfa 文件 ===" >> {log}
            ls -la results/hifiasm/asm.*.gfa >> {log} 2>&1
            mv results/hifiasm/asm.hic.hap1.p_ctg.gfa {output.gfa_hap1}
            mv results/hifiasm/asm.hic.hap2.p_ctg.gfa {output.gfa_hap2}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_hap1} > {output.fasta_hap1}
            awk -f scripts/gfa_to_fasta.awk < {output.gfa_hap2} > {output.fasta_hap2}
            ln -srn {output.fasta_hap1} {output.link_hap1}
            ln -srn {output.fasta_hap2} {output.link_hap2}
            """

else:

    rule hifiasm_collapsed:
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
