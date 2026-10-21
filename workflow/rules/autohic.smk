# AutoHiC (3D-DNA) scaffold 修正, yahs 之后:
#   matlock bam2 juicer (.mnd) → .assembly (yahs AGP) → 3D-DNA visualizer (.hic)
#   → AutoHiC onehic.py 神经网络纠错 (translocation/inversion/debris)
# 产物: results/autohic_{hap}/out_JBAT.assembly (纠错后) + error_summary.json;
# 后续 Juicebox 手动 review 为交互步骤, 在流程外进行.

rule autohic_mnd:
    input:
        bam="results/arima_mapping_pipeline_{hap}/REP_DIR/paired_mark_dups_final.bam",
    output:
        mnd="results/autohic_{hap}/out.sorted.links.mnd",
    log:
        "logs/autohic_mnd_{hap}.log",
    resources:
        mem_mb=config["high"]["mem_mb"],
    conda:
        "../envs/autohic.yaml"
    shell:
        """
        mkdir -p results/autohic_{wildcards.hap}
        # matlock bam2 需 name-sorted 输入 (实跑验证过的链路), picard 产物为坐标序
        samtools sort -@ 8 -n -m 2G -T results/autohic_{wildcards.hap}/nsort_tmp \
            -o results/autohic_{wildcards.hap}/HiC.nsorted.bam {input.bam} >> {log} 2>&1
        matlock bam2 juicer results/autohic_{wildcards.hap}/HiC.nsorted.bam \
            results/autohic_{wildcards.hap}/out.links.mnd >> {log} 2>&1
        sort -k2,2 -k6,6 -o {output.mnd} results/autohic_{wildcards.hap}/out.links.mnd >> {log} 2>&1
        """

rule autohic_assembly:
    input:
        agp="results/yahs_{hap}/asm_yahs_scaffolds_final.agp",
    output:
        "results/autohic_{hap}/scaffolds.assembly",
    log:
        "logs/autohic_assembly_{hap}.log",
    resources:
        mem_mb=config["low"]["mem_mb"],
    conda:
        "../envs/autohic.yaml"
    shell:
        """
        awk 'BEGIN{{print ">assembly"}} /^scaffold/{{printf "%s %s\\n", $2-1, $3}} \
            END{{print ">contig_orientation"}}' {input.agp} > {output} 2> {log}
        """

rule autohic_hic:
    input:
        mnd="results/autohic_{hap}/out.sorted.links.mnd",
        assembly="results/autohic_{hap}/scaffolds.assembly",
    output:
        hic="results/autohic_{hap}/out_JBAT.hic",
    log:
        "logs/autohic_hic_{hap}.log",
    resources:
        mem_mb=config["medium"]["mem_mb"],
    params:
        visualizer=config["autohic"]["visualizer"],
    conda:
        "../envs/autohic.yaml"
    shell:
        """
        cd results/autohic_{wildcards.hap} && \
        bash {params.visualizer} -p false scaffolds.assembly out.sorted.links.mnd \
            > ../../{log} 2>&1
        """

rule autohic:
    input:
        hic="results/autohic_{hap}/out_JBAT.hic",
        assembly="results/autohic_{hap}/scaffolds.assembly",
    output:
        corrected="results/autohic_{hap}/out_JBAT.assembly",
        adjusted="results/autohic_{hap}/adjusted.assembly",
        summary="results/autohic_{hap}/error_summary.json",
    threads: config["medium"]["t"]
    log:
        "logs/autohic_{hap}.log",
    resources:
        mem_mb=config["medium"]["mem_mb"],
    params:
        autohic_dir=config["autohic"]["autohic_dir"],
        model=config["autohic"]["model"],
    conda:
        "../envs/autohic.yaml"
    shell:
        """
        python {params.autohic_dir}/onehic.py \
            -hic {input.hic} -asy {input.assembly} \
            -autohic {params.autohic_dir} -p {params.model} \
            -out results/autohic_{wildcards.hap} -t {threads} > {log} 2>&1
        """
